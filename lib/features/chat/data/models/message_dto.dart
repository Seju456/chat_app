/// Wire format for messages coming from / going to the API.
class MessageDto {
  const MessageDto({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.createdAt,
    required this.status,
    this.text,
    this.mediaUrls = const [],
    this.voiceDurationMs,
    this.replyToId,
    this.replyText,
    this.replySenderName,
    this.replyType,
    this.isForwarded = false,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String senderName;

  /// Index of `MessageType`.
  final int type;
  final String? text;
  final List<String> mediaUrls;
  final int? voiceDurationMs;

  /// Epoch milliseconds.
  final int createdAt;

  /// Index of `MessageStatus`.
  final int status;
  final String? replyToId;
  final String? replyText;
  final String? replySenderName;
  final int? replyType;
  final bool isForwarded;

  MessageDto copyWith({int? status}) => MessageDto(
    id: id,
    chatId: chatId,
    senderId: senderId,
    senderName: senderName,
    type: type,
    createdAt: createdAt,
    status: status ?? this.status,
    text: text,
    mediaUrls: mediaUrls,
    voiceDurationMs: voiceDurationMs,
    replyToId: replyToId,
    replyText: replyText,
    replySenderName: replySenderName,
    replyType: replyType,
    isForwarded: isForwarded,
  );
}
