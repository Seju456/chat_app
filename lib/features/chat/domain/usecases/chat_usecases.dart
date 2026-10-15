import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/chat.dart';
import '../entities/search_results.dart';
import '../repositories/chat_repository.dart';

class WatchChats {
  const WatchChats(this._repository);
  final ChatRepository _repository;

  Stream<List<Chat>> call({required bool archived}) =>
      _repository.watchChats(archived: archived);
}

class WatchArchivedSummary {
  const WatchArchivedSummary(this._repository);
  final ChatRepository _repository;

  Stream<ArchivedSummary> call() => _repository.watchArchivedSummary();
}

class WatchChat {
  const WatchChat(this._repository);
  final ChatRepository _repository;

  Stream<Chat?> call(String chatId) => _repository.watchChat(chatId);
}

class RefreshChats {
  const RefreshChats(this._repository);
  final ChatRepository _repository;

  Future<Result<void>> call() => _repository.refreshChats();
}

/// Business rule: at most [Chat.maxPinned] chats can be pinned.
class TogglePinChat {
  const TogglePinChat(this._repository);
  final ChatRepository _repository;

  Future<Result<void>> call(Chat chat) async {
    if (!chat.isPinned &&
        await _repository.pinnedChatCount() >= Chat.maxPinned) {
      return const Err(
        ValidationFailure('You can only pin up to ${Chat.maxPinned} chats'),
      );
    }
    return _repository.setPinned(chat.id, pinned: !chat.isPinned);
  }
}

class SetChatArchived {
  const SetChatArchived(this._repository);
  final ChatRepository _repository;

  Future<Result<void>> call(String chatId, {required bool archived}) =>
      _repository.setArchived(chatId, archived: archived);
}

class MarkChatRead {
  const MarkChatRead(this._repository);
  final ChatRepository _repository;

  Future<Result<void>> call(String chatId) => _repository.markRead(chatId);
}

class SearchChats {
  const SearchChats(this._repository);
  final ChatRepository _repository;

  Future<Result<SearchResults>> call(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return Future.value(const Success(SearchResults.empty));
    }
    return _repository.search(trimmed);
  }
}
