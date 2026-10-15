import 'package:intl/intl.dart';

/// WhatsApp-like timestamp formatting.
abstract final class DateFormatter {
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Time shown inside a message bubble, e.g. `14:05`.
  static String time(DateTime date) => DateFormat.Hm().format(date);

  /// Time shown in the chat list: today -> time, yesterday, weekday, date.
  static String chatListTime(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    if (isSameDay(date, today)) return time(date);
    final yesterday = today.subtract(const Duration(days: 1));
    if (isSameDay(date, yesterday)) return 'Yesterday';
    if (today.difference(date).inDays < 7) {
      return DateFormat.EEEE().format(date);
    }
    return DateFormat.yMd().format(date);
  }

  /// Label for the sticky date chip between message groups.
  static String dateSeparator(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    if (isSameDay(date, today)) return 'Today';
    if (isSameDay(date, today.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    if (today.difference(date).inDays < 7) {
      return DateFormat.EEEE().format(date);
    }
    if (date.year == today.year) return DateFormat.MMMMd().format(date);
    return DateFormat.yMMMMd().format(date);
  }

  /// `m:ss` duration used by voice messages.
  static String duration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
