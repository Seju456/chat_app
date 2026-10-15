import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/audio/voice_recorder.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/media/image_pick_error_text.dart';
import '../../../../../core/media/image_picker_service.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_avatar.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_view.dart';
import '../../../../../core/widgets/skeleton.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';
import '../../forward/pages/forward_page.dart';
import '../../gallery/pages/chat_media_page.dart';
import '../../gallery/pages/gallery_page.dart';
import '../../gallery/pages/image_send_preview_page.dart';
import '../../load_status.dart';
import '../cubit/conversation_cubit.dart';
import '../cubit/conversation_state.dart';
import '../cubit/voice_playback_cubit.dart';
import '../message_grouping.dart';
import '../widgets/date_chip.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_bar.dart';
import '../widgets/scroll_to_bottom_fab.dart';
import '../widgets/swipe_to_reply.dart';

/// A request to scroll to and highlight a message. Each tap creates a new
/// instance, so tapping the same search result twice reveals it again.
class MessageFocus {
  MessageFocus(this.messageId);
  final String messageId;
}

class ConversationPage extends StatelessWidget {
  const ConversationPage({
    super.key,
    required this.chatId,
    this.onClose,
    this.focus,
  });

  final String chatId;

  /// Message to jump to once the chat opens (e.g. from search).
  final MessageFocus? focus;

  /// Set in two-pane mode, where there is no route to pop.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ConversationCubit>(param1: chatId)..start(),
      child: _ConversationView(onClose: onClose, focus: focus),
    );
  }
}

class _ConversationView extends StatefulWidget {
  const _ConversationView({this.onClose, this.focus});
  final VoidCallback? onClose;
  final MessageFocus? focus;

  @override
  State<_ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<_ConversationView> {
  static const _loadMoreThreshold = 800.0;
  static const _fabThreshold = 400.0;

  final _scrollController = ScrollController();
  final _showFab = ValueNotifier(false);

  /// Only the message being revealed gets a GlobalKey, to find its position.
  final _revealKey = GlobalKey();
  String? _revealId;
  String? _highlightId;
  Timer? _highlightTimer;

  ConversationCubit get _cubit => context.read<ConversationCubit>();

  /// Kept as a field so it is reachable in [dispose].
  late final VoicePlaybackCubit _playback = context.read<VoicePlaybackCubit>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _playback; // Resolve while the element is active.
    if (widget.focus != null) _reveal(widget.focus!.messageId);
  }

  @override
  void didUpdateWidget(_ConversationView old) {
    super.didUpdateWidget(old);
    final focus = widget.focus;
    if (focus != null && !identical(focus, old.focus)) {
      _reveal(focus.messageId);
    }
  }

  @override
  void dispose() {
    // Leaving the chat stops its voice note.
    _playback.stop();
    _highlightTimer?.cancel();
    _scrollController.dispose();
    _showFab.dispose();
    super.dispose();
  }

  /// Loads history up to [messageId], scrolls it into view and highlights it.
  /// Bubbles have variable heights, so the list is stepped towards older
  /// messages until the target is built, then centred precisely.
  Future<void> _reveal(String messageId) async {
    final found = await _cubit.ensureLoaded(messageId);
    if (!mounted) return;
    if (!found) {
      context.showMessage('Couldn’t find that message in this chat');
      return;
    }
    setState(() => _revealId = messageId);
    await WidgetsBinding.instance.endOfFrame;

    for (var step = 0; step < 500 && mounted; step++) {
      final target = _revealKey.currentContext;
      if (target != null && target.mounted) {
        await Scrollable.ensureVisible(
          target,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
        _highlight(messageId);
        return;
      }
      if (!_scrollController.hasClients) {
        await WidgetsBinding.instance.endOfFrame;
        continue;
      }
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent) break;
      // Reversed list: larger offsets are older messages.
      _scrollController.jumpTo(
        min(
          position.pixels + position.viewportDimension * 0.8,
          position.maxScrollExtent,
        ),
      );
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  void _highlight(String messageId) {
    if (!mounted) return;
    setState(() => _highlightId = messageId);
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _highlightId = null);
    });
  }

  // The list is reversed: offset 0 is the newest message.
  void _onScroll() {
    final position = _scrollController.position;
    _cubit.setAtBottom(position.pixels < 80);
    _showFab.value = position.pixels > _fabThreshold;
    if (position.pixels > position.maxScrollExtent - _loadMoreThreshold) {
      _cubit.loadMore();
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    final distance = _scrollController.offset;
    if (distance > 4000) _scrollController.jumpTo(1500);
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handle(Future<Failure?> action, {VoidCallback? retry}) async {
    final failure = await action;
    if (failure != null && mounted) {
      context.showFailure(failure, onRetry: retry);
    }
  }

  void _sendText(String text) {
    _handle(_cubit.sendText(text));
    _scrollToBottom();
  }

  void _sendVoice(Duration duration, String filePath) {
    _handle(_cubit.sendVoice(duration, filePath));
    _scrollToBottom();
  }

  /// Gallery (multi-select) → review screen (remove, add, caption) → send.
  Future<void> _pickImages() async {
    final picker = sl<ImagePickerService>();
    final List<String> picked;
    try {
      picked = await picker.pickFromGallery();
    } catch (e) {
      if (mounted) context.showMessage(imagePickErrorText(e));
      return;
    }
    if (picked.isEmpty || !mounted) return;

    final result = await Navigator.of(context).push<ImageSendResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImageSendPreviewPage(
          initialPaths: picked,
          picker: picker,
          recipientName: _cubit.state.chat?.name,
        ),
      ),
    );
    if (result == null || !mounted) return;

    final List<String> saved;
    try {
      saved = await picker.persist(result.paths);
    } catch (e) {
      if (mounted) context.showMessage('Couldn’t attach those photos');
      return;
    }
    if (!mounted) return;
    _handle(_cubit.sendImages(saved, caption: result.caption));
    _scrollToBottom();
  }

  void _onMessageTap(ConversationState state, Message message) {
    if (state.isSelecting) {
      _cubit.toggleSelection(message);
    } else if (message.status == MessageStatus.failed) {
      _handle(_cubit.resend(message));
    }
  }

  void _openImage(Message message, int index) {
    Navigator.of(context).push(
      GalleryPage.route(
        images: [
          for (var i = 0; i < message.mediaUrls.length; i++)
            GalleryImage(
              url: message.mediaUrls[i],
              heroTag: '${message.id}-$i',
              message: message,
            ),
        ],
        initialIndex: index,
      ),
    );
  }

  Future<void> _forward(List<Message> messages) async {
    final forwarded = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ForwardPage(messages: messages)),
    );
    if (forwarded == true && mounted) {
      _cubit.clearSelection();
      context.showMessage('Message${messages.length > 1 ? 's' : ''} forwarded');
    }
  }

  void _copy(List<Message> messages) {
    final text = messages.reversed
        .where((m) => (m.text ?? '').isNotEmpty)
        .map((m) => m.text)
        .join('\n');
    Clipboard.setData(ClipboardData(text: text));
    _cubit.clearSelection();
    context.showMessage('Copied');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return BlocBuilder<ConversationCubit, ConversationState>(
      builder: (context, state) => PopScope(
        canPop: !state.isSelecting,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _cubit.clearSelection();
        },
        child: Scaffold(
          appBar: state.isSelecting
              ? _SelectionAppBar(
                  state: state,
                  onClose: _cubit.clearSelection,
                  onReply: () =>
                      _cubit.setReplyTo(state.selectedMessages.first),
                  onCopy: () => _copy(state.selectedMessages),
                  onForward: () => _forward(state.selectedMessages),
                )
              : _ChatAppBar(chat: state.chat, onClose: widget.onClose),
          body: ColoredBox(
            color: colors.chatBackground,
            child: Column(
              children: [
                if (state.isStale)
                  ErrorBanner(
                    message: 'Offline — showing saved messages',
                    onRetry: _cubit.loadMore,
                  ),
                Expanded(child: _body(state)),
                MessageInputBar(
                  replyingTo: state.replyingTo,
                  onCancelReply: _cubit.cancelReply,
                  onSendText: _sendText,
                  onSendVoice: _sendVoice,
                  recorder: sl<VoiceRecorder>(),
                  onPickImages: _pickImages,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(ConversationState state) {
    switch (state.status) {
      case LoadStatus.loading:
        return const MessageListSkeleton();
      case LoadStatus.failure:
        return ErrorView(failure: state.failure!, onRetry: _cubit.loadInitial);
      case LoadStatus.success:
        if (state.messages.isEmpty) {
          return EmptyState(
            icon: Icons.waving_hand_outlined,
            title: 'No messages yet',
            message: 'Say hello to ${state.chat?.name ?? 'start the chat'}.',
            action: FilledButton.tonal(
              onPressed: () => _sendText('Hi 👋'),
              child: const Text('Say hi 👋'),
            ),
          );
        }
    }
    final isGroup = state.chat?.isGroup ?? false;
    final showTopRow = state.hasMore || state.loadMoreFailure != null;
    return Stack(
      children: [
        Scrollbar(
          controller: _scrollController,
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            itemCount: state.items.length + (showTopRow ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.items.length) {
                return _TopLoader(
                  failure: state.loadMoreFailure,
                  onRetry: _cubit.loadMore,
                );
              }
              return switch (state.items[index]) {
                DateSeparatorItem(:final date) => DateChip(date: date),
                final MessageItem item => SwipeToReply(
                  key: item.message.id == _revealId
                      ? _revealKey
                      : ValueKey(item.message.id),
                  enabled: !state.isSelecting,
                  onReply: () => _cubit.setReplyTo(item.message),
                  child: MessageBubble(
                    item: item,
                    isGroupChat: isGroup,
                    isSelected: state.selectedIds.contains(item.message.id),
                    isHighlighted: item.message.id == _highlightId,
                    onTap: () => _onMessageTap(state, item.message),
                    onLongPress: () => _cubit.toggleSelection(item.message),
                    onOpenImage: _openImage,
                  ),
                ),
              };
            },
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: ValueListenableBuilder<bool>(
            valueListenable: _showFab,
            builder: (context, visible, _) => ScrollToBottomFab(
              visible: visible || state.unseenCount > 0,
              unseenCount: state.unseenCount,
              onPressed: _scrollToBottom,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopLoader extends StatelessWidget {
  const _TopLoader({required this.failure, required this.onRetry});

  final Failure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (failure != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ActionChip(
            avatar: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Couldn’t load older messages. Retry'),
            onPressed: onRetry,
          ),
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.chat, this.onClose});

  final Chat? chat;
  final VoidCallback? onClose;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final chat = this.chat;
    final subtitle = chat == null
        ? ''
        : chat.isGroup
        ? 'Tap here for group info'
        : chat.isOnline
        ? 'online'
        : 'last seen recently';
    return AppBar(
      titleSpacing: 0,
      leading: onClose != null
          ? IconButton(
              tooltip: 'Close chat',
              icon: const Icon(Icons.close_rounded),
              onPressed: onClose,
            )
          : null,
      title: chat == null
          ? const SizedBox.shrink()
          : Row(
              children: [
                AppAvatar(
                  name: chat.name,
                  color: chat.avatarColor,
                  isGroup: chat.isGroup,
                  size: 38,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.chatColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      actions: [
        if (chat != null)
          PopupMenuButton<String>(
            onSelected: (_) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ChatMediaPage(chatId: chat.id, chatName: chat.name),
              ),
            ),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'media', child: Text('Media')),
            ],
          ),
      ],
    );
  }
}

class _SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SelectionAppBar({
    required this.state,
    required this.onClose,
    required this.onReply,
    required this.onCopy,
    required this.onForward,
  });

  final ConversationState state;
  final VoidCallback onClose;
  final VoidCallback onReply;
  final VoidCallback onCopy;
  final VoidCallback onForward;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedMessages;
    final canCopy = selected.any((m) => (m.text ?? '').isNotEmpty);
    return AppBar(
      leading: IconButton(
        tooltip: 'Clear selection',
        icon: const Icon(Icons.close_rounded),
        onPressed: onClose,
      ),
      title: Text('${state.selectedIds.length}'),
      actions: [
        if (selected.length == 1)
          IconButton(
            tooltip: 'Reply',
            icon: const Icon(Icons.reply_rounded),
            onPressed: onReply,
          ),
        if (canCopy)
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy_rounded),
            onPressed: onCopy,
          ),
        IconButton(
          tooltip: 'Forward',
          icon: const Icon(Icons.shortcut_rounded),
          onPressed: onForward,
        ),
      ],
    );
  }
}
