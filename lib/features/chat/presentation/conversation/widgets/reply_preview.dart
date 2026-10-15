import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/message.dart';
import 'sender_color.dart';

/// Quoted message: used inside bubbles and above the composer.
class ReplyPreview extends StatelessWidget {
  const ReplyPreview({
    super.key,
    required this.reply,
    this.onClose,
    this.isInBubble = true,
    this.isMine = false,
  });

  final ReplyInfo reply;
  final VoidCallback? onClose;
  final bool isInBubble;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final accent = reply.senderName == 'You'
        ? Theme.of(context).colorScheme.primary
        : senderColor(reply.senderName);
    final background = Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.22)
        : Colors.black.withValues(alpha: 0.05);
    final icon = switch (reply.type) {
      MessageType.image => Icons.photo_rounded,
      MessageType.voice => Icons.mic_rounded,
      MessageType.text => null,
    };
    return Container(
      margin: isInBubble ? const EdgeInsets.only(bottom: 4) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reply.senderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 15, color: colors.secondaryText),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            reply.previewText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.secondaryText,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (onClose != null)
              IconButton(
                tooltip: 'Cancel reply',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: onClose,
              ),
          ],
        ),
      ),
    );
  }
}
