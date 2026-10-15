import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/widgets/empty_state.dart';
import '../chat/domain/entities/chat.dart';
import '../chat/presentation/chat_list/cubit/chat_list_cubit.dart';
import '../chat/presentation/chat_list/pages/chat_list_page.dart';
import '../chat/presentation/conversation/pages/conversation_page.dart';

/// Responsive shell: a single stack on phones, master/detail on wide screens.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedChatId;
  MessageFocus? _focus;

  void _openChat(Chat chat, {required bool wide, String? messageId}) {
    final focus = messageId == null ? null : MessageFocus(messageId);
    if (wide) {
      // Close pushed routes (e.g. archive) and show the chat in the pane.
      Navigator.of(context).popUntil((route) => route.isFirst);
      setState(() {
        _selectedChatId = chat.id;
        _focus = focus;
      });
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ConversationPage(chatId: chat.id, focus: focus),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatListCubit>(param1: false)..start(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= Breakpoints.twoPane;
          final list = ChatListPage(
            selectedChatId: wide ? _selectedChatId : null,
            onOpenChat: (chat, {messageId}) =>
                _openChat(chat, wide: wide, messageId: messageId),
          );
          if (!wide) return list;
          return Row(
            children: [
              SizedBox(
                width: (constraints.maxWidth * 0.35).clamp(340, 440),
                child: list,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _selectedChatId == null
                    ? const _NoChatSelected()
                    : ConversationPage(
                        key: ValueKey(_selectedChatId),
                        chatId: _selectedChatId!,
                        focus: _focus,
                        onClose: () => setState(() => _selectedChatId = null),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NoChatSelected extends StatelessWidget {
  const _NoChatSelected();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.chatColors.chatBackground,
      child: const EmptyState(
        icon: Icons.forum_outlined,
        title: 'Select a chat',
        message: 'Pick a conversation from the list to start messaging.',
      ),
    );
  }
}
