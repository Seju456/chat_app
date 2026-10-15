import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../core/widgets/app_avatar.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_view.dart';
import '../../../../../core/widgets/highlighted_text.dart';
import '../../open_chat.dart';
import '../cubit/search_cubit.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({super.key, required this.onOpenChat});

  final OpenChat onOpenChat;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final results = state.results;
        if (state.status == SearchStatus.idle) {
          return const EmptyState(
            icon: Icons.search_rounded,
            title: 'Search chats and messages',
            message: 'Find people, groups and messages saved on this device.',
          );
        }
        if (state.status == SearchStatus.failure) {
          return ErrorView(
            failure: state.failure!,
            onRetry: () =>
                context.read<SearchCubit>().onQueryChanged(state.query),
          );
        }
        if (state.status == SearchStatus.done && results.isEmpty) {
          return EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No results',
            message: 'Nothing matches “${state.query.trim()}”.',
          );
        }
        final colors = context.chatColors;
        final headerStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colors.unreadBadge,
          fontWeight: FontWeight.w600,
        );
        return ListView(
          children: [
            if (state.status == SearchStatus.searching)
              const LinearProgressIndicator(minHeight: 2),
            if (results.chats.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Chats', style: headerStyle),
              ),
              for (final chat in results.chats)
                ListTile(
                  onTap: () => onOpenChat(chat),
                  leading: AppAvatar(
                    name: chat.name,
                    color: chat.avatarColor,
                    isGroup: chat.isGroup,
                    size: 44,
                  ),
                  title: HighlightedText(text: chat.name, query: state.query),
                  subtitle: chat.lastMessage == null
                      ? null
                      : Text(
                          chat.lastMessage!.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
            ],
            if (results.messages.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Messages', style: headerStyle),
              ),
              for (final hit in results.messages)
                ListTile(
                  onTap: () => onOpenChat(hit.chat, messageId: hit.message.id),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          hit.chat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormatter.chatListTime(hit.message.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  subtitle: HighlightedText(
                    text: hit.message.isMine
                        ? 'You: ${hit.message.previewText}'
                        : hit.message.previewText,
                    query: state.query,
                    maxLines: 2,
                    style: TextStyle(color: colors.secondaryText),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}
