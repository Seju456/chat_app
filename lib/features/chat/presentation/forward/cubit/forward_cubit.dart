import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/usecases/chat_usecases.dart';
import '../../../domain/usecases/message_usecases.dart';

class ForwardState extends Equatable {
  const ForwardState({
    this.chats = const [],
    this.query = '',
    this.selectedIds = const {},
    this.isSending = false,
  });

  final List<Chat> chats;
  final String query;
  final Set<String> selectedIds;
  final bool isSending;

  List<Chat> get visibleChats {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return chats;
    return chats.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  List<Chat> get selectedChats =>
      chats.where((c) => selectedIds.contains(c.id)).toList();

  ForwardState copyWith({
    List<Chat>? chats,
    String? query,
    Set<String>? selectedIds,
    bool? isSending,
  }) => ForwardState(
    chats: chats ?? this.chats,
    query: query ?? this.query,
    selectedIds: selectedIds ?? this.selectedIds,
    isSending: isSending ?? this.isSending,
  );

  @override
  List<Object?> get props => [chats, query, selectedIds, isSending];
}

class ForwardCubit extends Cubit<ForwardState> {
  ForwardCubit({
    required this.messages,
    required this._watchChats,
    required this._forwardMessages,
  }) : super(const ForwardState()) {
    _sub = _watchChats(
      archived: false,
    ).listen((chats) => emit(state.copyWith(chats: chats)));
  }

  static const maxRecipients = 5;

  final List<Message> messages;
  final WatchChats _watchChats;
  final ForwardMessages _forwardMessages;
  late final StreamSubscription<List<Chat>> _sub;

  void search(String query) => emit(state.copyWith(query: query));

  /// Returns false when the recipient limit would be exceeded.
  bool toggle(Chat chat) {
    final ids = {...state.selectedIds};
    if (!ids.remove(chat.id)) {
      if (ids.length >= maxRecipients) return false;
      ids.add(chat.id);
    }
    emit(state.copyWith(selectedIds: ids));
    return true;
  }

  Future<Failure?> send() async {
    emit(state.copyWith(isSending: true));
    final result = await _forwardMessages(messages, state.selectedIds.toList());
    if (!isClosed) emit(state.copyWith(isSending: false));
    return result.failureOrNull;
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
