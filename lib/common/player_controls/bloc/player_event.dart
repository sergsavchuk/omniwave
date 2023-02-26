part of 'player_bloc.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();
}

class PlayerToggleRequested extends PlayerEvent {
  @override
  List<Object?> get props => [];
}

class PlayerTrackCollectionPlayRequested extends PlayerEvent {
  const PlayerTrackCollectionPlayRequested(this.trackCollection);

  final TrackCollection trackCollection;

  @override
  List<Object?> get props => [trackCollection];
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
