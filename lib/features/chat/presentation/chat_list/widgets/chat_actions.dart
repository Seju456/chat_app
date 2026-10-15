import 'package:flutter/material.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/widgets/error_view.dart';
import '../../../domain/entities/chat.dart';
import '../cubit/chat_list_cubit.dart';

/// Long-press sheet with pin / archive / read actions for a chat.
Future<void> showChatActions(
  BuildContext context, {
  required Chat chat,
  required ChatListCubit cubit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      Future<void> run(Future<Failure?> Function() action) async {
        Navigator.pop(sheetContext);
        final failure = await action();
        if (failure != null && context.mounted) context.showFailure(failure);
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                chat.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (!chat.isArchived)
              ListTile(
                leading: Icon(
                  chat.isPinned
                      ? Icons.push_pin_outlined
                      : Icons.push_pin_rounded,
                ),
                title: Text(chat.isPinned ? 'Unpin chat' : 'Pin chat'),
                onTap: () => run(() => cubit.togglePin(chat)),
              ),
            ListTile(
              leading: Icon(
                chat.isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              title: Text(chat.isArchived ? 'Unarchive chat' : 'Archive chat'),
              onTap: () => run(
                () => cubit.setArchived(chat, archived: !chat.isArchived),
              ),
            ),
            if (chat.hasUnread)
              ListTile(
                leading: const Icon(Icons.mark_chat_read_outlined),
                title: const Text('Mark as read'),
                onTap: () => run(() => cubit.markRead(chat)),
              ),
          ],
        ),
      );
    },
  );
}
