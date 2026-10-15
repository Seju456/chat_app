import 'package:drift/drift.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/search_results.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/message_local_data_source.dart';
import '../models/mappers.dart';
import 'error_mapping.dart';

/// Offline-first: the UI only ever observes the local database, the network
/// is used to refresh it. Pin/archive/read flags are device-local preferences.
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this._remote,
    required this._chatLocal,
    required this._messageLocal,
  });

  final ChatRemoteDataSource _remote;
  final ChatLocalDataSource _chatLocal;
  final MessageLocalDataSource _messageLocal;

  @override
  Stream<List<Chat>> watchChats({required bool archived}) => _chatLocal
      .watchChats(archived: archived)
      .map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Stream<ArchivedSummary> watchArchivedSummary() =>
      _chatLocal.watchArchived().map(
        (rows) => ArchivedSummary(
          count: rows.length,
          unreadChats: rows.where((r) => r.unreadCount > 0).length,
        ),
      );

  @override
  Stream<Chat?> watchChat(String chatId) =>
      _chatLocal.watchChat(chatId).map((row) => row?.toEntity());

  @override
  Future<Result<void>> refreshChats() => guard(() async {
    final remoteChats = await _remote.fetchChats();
    final existing = {for (final c in await _chatLocal.getAll()) c.id: c};

    final newRows = <ChatsCompanion>[];
    for (final dto in remoteChats) {
      final local = existing[dto.id];
      if (local == null) {
        newRows.add(dto.toCompanion());
        continue;
      }
      final remoteAt = dto.lastMessage?.createdAt ?? 0;
      final isNewer = remoteAt > (local.lastMessageAt ?? 0);
      // Keep local preferences, take server-owned fields.
      final full = dto.toCompanion();
      await _chatLocal.updateChat(
        dto.id,
        ChatsCompanion(
          name: Value(dto.name),
          isOnline: Value(dto.isOnline),
          lastMessageId: isNewer ? full.lastMessageId : const Value.absent(),
          lastMessageText: isNewer
              ? full.lastMessageText
              : const Value.absent(),
          lastMessageType: isNewer
              ? full.lastMessageType
              : const Value.absent(),
          lastMessageAt: isNewer ? full.lastMessageAt : const Value.absent(),
          lastMessageIsMine: isNewer
              ? full.lastMessageIsMine
              : const Value.absent(),
          lastMessageStatus: isNewer
              ? full.lastMessageStatus
              : const Value.absent(),
          lastMessageSender: isNewer
              ? full.lastMessageSender
              : const Value.absent(),
        ),
      );
    }
    if (newRows.isNotEmpty) await _chatLocal.insertAll(newRows);
  });

  @override
  Future<int> pinnedChatCount() => _chatLocal.pinnedCount();

  @override
  Future<Result<void>> setPinned(String chatId, {required bool pinned}) =>
      guard(
        () => _chatLocal.updateChat(
          chatId,
          ChatsCompanion(
            pinnedAt: Value(
              pinned ? DateTime.now().millisecondsSinceEpoch : null,
            ),
          ),
        ),
      );

  @override
  Future<Result<void>> setArchived(String chatId, {required bool archived}) =>
      guard(
        () => _chatLocal.updateChat(
          chatId,
          ChatsCompanion(
            isArchived: Value(archived),
            // Archived chats lose their pin, like WhatsApp.
            pinnedAt: archived ? const Value(null) : const Value.absent(),
          ),
        ),
      );

  @override
  Future<Result<void>> markRead(String chatId) => guard(
    () => _chatLocal.updateChat(
      chatId,
      const ChatsCompanion(unreadCount: Value(0)),
    ),
  );

  @override
  Future<Result<SearchResults>> search(String query) => guard(() async {
    final chats = await _chatLocal.searchByName(query);
    final messageRows = await _messageLocal.search(query);
    final owners = {
      for (final c in await _chatLocal.getByIds(
        messageRows.map((m) => m.chatId).toSet(),
      ))
        c.id: c.toEntity(),
    };
    return SearchResults(
      chats: chats.map((c) => c.toEntity()).toList(),
      messages: [
        for (final row in messageRows)
          if (owners[row.chatId] != null)
            MessageSearchHit(
              message: row.toEntity(),
              chat: owners[row.chatId]!,
            ),
      ],
    );
  });
}
