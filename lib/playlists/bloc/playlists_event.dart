part of 'playlists_bloc.dart';

abstract class PlaylistsEvent extends Equatable {
  const PlaylistsEvent();
}

class PlaylistsPageLoadRequested extends PlaylistsEvent {
  const PlaylistsPageLoadRequested(this.offset);

  final int offset;

  @override
  List<Object?> get props => [offset];
}
