part of 'playlists_bloc.dart';

class PlaylistsState extends Equatable {
  const PlaylistsState({
    this.playlists = const [],
    this.loadingNextPage = false,
  });

  final List<Playlist> playlists;
  final bool loadingNextPage;

  @override
  List<Object> get props => [playlists, loadingNextPage];
}
