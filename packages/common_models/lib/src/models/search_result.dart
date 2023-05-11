import 'package:equatable/equatable.dart';

class SearchResult<T> extends Equatable {
  const SearchResult(this._result);

  final T _result;

  T get result => _result;

  @override
  List<Object?> get props => [result];
}
