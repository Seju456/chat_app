import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/usecases/chat_usecases.dart';
import '../../../domain/usecases/message_usecases.dart';
import '../../load_status.dart';
import '../message_grouping.dart';
import 'conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  ConversationCubit({
    required this.chatId,
    required this._watchChat,
    required this._getMessages,
    required this._watchMessageChanges,
    required this._sendMessage,
    required this._resendMessage,
    required this._markChatRead,
    required this._setActiveChat,
  }) : super(const ConversationState());

  final String chatId;
  final WatchChat _watchChat;
  final GetMessages _getMessages;
  final WatchMessageChanges _watchMessageChanges;
  final SendMessage _sendMessage;
  final ResendMessage _resendMessage;
  final MarkChatRead _markChatRead;
  final SetActiveChat _setActiveChat;

  StreamSubscription<Chat?>? _chatSub;
  StreamSubscription<Message>? _changesSub;
  bool _atBottom = true;
  Future<void> _initialLoad = Future.value();
  Future<void>? _pendingLoadMore;

  /// Upper bound on pages fetched while searching for a message.
  static const _maxRevealPages = 200;

  void start() {
    _setActiveChat(chatId, active: true);
    _markChatRead(chatId);
    _chatSub = _watchChat(chatId).listen((chat) {
      if (chat != null) emit(state.copyWith(chat: chat));
    });
    _changesSub = _watchMessageChanges(chatId).listen(_onMessageChanged);
    _initialLoad = loadInitial();
  }

  Future<void> loadInitial() async {
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    final result = await _getMessages(chatId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: LoadStatus.failure, failure: () => failure),
      ),
      (page) => emit(
        _withMessages(
          _merge(state.messages, page.messages),
          status: LoadStatus.success,
          hasMore: page.hasMore,
          isStale: page.isStale,
        ),
      ),
    );
  }

  /// Concurrent callers (scroll listener, [ensureLoaded]) share one request.
  Future<void> loadMore() => _pendingLoadMore ??= _loadMore().whenComplete(
    () => _pendingLoadMore = null,
  );

  /// Pages back through history until [messageId] is loaded (e.g. when
  /// opening a search result). Returns false if it cannot be reached.
  Future<bool> ensureLoaded(String messageId) async {
    await _initialLoad;
    for (var page = 0; page < _maxRevealPages; page++) {
      if (isClosed) return false;
      if (state.messages.any((m) => m.id == messageId)) return true;
      if (state.status != LoadStatus.success || !state.hasMore) return false;
      await loadMore();
      if (state.loadMoreFailure != null) return false;
    }
    return false;
  }

  Future<void> _loadMore() async {
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.status != LoadStatus.success ||
        state.messages.isEmpty) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true, loadMoreFailure: () => null));
    final result = await _getMessages(chatId, before: state.messages.last);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingMore: false, loadMoreFailure: () => failure),
      ),
      (page) => emit(
        _withMessages(
          _merge(state.messages, page.messages),
          isLoadingMore: false,
          hasMore: page.hasMore,
          isStale: page.isStale,
        ),
      ),
    );
  }

  Future<Failure?> sendText(String text) => _send(
    OutgoingMessage(
      chatId: chatId,
      type: MessageType.text,
      text: text,
      replyTo: state.replyingTo?.toReplyInfo(),
    ),
  );

  /// [filePath] is the recorded audio; it travels in `mediaUrls`.
  Future<Failure?> sendVoice(Duration duration, String filePath) => _send(
    OutgoingMessage(
      chatId: chatId,
      type: MessageType.voice,
      voiceDuration: duration,
      mediaUrls: [filePath],
      replyTo: state.replyingTo?.toReplyInfo(),
    ),
  );

  Future<Failure?> sendImages(List<String> urls, {String? caption}) => _send(
    OutgoingMessage(
      chatId: chatId,
      type: MessageType.image,
      mediaUrls: urls,
      text: caption,
      replyTo: state.replyingTo?.toReplyInfo(),
    ),
  );

  Future<Failure?> _send(OutgoingMessage message) async {
    final result = await _sendMessage(message);
    if (isClosed) return null;
    // Only validation errors keep the reply draft; network failures leave
    // a "failed" bubble the user can tap to retry.
    if (result.failureOrNull is! ValidationFailure) {
      emit(state.copyWith(replyingTo: () => null));
    }
    return result.failureOrNull;
  }

  Future<Failure?> resend(Message message) async =>
      (await _resendMessage(message)).failureOrNull;

  void setReplyTo(Message message) =>
      emit(state.copyWith(replyingTo: () => message, selectedIds: const {}));

  void cancelReply() => emit(state.copyWith(replyingTo: () => null));

  void toggleSelection(Message message) {
    final ids = {...state.selectedIds};
    if (!ids.remove(message.id)) ids.add(message.id);
    emit(state.copyWith(selectedIds: ids));
  }

  void clearSelection() => emit(state.copyWith(selectedIds: const {}));

  void setAtBottom(bool atBottom) {
    if (_atBottom == atBottom) return;
    _atBottom = atBottom;
    if (atBottom && state.unseenCount > 0) {
      emit(state.copyWith(unseenCount: 0));
    }
  }

  void _onMessageChanged(Message message) {
    final exists = state.messages.any((m) => m.id == message.id);
    final unseen = !exists && !message.isMine && !_atBottom
        ? state.unseenCount + 1
        : state.unseenCount;
    final messages = exists
        ? [for (final m in state.messages) m.id == message.id ? message : m]
        : _merge(state.messages, [message]);
    emit(_withMessages(messages).copyWith(unseenCount: unseen));
  }

  ConversationState _withMessages(
    List<Message> messages, {
    LoadStatus? status,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isStale,
  }) => state.copyWith(
    messages: messages,
    items: buildMessageItems(messages),
    status: status,
    hasMore: hasMore,
    isLoadingMore: isLoadingMore,
    isStale: isStale,
  );

  /// De-duplicates by id and keeps newest-first order.
  static List<Message> _merge(List<Message> current, List<Message> incoming) {
    final byId = {for (final m in current) m.id: m};
    for (final m in incoming) {
      byId[m.id] = m;
    }
    return byId.values.toList()..sort((a, b) {
      final byTime = b.createdAt.compareTo(a.createdAt);
      return byTime != 0 ? byTime : b.id.compareTo(a.id);
    });
  }

  @override
  Future<void> close() {
    _setActiveChat(chatId, active: false);
    _chatSub?.cancel();
    _changesSub?.cancel();
    return super.close();
  }
}
