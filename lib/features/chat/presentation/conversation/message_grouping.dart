import 'package:equatable/equatable.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/message.dart';

sealed class MessageListItem extends Equatable {
  const MessageListItem();
}

class DateSeparatorItem extends MessageListItem {
  const DateSeparatorItem(this.date);
  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class MessageItem extends MessageListItem {
  const MessageItem({
    required this.message,
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });

  final Message message;

  /// Oldest message of a consecutive run from the same sender:
  /// gets the bubble tail and (in groups) the sender name.
  final bool isFirstInGroup;
  final bool isLastInGroup;

  @override
  List<Object?> get props => [message, isFirstInGroup, isLastInGroup];
}

/// Turns newest-first messages into newest-first list items for a reversed
/// ListView: consecutive messages from the same sender within [groupGap]
/// are grouped, and a date separator is placed above each day.
List<MessageListItem> buildMessageItems(
  List<Message> newestFirst, {
  Duration groupGap = const Duration(minutes: 5),
}) {
  bool grouped(Message older, Message newer) =>
      older.senderId == newer.senderId &&
      DateFormatter.isSameDay(older.createdAt, newer.createdAt) &&
      newer.createdAt.difference(older.createdAt) < groupGap;

  final items = <MessageListItem>[];
  for (var i = 0; i < newestFirst.length; i++) {
    final message = newestFirst[i];
    final newer = i > 0 ? newestFirst[i - 1] : null;
    final older = i < newestFirst.length - 1 ? newestFirst[i + 1] : null;
    items.add(
      MessageItem(
        message: message,
        isFirstInGroup: older == null || !grouped(older, message),
        isLastInGroup: newer == null || !grouped(message, newer),
      ),
    );
    if (older == null ||
        !DateFormatter.isSameDay(older.createdAt, message.createdAt)) {
      items.add(DateSeparatorItem(message.createdAt));
    }
  }
  return items;
}
