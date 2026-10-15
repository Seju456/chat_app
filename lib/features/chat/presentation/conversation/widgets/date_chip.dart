import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_formatter.dart';

class DateChip extends StatelessWidget {
  const DateChip({super.key, required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: colors.dateChip,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          DateFormatter.dateSeparator(date),
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }
}
