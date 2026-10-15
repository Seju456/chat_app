// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChatsTable extends Chats with TableInfo<$ChatsTable, ChatRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarColorMeta = const VerificationMeta(
    'avatarColor',
  );
  @override
  late final GeneratedColumn<int> avatarColor = GeneratedColumn<int>(
    'avatar_color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isGroupMeta = const VerificationMeta(
    'isGroup',
  );
  @override
  late final GeneratedColumn<bool> isGroup = GeneratedColumn<bool>(
    'is_group',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_group" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isOnlineMeta = const VerificationMeta(
    'isOnline',
  );
  @override
  late final GeneratedColumn<bool> isOnline = GeneratedColumn<bool>(
    'is_online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_online" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastMessageIdMeta = const VerificationMeta(
    'lastMessageId',
  );
  @override
  late final GeneratedColumn<String> lastMessageId = GeneratedColumn<String>(
    'last_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageTextMeta = const VerificationMeta(
    'lastMessageText',
  );
  @override
  late final GeneratedColumn<String> lastMessageText = GeneratedColumn<String>(
    'last_message_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageTypeMeta = const VerificationMeta(
    'lastMessageType',
  );
  @override
  late final GeneratedColumn<int> lastMessageType = GeneratedColumn<int>(
    'last_message_type',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<int> lastMessageAt = GeneratedColumn<int>(
    'last_message_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageIsMineMeta = const VerificationMeta(
    'lastMessageIsMine',
  );
  @override
  late final GeneratedColumn<bool> lastMessageIsMine = GeneratedColumn<bool>(
    'last_message_is_mine',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("last_message_is_mine" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastMessageStatusMeta = const VerificationMeta(
    'lastMessageStatus',
  );
  @override
  late final GeneratedColumn<int> lastMessageStatus = GeneratedColumn<int>(
    'last_message_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageSenderMeta = const VerificationMeta(
    'lastMessageSender',
  );
  @override
  late final GeneratedColumn<String> lastMessageSender =
      GeneratedColumn<String>(
        'last_message_sender',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pinnedAtMeta = const VerificationMeta(
    'pinnedAt',
  );
  @override
  late final GeneratedColumn<int> pinnedAt = GeneratedColumn<int>(
    'pinned_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    avatarColor,
    isGroup,
    isOnline,
    lastMessageId,
    lastMessageText,
    lastMessageType,
    lastMessageAt,
    lastMessageIsMine,
    lastMessageStatus,
    lastMessageSender,
    unreadCount,
    pinnedAt,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_color')) {
      context.handle(
        _avatarColorMeta,
        avatarColor.isAcceptableOrUnknown(
          data['avatar_color']!,
          _avatarColorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avatarColorMeta);
    }
    if (data.containsKey('is_group')) {
      context.handle(
        _isGroupMeta,
        isGroup.isAcceptableOrUnknown(data['is_group']!, _isGroupMeta),
      );
    }
    if (data.containsKey('is_online')) {
      context.handle(
        _isOnlineMeta,
        isOnline.isAcceptableOrUnknown(data['is_online']!, _isOnlineMeta),
      );
    }
    if (data.containsKey('last_message_id')) {
      context.handle(
        _lastMessageIdMeta,
        lastMessageId.isAcceptableOrUnknown(
          data['last_message_id']!,
          _lastMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message_text')) {
      context.handle(
        _lastMessageTextMeta,
        lastMessageText.isAcceptableOrUnknown(
          data['last_message_text']!,
          _lastMessageTextMeta,
        ),
      );
    }
    if (data.containsKey('last_message_type')) {
      context.handle(
        _lastMessageTypeMeta,
        lastMessageType.isAcceptableOrUnknown(
          data['last_message_type']!,
          _lastMessageTypeMeta,
        ),
      );
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    }
    if (data.containsKey('last_message_is_mine')) {
      context.handle(
        _lastMessageIsMineMeta,
        lastMessageIsMine.isAcceptableOrUnknown(
          data['last_message_is_mine']!,
          _lastMessageIsMineMeta,
        ),
      );
    }
    if (data.containsKey('last_message_status')) {
      context.handle(
        _lastMessageStatusMeta,
        lastMessageStatus.isAcceptableOrUnknown(
          data['last_message_status']!,
          _lastMessageStatusMeta,
        ),
      );
    }
    if (data.containsKey('last_message_sender')) {
      context.handle(
        _lastMessageSenderMeta,
        lastMessageSender.isAcceptableOrUnknown(
          data['last_message_sender']!,
          _lastMessageSenderMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('pinned_at')) {
      context.handle(
        _pinnedAtMeta,
        pinnedAt.isAcceptableOrUnknown(data['pinned_at']!, _pinnedAtMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avatar_color'],
      )!,
      isGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_group'],
      )!,
      isOnline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_online'],
      )!,
      lastMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_id'],
      ),
      lastMessageText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_text'],
      ),
      lastMessageType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_type'],
      ),
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_at'],
      ),
      lastMessageIsMine: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}last_message_is_mine'],
      )!,
      lastMessageStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_status'],
      ),
      lastMessageSender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_sender'],
      ),
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      pinnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pinned_at'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $ChatsTable createAlias(String alias) {
    return $ChatsTable(attachedDatabase, alias);
  }
}

class ChatRow extends DataClass implements Insertable<ChatRow> {
  final String id;
  final String name;
  final int avatarColor;
  final bool isGroup;
  final bool isOnline;
  final String? lastMessageId;
  final String? lastMessageText;
  final int? lastMessageType;
  final int? lastMessageAt;
  final bool lastMessageIsMine;
  final int? lastMessageStatus;
  final String? lastMessageSender;
  final int unreadCount;
  final int? pinnedAt;
  final bool isArchived;
  const ChatRow({
    required this.id,
    required this.name,
    required this.avatarColor,
    required this.isGroup,
    required this.isOnline,
    this.lastMessageId,
    this.lastMessageText,
    this.lastMessageType,
    this.lastMessageAt,
    required this.lastMessageIsMine,
    this.lastMessageStatus,
    this.lastMessageSender,
    required this.unreadCount,
    this.pinnedAt,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['avatar_color'] = Variable<int>(avatarColor);
    map['is_group'] = Variable<bool>(isGroup);
    map['is_online'] = Variable<bool>(isOnline);
    if (!nullToAbsent || lastMessageId != null) {
      map['last_message_id'] = Variable<String>(lastMessageId);
    }
    if (!nullToAbsent || lastMessageText != null) {
      map['last_message_text'] = Variable<String>(lastMessageText);
    }
    if (!nullToAbsent || lastMessageType != null) {
      map['last_message_type'] = Variable<int>(lastMessageType);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<int>(lastMessageAt);
    }
    map['last_message_is_mine'] = Variable<bool>(lastMessageIsMine);
    if (!nullToAbsent || lastMessageStatus != null) {
      map['last_message_status'] = Variable<int>(lastMessageStatus);
    }
    if (!nullToAbsent || lastMessageSender != null) {
      map['last_message_sender'] = Variable<String>(lastMessageSender);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    if (!nullToAbsent || pinnedAt != null) {
      map['pinned_at'] = Variable<int>(pinnedAt);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  ChatsCompanion toCompanion(bool nullToAbsent) {
    return ChatsCompanion(
      id: Value(id),
      name: Value(name),
      avatarColor: Value(avatarColor),
      isGroup: Value(isGroup),
      isOnline: Value(isOnline),
      lastMessageId: lastMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageId),
      lastMessageText: lastMessageText == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageText),
      lastMessageType: lastMessageType == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageType),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      lastMessageIsMine: Value(lastMessageIsMine),
      lastMessageStatus: lastMessageStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageStatus),
      lastMessageSender: lastMessageSender == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageSender),
      unreadCount: Value(unreadCount),
      pinnedAt: pinnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pinnedAt),
      isArchived: Value(isArchived),
    );
  }

  factory ChatRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatarColor: serializer.fromJson<int>(json['avatarColor']),
      isGroup: serializer.fromJson<bool>(json['isGroup']),
      isOnline: serializer.fromJson<bool>(json['isOnline']),
      lastMessageId: serializer.fromJson<String?>(json['lastMessageId']),
      lastMessageText: serializer.fromJson<String?>(json['lastMessageText']),
      lastMessageType: serializer.fromJson<int?>(json['lastMessageType']),
      lastMessageAt: serializer.fromJson<int?>(json['lastMessageAt']),
      lastMessageIsMine: serializer.fromJson<bool>(json['lastMessageIsMine']),
      lastMessageStatus: serializer.fromJson<int?>(json['lastMessageStatus']),
      lastMessageSender: serializer.fromJson<String?>(
        json['lastMessageSender'],
      ),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      pinnedAt: serializer.fromJson<int?>(json['pinnedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'avatarColor': serializer.toJson<int>(avatarColor),
      'isGroup': serializer.toJson<bool>(isGroup),
      'isOnline': serializer.toJson<bool>(isOnline),
      'lastMessageId': serializer.toJson<String?>(lastMessageId),
      'lastMessageText': serializer.toJson<String?>(lastMessageText),
      'lastMessageType': serializer.toJson<int?>(lastMessageType),
      'lastMessageAt': serializer.toJson<int?>(lastMessageAt),
      'lastMessageIsMine': serializer.toJson<bool>(lastMessageIsMine),
      'lastMessageStatus': serializer.toJson<int?>(lastMessageStatus),
      'lastMessageSender': serializer.toJson<String?>(lastMessageSender),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'pinnedAt': serializer.toJson<int?>(pinnedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  ChatRow copyWith({
    String? id,
    String? name,
    int? avatarColor,
    bool? isGroup,
    bool? isOnline,
    Value<String?> lastMessageId = const Value.absent(),
    Value<String?> lastMessageText = const Value.absent(),
    Value<int?> lastMessageType = const Value.absent(),
    Value<int?> lastMessageAt = const Value.absent(),
    bool? lastMessageIsMine,
    Value<int?> lastMessageStatus = const Value.absent(),
    Value<String?> lastMessageSender = const Value.absent(),
    int? unreadCount,
    Value<int?> pinnedAt = const Value.absent(),
    bool? isArchived,
  }) => ChatRow(
    id: id ?? this.id,
    name: name ?? this.name,
    avatarColor: avatarColor ?? this.avatarColor,
    isGroup: isGroup ?? this.isGroup,
    isOnline: isOnline ?? this.isOnline,
    lastMessageId: lastMessageId.present
        ? lastMessageId.value
        : this.lastMessageId,
    lastMessageText: lastMessageText.present
        ? lastMessageText.value
        : this.lastMessageText,
    lastMessageType: lastMessageType.present
        ? lastMessageType.value
        : this.lastMessageType,
    lastMessageAt: lastMessageAt.present
        ? lastMessageAt.value
        : this.lastMessageAt,
    lastMessageIsMine: lastMessageIsMine ?? this.lastMessageIsMine,
    lastMessageStatus: lastMessageStatus.present
        ? lastMessageStatus.value
        : this.lastMessageStatus,
    lastMessageSender: lastMessageSender.present
        ? lastMessageSender.value
        : this.lastMessageSender,
    unreadCount: unreadCount ?? this.unreadCount,
    pinnedAt: pinnedAt.present ? pinnedAt.value : this.pinnedAt,
    isArchived: isArchived ?? this.isArchived,
  );
  ChatRow copyWithCompanion(ChatsCompanion data) {
    return ChatRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatarColor: data.avatarColor.present
          ? data.avatarColor.value
          : this.avatarColor,
      isGroup: data.isGroup.present ? data.isGroup.value : this.isGroup,
      isOnline: data.isOnline.present ? data.isOnline.value : this.isOnline,
      lastMessageId: data.lastMessageId.present
          ? data.lastMessageId.value
          : this.lastMessageId,
      lastMessageText: data.lastMessageText.present
          ? data.lastMessageText.value
          : this.lastMessageText,
      lastMessageType: data.lastMessageType.present
          ? data.lastMessageType.value
          : this.lastMessageType,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      lastMessageIsMine: data.lastMessageIsMine.present
          ? data.lastMessageIsMine.value
          : this.lastMessageIsMine,
      lastMessageStatus: data.lastMessageStatus.present
          ? data.lastMessageStatus.value
          : this.lastMessageStatus,
      lastMessageSender: data.lastMessageSender.present
          ? data.lastMessageSender.value
          : this.lastMessageSender,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      pinnedAt: data.pinnedAt.present ? data.pinnedAt.value : this.pinnedAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarColor: $avatarColor, ')
          ..write('isGroup: $isGroup, ')
          ..write('isOnline: $isOnline, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('lastMessageText: $lastMessageText, ')
          ..write('lastMessageType: $lastMessageType, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('lastMessageIsMine: $lastMessageIsMine, ')
          ..write('lastMessageStatus: $lastMessageStatus, ')
          ..write('lastMessageSender: $lastMessageSender, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('pinnedAt: $pinnedAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    avatarColor,
    isGroup,
    isOnline,
    lastMessageId,
    lastMessageText,
    lastMessageType,
    lastMessageAt,
    lastMessageIsMine,
    lastMessageStatus,
    lastMessageSender,
    unreadCount,
    pinnedAt,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatarColor == this.avatarColor &&
          other.isGroup == this.isGroup &&
          other.isOnline == this.isOnline &&
          other.lastMessageId == this.lastMessageId &&
          other.lastMessageText == this.lastMessageText &&
          other.lastMessageType == this.lastMessageType &&
          other.lastMessageAt == this.lastMessageAt &&
          other.lastMessageIsMine == this.lastMessageIsMine &&
          other.lastMessageStatus == this.lastMessageStatus &&
          other.lastMessageSender == this.lastMessageSender &&
          other.unreadCount == this.unreadCount &&
          other.pinnedAt == this.pinnedAt &&
          other.isArchived == this.isArchived);
}

class ChatsCompanion extends UpdateCompanion<ChatRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> avatarColor;
  final Value<bool> isGroup;
  final Value<bool> isOnline;
  final Value<String?> lastMessageId;
  final Value<String?> lastMessageText;
  final Value<int?> lastMessageType;
  final Value<int?> lastMessageAt;
  final Value<bool> lastMessageIsMine;
  final Value<int?> lastMessageStatus;
  final Value<String?> lastMessageSender;
  final Value<int> unreadCount;
  final Value<int?> pinnedAt;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const ChatsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarColor = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.lastMessageText = const Value.absent(),
    this.lastMessageType = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.lastMessageIsMine = const Value.absent(),
    this.lastMessageStatus = const Value.absent(),
    this.lastMessageSender = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.pinnedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatsCompanion.insert({
    required String id,
    required String name,
    required int avatarColor,
    this.isGroup = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.lastMessageText = const Value.absent(),
    this.lastMessageType = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.lastMessageIsMine = const Value.absent(),
    this.lastMessageStatus = const Value.absent(),
    this.lastMessageSender = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.pinnedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       avatarColor = Value(avatarColor);
  static Insertable<ChatRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? avatarColor,
    Expression<bool>? isGroup,
    Expression<bool>? isOnline,
    Expression<String>? lastMessageId,
    Expression<String>? lastMessageText,
    Expression<int>? lastMessageType,
    Expression<int>? lastMessageAt,
    Expression<bool>? lastMessageIsMine,
    Expression<int>? lastMessageStatus,
    Expression<String>? lastMessageSender,
    Expression<int>? unreadCount,
    Expression<int>? pinnedAt,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatarColor != null) 'avatar_color': avatarColor,
      if (isGroup != null) 'is_group': isGroup,
      if (isOnline != null) 'is_online': isOnline,
      if (lastMessageId != null) 'last_message_id': lastMessageId,
      if (lastMessageText != null) 'last_message_text': lastMessageText,
      if (lastMessageType != null) 'last_message_type': lastMessageType,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (lastMessageIsMine != null) 'last_message_is_mine': lastMessageIsMine,
      if (lastMessageStatus != null) 'last_message_status': lastMessageStatus,
      if (lastMessageSender != null) 'last_message_sender': lastMessageSender,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (pinnedAt != null) 'pinned_at': pinnedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? avatarColor,
    Value<bool>? isGroup,
    Value<bool>? isOnline,
    Value<String?>? lastMessageId,
    Value<String?>? lastMessageText,
    Value<int?>? lastMessageType,
    Value<int?>? lastMessageAt,
    Value<bool>? lastMessageIsMine,
    Value<int?>? lastMessageStatus,
    Value<String?>? lastMessageSender,
    Value<int>? unreadCount,
    Value<int?>? pinnedAt,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return ChatsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarColor: avatarColor ?? this.avatarColor,
      isGroup: isGroup ?? this.isGroup,
      isOnline: isOnline ?? this.isOnline,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageIsMine: lastMessageIsMine ?? this.lastMessageIsMine,
      lastMessageStatus: lastMessageStatus ?? this.lastMessageStatus,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      unreadCount: unreadCount ?? this.unreadCount,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarColor.present) {
      map['avatar_color'] = Variable<int>(avatarColor.value);
    }
    if (isGroup.present) {
      map['is_group'] = Variable<bool>(isGroup.value);
    }
    if (isOnline.present) {
      map['is_online'] = Variable<bool>(isOnline.value);
    }
    if (lastMessageId.present) {
      map['last_message_id'] = Variable<String>(lastMessageId.value);
    }
    if (lastMessageText.present) {
      map['last_message_text'] = Variable<String>(lastMessageText.value);
    }
    if (lastMessageType.present) {
      map['last_message_type'] = Variable<int>(lastMessageType.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<int>(lastMessageAt.value);
    }
    if (lastMessageIsMine.present) {
      map['last_message_is_mine'] = Variable<bool>(lastMessageIsMine.value);
    }
    if (lastMessageStatus.present) {
      map['last_message_status'] = Variable<int>(lastMessageStatus.value);
    }
    if (lastMessageSender.present) {
      map['last_message_sender'] = Variable<String>(lastMessageSender.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (pinnedAt.present) {
      map['pinned_at'] = Variable<int>(pinnedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarColor: $avatarColor, ')
          ..write('isGroup: $isGroup, ')
          ..write('isOnline: $isOnline, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('lastMessageText: $lastMessageText, ')
          ..write('lastMessageType: $lastMessageType, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('lastMessageIsMine: $lastMessageIsMine, ')
          ..write('lastMessageStatus: $lastMessageStatus, ')
          ..write('lastMessageSender: $lastMessageSender, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('pinnedAt: $pinnedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderNameMeta = const VerificationMeta(
    'senderName',
  );
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
    'sender_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isMineMeta = const VerificationMeta('isMine');
  @override
  late final GeneratedColumn<bool> isMine = GeneratedColumn<bool>(
    'is_mine',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mine" IN (0, 1))',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> mediaUrls =
      GeneratedColumn<String>(
        'media_urls',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($MessagesTable.$convertermediaUrls);
  static const VerificationMeta _voiceDurationMsMeta = const VerificationMeta(
    'voiceDurationMs',
  );
  @override
  late final GeneratedColumn<int> voiceDurationMs = GeneratedColumn<int>(
    'voice_duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _replyToIdMeta = const VerificationMeta(
    'replyToId',
  );
  @override
  late final GeneratedColumn<String> replyToId = GeneratedColumn<String>(
    'reply_to_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyTextMeta = const VerificationMeta(
    'replyText',
  );
  @override
  late final GeneratedColumn<String> replyText = GeneratedColumn<String>(
    'reply_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replySenderNameMeta = const VerificationMeta(
    'replySenderName',
  );
  @override
  late final GeneratedColumn<String> replySenderName = GeneratedColumn<String>(
    'reply_sender_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyTypeMeta = const VerificationMeta(
    'replyType',
  );
  @override
  late final GeneratedColumn<int> replyType = GeneratedColumn<int>(
    'reply_type',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isForwardedMeta = const VerificationMeta(
    'isForwarded',
  );
  @override
  late final GeneratedColumn<bool> isForwarded = GeneratedColumn<bool>(
    'is_forwarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_forwarded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatId,
    senderId,
    senderName,
    isMine,
    type,
    body,
    mediaUrls,
    voiceDurationMs,
    createdAt,
    status,
    replyToId,
    replyText,
    replySenderName,
    replyType,
    isForwarded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('sender_name')) {
      context.handle(
        _senderNameMeta,
        senderName.isAcceptableOrUnknown(data['sender_name']!, _senderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_senderNameMeta);
    }
    if (data.containsKey('is_mine')) {
      context.handle(
        _isMineMeta,
        isMine.isAcceptableOrUnknown(data['is_mine']!, _isMineMeta),
      );
    } else if (isInserting) {
      context.missing(_isMineMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('voice_duration_ms')) {
      context.handle(
        _voiceDurationMsMeta,
        voiceDurationMs.isAcceptableOrUnknown(
          data['voice_duration_ms']!,
          _voiceDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('reply_to_id')) {
      context.handle(
        _replyToIdMeta,
        replyToId.isAcceptableOrUnknown(data['reply_to_id']!, _replyToIdMeta),
      );
    }
    if (data.containsKey('reply_text')) {
      context.handle(
        _replyTextMeta,
        replyText.isAcceptableOrUnknown(data['reply_text']!, _replyTextMeta),
      );
    }
    if (data.containsKey('reply_sender_name')) {
      context.handle(
        _replySenderNameMeta,
        replySenderName.isAcceptableOrUnknown(
          data['reply_sender_name']!,
          _replySenderNameMeta,
        ),
      );
    }
    if (data.containsKey('reply_type')) {
      context.handle(
        _replyTypeMeta,
        replyType.isAcceptableOrUnknown(data['reply_type']!, _replyTypeMeta),
      );
    }
    if (data.containsKey('is_forwarded')) {
      context.handle(
        _isForwardedMeta,
        isForwarded.isAcceptableOrUnknown(
          data['is_forwarded']!,
          _isForwardedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      senderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_name'],
      )!,
      isMine: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mine'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      mediaUrls: $MessagesTable.$convertermediaUrls.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}media_urls'],
        )!,
      ),
      voiceDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voice_duration_ms'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      replyToId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_to_id'],
      ),
      replyText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_text'],
      ),
      replySenderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_sender_name'],
      ),
      replyType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reply_type'],
      ),
      isForwarded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_forwarded'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertermediaUrls =
      const StringListConverter();
}

class MessageRow extends DataClass implements Insertable<MessageRow> {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final bool isMine;
  final int type;
  final String? body;
  final List<String> mediaUrls;
  final int? voiceDurationMs;
  final int createdAt;
  final int status;
  final String? replyToId;
  final String? replyText;
  final String? replySenderName;
  final int? replyType;
  final bool isForwarded;
  const MessageRow({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.isMine,
    required this.type,
    this.body,
    required this.mediaUrls,
    this.voiceDurationMs,
    required this.createdAt,
    required this.status,
    this.replyToId,
    this.replyText,
    this.replySenderName,
    this.replyType,
    required this.isForwarded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_id'] = Variable<String>(chatId);
    map['sender_id'] = Variable<String>(senderId);
    map['sender_name'] = Variable<String>(senderName);
    map['is_mine'] = Variable<bool>(isMine);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    {
      map['media_urls'] = Variable<String>(
        $MessagesTable.$convertermediaUrls.toSql(mediaUrls),
      );
    }
    if (!nullToAbsent || voiceDurationMs != null) {
      map['voice_duration_ms'] = Variable<int>(voiceDurationMs);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || replyToId != null) {
      map['reply_to_id'] = Variable<String>(replyToId);
    }
    if (!nullToAbsent || replyText != null) {
      map['reply_text'] = Variable<String>(replyText);
    }
    if (!nullToAbsent || replySenderName != null) {
      map['reply_sender_name'] = Variable<String>(replySenderName);
    }
    if (!nullToAbsent || replyType != null) {
      map['reply_type'] = Variable<int>(replyType);
    }
    map['is_forwarded'] = Variable<bool>(isForwarded);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      chatId: Value(chatId),
      senderId: Value(senderId),
      senderName: Value(senderName),
      isMine: Value(isMine),
      type: Value(type),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      mediaUrls: Value(mediaUrls),
      voiceDurationMs: voiceDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceDurationMs),
      createdAt: Value(createdAt),
      status: Value(status),
      replyToId: replyToId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToId),
      replyText: replyText == null && nullToAbsent
          ? const Value.absent()
          : Value(replyText),
      replySenderName: replySenderName == null && nullToAbsent
          ? const Value.absent()
          : Value(replySenderName),
      replyType: replyType == null && nullToAbsent
          ? const Value.absent()
          : Value(replyType),
      isForwarded: Value(isForwarded),
    );
  }

  factory MessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRow(
      id: serializer.fromJson<String>(json['id']),
      chatId: serializer.fromJson<String>(json['chatId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      senderName: serializer.fromJson<String>(json['senderName']),
      isMine: serializer.fromJson<bool>(json['isMine']),
      type: serializer.fromJson<int>(json['type']),
      body: serializer.fromJson<String?>(json['body']),
      mediaUrls: serializer.fromJson<List<String>>(json['mediaUrls']),
      voiceDurationMs: serializer.fromJson<int?>(json['voiceDurationMs']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      status: serializer.fromJson<int>(json['status']),
      replyToId: serializer.fromJson<String?>(json['replyToId']),
      replyText: serializer.fromJson<String?>(json['replyText']),
      replySenderName: serializer.fromJson<String?>(json['replySenderName']),
      replyType: serializer.fromJson<int?>(json['replyType']),
      isForwarded: serializer.fromJson<bool>(json['isForwarded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatId': serializer.toJson<String>(chatId),
      'senderId': serializer.toJson<String>(senderId),
      'senderName': serializer.toJson<String>(senderName),
      'isMine': serializer.toJson<bool>(isMine),
      'type': serializer.toJson<int>(type),
      'body': serializer.toJson<String?>(body),
      'mediaUrls': serializer.toJson<List<String>>(mediaUrls),
      'voiceDurationMs': serializer.toJson<int?>(voiceDurationMs),
      'createdAt': serializer.toJson<int>(createdAt),
      'status': serializer.toJson<int>(status),
      'replyToId': serializer.toJson<String?>(replyToId),
      'replyText': serializer.toJson<String?>(replyText),
      'replySenderName': serializer.toJson<String?>(replySenderName),
      'replyType': serializer.toJson<int?>(replyType),
      'isForwarded': serializer.toJson<bool>(isForwarded),
    };
  }

  MessageRow copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    bool? isMine,
    int? type,
    Value<String?> body = const Value.absent(),
    List<String>? mediaUrls,
    Value<int?> voiceDurationMs = const Value.absent(),
    int? createdAt,
    int? status,
    Value<String?> replyToId = const Value.absent(),
    Value<String?> replyText = const Value.absent(),
    Value<String?> replySenderName = const Value.absent(),
    Value<int?> replyType = const Value.absent(),
    bool? isForwarded,
  }) => MessageRow(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    senderId: senderId ?? this.senderId,
    senderName: senderName ?? this.senderName,
    isMine: isMine ?? this.isMine,
    type: type ?? this.type,
    body: body.present ? body.value : this.body,
    mediaUrls: mediaUrls ?? this.mediaUrls,
    voiceDurationMs: voiceDurationMs.present
        ? voiceDurationMs.value
        : this.voiceDurationMs,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    replyToId: replyToId.present ? replyToId.value : this.replyToId,
    replyText: replyText.present ? replyText.value : this.replyText,
    replySenderName: replySenderName.present
        ? replySenderName.value
        : this.replySenderName,
    replyType: replyType.present ? replyType.value : this.replyType,
    isForwarded: isForwarded ?? this.isForwarded,
  );
  MessageRow copyWithCompanion(MessagesCompanion data) {
    return MessageRow(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      senderName: data.senderName.present
          ? data.senderName.value
          : this.senderName,
      isMine: data.isMine.present ? data.isMine.value : this.isMine,
      type: data.type.present ? data.type.value : this.type,
      body: data.body.present ? data.body.value : this.body,
      mediaUrls: data.mediaUrls.present ? data.mediaUrls.value : this.mediaUrls,
      voiceDurationMs: data.voiceDurationMs.present
          ? data.voiceDurationMs.value
          : this.voiceDurationMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
      replyToId: data.replyToId.present ? data.replyToId.value : this.replyToId,
      replyText: data.replyText.present ? data.replyText.value : this.replyText,
      replySenderName: data.replySenderName.present
          ? data.replySenderName.value
          : this.replySenderName,
      replyType: data.replyType.present ? data.replyType.value : this.replyType,
      isForwarded: data.isForwarded.present
          ? data.isForwarded.value
          : this.isForwarded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRow(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('isMine: $isMine, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('mediaUrls: $mediaUrls, ')
          ..write('voiceDurationMs: $voiceDurationMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('replyToId: $replyToId, ')
          ..write('replyText: $replyText, ')
          ..write('replySenderName: $replySenderName, ')
          ..write('replyType: $replyType, ')
          ..write('isForwarded: $isForwarded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatId,
    senderId,
    senderName,
    isMine,
    type,
    body,
    mediaUrls,
    voiceDurationMs,
    createdAt,
    status,
    replyToId,
    replyText,
    replySenderName,
    replyType,
    isForwarded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRow &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.senderId == this.senderId &&
          other.senderName == this.senderName &&
          other.isMine == this.isMine &&
          other.type == this.type &&
          other.body == this.body &&
          other.mediaUrls == this.mediaUrls &&
          other.voiceDurationMs == this.voiceDurationMs &&
          other.createdAt == this.createdAt &&
          other.status == this.status &&
          other.replyToId == this.replyToId &&
          other.replyText == this.replyText &&
          other.replySenderName == this.replySenderName &&
          other.replyType == this.replyType &&
          other.isForwarded == this.isForwarded);
}

class MessagesCompanion extends UpdateCompanion<MessageRow> {
  final Value<String> id;
  final Value<String> chatId;
  final Value<String> senderId;
  final Value<String> senderName;
  final Value<bool> isMine;
  final Value<int> type;
  final Value<String?> body;
  final Value<List<String>> mediaUrls;
  final Value<int?> voiceDurationMs;
  final Value<int> createdAt;
  final Value<int> status;
  final Value<String?> replyToId;
  final Value<String?> replyText;
  final Value<String?> replySenderName;
  final Value<int?> replyType;
  final Value<bool> isForwarded;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderName = const Value.absent(),
    this.isMine = const Value.absent(),
    this.type = const Value.absent(),
    this.body = const Value.absent(),
    this.mediaUrls = const Value.absent(),
    this.voiceDurationMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.replyText = const Value.absent(),
    this.replySenderName = const Value.absent(),
    this.replyType = const Value.absent(),
    this.isForwarded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String chatId,
    required String senderId,
    required String senderName,
    required bool isMine,
    required int type,
    this.body = const Value.absent(),
    this.mediaUrls = const Value.absent(),
    this.voiceDurationMs = const Value.absent(),
    required int createdAt,
    required int status,
    this.replyToId = const Value.absent(),
    this.replyText = const Value.absent(),
    this.replySenderName = const Value.absent(),
    this.replyType = const Value.absent(),
    this.isForwarded = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chatId = Value(chatId),
       senderId = Value(senderId),
       senderName = Value(senderName),
       isMine = Value(isMine),
       type = Value(type),
       createdAt = Value(createdAt),
       status = Value(status);
  static Insertable<MessageRow> custom({
    Expression<String>? id,
    Expression<String>? chatId,
    Expression<String>? senderId,
    Expression<String>? senderName,
    Expression<bool>? isMine,
    Expression<int>? type,
    Expression<String>? body,
    Expression<String>? mediaUrls,
    Expression<int>? voiceDurationMs,
    Expression<int>? createdAt,
    Expression<int>? status,
    Expression<String>? replyToId,
    Expression<String>? replyText,
    Expression<String>? replySenderName,
    Expression<int>? replyType,
    Expression<bool>? isForwarded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (senderId != null) 'sender_id': senderId,
      if (senderName != null) 'sender_name': senderName,
      if (isMine != null) 'is_mine': isMine,
      if (type != null) 'type': type,
      if (body != null) 'body': body,
      if (mediaUrls != null) 'media_urls': mediaUrls,
      if (voiceDurationMs != null) 'voice_duration_ms': voiceDurationMs,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (replyToId != null) 'reply_to_id': replyToId,
      if (replyText != null) 'reply_text': replyText,
      if (replySenderName != null) 'reply_sender_name': replySenderName,
      if (replyType != null) 'reply_type': replyType,
      if (isForwarded != null) 'is_forwarded': isForwarded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? chatId,
    Value<String>? senderId,
    Value<String>? senderName,
    Value<bool>? isMine,
    Value<int>? type,
    Value<String?>? body,
    Value<List<String>>? mediaUrls,
    Value<int?>? voiceDurationMs,
    Value<int>? createdAt,
    Value<int>? status,
    Value<String?>? replyToId,
    Value<String?>? replyText,
    Value<String?>? replySenderName,
    Value<int?>? replyType,
    Value<bool>? isForwarded,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      isMine: isMine ?? this.isMine,
      type: type ?? this.type,
      body: body ?? this.body,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      voiceDurationMs: voiceDurationMs ?? this.voiceDurationMs,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      replyText: replyText ?? this.replyText,
      replySenderName: replySenderName ?? this.replySenderName,
      replyType: replyType ?? this.replyType,
      isForwarded: isForwarded ?? this.isForwarded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (isMine.present) {
      map['is_mine'] = Variable<bool>(isMine.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (mediaUrls.present) {
      map['media_urls'] = Variable<String>(
        $MessagesTable.$convertermediaUrls.toSql(mediaUrls.value),
      );
    }
    if (voiceDurationMs.present) {
      map['voice_duration_ms'] = Variable<int>(voiceDurationMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (replyToId.present) {
      map['reply_to_id'] = Variable<String>(replyToId.value);
    }
    if (replyText.present) {
      map['reply_text'] = Variable<String>(replyText.value);
    }
    if (replySenderName.present) {
      map['reply_sender_name'] = Variable<String>(replySenderName.value);
    }
    if (replyType.present) {
      map['reply_type'] = Variable<int>(replyType.value);
    }
    if (isForwarded.present) {
      map['is_forwarded'] = Variable<bool>(isForwarded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('isMine: $isMine, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('mediaUrls: $mediaUrls, ')
          ..write('voiceDurationMs: $voiceDurationMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('replyToId: $replyToId, ')
          ..write('replyText: $replyText, ')
          ..write('replySenderName: $replySenderName, ')
          ..write('replyType: $replyType, ')
          ..write('isForwarded: $isForwarded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KeyValuesTable extends KeyValues
    with TableInfo<$KeyValuesTable, KeyValueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryKeyMeta = const VerificationMeta(
    'entryKey',
  );
  @override
  late final GeneratedColumn<String> entryKey = GeneratedColumn<String>(
    'entry_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryValueMeta = const VerificationMeta(
    'entryValue',
  );
  @override
  late final GeneratedColumn<String> entryValue = GeneratedColumn<String>(
    'entry_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entryKey, entryValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyValueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_key')) {
      context.handle(
        _entryKeyMeta,
        entryKey.isAcceptableOrUnknown(data['entry_key']!, _entryKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entryKeyMeta);
    }
    if (data.containsKey('entry_value')) {
      context.handle(
        _entryValueMeta,
        entryValue.isAcceptableOrUnknown(data['entry_value']!, _entryValueMeta),
      );
    } else if (isInserting) {
      context.missing(_entryValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryKey};
  @override
  KeyValueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValueRow(
      entryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_key'],
      )!,
      entryValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_value'],
      )!,
    );
  }

  @override
  $KeyValuesTable createAlias(String alias) {
    return $KeyValuesTable(attachedDatabase, alias);
  }
}

class KeyValueRow extends DataClass implements Insertable<KeyValueRow> {
  final String entryKey;
  final String entryValue;
  const KeyValueRow({required this.entryKey, required this.entryValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_key'] = Variable<String>(entryKey);
    map['entry_value'] = Variable<String>(entryValue);
    return map;
  }

  KeyValuesCompanion toCompanion(bool nullToAbsent) {
    return KeyValuesCompanion(
      entryKey: Value(entryKey),
      entryValue: Value(entryValue),
    );
  }

  factory KeyValueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValueRow(
      entryKey: serializer.fromJson<String>(json['entryKey']),
      entryValue: serializer.fromJson<String>(json['entryValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryKey': serializer.toJson<String>(entryKey),
      'entryValue': serializer.toJson<String>(entryValue),
    };
  }

  KeyValueRow copyWith({String? entryKey, String? entryValue}) => KeyValueRow(
    entryKey: entryKey ?? this.entryKey,
    entryValue: entryValue ?? this.entryValue,
  );
  KeyValueRow copyWithCompanion(KeyValuesCompanion data) {
    return KeyValueRow(
      entryKey: data.entryKey.present ? data.entryKey.value : this.entryKey,
      entryValue: data.entryValue.present
          ? data.entryValue.value
          : this.entryValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueRow(')
          ..write('entryKey: $entryKey, ')
          ..write('entryValue: $entryValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryKey, entryValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValueRow &&
          other.entryKey == this.entryKey &&
          other.entryValue == this.entryValue);
}

class KeyValuesCompanion extends UpdateCompanion<KeyValueRow> {
  final Value<String> entryKey;
  final Value<String> entryValue;
  final Value<int> rowid;
  const KeyValuesCompanion({
    this.entryKey = const Value.absent(),
    this.entryValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValuesCompanion.insert({
    required String entryKey,
    required String entryValue,
    this.rowid = const Value.absent(),
  }) : entryKey = Value(entryKey),
       entryValue = Value(entryValue);
  static Insertable<KeyValueRow> custom({
    Expression<String>? entryKey,
    Expression<String>? entryValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryKey != null) 'entry_key': entryKey,
      if (entryValue != null) 'entry_value': entryValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValuesCompanion copyWith({
    Value<String>? entryKey,
    Value<String>? entryValue,
    Value<int>? rowid,
  }) {
    return KeyValuesCompanion(
      entryKey: entryKey ?? this.entryKey,
      entryValue: entryValue ?? this.entryValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryKey.present) {
      map['entry_key'] = Variable<String>(entryKey.value);
    }
    if (entryValue.present) {
      map['entry_value'] = Variable<String>(entryValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValuesCompanion(')
          ..write('entryKey: $entryKey, ')
          ..write('entryValue: $entryValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatsTable chats = $ChatsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $KeyValuesTable keyValues = $KeyValuesTable(this);
  late final Index idxMessagesChatCreated = Index(
    'idx_messages_chat_created',
    'CREATE INDEX idx_messages_chat_created ON messages (chat_id, created_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    chats,
    messages,
    keyValues,
    idxMessagesChatCreated,
  ];
}

typedef $$ChatsTableCreateCompanionBuilder =
    ChatsCompanion Function({
      required String id,
      required String name,
      required int avatarColor,
      Value<bool> isGroup,
      Value<bool> isOnline,
      Value<String?> lastMessageId,
      Value<String?> lastMessageText,
      Value<int?> lastMessageType,
      Value<int?> lastMessageAt,
      Value<bool> lastMessageIsMine,
      Value<int?> lastMessageStatus,
      Value<String?> lastMessageSender,
      Value<int> unreadCount,
      Value<int?> pinnedAt,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$ChatsTableUpdateCompanionBuilder =
    ChatsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> avatarColor,
      Value<bool> isGroup,
      Value<bool> isOnline,
      Value<String?> lastMessageId,
      Value<String?> lastMessageText,
      Value<int?> lastMessageType,
      Value<int?> lastMessageAt,
      Value<bool> lastMessageIsMine,
      Value<int?> lastMessageStatus,
      Value<String?> lastMessageSender,
      Value<int> unreadCount,
      Value<int?> pinnedAt,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$ChatsTableFilterComposer extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avatarColor => $composableBuilder(
    column: $table.avatarColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessageText => $composableBuilder(
    column: $table.lastMessageText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageType => $composableBuilder(
    column: $table.lastMessageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lastMessageIsMine => $composableBuilder(
    column: $table.lastMessageIsMine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageStatus => $composableBuilder(
    column: $table.lastMessageStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessageSender => $composableBuilder(
    column: $table.lastMessageSender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pinnedAt => $composableBuilder(
    column: $table.pinnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avatarColor => $composableBuilder(
    column: $table.avatarColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessageText => $composableBuilder(
    column: $table.lastMessageText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageType => $composableBuilder(
    column: $table.lastMessageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lastMessageIsMine => $composableBuilder(
    column: $table.lastMessageIsMine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageStatus => $composableBuilder(
    column: $table.lastMessageStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessageSender => $composableBuilder(
    column: $table.lastMessageSender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pinnedAt => $composableBuilder(
    column: $table.pinnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get avatarColor => $composableBuilder(
    column: $table.avatarColor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isGroup =>
      $composableBuilder(column: $table.isGroup, builder: (column) => column);

  GeneratedColumn<bool> get isOnline =>
      $composableBuilder(column: $table.isOnline, builder: (column) => column);

  GeneratedColumn<String> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessageText => $composableBuilder(
    column: $table.lastMessageText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageType => $composableBuilder(
    column: $table.lastMessageType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lastMessageIsMine => $composableBuilder(
    column: $table.lastMessageIsMine,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageStatus => $composableBuilder(
    column: $table.lastMessageStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessageSender => $composableBuilder(
    column: $table.lastMessageSender,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pinnedAt =>
      $composableBuilder(column: $table.pinnedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$ChatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatsTable,
          ChatRow,
          $$ChatsTableFilterComposer,
          $$ChatsTableOrderingComposer,
          $$ChatsTableAnnotationComposer,
          $$ChatsTableCreateCompanionBuilder,
          $$ChatsTableUpdateCompanionBuilder,
          (ChatRow, BaseReferences<_$AppDatabase, $ChatsTable, ChatRow>),
          ChatRow,
          PrefetchHooks Function()
        > {
  $$ChatsTableTableManager(_$AppDatabase db, $ChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> avatarColor = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<String?> lastMessageId = const Value.absent(),
                Value<String?> lastMessageText = const Value.absent(),
                Value<int?> lastMessageType = const Value.absent(),
                Value<int?> lastMessageAt = const Value.absent(),
                Value<bool> lastMessageIsMine = const Value.absent(),
                Value<int?> lastMessageStatus = const Value.absent(),
                Value<String?> lastMessageSender = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<int?> pinnedAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatsCompanion(
                id: id,
                name: name,
                avatarColor: avatarColor,
                isGroup: isGroup,
                isOnline: isOnline,
                lastMessageId: lastMessageId,
                lastMessageText: lastMessageText,
                lastMessageType: lastMessageType,
                lastMessageAt: lastMessageAt,
                lastMessageIsMine: lastMessageIsMine,
                lastMessageStatus: lastMessageStatus,
                lastMessageSender: lastMessageSender,
                unreadCount: unreadCount,
                pinnedAt: pinnedAt,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int avatarColor,
                Value<bool> isGroup = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<String?> lastMessageId = const Value.absent(),
                Value<String?> lastMessageText = const Value.absent(),
                Value<int?> lastMessageType = const Value.absent(),
                Value<int?> lastMessageAt = const Value.absent(),
                Value<bool> lastMessageIsMine = const Value.absent(),
                Value<int?> lastMessageStatus = const Value.absent(),
                Value<String?> lastMessageSender = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<int?> pinnedAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatsCompanion.insert(
                id: id,
                name: name,
                avatarColor: avatarColor,
                isGroup: isGroup,
                isOnline: isOnline,
                lastMessageId: lastMessageId,
                lastMessageText: lastMessageText,
                lastMessageType: lastMessageType,
                lastMessageAt: lastMessageAt,
                lastMessageIsMine: lastMessageIsMine,
                lastMessageStatus: lastMessageStatus,
                lastMessageSender: lastMessageSender,
                unreadCount: unreadCount,
                pinnedAt: pinnedAt,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChatsTable, ChatRow>(table),
                  BaseReferences<_$AppDatabase, $ChatsTable, ChatRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatsTable,
      ChatRow,
      $$ChatsTableFilterComposer,
      $$ChatsTableOrderingComposer,
      $$ChatsTableAnnotationComposer,
      $$ChatsTableCreateCompanionBuilder,
      $$ChatsTableUpdateCompanionBuilder,
      (ChatRow, BaseReferences<_$AppDatabase, $ChatsTable, ChatRow>),
      ChatRow,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String chatId,
      required String senderId,
      required String senderName,
      required bool isMine,
      required int type,
      Value<String?> body,
      Value<List<String>> mediaUrls,
      Value<int?> voiceDurationMs,
      required int createdAt,
      required int status,
      Value<String?> replyToId,
      Value<String?> replyText,
      Value<String?> replySenderName,
      Value<int?> replyType,
      Value<bool> isForwarded,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> chatId,
      Value<String> senderId,
      Value<String> senderName,
      Value<bool> isMine,
      Value<int> type,
      Value<String?> body,
      Value<List<String>> mediaUrls,
      Value<int?> voiceDurationMs,
      Value<int> createdAt,
      Value<int> status,
      Value<String?> replyToId,
      Value<String?> replyText,
      Value<String?> replySenderName,
      Value<int?> replyType,
      Value<bool> isForwarded,
      Value<int> rowid,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMine => $composableBuilder(
    column: $table.isMine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get mediaUrls => $composableBuilder(
    column: $table.mediaUrls,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get voiceDurationMs => $composableBuilder(
    column: $table.voiceDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyToId => $composableBuilder(
    column: $table.replyToId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyText => $composableBuilder(
    column: $table.replyText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replySenderName => $composableBuilder(
    column: $table.replySenderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replyType => $composableBuilder(
    column: $table.replyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isForwarded => $composableBuilder(
    column: $table.isForwarded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMine => $composableBuilder(
    column: $table.isMine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaUrls => $composableBuilder(
    column: $table.mediaUrls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voiceDurationMs => $composableBuilder(
    column: $table.voiceDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyToId => $composableBuilder(
    column: $table.replyToId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyText => $composableBuilder(
    column: $table.replyText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replySenderName => $composableBuilder(
    column: $table.replySenderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replyType => $composableBuilder(
    column: $table.replyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isForwarded => $composableBuilder(
    column: $table.isForwarded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMine =>
      $composableBuilder(column: $table.isMine, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get mediaUrls =>
      $composableBuilder(column: $table.mediaUrls, builder: (column) => column);

  GeneratedColumn<int> get voiceDurationMs => $composableBuilder(
    column: $table.voiceDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get replyToId =>
      $composableBuilder(column: $table.replyToId, builder: (column) => column);

  GeneratedColumn<String> get replyText =>
      $composableBuilder(column: $table.replyText, builder: (column) => column);

  GeneratedColumn<String> get replySenderName => $composableBuilder(
    column: $table.replySenderName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get replyType =>
      $composableBuilder(column: $table.replyType, builder: (column) => column);

  GeneratedColumn<bool> get isForwarded => $composableBuilder(
    column: $table.isForwarded,
    builder: (column) => column,
  );
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          MessageRow,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (
            MessageRow,
            BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>,
          ),
          MessageRow,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> chatId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> senderName = const Value.absent(),
                Value<bool> isMine = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<List<String>> mediaUrls = const Value.absent(),
                Value<int?> voiceDurationMs = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> replyToId = const Value.absent(),
                Value<String?> replyText = const Value.absent(),
                Value<String?> replySenderName = const Value.absent(),
                Value<int?> replyType = const Value.absent(),
                Value<bool> isForwarded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                chatId: chatId,
                senderId: senderId,
                senderName: senderName,
                isMine: isMine,
                type: type,
                body: body,
                mediaUrls: mediaUrls,
                voiceDurationMs: voiceDurationMs,
                createdAt: createdAt,
                status: status,
                replyToId: replyToId,
                replyText: replyText,
                replySenderName: replySenderName,
                replyType: replyType,
                isForwarded: isForwarded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String chatId,
                required String senderId,
                required String senderName,
                required bool isMine,
                required int type,
                Value<String?> body = const Value.absent(),
                Value<List<String>> mediaUrls = const Value.absent(),
                Value<int?> voiceDurationMs = const Value.absent(),
                required int createdAt,
                required int status,
                Value<String?> replyToId = const Value.absent(),
                Value<String?> replyText = const Value.absent(),
                Value<String?> replySenderName = const Value.absent(),
                Value<int?> replyType = const Value.absent(),
                Value<bool> isForwarded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                chatId: chatId,
                senderId: senderId,
                senderName: senderName,
                isMine: isMine,
                type: type,
                body: body,
                mediaUrls: mediaUrls,
                voiceDurationMs: voiceDurationMs,
                createdAt: createdAt,
                status: status,
                replyToId: replyToId,
                replyText: replyText,
                replySenderName: replySenderName,
                replyType: replyType,
                isForwarded: isForwarded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessagesTable, MessageRow>(table),
                  BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      MessageRow,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (MessageRow, BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>),
      MessageRow,
      PrefetchHooks Function()
    >;
typedef $$KeyValuesTableCreateCompanionBuilder =
    KeyValuesCompanion Function({
      required String entryKey,
      required String entryValue,
      Value<int> rowid,
    });
typedef $$KeyValuesTableUpdateCompanionBuilder =
    KeyValuesCompanion Function({
      Value<String> entryKey,
      Value<String> entryValue,
      Value<int> rowid,
    });

class $$KeyValuesTableFilterComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entryKey => $composableBuilder(
    column: $table.entryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryValue => $composableBuilder(
    column: $table.entryValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KeyValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entryKey => $composableBuilder(
    column: $table.entryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryValue => $composableBuilder(
    column: $table.entryValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeyValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entryKey =>
      $composableBuilder(column: $table.entryKey, builder: (column) => column);

  GeneratedColumn<String> get entryValue => $composableBuilder(
    column: $table.entryValue,
    builder: (column) => column,
  );
}

class $$KeyValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeyValuesTable,
          KeyValueRow,
          $$KeyValuesTableFilterComposer,
          $$KeyValuesTableOrderingComposer,
          $$KeyValuesTableAnnotationComposer,
          $$KeyValuesTableCreateCompanionBuilder,
          $$KeyValuesTableUpdateCompanionBuilder,
          (
            KeyValueRow,
            BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>,
          ),
          KeyValueRow,
          PrefetchHooks Function()
        > {
  $$KeyValuesTableTableManager(_$AppDatabase db, $KeyValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entryKey = const Value.absent(),
                Value<String> entryValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion(
                entryKey: entryKey,
                entryValue: entryValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryKey,
                required String entryValue,
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion.insert(
                entryKey: entryKey,
                entryValue: entryValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KeyValuesTable, KeyValueRow>(table),
                  BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeyValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeyValuesTable,
      KeyValueRow,
      $$KeyValuesTableFilterComposer,
      $$KeyValuesTableOrderingComposer,
      $$KeyValuesTableAnnotationComposer,
      $$KeyValuesTableCreateCompanionBuilder,
      $$KeyValuesTableUpdateCompanionBuilder,
      (
        KeyValueRow,
        BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>,
      ),
      KeyValueRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatsTableTableManager get chats =>
      $$ChatsTableTableManager(_db, _db.chats);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$KeyValuesTableTableManager get keyValues =>
      $$KeyValuesTableTableManager(_db, _db.keyValues);
}
