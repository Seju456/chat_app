import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../core/widgets/message_status_icon.dart';
import '../../../domain/entities/message.dart';
import '../message_grouping.dart';
import 'image_grid.dart';
import 'reply_preview.dart';
import 'sender_color.dart';
import 'voice_message_player.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.item,
    required this.isGroupChat,
    required this.isSelected,
    this.isHighlighted = false,
    required this.onTap,
    required this.onLongPress,
    required this.onOpenImage,
  });

  final MessageItem item;
  final bool isGroupChat;
  final bool isSelected;

  /// Briefly true after jumping to this message (e.g. from search).
  final bool isHighlighted;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final void Function(Message message, int index) onOpenImage;

  Message get message => item.message;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final mine = message.isMine;
    final maxWidth = min(MediaQuery.sizeOf(context).width * 0.78, 520.0);
    const r = Radius.circular(10);
    const tail = Radius.circular(2);
    final radius = BorderRadius.only(
      topLeft: !mine && item.isFirstInGroup ? tail : r,
      topRight: mine && item.isFirstInGroup ? tail : r,
      bottomLeft: r,
      bottomRight: r,
    );
    final showSender = isGroupChat && !mine && item.isFirstInGroup;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        // Slow fade so the search highlight eases out.
        duration: Duration(milliseconds: isSelected ? 150 : 700),
        color: isSelected
            ? colors.selectionOverlay
            : isHighlighted
            ? colors.highlight
            : Colors.transparent,
        padding: EdgeInsets.only(
          top: item.isFirstInGroup ? 6 : 1.5,
          bottom: 1.5,
          left: 12,
          right: 12,
        ),
        child: Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Semantics(
              label:
                  '${mine ? 'You' : message.senderName}: '
                  '${message.previewText}',
              child: Container(
                decoration: BoxDecoration(
                  color: mine ? colors.outgoingBubble : colors.incomingBubble,
                  borderRadius: radius,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                // Size the bubble to its widest child (quote or text, capped
                // by maxWidth) and stretch the rest to match, so a reply
                // bubble hugs its content and time/ticks sit at the end.
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showSender)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                          child: Text(
                            message.senderName,
                            style: TextStyle(
                              color: senderColor(message.senderName),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      if (message.isForwarded) const _ForwardedLabel(),
                      if (message.replyTo != null)
                        ReplyPreview(reply: message.replyTo!, isMine: mine),
                      _content(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
          child: _TextWithMeta(message: message),
        );
      case MessageType.image:
        final caption = message.text;
        final hasCaption = caption != null && caption.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ImageGrid(
                  urls: message.mediaUrls,
                  heroPrefix: message.id,
                  onOpen: (i) => onOpenImage(message, i),
                ),
                if (!hasCaption)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _Meta(message: message, onImage: true),
                    ),
                  ),
              ],
            ),
            if (hasCaption)
              SizedBox(
                width: ImageGrid.width,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                  child: _TextWithMeta(message: message),
                ),
              ),
          ],
        );
      case MessageType.voice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            VoiceMessagePlayer(message: message),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _Meta(message: message),
            ),
          ],
        );
    }
  }
}

/// Text that reserves room on its last line for the time/ticks, so short
/// messages stay on one line like WhatsApp.
class _TextWithMeta extends StatelessWidget {
  const _TextWithMeta({required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontSize: 15.5, height: 1.3);
    final metaWidth = message.isMine ? 66.0 : 44.0;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text.rich(
            TextSpan(
              text: message.text ?? '',
              style: style,
              children: [
                WidgetSpan(child: SizedBox(width: metaWidth, height: 12)),
              ],
            ),
          ),
        ),
        Positioned(right: 0, bottom: 0, child: _Meta(message: message)),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.message, this.onImage = false});
  final Message message;
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final color = onImage ? Colors.white : colors.secondaryText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormatter.time(message.createdAt),
          style: TextStyle(fontSize: 11, color: color),
        ),
        if (message.isMine) ...[
          const SizedBox(width: 3),
          MessageStatusIcon(status: message.status),
        ],
      ],
    );
  }
}

class _ForwardedLabel extends StatelessWidget {
  const _ForwardedLabel();

  @override
  Widget build(BuildContext context) {
    final color = context.chatColors.secondaryText;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shortcut_rounded, size: 15, color: color),
          const SizedBox(width: 3),
          Text(
            'Forwarded',
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
