import '../models/chat_dto.dart';
import '../models/message_dto.dart';

/// Push events delivered by the backend (e.g. over a WebSocket).
sealed class RemoteEvent {
  const RemoteEvent();
}

class IncomingMessageEvent extends RemoteEvent {
  const IncomingMessageEvent(this.message);
  final MessageDto message;
}

class MessageStatusEvent extends RemoteEvent {
  const MessageStatusEvent({
    required this.chatId,
    required this.messageId,
    required this.status,
  });

  final String chatId;
  final String messageId;
  final int status;
}

/// Contract for the chat backend. Implementations throw `NetworkException`
/// or `ServerException`; repositories convert them into failures.
abstract interface class ChatRemoteDataSource {
  Future<List<ChatDto>> fetchChats();

  /// Messages strictly older than the cursor, newest first.
  Future<List<MessageDto>> fetchMessages(
    String chatId, {
    int? beforeCreatedAt,
    String? beforeId,
    int limit = 30,
  });

  Future<MessageDto> sendMessage(MessageDto message);

  Stream<RemoteEvent> get events;

  void dispose();
}
