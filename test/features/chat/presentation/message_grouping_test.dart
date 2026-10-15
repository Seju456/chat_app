import 'package:chat_app/features/chat/presentation/conversation/message_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers.dart';

void main() {
  final day1 = DateTime(2026, 10, 1, 10);
  final day2 = DateTime(2026, 10, 2, 9);

  test('empty list yields no items', () {
    expect(buildMessageItems(const []), isEmpty);
  });

  test('groups consecutive messages from the same sender', () {
    // Newest first.
    final items = buildMessageItems([
      msg('3', at: day1.add(const Duration(minutes: 2))),
      msg('2', at: day1.add(const Duration(minutes: 1))),
      msg('1', at: day1),
    ]);
    final messages = items.whereType<MessageItem>().toList();
    expect(messages.map((m) => m.isFirstInGroup), [false, false, true]);
    expect(messages.map((m) => m.isLastInGroup), [true, false, false]);
    expect(items.last, isA<DateSeparatorItem>());
  });

  test('breaks groups on sender change and long gaps', () {
    final items = buildMessageItems([
      msg('3', at: day1.add(const Duration(minutes: 30))),
      msg('2', at: day1.add(const Duration(minutes: 1)), sender: 'b'),
      msg('1', at: day1),
    ]).whereType<MessageItem>().toList();
    expect(items.every((m) => m.isFirstInGroup && m.isLastInGroup), isTrue);
  });

  test('inserts a date separator above the first message of each day', () {
    final items = buildMessageItems([msg('2', at: day2), msg('1', at: day1)]);
    expect(items.map((i) => i.runtimeType), [
      MessageItem,
      DateSeparatorItem,
      MessageItem,
      DateSeparatorItem,
    ]);
    expect((items[1] as DateSeparatorItem).date, day2);
  });
}
