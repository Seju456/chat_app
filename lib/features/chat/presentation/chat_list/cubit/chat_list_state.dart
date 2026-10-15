import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/chat.dart';
import '../../load_status.dart';

class ChatListState extends Equatable {
  const ChatListState({
    this.status = LoadStatus.loading,
    this.chats = const [],
    this.archived = const ArchivedSummary(count: 0, unreadChats: 0),
    this.failure,
    this.refreshFailure,
    this.isRefreshing = false,
  });

  final LoadStatus status;
  final List<Chat> chats;
  final ArchivedSummary archived;

  /// Blocking error: nothing cached and the network failed.
  final Failure? failure;

  /// Non-blocking error: cached data is shown, but refresh failed.
  final Failure? refreshFailure;
  final bool isRefreshing;

  ChatListState copyWith({
    LoadStatus? status,
    List<Chat>? chats,
    ArchivedSummary? archived,
    Failure? Function()? failure,
    Failure? Function()? refreshFailure,
    bool? isRefreshing,
  }) => ChatListState(
    status: status ?? this.status,
    chats: chats ?? this.chats,
    archived: archived ?? this.archived,
    failure: failure != null ? failure() : this.failure,
    refreshFailure: refreshFailure != null
        ? refreshFailure()
        : this.refreshFailure,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );

  @override
  List<Object?> get props => [
    status,
    chats,
    archived,
    failure,
    refreshFailure,
    isRefreshing,
  ];
}
