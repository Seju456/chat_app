import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/message.dart';

class ChatLocalDataSource {
  ChatLocalDataSource(this._db);
  final AppDatabase _db;

  $ChatsTable get _chats => _db.chats;

  Stream<List<ChatRow>> watchChats({required bool archived}) {
    final query = _db.select(_chats)
      ..where((c) => c.isArchived.equals(archived))
      ..orderBy([
        // Pinned first (most recently pinned on top), then by recency.
        (c) => OrderingTerm.asc(c.pinnedAt.isNull()),
        (c) => OrderingTerm.desc(c.pinnedAt),
        (c) => OrderingTerm(
          expression: c.lastMessageAt,
          mode: OrderingMode.desc,
          nulls: NullsOrder.last,
        ),
      ]);
    return query.watch();
  }

  Stream<List<ChatRow>> watchArchived() =>
      (_db.select(_chats)..where((c) => c.isArchived.equals(true))).watch();

  Stream<ChatRow?> watchChat(String id) =>
      (_db.select(_chats)..where((c) => c.id.equals(id))).watchSingleOrNull();

  Future<List<ChatRow>> getAll() => _db.select(_chats).get();

  Future<List<ChatRow>> getByIds(Iterable<String> ids) =>
      (_db.select(_chats)..where((c) => c.id.isIn(ids))).get();

  Future<List<ChatRow>> searchByName(String query) =>
      (_db.select(_chats)
            ..where((c) => c.name.like('%${_escape(query)}%', escapeChar: r'\'))
            ..orderBy([(c) => OrderingTerm.desc(c.lastMessageAt)]))
          .get();

  Future<void> insertAll(List<ChatsCompanion> rows) => _db.batch(
    (b) => b.insertAll(_chats, rows, mode: InsertMode.insertOrIgnore),
  );

  Future<void> updateChat(String id, ChatsCompanion companion) =>
      (_db.update(_chats)..where((c) => c.id.equals(id))).write(companion);

  Future<int> pinnedCount() async {
    final count = _chats.id.count();
    final row =
        await (_db.selectOnly(_chats)
              ..addColumns([count])
              ..where(_chats.pinnedAt.isNotNull()))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> incrementUnread(String id) => _db.customUpdate(
    'UPDATE chats SET unread_count = unread_count + 1 WHERE id = ?',
    variables: [Variable.withString(id)],
    updates: {_chats},
  );

  /// Updates the chat preview if [message] is at least as new as the current.
  Future<void> applyLastMessage(Message message) async {
    final at = message.createdAt.millisecondsSinceEpoch;
    await (_db.update(_chats)..where(
          (c) =>
              c.id.equals(message.chatId) &
              (c.lastMessageAt.isNull() |
                  c.lastMessageAt.isSmallerOrEqualValue(at)),
        ))
        .write(
          ChatsCompanion(
            lastMessageId: Value(message.id),
            lastMessageText: Value(message.previewText),
            lastMessageType: Value(message.type.index),
            lastMessageAt: Value(at),
            lastMessageIsMine: Value(message.isMine),
            lastMessageStatus: Value(message.status.index),
            lastMessageSender: Value(
              message.isMine ? 'You' : message.senderName,
            ),
          ),
        );
  }

  /// Keeps the ticks in the chat list in sync with message receipts.
  Future<void> updateLastMessageStatus(
    String chatId,
    String messageId,
    MessageStatus status,
  ) =>
      (_db.update(_chats)..where(
            (c) => c.id.equals(chatId) & c.lastMessageId.equals(messageId),
          ))
          .write(ChatsCompanion(lastMessageStatus: Value(status.index)));
}

String _escape(String input) =>
    input.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
