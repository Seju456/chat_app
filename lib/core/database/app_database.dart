import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Local cache schema. Enums are stored as their `index` and timestamps as
/// epoch milliseconds so the database layer stays independent of the domain.
@DataClassName('ChatRow')
class Chats extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get avatarColor => integer()();
  BoolColumn get isGroup => boolean().withDefault(const Constant(false))();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
  TextColumn get lastMessageId => text().nullable()();
  TextColumn get lastMessageText => text().nullable()();
  IntColumn get lastMessageType => integer().nullable()();
  IntColumn get lastMessageAt => integer().nullable()();
  BoolColumn get lastMessageIsMine =>
      boolean().withDefault(const Constant(false))();
  IntColumn get lastMessageStatus => integer().nullable()();
  TextColumn get lastMessageSender => text().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  IntColumn get pinnedAt => integer().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MessageRow')
@TableIndex(name: 'idx_messages_chat_created', columns: {#chatId, #createdAt})
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get senderId => text()();
  TextColumn get senderName => text()();
  BoolColumn get isMine => boolean()();
  IntColumn get type => integer()();
  TextColumn get body => text().nullable()();
  TextColumn get mediaUrls => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  IntColumn get voiceDurationMs => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get status => integer()();
  TextColumn get replyToId => text().nullable()();
  TextColumn get replyText => text().nullable()();
  TextColumn get replySenderName => text().nullable()();
  IntColumn get replyType => integer().nullable()();
  BoolColumn get isForwarded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KeyValueRow')
class KeyValues extends Table {
  TextColumn get entryKey => text()();
  TextColumn get entryValue => text()();

  @override
  Set<Column> get primaryKey => {entryKey};
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List<dynamic>).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

@DriftDatabase(tables: [Chats, Messages, KeyValues])
class AppDatabase extends _$AppDatabase {
  /// Pass an executor (e.g. `NativeDatabase.memory()`) in tests.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'chat_app'));

  @override
  int get schemaVersion => 1;
}
