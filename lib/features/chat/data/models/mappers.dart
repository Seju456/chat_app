import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import 'chat_dto.dart';
import 'message_dto.dart';

DateTime _fromMs(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);

extension ChatRowMapper on ChatRow {
  Chat toEntity() => Chat(
    id: id,
    name: name,
    avatarColor: avatarColor,
    isGroup: isGroup,
    isOnline: isOnline,
    unreadCount: unreadCount,
    pinnedAt: pinnedAt == null ? null : _fromMs(pinnedAt!),
    isArchived: isArchived,
    lastMessage: lastMessageId == null || lastMessageAt == null
        ? null
        : LastMessage(
            id: lastMessageId!,
            text: lastMessageText ?? '',
            type: MessageType.values[lastMessageType ?? 0],
            sentAt: _fromMs(lastMessageAt!),
            isMine: lastMessageIsMine,
            status: lastMessageStatus == null
                ? null
                : MessageStatus.values[lastMessageStatus!],
            senderName: lastMessageSender,
          ),
  );
}

extension ChatDtoMapper on ChatDto {
  ChatsCompanion toCompanion() =>
      ChatsCompanion.insert(
        id: id,
        name: name,
        avatarColor: avatarColor,
        isGroup: Value(isGroup),
        isOnline: Value(isOnline),
        unreadCount: Value(unreadCount),
      ).copyWith(
        lastMessageId: Value(lastMessage?.id),
        lastMessageText: Value(lastMessage?.previewText),
        lastMessageType: Value(lastMessage?.type),
        lastMessageAt: Value(lastMessage?.createdAt),
        lastMessageIsMine: Value(lastMessage?.senderId == Message.myUserId),
        lastMessageStatus: Value(lastMessage?.status),
        lastMessageSender: Value(lastMessage?.senderName),
      );
}

extension MessageDtoMapper on MessageDto {
  String get previewText => Message.previewFor(MessageType.values[type], text);

  Message toEntity() => Message(
    id: id,
    chatId: chatId,
    senderId: senderId,
    senderName: senderName,
    isMine: senderId == Message.myUserId,
    type: MessageType.values[type],
    text: text,
    mediaUrls: mediaUrls,
    voiceDuration: voiceDurationMs == null
        ? null
        : Duration(milliseconds: voiceDurationMs!),
    createdAt: _fromMs(createdAt),
    status: MessageStatus.values[status],
    isForwarded: isForwarded,
    replyTo: replyToId == null
        ? null
        : ReplyInfo(
            messageId: replyToId!,
            senderName: replySenderName ?? '',
            type: MessageType.values[replyType ?? 0],
            text: replyText,
          ),
  );
}

extension MessageRowMapper on MessageRow {
  Message toEntity() => Message(
    id: id,
    chatId: chatId,
    senderId: senderId,
    senderName: senderName,
    isMine: isMine,
    type: MessageType.values[type],
    text: body,
    mediaUrls: mediaUrls,
    voiceDuration: voiceDurationMs == null
        ? null
        : Duration(milliseconds: voiceDurationMs!),
    createdAt: _fromMs(createdAt),
    status: MessageStatus.values[status],
    isForwarded: isForwarded,
    replyTo: replyToId == null
        ? null
        : ReplyInfo(
            messageId: replyToId!,
            senderName: replySenderName ?? '',
            type: MessageType.values[replyType ?? 0],
            text: replyText,
          ),
  );
}

extension MessageEntityMapper on Message {
  MessagesCompanion toCompanion() => MessagesCompanion.insert(
    id: id,
    chatId: chatId,
    senderId: senderId,
    senderName: senderName,
    isMine: isMine,
    type: type.index,
    body: Value(text),
    mediaUrls: Value(mediaUrls),
    voiceDurationMs: Value(voiceDuration?.inMilliseconds),
    createdAt: createdAt.millisecondsSinceEpoch,
    status: status.index,
    replyToId: Value(replyTo?.messageId),
    replyText: Value(replyTo?.text),
    replySenderName: Value(replyTo?.senderName),
    replyType: Value(replyTo?.type.index),
    isForwarded: Value(isForwarded),
  );

  MessageDto toDto() => MessageDto(
    id: id,
    chatId: chatId,
    senderId: senderId,
    senderName: senderName,
    type: type.index,
    createdAt: createdAt.millisecondsSinceEpoch,
    status: status.index,
    text: text,
    mediaUrls: mediaUrls,
    voiceDurationMs: voiceDuration?.inMilliseconds,
    replyToId: replyTo?.messageId,
    replyText: replyTo?.text,
    replySenderName: replyTo?.senderName,
    replyType: replyTo?.type.index,
    isForwarded: isForwarded,
  );
}
