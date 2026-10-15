import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_view.dart';
import '../../../../../core/widgets/skeleton.dart';
import '../../../../../core/widgets/unread_badge.dart';
import '../../../domain/entities/chat.dart';
import '../../load_status.dart';
import '../../open_chat.dart';
import '../cubit/chat_list_cubit.dart';
import '../cubit/chat_list_state.dart';
import 'chat_actions.dart';
import 'chat_tile.dart';

/// Shared list body for the main chat list and the archive.
class ChatListView extends StatelessWidget {
  const ChatListView({
    super.key,
    required this.onOpenChat,
    this.selectedChatId,
    this.onOpenArchived,
  });

  final OpenChat onOpenChat;
  final String? selectedChatId;
  final VoidCallback? onOpenArchived;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatListCubit>();
    return BlocBuilder<ChatListCubit, ChatListState>(
      builder: (context, state) => switch (state.status) {
        LoadStatus.loading => const ChatListSkeleton(),
        LoadStatus.failure => ErrorView(
          failure: state.failure!,
          onRetry: cubit.refresh,
        ),
        LoadStatus.success => RefreshIndicator(
          onRefresh: cubit.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (state.refreshFailure != null)
                SliverToBoxAdapter(
                  child: ErrorBanner(
                    message: 'Offline — showing saved chats',
                    onRetry: cubit.refresh,
                  ),
                ),
              if (onOpenArchived != null && state.archived.count > 0)
                SliverToBoxAdapter(
                  child: _ArchivedRow(
                    count: state.archived.count,
                    unreadChats: state.archived.unreadChats,
                    onTap: onOpenArchived!,
                  ),
                ),
              if (state.chats.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: cubit.archived
                      ? const EmptyState(
                          icon: Icons.archive_outlined,
                          title: 'No archived chats',
                          message:
                              'Long-press or swipe a chat to archive it. '
                              'Archived chats stay here until you unarchive '
                              'them.',
                        )
                      : const EmptyState(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'No chats yet',
                          message:
                              'Start a conversation and it will '
                              'show up here.',
                        ),
                )
              else
                SliverList.builder(
                  itemCount: state.chats.length,
                  itemBuilder: (context, index) {
                    final chat = state.chats[index];
                    return _DismissibleChat(
                      key: ValueKey(chat.id),
                      chat: chat,
                      cubit: cubit,
                      child: ChatTile(
                        chat: chat,
                        isSelected: chat.id == selectedChatId,
                        onTap: () => onOpenChat(chat),
                        onLongPress: () =>
                            showChatActions(context, chat: chat, cubit: cubit),
                      ),
                    );
                  },
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
        ),
      },
    );
  }
}

/// Swipe left to archive / unarchive, with undo.
class _DismissibleChat extends StatelessWidget {
  const _DismissibleChat({
    super.key,
    required this.chat,
    required this.cubit,
    required this.child,
  });

  final Chat chat;
  final ChatListCubit cubit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final archive = !chat.isArchived;
    return Dismissible(
      key: ValueKey('dismiss-${chat.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              archive ? Icons.archive_rounded : Icons.unarchive_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              archive ? 'Archive' : 'Unarchive',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        final failure = await cubit.setArchived(chat, archived: archive);
        if (!context.mounted) return false;
        if (failure != null) {
          context.showFailure(failure);
          return false;
        }
        context.showMessage(
          archive ? 'Chat archived' : 'Chat unarchived',
          actionLabel: 'Undo',
          onAction: () => cubit.setArchived(chat, archived: !archive),
        );
        // The stream removes the row; returning false avoids a double remove.
        return false;
      },
      child: child,
    );
  }
}

class _ArchivedRow extends StatelessWidget {
  const _ArchivedRow({
    required this.count,
    required this.unreadChats,
    required this.onTap,
  });

  final int count;
  final int unreadChats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 28),
      leading: Icon(Icons.archive_outlined, color: colors.unreadBadge),
      title: const Text(
        'Archived',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: unreadChats > 0
          ? UnreadBadge(count: unreadChats)
          : Text('$count', style: TextStyle(color: colors.unreadBadge)),
    );
  }
}
