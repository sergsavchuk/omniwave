part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {}

class SearchQueryChanged extends SearchEvent {
  SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
