import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/message.dart';
import '../models/chat_dto.dart';
import '../models/message_dto.dart';
import 'chat_remote_data_source.dart';

/// In-memory backend that behaves like a real one: network latency, random
/// failures, cursor pagination, delivery/read receipts and replies from the
/// other side. Swap it for an HTTP/WebSocket implementation of
/// [ChatRemoteDataSource] without touching anything above the data layer.
class FakeChatRemoteDataSource implements ChatRemoteDataSource {
  FakeChatRemoteDataSource({
    Random? random,
    this.latency = const Duration(milliseconds: 700),
    this.failureRate = 0.1,
    this.backgroundTraffic = true,
    this.replyProbability = 0.65,
    DateTime Function()? clock,
  }) : _random = random ?? Random(),
       _clock = clock ?? DateTime.now {
    if (backgroundTraffic) {
      _trafficTimer = Timer.periodic(
        const Duration(seconds: 45),
        (_) => _emitRandomIncoming(),
      );
    }
  }

  final Duration latency;

  /// Probability (0..1) that a request fails with [NetworkException].
  final double failureRate;
  final bool backgroundTraffic;

  /// Chance that the other person reads and answers a message you send.
  final double replyProbability;
  final Random _random;
  final DateTime Function() _clock;
  final _events = StreamController<RemoteEvent>.broadcast();
  Timer? _trafficTimer;
  final _pendingTimers = <Timer>[];

  late final _World _world = _World.generate(_clock());

  @override
  Stream<RemoteEvent> get events => _events.stream;

  @override
  Future<List<ChatDto>> fetchChats() async {
    await _simulateNetwork();
    return [
      for (final chat in _world.chats)
        ChatDto(
          id: chat.id,
          name: chat.name,
          avatarColor: chat.avatarColor,
          isGroup: chat.isGroup,
          isOnline: chat.isOnline,
          unreadCount: chat.unreadCount,
          lastMessage: _world.messages[chat.id]!.firstOrNull,
        ),
    ];
  }

  @override
  Future<List<MessageDto>> fetchMessages(
    String chatId, {
    int? beforeCreatedAt,
    String? beforeId,
    int limit = 30,
  }) async {
    await _simulateNetwork();
    final all = _world.messages[chatId];
    if (all == null) throw const ServerException('Chat not found');
    return all
        .where(
          (m) =>
              beforeCreatedAt == null ||
              m.createdAt < beforeCreatedAt ||
              (m.createdAt == beforeCreatedAt &&
                  beforeId != null &&
                  m.id.compareTo(beforeId) < 0),
        )
        .take(limit)
        .toList();
  }

  @override
  Future<MessageDto> sendMessage(MessageDto message) async {
    await _simulateNetwork(failureRate: failureRate / 2);
    final sent = message.copyWith(status: MessageStatus.sent.index);
    _world.messages[message.chatId]?.insert(0, sent);
    _scheduleReceipts(sent);
    return sent;
  }

  @override
  void dispose() {
    _trafficTimer?.cancel();
    for (final t in _pendingTimers) {
      t.cancel();
    }
    _events.close();
  }

  Future<void> _simulateNetwork({double? failureRate}) async {
    final jitter = latency.inMilliseconds == 0
        ? 0
        : _random.nextInt(latency.inMilliseconds ~/ 2 + 1);
    await Future<void>.delayed(latency + Duration(milliseconds: jitter));
    if (_random.nextDouble() < (failureRate ?? this.failureRate)) {
      throw const NetworkException('Connection timed out. Check your network.');
    }
  }

  void _later(Duration delay, void Function() action) {
    late final Timer timer;
    timer = Timer(delay, () {
      _pendingTimers.remove(timer);
      if (!_events.isClosed) action();
    });
    _pendingTimers.add(timer);
  }

  void _scheduleReceipts(MessageDto sent) {
    _later(const Duration(milliseconds: 900), () {
      _events.add(
        MessageStatusEvent(
          chatId: sent.chatId,
          messageId: sent.id,
          status: MessageStatus.delivered.index,
        ),
      );
    });
    if (_random.nextDouble() >= replyProbability) return;
    final replyDelay = Duration(milliseconds: 1800 + _random.nextInt(2500));
    _later(replyDelay, () {
      _events.add(
        MessageStatusEvent(
          chatId: sent.chatId,
          messageId: sent.id,
          status: MessageStatus.read.index,
        ),
      );
    });
    _later(replyDelay + const Duration(milliseconds: 1200), () {
      _emitIncoming(sent.chatId, replyTo: sent);
    });
  }

  void _emitReadUpToLatestMine(String chatId) {
    final latestMine = _world.messages[chatId]
        ?.where((m) => m.senderId == Message.myUserId)
        .firstOrNull;
    if (latestMine == null) return;
    _events.add(
      MessageStatusEvent(
        chatId: chatId,
        messageId: latestMine.id,
        status: MessageStatus.read.index,
      ),
    );
  }

  void _emitRandomIncoming() {
    final chat = _world.chats[_random.nextInt(_world.chats.length)];
    _emitIncoming(chat.id);
  }

  /// Makes the other side send a message now (demo/testing hook).
  @visibleForTesting
  void simulateIncoming(String chatId) => _emitIncoming(chatId);

  void _emitIncoming(String chatId, {MessageDto? replyTo}) {
    final chat = _world.chats.firstWhere((c) => c.id == chatId);
    // Someone typing in a 1:1 chat has seen it: report my newest message as
    // read first (receipts are cumulative, so earlier ones follow). Groups
    // need every member to read, so one reply doesn't imply that.
    if (!chat.isGroup) _emitReadUpToLatestMine(chatId);
    final sender = chat.isGroup
        ? chat.members[_random.nextInt(chat.members.length)]
        : chat.name;
    final quote = replyTo != null && _random.nextDouble() < 0.3;
    final now = _clock().millisecondsSinceEpoch;
    final message = MessageDto(
      id: '${chatId}_in_${now}_${_random.nextInt(1 << 20)}',
      chatId: chatId,
      senderId: 'user_$sender',
      senderName: sender,
      type: MessageType.text.index,
      text: _replies[_random.nextInt(_replies.length)],
      createdAt: now,
      status: MessageStatus.delivered.index,
      replyToId: quote ? replyTo.id : null,
      replyText: quote ? replyTo.text : null,
      replySenderName: quote ? 'You' : null,
      replyType: quote ? replyTo.type : null,
    );
    _world.messages[chatId]?.insert(0, message);
    _events.add(IncomingMessageEvent(message));
  }
}

class _FakeChat {
  _FakeChat({
    required this.id,
    required this.name,
    required this.avatarColor,
    required this.isGroup,
    required this.isOnline,
    required this.members,
  });

  final String id;
  final String name;
  final int avatarColor;
  final bool isGroup;
  final bool isOnline;
  final List<String> members;
  int unreadCount = 0;
}

/// Deterministic seed data so the app looks the same on every launch.
class _World {
  _World(this.chats, this.messages);

  final List<_FakeChat> chats;

  /// Newest first.
  final Map<String, List<MessageDto>> messages;

  static _World generate(DateTime now) {
    final rnd = Random(42);
    final chats = <_FakeChat>[];
    final messages = <String, List<MessageDto>>{};

    final entries = <(String, bool)>[
      for (final name in _people) (name, false),
      for (final name in _groups) (name, true),
    ]..shuffle(rnd);

    for (var i = 0; i < entries.length; i++) {
      final (name, isGroup) = entries[i];
      final id = 'chat_${i.toString().padLeft(3, '0')}';
      final members = isGroup
          ? (List.of(_people)..shuffle(rnd)).take(3 + rnd.nextInt(5)).toList()
          : [name];
      final chat = _FakeChat(
        id: id,
        name: name,
        avatarColor: _palette[rnd.nextInt(_palette.length)],
        isGroup: isGroup,
        isOnline: !isGroup && rnd.nextDouble() < 0.35,
        members: members,
      );
      chats.add(chat);

      // The last chat intentionally has no messages (empty state).
      final count = i == entries.length - 1
          ? 0
          : i < 4
          ? 220 + rnd.nextInt(120)
          : 8 + rnd.nextInt(90);
      final unread = i % 3 == 1 ? 1 + rnd.nextInt(12) : 0;
      chat.unreadCount = min(unread, count);
      messages[id] = _generateMessages(
        rnd: rnd,
        chat: chat,
        count: count,
        newest: now.subtract(Duration(minutes: i * i * 9 + rnd.nextInt(30))),
      );
    }
    return _World(chats, messages);
  }

  static List<MessageDto> _generateMessages({
    required Random rnd,
    required _FakeChat chat,
    required int count,
    required DateTime newest,
  }) {
    // Timestamps from newest to oldest with conversation-like gaps.
    final times = <int>[];
    var t = newest;
    for (var k = 0; k < count; k++) {
      times.add(t.millisecondsSinceEpoch);
      final roll = rnd.nextDouble();
      t = t.subtract(
        roll < 0.7
            ? Duration(seconds: 20 + rnd.nextInt(240))
            : roll < 0.95
            ? Duration(minutes: 10 + rnd.nextInt(170))
            : Duration(hours: 20 + rnd.nextInt(30)),
      );
    }

    final result = <MessageDto>[];
    // Generate chronologically so replies can quote earlier messages.
    for (var k = count - 1; k >= 0; k--) {
      final index = count - 1 - k;
      final isUnread = k < chat.unreadCount;
      final mine = !isUnread && rnd.nextDouble() < 0.45;
      final sender = mine
          ? 'You'
          : chat.members[rnd.nextInt(chat.members.length)];
      final id = '${chat.id}_m${index.toString().padLeft(5, '0')}';

      final roll = rnd.nextDouble();
      final type = roll < 0.78
          ? MessageType.text
          : roll < 0.9
          ? MessageType.image
          : MessageType.voice;

      MessageDto? quoted;
      if (result.isNotEmpty && rnd.nextDouble() < 0.08) {
        quoted = result[result.length - 1 - rnd.nextInt(min(5, result.length))];
      }

      final status = !mine
          ? MessageStatus.read
          : k < 2
          ? MessageStatus.delivered
          : MessageStatus.read;

      result.add(
        MessageDto(
          id: id,
          chatId: chat.id,
          senderId: mine ? Message.myUserId : 'user_$sender',
          senderName: sender,
          type: type.index,
          createdAt: times[k],
          status: status.index,
          text: switch (type) {
            MessageType.text => _texts[rnd.nextInt(_texts.length)],
            MessageType.image =>
              rnd.nextBool() ? _captions[rnd.nextInt(_captions.length)] : null,
            MessageType.voice => null,
          },
          mediaUrls: type == MessageType.image
              ? List.generate(
                  rnd.nextDouble() < 0.6 ? 1 : 2 + rnd.nextInt(5),
                  (n) => 'https://picsum.photos/seed/$id-$n/800/800',
                )
              : const [],
          voiceDurationMs: type == MessageType.voice
              ? (3 + rnd.nextInt(80)) * 1000
              : null,
          isForwarded: rnd.nextDouble() < 0.03,
          replyToId: quoted?.id,
          replyText: quoted?.text,
          replySenderName: quoted == null
              ? null
              : quoted.senderId == Message.myUserId
              ? 'You'
              : quoted.senderName,
          replyType: quoted?.type,
        ),
      );
    }
    return result.reversed.toList();
  }
}

const _palette = [
  0xFF1E88E5,
  0xFF43A047,
  0xFFE53935,
  0xFF8E24AA,
  0xFFFB8C00,
  0xFF00897B,
  0xFF6D4C41,
  0xFF3949AB,
  0xFFD81B60,
  0xFF7CB342,
];

const _people = [
  'Aarav Shah',
  'Priya Patel',
  'Liam Johnson',
  'Emma Wilson',
  'Noah Brown',
  'Olivia Davis',
  'Rohan Mehta',
  'Sophia Martinez',
  'Mateo Garcia',
  'Isabella Rossi',
  'Kenji Tanaka',
  'Ananya Iyer',
  'Lucas Müller',
  'Mia Schneider',
  'Arjun Nair',
  'Chloe Dubois',
  'Ethan Clark',
  'Zara Khan',
  'Diego López',
  'Hana Kim',
  'Omar Haddad',
  'Nora Lindqvist',
  'Vikram Rao',
  'Grace Lee',
  'Samuel Okafor',
  'Ava Thompson',
  'Kabir Singh',
  'Leila Ahmadi',
  'Mom',
  'Dad',
];

const _groups = [
  'Family ❤️',
  'Weekend Trek 🏔️',
  'Flutter Devs',
  'College Friends',
  'Office – Mobile Team',
  'Book Club 📚',
];

const _texts = [
  'Hey! How are you?',
  'On my way 🚗',
  'Sounds good to me',
  'Can we move the meeting to 4?',
  'Haha that is hilarious 😂',
  'Did you see the new release?',
  'I will call you in 5 minutes',
  'Thanks a lot! 🙏',
  'Where are we meeting tonight?',
  'Just finished the PR, please review when you get a chance',
  'Lunch tomorrow?',
  'Okay 👍',
  'Running a bit late, sorry!',
  'That’s amazing news, congratulations!! 🎉',
  'Can you send me the document?',
  'Let me check and get back to you',
  'Good morning ☀️',
  'Happy birthday!! 🎂🥳',
  'Miss you guys',
  'The build is green now ✅',
  'Who is bringing snacks?',
  'I think we should go with option B. It scales better and the team '
      'already knows the stack, so onboarding will be faster.',
  'Here’s the plan: we meet at 7, grab dinner, then head to the movie. '
      'Tickets are already booked, just don’t be late this time 😅',
  'Yes',
  'No worries',
  'See you soon!',
  'Love it ❤️',
  'brb',
  'Did you finish the assignment?',
  'Weather is crazy today 🌧️',
];

const _captions = [
  'Look at this view 😍',
  'From yesterday',
  'Throwback',
  'New setup 💻',
  'Dinner was 🔥',
];

const _replies = [
  'Got it 👍',
  'Haha yes!',
  'Sure, let me check',
  'Perfect, thanks!',
  'On it 🚀',
  'Interesting… tell me more',
  'Ok see you then',
  'Sounds like a plan',
  '😂😂😂',
  'Will do!',
  'Absolutely',
];
