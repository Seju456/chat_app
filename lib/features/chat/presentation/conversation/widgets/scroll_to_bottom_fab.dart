import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/unread_badge.dart';

class ScrollToBottomFab extends StatelessWidget {
  const ScrollToBottomFab({
    super.key,
    required this.visible,
    required this.unseenCount,
    required this.onPressed,
  });

  final bool visible;
  final int unseenCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return AnimatedScale(
      scale: visible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton.small(
            heroTag: null,
            tooltip: 'Scroll to latest',
            backgroundColor: colors.dateChip,
            foregroundColor: colors.secondaryText,
            elevation: 2,
            onPressed: onPressed,
            child: const Icon(Icons.keyboard_double_arrow_down_rounded),
          ),
          Positioned(
            top: -6,
            right: -4,
            child: UnreadBadge(count: unseenCount),
          ),
        ],
      ),
    );
  }
}
