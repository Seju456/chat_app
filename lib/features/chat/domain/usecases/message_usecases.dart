import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/message.dart';
import '../repositories/message_repository.dart';

class GetMessages {
  const GetMessages(this._repository);
  final MessageRepository _repository;

  static const pageSize = 30;

  Future<Result<MessagePage>> call(String chatId, {Message? before}) =>
      _repository.getMessages(chatId, before: before, limit: pageSize);
}

class WatchMessageChanges {
  const WatchMessageChanges(this._repository);
  final MessageRepository _repository;

  Stream<Message> call(String chatId) =>
      _repository.watchMessageChanges(chatId);
}

class SendMessage {
  const SendMessage(this._repository);
  final MessageRepository _repository;

  static const maxLength = 4096;

  Future<Result<Message>> call(OutgoingMessage message) {
    final text = message.text?.trim();
    if (message.type == MessageType.text && (text == null || text.isEmpty)) {
      return Future.value(const Err(ValidationFailure('Message is empty')));
    }
    if ((text?.length ?? 0) > maxLength) {
      return Future.value(const Err(ValidationFailure('Message is too long')));
    }
    if (message.type == MessageType.image && message.mediaUrls.isEmpty) {
      return Future.value(const Err(ValidationFailure('No images selected')));
    }
    return _repository.sendMessage(message);
  }
}

class ResendMessage {
  const ResendMessage(this._repository);
  final MessageRepository _repository;

  Future<Result<Message>> call(Message message) =>
      _repository.resendMessage(message);
}

class ForwardMessages {
  const ForwardMessages(this._repository);
  final MessageRepository _repository;

  Future<Result<void>> call(List<Message> messages, List<String> chatIds) {
    if (messages.isEmpty || chatIds.isEmpty) {
      return Future.value(
        const Err(ValidationFailure('Select at least one chat')),
      );
    }
    return _repository.forwardMessages(messages, chatIds);
  }
}

class GetChatMedia {
  const GetChatMedia(this._repository);
  final MessageRepository _repository;

  Future<Result<List<Message>>> call(String chatId) =>
      _repository.getMedia(chatId);
}

class SetActiveChat {
  const SetActiveChat(this._repository);
  final MessageRepository _repository;

  void call(String chatId, {required bool active}) =>
      _repository.setChatActive(chatId, active: active);
}
