part of 'player_bloc.dart';

// ignore_for_file: use_late_for_private_fields_and_variables
class PlayerState extends Equatable {
  const PlayerState({
    this.isPlaying = false,
    this.playbackPosition = Duration.zero,
    this.currentTrack,
    this.currentAlbum,
  });

  final bool isPlaying;
  final Duration playbackPosition;

  final Track? currentTrack;
  final Album? currentAlbum;

  double get playbackProgress => currentTrack == null ||
          currentTrack?.duration == Duration.zero
      ? 0
      : playbackPosition.inMilliseconds / currentTrack!.duration.inMilliseconds;

  PlayerState copyWith({
    bool? isPlaying,
    Duration? playbackPosition,
    Track? currentTrack,
    Album? currentAlbum,
  }) =>
      PlayerState(
        isPlaying: isPlaying ?? this.isPlaying,
        playbackPosition: playbackPosition ?? this.playbackPosition,
        currentTrack: currentTrack ?? this.currentTrack,
        currentAlbum: currentAlbum ?? this.currentAlbum,
      );

  @override
  List<Object?> get props =>
      [isPlaying, currentTrack, currentAlbum, playbackPosition];
}
