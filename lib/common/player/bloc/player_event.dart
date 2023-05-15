part of 'player_bloc.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();
}

class PlayerToggleRequested extends PlayerEvent {
  @override
  List<Object?> get props => [];
}

class PlayerTrackPlayRequested extends PlayerEvent {
  const PlayerTrackPlayRequested(this.track, {this.trackCollection});

  final Track track;
  final TrackCollection? trackCollection;

  @override
  List<Object?> get props => [track, trackCollection];
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

class PlayerTrackCollectionPlayToggleRequested extends PlayerEvent {
  const PlayerTrackCollectionPlayToggleRequested(this.trackCollection);

  final TrackCollection trackCollection;

  @override
  List<Object?> get props => [trackCollection];
}
