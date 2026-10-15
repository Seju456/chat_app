import '../../../../core/utils/result.dart';
import '../entities/message.dart';

abstract interface class MessageRepository {
  /// Cursor-based page of messages older than [before] (newest first).
  /// Served from cache when possible, falling back to the network.
  Future<Result<MessagePage>> getMessages(
    String chatId, {
    Message? before,
    int limit,
  });

  /// New or updated messages for [chatId] (sent, received, status changes).
  Stream<Message> watchMessageChanges(String chatId);

  Future<Result<Message>> sendMessage(OutgoingMessage message);

  Future<Result<Message>> resendMessage(Message message);

  Future<Result<void>> forwardMessages(
    List<Message> messages,
    List<String> chatIds,
  );

  /// Cached image messages of a chat, newest first.
  Future<Result<List<Message>>> getMedia(String chatId);

  /// Incoming messages for an open (active) chat are not counted as unread.
  void setChatActive(String chatId, {required bool active});
}
