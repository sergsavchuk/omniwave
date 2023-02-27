part of 'albums_bloc.dart';

abstract class AlbumsEvent extends Equatable {
  const AlbumsEvent();
}

class AlbumsPageLoadRequested extends AlbumsEvent {
  const AlbumsPageLoadRequested(this.offset);

  final int offset;

  @override
  List<Object?> get props => [offset];
}
