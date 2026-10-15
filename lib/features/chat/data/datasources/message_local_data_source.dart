import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/message.dart';

class MessageLocalDataSource {
  MessageLocalDataSource(this._db);
  final AppDatabase _db;

  $MessagesTable get _messages => _db.messages;

  /// Keyset pagination on (createdAt, id) — stable even when new messages
  /// arrive while the user scrolls, unlike OFFSET-based paging.
  Future<List<MessageRow>> getPage(
    String chatId, {
    int? beforeCreatedAt,
    String? beforeId,
    required int limit,
  }) {
    final query = _db.select(_messages)
      ..where((m) {
        var predicate = m.chatId.equals(chatId);
        if (beforeCreatedAt != null) {
          predicate =
              predicate &
              (m.createdAt.isSmallerThanValue(beforeCreatedAt) |
                  (m.createdAt.equals(beforeCreatedAt) &
                      m.id.isSmallerThanValue(beforeId ?? '')));
        }
        return predicate;
      })
      ..orderBy([
        (m) => OrderingTerm.desc(m.createdAt),
        (m) => OrderingTerm.desc(m.id),
      ])
      ..limit(limit);
    return query.get();
  }

  Future<MessageRow?> getById(String id) =>
      (_db.select(_messages)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<void> upsert(MessagesCompanion row) =>
      _db.into(_messages).insertOnConflictUpdate(row);

  Future<void> upsertAll(List<MessagesCompanion> rows) =>
      _db.batch((b) => b.insertAllOnConflictUpdate(_messages, rows));

  Future<void> updateStatus(String id, MessageStatus status) =>
      (_db.update(_messages)..where((m) => m.id.equals(id))).write(
        MessagesCompanion(status: Value(status.index)),
      );

  /// Applies a cumulative receipt: a message I sent at [upTo] being
  /// delivered/read means all my earlier messages in the chat are too.
  /// Only moves statuses forward and never touches unsent (sending/failed)
  /// messages. Returns the rows that changed, with their new status.
  Future<List<MessageRow>> advanceMyStatusesUpTo(
    String chatId, {
    required int upTo,
    required MessageStatus status,
  }) => _db.transaction(() async {
    final behind =
        await (_db.select(_messages)..where(
              (m) =>
                  m.chatId.equals(chatId) &
                  m.isMine.equals(true) &
                  m.createdAt.isSmallerOrEqualValue(upTo) &
                  m.status.isBetweenValues(
                    MessageStatus.sent.index,
                    status.index - 1,
                  ),
            ))
            .get();
    if (behind.isEmpty) return const <MessageRow>[];
    await (_db.update(_messages)
          ..where((m) => m.id.isIn(behind.map((r) => r.id))))
        .write(MessagesCompanion(status: Value(status.index)));
    return [for (final r in behind) r.copyWith(status: status.index)];
  });

  Future<List<MessageRow>> getImages(String chatId) =>
      (_db.select(_messages)
            ..where(
              (m) =>
                  m.chatId.equals(chatId) &
                  m.type.equals(MessageType.image.index),
            )
            ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
          .get();

  Future<List<MessageRow>> search(String query, {int limit = 50}) =>
      (_db.select(_messages)
            ..where((m) => m.body.like('%${_escape(query)}%', escapeChar: r'\'))
            ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
            ..limit(limit))
          .get();
}

String _escape(String input) =>
    input.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
