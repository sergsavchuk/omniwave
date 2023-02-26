part of 'playlists_bloc.dart';

class PlaylistsState extends Equatable {
  const PlaylistsState({this.playlists = const []});

  final List<Playlist> playlists;

  @override
  List<Object> get props => [playlists];
}
