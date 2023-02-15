part of 'albums_bloc.dart';

abstract class AlbumsEvent extends Equatable {
  const AlbumsEvent();
}

class AlbumsStarted extends AlbumsEvent {
  @override
  List<Object?> get props => [];
}
