import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/message_local_data_source.dart';
import '../models/mappers.dart';
import 'error_mapping.dart';

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl({
    required this._remote,
    required this._messageLocal,
    required this._chatLocal,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _remoteSub = _remote.events.listen(_onRemoteEvent);
  }

  final ChatRemoteDataSource _remote;
  final MessageLocalDataSource _messageLocal;
  final ChatLocalDataSource _chatLocal;
  final DateTime Function() _clock;
  final _changes = StreamController<Message>.broadcast();
  late final StreamSubscription<RemoteEvent> _remoteSub;
  String? _activeChatId;
  int _idCounter = 0;

  @override
  void setChatActive(String chatId, {required bool active}) {
    if (active) {
      _activeChatId = chatId;
    } else if (_activeChatId == chatId) {
      _activeChatId = null;
    }
  }

  @override
  Stream<Message> watchMessageChanges(String chatId) =>
      _changes.stream.where((m) => m.chatId == chatId);

  @override
  Future<Result<MessagePage>> getMessages(
    String chatId, {
    Message? before,
    int limit = 30,
  }) async {
    final List<Message> cached;
    try {
      cached = (await _messageLocal.getPage(
        chatId,
        beforeCreatedAt: before?.createdAt.millisecondsSinceEpoch,
        beforeId: before?.id,
        limit: limit,
      )).map((r) => r.toEntity()).toList();
    } catch (e) {
      debugPrint('Cache read failed: $e');
      return const Err(CacheFailure());
    }
    if (cached.length == limit) {
      return Success(MessagePage(messages: cached, hasMore: true));
    }

    // Cache is exhausted: continue from the oldest message we know about.
    final anchor = cached.isNotEmpty ? cached.last : before;
    final missing = limit - cached.length;
    final remote = await guard(
      () => _remote.fetchMessages(
        chatId,
        beforeCreatedAt: anchor?.createdAt.millisecondsSinceEpoch,
        beforeId: anchor?.id,
        limit: missing,
      ),
    );

    switch (remote) {
      case Success(value: final dtos):
        try {
          await _messageLocal.upsertAll(
            dtos.map((d) => d.toEntity().toCompanion()).toList(),
          );
        } catch (e) {
          debugPrint('Cache write failed: $e');
        }
        return Success(
          MessagePage(
            messages: [...cached, ...dtos.map((d) => d.toEntity())],
            hasMore: dtos.length == missing,
          ),
        );
      case Err(:final failure):
        if (cached.isEmpty) return Err(failure);
        return Success(
          MessagePage(messages: cached, hasMore: true, isStale: true),
        );
    }
  }

  @override
  Future<Result<Message>> sendMessage(OutgoingMessage outgoing) async {
    final message = Message(
      id: _newLocalId(),
      chatId: outgoing.chatId,
      senderId: Message.myUserId,
      senderName: 'You',
      isMine: true,
      type: outgoing.type,
      text: outgoing.text?.trim(),
      mediaUrls: outgoing.mediaUrls,
      voiceDuration: outgoing.voiceDuration,
      createdAt: _clock(),
      status: MessageStatus.sending,
      replyTo: outgoing.replyTo,
      isForwarded: outgoing.isForwarded,
    );
    try {
      await _messageLocal.upsert(message.toCompanion());
      await _chatLocal.applyLastMessage(message);
    } catch (e) {
      debugPrint('Cache write failed: $e');
      return const Err(CacheFailure('Could not save the message.'));
    }
    _emit(message);
    return _deliver(message);
  }

  @override
  Future<Result<Message>> resendMessage(Message message) async {
    final retry = message.copyWith(status: MessageStatus.sending);
    await _saveStatus(retry);
    return _deliver(retry);
  }

  @override
  Future<Result<void>> forwardMessages(
    List<Message> messages,
    List<String> chatIds,
  ) async {
    final ordered = [...messages]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final results = await Future.wait([
      for (final chatId in chatIds)
        for (final m in ordered)
          sendMessage(
            OutgoingMessage(
              chatId: chatId,
              type: m.type,
              text: m.text,
              mediaUrls: m.mediaUrls,
              voiceDuration: m.voiceDuration,
              isForwarded: true,
            ),
          ),
    ]);
    final failed = results.where((r) => !r.isSuccess).length;
    if (failed > 0) {
      return Err(
        NetworkFailure(
          '$failed message${failed == 1 ? '' : 's'} could not be forwarded. '
          'Tap them to retry.',
        ),
      );
    }
    return const Success(null);
  }

  @override
  Future<Result<List<Message>>> getMedia(String chatId) => guard(
    () async => (await _messageLocal.getImages(
      chatId,
    )).map((r) => r.toEntity()).toList(),
  );

  Future<Result<Message>> _deliver(Message message) async {
    try {
      final sent = (await _remote.sendMessage(message.toDto())).toEntity();
      // A receipt may already have advanced the status past "sent".
      final current = await _messageLocal.getById(message.id);
      final status =
          current != null &&
              current.status > MessageStatus.sending.index &&
              current.status != MessageStatus.failed.index
          ? MessageStatus.values[current.status]
          : sent.status;
      final updated = message.copyWith(status: status);
      await _saveStatus(updated);
      return Success(updated);
    } on NetworkException catch (e) {
      await _saveStatus(message.copyWith(status: MessageStatus.failed));
      return Err(NetworkFailure(e.message));
    } on ServerException catch (e) {
      await _saveStatus(message.copyWith(status: MessageStatus.failed));
      return Err(ServerFailure(e.message));
    }
  }

  Future<void> _saveStatus(Message message) async {
    await _messageLocal.updateStatus(message.id, message.status);
    await _chatLocal.updateLastMessageStatus(
      message.chatId,
      message.id,
      message.status,
    );
    _emit(message);
  }

  Future<void> _onRemoteEvent(RemoteEvent event) async {
    try {
      switch (event) {
        case IncomingMessageEvent(:final message):
          final entity = message.toEntity();
          await _messageLocal.upsert(entity.toCompanion());
          await _chatLocal.applyLastMessage(entity);
          if (entity.chatId != _activeChatId) {
            await _chatLocal.incrementUnread(entity.chatId);
          }
          _emit(entity);
        case MessageStatusEvent(:final chatId, :final messageId, :final status):
          await _applyReceipt(chatId, messageId, MessageStatus.values[status]);
      }
    } catch (e, st) {
      debugPrint('Failed to apply remote event: $e\n$st');
    }
  }

  /// Receipts are cumulative, like WhatsApp: "delivered"/"read" for a
  /// message also applies to every earlier message I sent in that chat.
  Future<void> _applyReceipt(
    String chatId,
    String messageId,
    MessageStatus status,
  ) async {
    final row = await _messageLocal.getById(messageId);
    if (row == null) return;
    // A receipt can beat the send acknowledgement; it proves the server has
    // the message, so treat it as sent and let the receipt advance it.
    if (row.status == MessageStatus.sending.index) {
      await _messageLocal.updateStatus(messageId, MessageStatus.sent);
    }
    final changed = await _messageLocal.advanceMyStatusesUpTo(
      chatId,
      upTo: row.createdAt,
      status: status,
    );
    for (final r in changed) {
      final updated = r.toEntity();
      await _chatLocal.updateLastMessageStatus(chatId, r.id, updated.status);
      _emit(updated);
    }
  }

  void _emit(Message message) {
    if (!_changes.isClosed) _changes.add(message);
  }

  /// Sortable ids so messages created in the same millisecond keep order.
  String _newLocalId() {
    final ms = _clock().millisecondsSinceEpoch;
    final counter = (_idCounter++ % 100000).toString().padLeft(5, '0');
    return 'local_${ms}_$counter';
  }

  void dispose() {
    _remoteSub.cancel();
    _changes.close();
  }
}
