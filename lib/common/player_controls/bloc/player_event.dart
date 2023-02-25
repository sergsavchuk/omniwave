part of 'player_bloc.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();
}

class PlayerToggleRequested extends PlayerEvent {
  @override
  List<Object?> get props => [];
}

class PlayerAlbumPlayRequested extends PlayerEvent {
  const PlayerAlbumPlayRequested(this.album);

  final Album album;

  @override
  List<Object?> get props => [album];
}

class PlayerPlaybackPositionChanged extends PlayerEvent {
  const PlayerPlaybackPositionChanged(this.position);

  final Duration position;

  @override
  List<Object?> get props => [position];
}

class PlayerNextTrackRequested extends PlayerEvent {
  @override
  List<Object?> get props => [];
}

class PlayerPrevTrackRequested extends PlayerEvent {
  @override
  List<Object?> get props => [];
}
