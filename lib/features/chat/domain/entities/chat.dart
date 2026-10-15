import 'package:equatable/equatable.dart';

import 'message.dart';

class LastMessage extends Equatable {
  const LastMessage({
    required this.id,
    required this.text,
    required this.type,
    required this.sentAt,
    required this.isMine,
    this.status,
    this.senderName,
  });

  final String id;
  final String text;
  final MessageType type;
  final DateTime sentAt;
  final bool isMine;
  final MessageStatus? status;
  final String? senderName;

  @override
  List<Object?> get props => [
    id,
    text,
    type,
    sentAt,
    isMine,
    status,
    senderName,
  ];
}

class Chat extends Equatable {
  const Chat({
    required this.id,
    required this.name,
    required this.avatarColor,
    this.isGroup = false,
    this.isOnline = false,
    this.lastMessage,
    this.unreadCount = 0,
    this.pinnedAt,
    this.isArchived = false,
  });

  static const maxPinned = 3;

  final String id;
  final String name;
  final int avatarColor;
  final bool isGroup;
  final bool isOnline;
  final LastMessage? lastMessage;
  final int unreadCount;
  final DateTime? pinnedAt;
  final bool isArchived;

  bool get isPinned => pinnedAt != null;
  bool get hasUnread => unreadCount > 0;

  @override
  List<Object?> get props => [
    id,
    name,
    avatarColor,
    isGroup,
    isOnline,
    lastMessage,
    unreadCount,
    pinnedAt,
    isArchived,
  ];
}

class ArchivedSummary extends Equatable {
  const ArchivedSummary({required this.count, required this.unreadChats});

  final int count;
  final int unreadChats;

  @override
  List<Object?> get props => [count, unreadChats];
}
