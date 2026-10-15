import 'dart:async';

import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/utils/result.dart';
import 'package:chat_app/features/chat/domain/entities/chat.dart';
import 'package:chat_app/features/chat/domain/entities/search_results.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_app/features/chat/domain/usecases/chat_usecases.dart';
import 'package:chat_app/features/chat/presentation/chat_list/cubit/chat_list_cubit.dart';
import 'package:chat_app/features/chat/presentation/load_status.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeChatRepository implements ChatRepository {
  final chats = StreamController<List<Chat>>.broadcast();
  Result<void> refreshResult = const Success(null);
  int pinned = 0;

  @override
  Stream<List<Chat>> watchChats({required bool archived}) => chats.stream;

  @override
  Stream<ArchivedSummary> watchArchivedSummary() =>
      Stream.value(const ArchivedSummary(count: 0, unreadChats: 0));

  @override
  Future<Result<void>> refreshChats() async => refreshResult;

  @override
  Future<int> pinnedChatCount() async => pinned;

  @override
  Future<Result<void>> setPinned(String chatId, {required bool pinned}) async =>
      const Success(null);

  @override
  Stream<Chat?> watchChat(String chatId) => const Stream.empty();

  @override
  Future<Result<void>> setArchived(
    String chatId, {
    required bool archived,
  }) async => const Success(null);

  @override
  Future<Result<void>> markRead(String chatId) async => const Success(null);

  @override
  Future<Result<SearchResults>> search(String query) async =>
      const Success(SearchResults.empty);
}

void main() {
  late _FakeChatRepository repo;

  ChatListCubit build() => ChatListCubit(
    archived: false,
    watchChats: WatchChats(repo),
    watchArchivedSummary: WatchArchivedSummary(repo),
    refreshChats: RefreshChats(repo),
    togglePinChat: TogglePinChat(repo),
    setChatArchived: SetChatArchived(repo),
    markChatRead: MarkChatRead(repo),
  );

  const chat = Chat(id: '1', name: 'Ana', avatarColor: 0);

  setUp(() => repo = _FakeChatRepository());

  test('empty cache + network error -> blocking failure', () async {
    repo.refreshResult = const Err(NetworkFailure());
    final cubit = build()..start();
    repo.chats.add(const []);
    await pumpEventQueue();
    expect(cubit.state.status, LoadStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
    await cubit.close();
  });

  test(
    'cached chats + network error -> data with non-blocking banner',
    () async {
      repo.refreshResult = const Err(NetworkFailure());
      final cubit = build()..start();
      repo.chats.add(const [chat]);
      await pumpEventQueue();
      expect(cubit.state.status, LoadStatus.success);
      expect(cubit.state.chats, [chat]);
      expect(cubit.state.refreshFailure, isA<NetworkFailure>());
      await cubit.close();
    },
  );

  test('empty cache + successful sync -> empty state, not a spinner', () async {
    final cubit = build()..start();
    await pumpEventQueue();
    repo.chats.add(const []);
    await pumpEventQueue();
    expect(cubit.state.status, LoadStatus.success);
    expect(cubit.state.chats, isEmpty);
    await cubit.close();
  });

  test('pinning beyond the limit returns a ValidationFailure', () async {
    repo.pinned = Chat.maxPinned;
    final cubit = build();
    expect(await cubit.togglePin(chat), isA<ValidationFailure>());
    await cubit.close();
  });
}
