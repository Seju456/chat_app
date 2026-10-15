import 'dart:async';

import 'package:chat_app/core/database/app_database.dart';
import 'package:chat_app/core/error/exceptions.dart';
import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/utils/result.dart';
import 'package:chat_app/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:chat_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chat_app/features/chat/data/datasources/fake_chat_remote_data_source.dart';
import 'package:chat_app/features/chat/data/datasources/message_local_data_source.dart';
import 'package:chat_app/features/chat/data/models/chat_dto.dart';
import 'package:chat_app/features/chat/data/models/message_dto.dart';
import 'package:chat_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:chat_app/features/chat/data/repositories/message_repository_impl.dart';
import 'package:chat_app/features/chat/domain/entities/message.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps the fake backend so tests can switch the network off.
class _SwitchableRemote implements ChatRemoteDataSource {
  _SwitchableRemote(this._inner) {
    _inner.events.listen(_events.add);
  }
  final ChatRemoteDataSource _inner;

  /// Real backend events plus ones a test injects (receipts on demand).
  final _events = StreamController<RemoteEvent>.broadcast();
  void inject(RemoteEvent event) => _events.add(event);
  bool offline = false;
  int fetchCalls = 0;

  void _check() {
    if (offline) throw const NetworkException();
  }

  @override
  Future<List<ChatDto>> fetchChats() async {
    _check();
    return _inner.fetchChats();
  }

  @override
  Future<List<MessageDto>> fetchMessages(
    String chatId, {
    int? beforeCreatedAt,
    String? beforeId,
    int limit = 30,
  }) async {
    fetchCalls++;
    _check();
    return _inner.fetchMessages(
      chatId,
      beforeCreatedAt: beforeCreatedAt,
      beforeId: beforeId,
      limit: limit,
    );
  }

  @override
  Future<MessageDto> sendMessage(MessageDto message) async {
    _check();
    return _inner.sendMessage(message);
  }

  @override
  Stream<RemoteEvent> get events => _events.stream;

  @override
  void dispose() => _inner.dispose();
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late _SwitchableRemote remote;
  late FakeChatRemoteDataSource fake;
  late ChatRepositoryImpl chats;
  late MessageRepositoryImpl messages;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    remote = _SwitchableRemote(
      fake = FakeChatRemoteDataSource(
        latency: Duration.zero,
        failureRate: 0,
        backgroundTraffic: false,
        // Receipts come only from what a test triggers.
        replyProbability: 0,
      ),
    );
    final chatLocal = ChatLocalDataSource(db);
    final messageLocal = MessageLocalDataSource(db);
    chats = ChatRepositoryImpl(
      remote: remote,
      chatLocal: chatLocal,
      messageLocal: messageLocal,
    );
    messages = MessageRepositoryImpl(
      remote: remote,
      messageLocal: messageLocal,
      chatLocal: chatLocal,
    );
    expect((await chats.refreshChats()).isSuccess, isTrue);
  });

  tearDown(() async {
    messages.dispose();
    remote.dispose();
    await db.close();
  });

  Future<String> busiestChatId() async {
    final list = await chats.watchChats(archived: false).first;
    // The first generated chats have hundreds of messages.
    return list.firstWhere((c) => c.id == 'chat_000').id;
  }

  test('paginates without gaps or duplicates and caches pages', () async {
    final chatId = await busiestChatId();
    final seen = <String>[];
    Message? cursor;
    var hasMore = true;
    while (hasMore) {
      final page =
          (await messages.getMessages(chatId, before: cursor, limit: 50)
                  as Success<MessagePage>)
              .value;
      seen.addAll(page.messages.map((m) => m.id));
      hasMore = page.hasMore;
      if (page.messages.isNotEmpty) cursor = page.messages.last;
    }
    expect(seen.length, greaterThan(200));
    expect(seen.toSet().length, seen.length, reason: 'no duplicates');

    // Second pass is served from cache, even offline.
    remote.offline = true;
    final callsBefore = remote.fetchCalls;
    final cached = await messages.getMessages(chatId, limit: 50);
    expect((cached as Success<MessagePage>).value.messages.length, 50);
    expect(remote.fetchCalls, callsBefore);
  });

  test('returns a NetworkFailure when offline with an empty cache', () async {
    remote.offline = true;
    final result = await messages.getMessages('chat_001');
    expect(result.failureOrNull, isA<NetworkFailure>());
  });

  test('a failed send is persisted as failed and can be resent', () async {
    final chatId = await busiestChatId();
    remote.offline = true;
    final failed = await messages.sendMessage(
      OutgoingMessage(chatId: chatId, type: MessageType.text, text: 'hello'),
    );
    expect(failed.failureOrNull, isA<NetworkFailure>());

    final page =
        (await messages.getMessages(chatId, limit: 1) as Success<MessagePage>)
            .value;
    final saved = page.messages.single;
    expect(saved.text, 'hello');
    expect(saved.status, MessageStatus.failed);

    remote.offline = false;
    final resent = await messages.resendMessage(saved);
    expect((resent as Success<Message>).value.status, MessageStatus.sent);

    final chat = await chats.watchChat(chatId).first;
    expect(chat!.lastMessage!.text, 'hello');
  });

  test('a receipt also covers every earlier message I sent', () async {
    final chatId = await busiestChatId();
    final sent = <Message>[];
    for (final text in ['one', 'two', 'three']) {
      final r = await messages.sendMessage(
        OutgoingMessage(chatId: chatId, type: MessageType.text, text: text),
      );
      sent.add((r as Success<Message>).value);
    }
    final changes = <Message>[];
    final sub = messages.watchMessageChanges(chatId).listen(changes.add);

    Future<List<MessageStatus>> statuses() async {
      final page =
          (await messages.getMessages(chatId, limit: 3) as Success<MessagePage>)
              .value;
      // Oldest first: one, two, three.
      return page.messages.reversed.map((m) => m.status).toList();
    }

    // "Delivered" for the newest message implies the earlier ones too.
    remote.inject(
      MessageStatusEvent(
        chatId: chatId,
        messageId: sent.last.id,
        status: MessageStatus.delivered.index,
      ),
    );
    await pumpEventQueue();
    expect(await statuses(), List.filled(3, MessageStatus.delivered));

    // Reading the middle one marks it and the first as read, not the last.
    remote.inject(
      MessageStatusEvent(
        chatId: chatId,
        messageId: sent[1].id,
        status: MessageStatus.read.index,
      ),
    );
    await pumpEventQueue();
    expect(await statuses(), [
      MessageStatus.read,
      MessageStatus.read,
      MessageStatus.delivered,
    ]);

    // The open conversation is told about every message that changed.
    final readIds = changes
        .where((m) => m.status == MessageStatus.read)
        .map((m) => m.id)
        .toSet();
    expect(readIds, {sent[0].id, sent[1].id});
    await sub.cancel();
  });

  test('receipts never downgrade or touch failed messages', () async {
    final chatId = await busiestChatId();
    final ok =
        (await messages.sendMessage(
                  OutgoingMessage(
                    chatId: chatId,
                    type: MessageType.text,
                    text: 'ok',
                  ),
                )
                as Success<Message>)
            .value;
    remote.offline = true;
    await messages.sendMessage(
      OutgoingMessage(chatId: chatId, type: MessageType.text, text: 'lost'),
    );
    remote.offline = false;
    final latest =
        (await messages.sendMessage(
                  OutgoingMessage(
                    chatId: chatId,
                    type: MessageType.text,
                    text: 'new',
                  ),
                )
                as Success<Message>)
            .value;

    remote.inject(
      MessageStatusEvent(
        chatId: chatId,
        messageId: latest.id,
        status: MessageStatus.read.index,
      ),
    );
    await pumpEventQueue();
    // A late "delivered" must not pull read messages back.
    remote.inject(
      MessageStatusEvent(
        chatId: chatId,
        messageId: ok.id,
        status: MessageStatus.delivered.index,
      ),
    );
    await pumpEventQueue();

    final page =
        (await messages.getMessages(chatId, limit: 3) as Success<MessagePage>)
            .value;
    expect(
      {for (final m in page.messages) m.text: m.status},
      {
        'ok': MessageStatus.read,
        'lost': MessageStatus.failed,
        'new': MessageStatus.read,
      },
    );
    final chat = await chats.watchChat(chatId).first;
    expect(
      chat!.lastMessage!.status,
      MessageStatus.read,
      reason: 'chat list ticks follow too',
    );
  });

  Future<List<MessageStatus>> sendThenReply(String chatId) async {
    final sent = [
      for (final text in ['a', 'b', 'c'])
        ((await messages.sendMessage(
                  OutgoingMessage(
                    chatId: chatId,
                    type: MessageType.text,
                    text: text,
                  ),
                ))
                as Success<Message>)
            .value,
    ];
    fake.simulateIncoming(chatId);
    await pumpEventQueue();
    final page =
        (await messages.getMessages(chatId, limit: 10) as Success<MessagePage>)
            .value;
    return [
      for (final m in sent)
        page.messages.firstWhere((x) => x.id == m.id).status,
    ];
  }

  test('a reply in a 1:1 chat marks all my earlier messages read', () async {
    final chat = (await chats.watchChats(archived: false).first).firstWhere(
      (c) => !c.isGroup,
    );
    expect(await sendThenReply(chat.id), List.filled(3, MessageStatus.read));
  });

  test('one reply in a group does not mark my messages read', () async {
    final group = (await chats.watchChats(archived: false).first).firstWhere(
      (c) => c.isGroup,
    );
    expect(
      await sendThenReply(group.id),
      everyElement(isNot(MessageStatus.read)),
    );
  });

  test('pin limit and archive behave like WhatsApp', () async {
    final list = await chats.watchChats(archived: false).first;
    await chats.setPinned(list[5].id, pinned: true);
    var updated = await chats.watchChats(archived: false).first;
    expect(updated.first.id, list[5].id, reason: 'pinned chats come first');

    await chats.setArchived(list[5].id, archived: true);
    updated = await chats.watchChats(archived: false).first;
    expect(updated.any((c) => c.id == list[5].id), isFalse);
    final archived = await chats.watchChats(archived: true).first;
    expect(archived.single.isPinned, isFalse, reason: 'archiving unpins');
    expect(await chats.pinnedChatCount(), 0);
  });

  test('search finds chats by name and cached messages by text', () async {
    final chatId = await busiestChatId();
    await messages.getMessages(chatId, limit: 100);
    final results = (await chats.search('the') as Success).value;
    expect(results.messages, isNotEmpty);
    final all = await chats.watchChats(archived: false).first;
    final byName =
        (await chats.search(all.first.name.substring(0, 3)) as Success).value;
    expect(byName.chats.map((c) => c.id), contains(all.first.id));
  });
}
