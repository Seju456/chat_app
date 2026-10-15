import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../../domain/entities/search_results.dart';
import '../../../domain/usecases/chat_usecases.dart';

enum SearchStatus { idle, searching, done, failure }

class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.status = SearchStatus.idle,
    this.results = SearchResults.empty,
    this.failure,
  });

  final String query;
  final SearchStatus status;
  final SearchResults results;
  final Failure? failure;

  @override
  List<Object?> get props => [query, status, results, failure];
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._searchChats) : super(const SearchState());

  final SearchChats _searchChats;
  final _debouncer = Debouncer(const Duration(milliseconds: 300));
  int _requestId = 0;

  void onQueryChanged(String query) {
    if (query.trim().isEmpty) {
      _requestId++;
      emit(const SearchState());
      return;
    }
    emit(
      SearchState(
        query: query,
        status: SearchStatus.searching,
        results: state.results,
      ),
    );
    _debouncer.run(() => _search(query));
  }

  Future<void> _search(String query) async {
    // Drop responses that arrive after a newer query was issued.
    final id = ++_requestId;
    final result = await _searchChats(query);
    if (isClosed || id != _requestId) return;
    emit(
      result.fold(
        (f) =>
            SearchState(query: query, status: SearchStatus.failure, failure: f),
        (r) => SearchState(query: query, status: SearchStatus.done, results: r),
      ),
    );
  }

  void clear() => onQueryChanged('');

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}
