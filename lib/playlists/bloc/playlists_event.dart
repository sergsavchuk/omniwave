part of 'playlists_bloc.dart';

abstract class PlaylistsEvent extends Equatable {
  const PlaylistsEvent();
}

class PlaylistsLoadRequested extends PlaylistsEvent {
  @override
  List<Object?> get props => [];
}
