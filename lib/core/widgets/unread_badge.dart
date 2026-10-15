import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Pill-shaped unread counter. A [count] of 0 renders nothing.
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: count <= 0
          ? const SizedBox.shrink()
          : Container(
              key: ValueKey(count),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: colors.unreadBadge,
                borderRadius: BorderRadius.circular(10),
              ),
              // Factors of 1 keep the badge content-sized (not full width).
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  count > 999 ? '999+' : '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF111B21)
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
    );
  }
}
