part of 'search_bloc.dart';

class SearchState extends Equatable {
  const SearchState({required this.query, required this.results});

  final String query;

  final List<SearchResult<Object>> results;

  @override
  List<Object> get props => [query, results];
}
