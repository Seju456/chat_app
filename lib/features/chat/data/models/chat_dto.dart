import 'message_dto.dart';

class ChatDto {
  const ChatDto({
    required this.id,
    required this.name,
    required this.avatarColor,
    required this.isGroup,
    required this.isOnline,
    required this.unreadCount,
    this.lastMessage,
  });

  final String id;
  final String name;
  final int avatarColor;
  final bool isGroup;
  final bool isOnline;
  final int unreadCount;
  final MessageDto? lastMessage;
}
