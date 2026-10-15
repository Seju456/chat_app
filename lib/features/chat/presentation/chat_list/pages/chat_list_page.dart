import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../settings/presentation/theme_picker.dart';
import '../../open_chat.dart';
import '../../search/cubit/search_cubit.dart';
import '../../search/widgets/search_results_view.dart';
import '../widgets/chat_list_view.dart';
import 'archived_chats_page.dart';

/// Main chat list. Expects a [ChatListCubit] (archived = false) above it.
class ChatListPage extends StatefulWidget {
  const ChatListPage({
    super.key,
    required this.onOpenChat,
    this.selectedChatId,
  });

  final OpenChat onOpenChat;
  final String? selectedChatId;

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final _searchCubit = sl<SearchCubit>();
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _searchCubit.close();
    _searchController.dispose();
    super.dispose();
  }

  void _setSearching(bool value) {
    setState(() => _searching = value);
    if (!value) {
      _searchController.clear();
      _searchCubit.clear();
    }
  }

  void _openArchived() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArchivedChatsPage(onOpenChat: widget.onOpenChat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _setSearching(false);
      },
      child: Scaffold(
        appBar: _searching ? _searchBar() : _defaultBar(),
        body: _searching
            ? BlocProvider.value(
                value: _searchCubit,
                child: SearchResultsView(onOpenChat: widget.onOpenChat),
              )
            : ChatListView(
                onOpenChat: widget.onOpenChat,
                selectedChatId: widget.selectedChatId,
                onOpenArchived: _openArchived,
              ),
      ),
    );
  }

  PreferredSizeWidget _defaultBar() => AppBar(
    title: Text(
      'Chats',
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
    ),
    actions: [
      IconButton(
        tooltip: 'Search',
        icon: const Icon(Icons.search_rounded),
        onPressed: () => _setSearching(true),
      ),
      PopupMenuButton<String>(
        onSelected: (value) => switch (value) {
          'archived' => _openArchived(),
          'theme' => showThemePicker(context),
          _ => null,
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'archived', child: Text('Archived')),
          PopupMenuItem(value: 'theme', child: Text('Theme')),
        ],
      ),
    ],
  );

  PreferredSizeWidget _searchBar() => AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => _setSearching(false),
    ),
    title: TextField(
      controller: _searchController,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Search…',
        border: InputBorder.none,
      ),
      onChanged: _searchCubit.onQueryChanged,
    ),
    actions: [
      ValueListenableBuilder(
        valueListenable: _searchController,
        builder: (context, value, _) => value.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _searchController.clear();
                  _searchCubit.clear();
                },
              ),
      ),
    ],
  );
}
