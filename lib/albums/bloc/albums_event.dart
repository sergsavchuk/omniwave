part of 'albums_bloc.dart';

abstract class AlbumsEvent extends Equatable {
  const AlbumsEvent();
}

class AlbumsLoadRequested extends AlbumsEvent {
  @override
  List<Object?> get props => [];
}
