import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_avatar.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_view.dart';
import '../../../domain/entities/message.dart';
import '../cubit/forward_cubit.dart';

/// Pick up to [ForwardCubit.maxRecipients] chats. Pops `true` on success.
class ForwardPage extends StatelessWidget {
  const ForwardPage({super.key, required this.messages});

  final List<Message> messages;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ForwardCubit>(param1: messages),
      child: const _ForwardView(),
    );
  }
}

class _ForwardView extends StatelessWidget {
  const _ForwardView();

  Future<void> _send(BuildContext context) async {
    final failure = await context.read<ForwardCubit>().send();
    if (!context.mounted) return;
    if (failure != null) {
      // Messages were still queued; failed ones can be retried from the chat.
      context.showFailure(failure);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    }
    if (context.mounted) Navigator.pop(context, failure == null);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ForwardCubit>();
    final colors = context.chatColors;
    return BlocBuilder<ForwardCubit, ForwardState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Forward to…'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                onChanged: cubit.search,
                decoration: InputDecoration(
                  hintText: 'Search chats',
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: state.visibleChats.isEmpty
            ? EmptyState(
                icon: Icons.search_off_rounded,
                title: state.query.isEmpty ? 'No chats' : 'No matching chats',
              )
            : ListView.builder(
                itemCount: state.visibleChats.length,
                itemBuilder: (context, i) {
                  final chat = state.visibleChats[i];
                  final selected = state.selectedIds.contains(chat.id);
                  return ListTile(
                    onTap: () {
                      if (!cubit.toggle(chat)) {
                        context.showMessage(
                          'You can forward to up to '
                          '${ForwardCubit.maxRecipients} chats at a time',
                        );
                      }
                    },
                    leading: AppAvatar(
                      name: chat.name,
                      color: chat.avatarColor,
                      isGroup: chat.isGroup,
                      isSelected: selected,
                      size: 44,
                    ),
                    title: Text(chat.name),
                    selected: selected,
                    selectedTileColor: colors.selectionOverlay,
                  );
                },
              ),
        bottomNavigationBar: AnimatedSize(
          duration: const Duration(milliseconds: 180),
          child: state.selectedIds.isEmpty
              ? const SizedBox(width: double.infinity)
              : Material(
                  elevation: 8,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              state.selectedChats.map((c) => c.name).join(', '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          FloatingActionButton(
                            heroTag: null,
                            tooltip: 'Send',
                            onPressed: state.isSending
                                ? null
                                : () => _send(context),
                            child: state.isSending
                                ? const SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
