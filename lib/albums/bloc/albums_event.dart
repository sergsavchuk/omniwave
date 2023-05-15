part of 'albums_bloc.dart';

abstract class AlbumsEvent extends Equatable {
  const AlbumsEvent();
}

class AlbumsInitialLoadRequested extends AlbumsEvent {
  const AlbumsInitialLoadRequested();

  @override
  List<Object?> get props => [];
}

class AlbumsListChanged extends AlbumsEvent {
  const AlbumsListChanged(this.albums);

  final List<Album> albums;

  @override
  List<Object?> get props => [albums];
}
