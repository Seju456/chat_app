import '../../../../core/utils/result.dart';
import '../entities/chat.dart';
import '../entities/search_results.dart';

abstract interface class ChatRepository {
  /// Emits whenever the cached chat list changes. Pinned chats come first.
  Stream<List<Chat>> watchChats({required bool archived});

  Stream<ArchivedSummary> watchArchivedSummary();

  Stream<Chat?> watchChat(String chatId);

  /// Syncs the chat list from the network into the local cache.
  Future<Result<void>> refreshChats();

  Future<int> pinnedChatCount();

  Future<Result<void>> setPinned(String chatId, {required bool pinned});

  Future<Result<void>> setArchived(String chatId, {required bool archived});

  /// Clears the unread counter of a chat.
  Future<Result<void>> markRead(String chatId);

  /// Searches cached chats (by name) and cached messages (by text).
  Future<Result<SearchResults>> search(String query);
}
