import 'package:equatable/equatable.dart';

enum MessageType { text, image, voice }

enum MessageStatus { sending, sent, delivered, read, failed }

/// Snapshot of the message being replied to, denormalised so a reply can be
/// rendered even when the original is not loaded (or was never cached).
class ReplyInfo extends Equatable {
  const ReplyInfo({
    required this.messageId,
    required this.senderName,
    required this.type,
    this.text,
  });

  final String messageId;
  final String senderName;
  final MessageType type;
  final String? text;

  String get previewText => Message.previewFor(type, text);

  @override
  List<Object?> get props => [messageId, senderName, type, text];
}

class Message extends Equatable {
  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.isMine,
    required this.type,
    required this.createdAt,
    required this.status,
    this.text,
    this.mediaUrls = const [],
    this.voiceDuration,
    this.replyTo,
    this.isForwarded = false,
  });

  static const myUserId = 'me';

  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final bool isMine;
  final MessageType type;
  final String? text;
  final List<String> mediaUrls;
  final Duration? voiceDuration;
  final DateTime createdAt;
  final MessageStatus status;
  final ReplyInfo? replyTo;
  final bool isForwarded;

  String get previewText => previewFor(type, text);

  ReplyInfo toReplyInfo() => ReplyInfo(
    messageId: id,
    senderName: isMine ? 'You' : senderName,
    type: type,
    text: text,
  );

  static String previewFor(MessageType type, String? text) => switch (type) {
    MessageType.text => text ?? '',
    MessageType.image => (text?.isNotEmpty ?? false) ? text! : 'Photo',
    MessageType.voice => 'Voice message',
  };

  Message copyWith({MessageStatus? status}) => Message(
    id: id,
    chatId: chatId,
    senderId: senderId,
    senderName: senderName,
    isMine: isMine,
    type: type,
    text: text,
    mediaUrls: mediaUrls,
    voiceDuration: voiceDuration,
    createdAt: createdAt,
    status: status ?? this.status,
    replyTo: replyTo,
    isForwarded: isForwarded,
  );

  @override
  List<Object?> get props => [
    id,
    chatId,
    senderId,
    senderName,
    isMine,
    type,
    text,
    mediaUrls,
    voiceDuration,
    createdAt,
    status,
    replyTo,
    isForwarded,
  ];
}

/// Payload for a message the user is about to send.
class OutgoingMessage extends Equatable {
  const OutgoingMessage({
    required this.chatId,
    required this.type,
    this.text,
    this.mediaUrls = const [],
    this.voiceDuration,
    this.replyTo,
    this.isForwarded = false,
  });

  final String chatId;
  final MessageType type;
  final String? text;
  final List<String> mediaUrls;
  final Duration? voiceDuration;
  final ReplyInfo? replyTo;
  final bool isForwarded;

  @override
  List<Object?> get props => [
    chatId,
    type,
    text,
    mediaUrls,
    voiceDuration,
    replyTo,
    isForwarded,
  ];
}

class MessagePage extends Equatable {
  const MessagePage({
    required this.messages,
    required this.hasMore,
    this.isStale = false,
  });

  /// Newest first.
  final List<Message> messages;
  final bool hasMore;

  /// True when the remote could not be reached and only cache was returned.
  final bool isStale;

  @override
  List<Object?> get props => [messages, hasMore, isStale];
}
