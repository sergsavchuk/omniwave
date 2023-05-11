import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';
import 'package:rxdart/transformers.dart';

part 'search_event.dart';

part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required this.musicRepository})
      : super(SearchState(query: '', results: List.empty())) {
    on<SearchQueryChanged>(
      _queryChanged,
      transformer: _restartableDebounceTime(const Duration(milliseconds: 100)),
    );
  }

  final MusicRepositoryImpl musicRepository;

  FutureOr<void> _queryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (state.query == event.query) {
      return;
    }

    emit(SearchState(query: event.query, results: state.results));

    final searchResultStream = musicRepository.search(event.query);
    final resultList = <SearchResult<Object>>[];

    await for (final result in searchResultStream) {
      resultList.add(result);
      emit(
        SearchState(
          query: event.query,
          results: List.of(resultList),
        ),
      );
    }
  }

  EventTransformer<T> _restartableDebounceTime<T>(Duration duration) {
    return (events, mapper) =>
        restartable<T>().call(events.debounceTime(duration), mapper);
  }
}
