import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../core/widgets/app_avatar.dart';
import '../../../../../core/widgets/message_status_icon.dart';
import '../../../../../core/widgets/unread_badge.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.chatColors;
    final last = chat.lastMessage;
    return Material(
      color: isSelected ? colors.selectionOverlay : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              AppAvatar(
                name: chat.name,
                color: chat.avatarColor,
                isGroup: chat.isGroup,
                isOnline: chat.isOnline,
                size: 50,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.5,
                            ),
                          ),
                        ),
                        if (last != null)
                          Text(
                            DateFormatter.chatListTime(last.sentAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: chat.hasUnread
                                  ? colors.unreadBadge
                                  : colors.secondaryText,
                              fontWeight: chat.hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(child: _Preview(chat: chat)),
                        if (chat.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.push_pin_rounded,
                              size: 18,
                              color: colors.secondaryText,
                            ),
                          ),
                        if (chat.hasUnread) ...[
                          const SizedBox(width: 6),
                          UnreadBadge(count: chat.unreadCount),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.chat});
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: colors.secondaryText);
    final last = chat.lastMessage;
    if (last == null) {
      return Text('Tap to start chatting', style: style, maxLines: 1);
    }
    final typeIcon = switch (last.type) {
      MessageType.image => Icons.photo_rounded,
      MessageType.voice => Icons.mic_rounded,
      MessageType.text => null,
    };
    final prefix = chat.isGroup && !last.isMine && last.senderName != null
        ? '${last.senderName!.split(' ').first}: '
        : '';
    return Row(
      children: [
        if (last.isMine && last.status != null) ...[
          MessageStatusIcon(status: last.status!, size: 17),
          const SizedBox(width: 3),
        ],
        if (typeIcon != null) ...[
          Icon(typeIcon, size: 17, color: colors.secondaryText),
          const SizedBox(width: 3),
        ],
        Expanded(
          child: Text(
            '$prefix${last.text}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}
