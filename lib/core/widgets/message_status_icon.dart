import 'package:flutter/material.dart';

import '../../features/chat/domain/entities/message.dart';
import '../theme/app_theme.dart';

/// Clock / single tick / double tick / blue ticks / error.
class MessageStatusIcon extends StatelessWidget {
  const MessageStatusIcon({super.key, required this.status, this.size = 16});

  final MessageStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final (icon, color) = switch (status) {
      MessageStatus.sending => (Icons.schedule_rounded, colors.secondaryText),
      MessageStatus.sent => (Icons.done_rounded, colors.secondaryText),
      MessageStatus.delivered => (Icons.done_all_rounded, colors.secondaryText),
      MessageStatus.read => (Icons.done_all_rounded, colors.readTick),
      MessageStatus.failed => (
        Icons.error_outline_rounded,
        Theme.of(context).colorScheme.error,
      ),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        icon,
        key: ValueKey(status),
        size: size,
        color: color,
        semanticLabel: status.name,
      ),
    );
  }
}
