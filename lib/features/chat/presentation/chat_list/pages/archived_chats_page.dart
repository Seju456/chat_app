import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../open_chat.dart';
import '../cubit/chat_list_cubit.dart';
import '../widgets/chat_list_view.dart';

class ArchivedChatsPage extends StatelessWidget {
  const ArchivedChatsPage({super.key, required this.onOpenChat});

  final OpenChat onOpenChat;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatListCubit>(param1: true)..start(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Archived')),
        body: ChatListView(onOpenChat: onOpenChat),
      ),
    );
  }
}
