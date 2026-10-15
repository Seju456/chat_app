import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';
import '../../load_status.dart';
import '../message_grouping.dart';

class ConversationState extends Equatable {
  const ConversationState({
    this.status = LoadStatus.loading,
    this.chat,
    this.messages = const [],
    this.items = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.failure,
    this.loadMoreFailure,
    this.isStale = false,
    this.replyingTo,
    this.selectedIds = const {},
    this.unseenCount = 0,
  });

  final LoadStatus status;
  final Chat? chat;

  /// Newest first.
  final List<Message> messages;

  /// [messages] grouped with date separators, ready to render.
  final List<MessageListItem> items;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? failure;
  final Failure? loadMoreFailure;

  /// Showing cached messages because the network is unavailable.
  final bool isStale;
  final Message? replyingTo;
  final Set<String> selectedIds;

  /// Messages received while the user was scrolled away from the bottom.
  final int unseenCount;

  bool get isSelecting => selectedIds.isNotEmpty;

  List<Message> get selectedMessages =>
      messages.where((m) => selectedIds.contains(m.id)).toList();

  ConversationState copyWith({
    LoadStatus? status,
    Chat? chat,
    List<Message>? messages,
    List<MessageListItem>? items,
    bool? hasMore,
    bool? isLoadingMore,
    Failure? Function()? failure,
    Failure? Function()? loadMoreFailure,
    bool? isStale,
    Message? Function()? replyingTo,
    Set<String>? selectedIds,
    int? unseenCount,
  }) => ConversationState(
    status: status ?? this.status,
    chat: chat ?? this.chat,
    messages: messages ?? this.messages,
    items: items ?? this.items,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    failure: failure != null ? failure() : this.failure,
    loadMoreFailure: loadMoreFailure != null
        ? loadMoreFailure()
        : this.loadMoreFailure,
    isStale: isStale ?? this.isStale,
    replyingTo: replyingTo != null ? replyingTo() : this.replyingTo,
    selectedIds: selectedIds ?? this.selectedIds,
    unseenCount: unseenCount ?? this.unseenCount,
  );

  @override
  List<Object?> get props => [
    status,
    chat,
    messages,
    items,
    hasMore,
    isLoadingMore,
    failure,
    loadMoreFailure,
    isStale,
    replyingTo,
    selectedIds,
    unseenCount,
  ];
}
