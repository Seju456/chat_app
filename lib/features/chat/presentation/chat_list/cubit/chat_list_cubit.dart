import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/usecases/chat_usecases.dart';
import '../../load_status.dart';
import 'chat_list_state.dart';

/// Drives both the main chat list ([archived] = false) and the archive.
class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit({
    required this.archived,
    required this._watchChats,
    required this._watchArchivedSummary,
    required this._refreshChats,
    required this._togglePinChat,
    required this._setChatArchived,
    required this._markChatRead,
  }) : super(const ChatListState());

  final bool archived;
  final WatchChats _watchChats;
  final WatchArchivedSummary _watchArchivedSummary;
  final RefreshChats _refreshChats;
  final TogglePinChat _togglePinChat;
  final SetChatArchived _setChatArchived;
  final MarkChatRead _markChatRead;

  StreamSubscription<List<Chat>>? _chatsSub;
  StreamSubscription<ArchivedSummary>? _archivedSub;
  bool _syncedOnce = false;

  void start() {
    _chatsSub = _watchChats(archived: archived).listen(
      _onChats,
      onError: (_) => emit(
        state.copyWith(
          status: LoadStatus.failure,
          failure: () => const CacheFailure(),
        ),
      ),
    );
    if (!archived) {
      _archivedSub = _watchArchivedSummary().listen(
        (summary) => emit(state.copyWith(archived: summary)),
      );
      refresh();
    } else {
      // The archive is local-only; the main list keeps it in sync.
      _syncedOnce = true;
    }
  }

  void _onChats(List<Chat> chats) {
    // An empty cache before the first successful sync means "still loading"
    // (or the sync error stays visible), not "you have no chats".
    final ready = chats.isNotEmpty || _syncedOnce;
    emit(
      state.copyWith(
        chats: chats,
        status: ready ? LoadStatus.success : state.status,
        failure: ready ? () => null : null,
      ),
    );
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;
    if (state.status == LoadStatus.failure) {
      emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    }
    emit(state.copyWith(isRefreshing: true));
    final result = await _refreshChats();
    if (isClosed) return;
    result.fold(
      // refreshFailure is kept even when blocking, so the offline banner
      // still shows if cached chats arrive after the failed sync.
      (failure) => emit(
        state.chats.isEmpty
            ? state.copyWith(
                status: LoadStatus.failure,
                failure: () => failure,
                refreshFailure: () => failure,
                isRefreshing: false,
              )
            : state.copyWith(
                refreshFailure: () => failure,
                isRefreshing: false,
              ),
      ),
      (_) {
        _syncedOnce = true;
        emit(
          state.copyWith(
            status: LoadStatus.success,
            refreshFailure: () => null,
            isRefreshing: false,
          ),
        );
      },
    );
  }

  /// Returns a failure for the UI to surface (e.g. pin limit reached).
  Future<Failure?> togglePin(Chat chat) async =>
      (await _togglePinChat(chat)).failureOrNull;

  Future<Failure?> setArchived(Chat chat, {required bool archived}) async =>
      (await _setChatArchived(chat.id, archived: archived)).failureOrNull;

  Future<Failure?> markRead(Chat chat) async =>
      (await _markChatRead(chat.id)).failureOrNull;

  @override
  Future<void> close() {
    _chatsSub?.cancel();
    _archivedSub?.cancel();
    return super.close();
  }
}
