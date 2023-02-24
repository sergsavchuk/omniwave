import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/scheduler.dart';
import 'package:music_repository/music_repository.dart';

part 'player_event.dart';

part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({required MusicRepository musicRepository})
      : _musicRepository = musicRepository,
        super(const PlayerState()) {
    on<PlayerToggleRequested>(_toggleRequested);
    on<PlayerAlbumPlayRequested>(_albumPlayRequested);
    on<PlayerPlaybackPositionChanged>(_playbackPositionChanged);
    on<PlayerNextTrackRequested>(_nextTrackRequested);
    on<PlayerPrevTrackRequested>(_prevTrackRequested);
  }

  final MusicRepository _musicRepository;
  Player? _player;

  FutureOr<void> _prevTrackRequested(
    PlayerPrevTrackRequested event,
    Emitter<PlayerState> emit,
  ) {
    if (state.currentAlbum == null) {
      return null;
    }

    final tracks = state.currentAlbum!.tracks;
    if (state.currentTrack != null && tracks.indexOf(state.currentTrack!) > 0) {
      final track = tracks[tracks.indexOf(state.currentTrack!) - 1];
      _play(track);
      emit(
        state.copyWith(
          isPlaying: true,
          currentTrack: track,
        ),
      );
    }
  }

  FutureOr<void> _nextTrackRequested(
    PlayerNextTrackRequested event,
    Emitter<PlayerState> emit,
  ) {
    if (state.currentAlbum == null) {
      return null;
    }

    final tracks = state.currentAlbum!.tracks;
    if (state.currentTrack != null &&
        tracks.indexOf(state.currentTrack!) < tracks.length - 1) {
      final track = tracks[tracks.indexOf(state.currentTrack!) + 1];
      _play(track);
      emit(
        state.copyWith(
          isPlaying: true,
          playbackPosition: Duration.zero,
          currentTrack: track,
        ),
      );
    }
  }

  FutureOr<void> _playbackPositionChanged(
    PlayerPlaybackPositionChanged event,
    Emitter<PlayerState> emit,
  ) {
    if (event.position != state.playbackPosition) {
      emit(state.copyWith(playbackPosition: event.position));
    }
  }

  FutureOr<void> _albumPlayRequested(
    PlayerAlbumPlayRequested event,
    Emitter<PlayerState> emit,
  ) {
    if (event.album != state.currentAlbum && event.album.tracks.isNotEmpty) {
      _play(event.album.tracks[0]);
      emit(
        PlayerState(
          isPlaying: true,
          currentTrack: event.album.tracks[0],
          currentAlbum: event.album,
        ),
      );
    }
  }

  FutureOr<void> _toggleRequested(
    PlayerToggleRequested event,
    Emitter<PlayerState> emit,
  ) {
    if (state.currentTrack == null) {
      return null;
    }

    if (state.isPlaying) {
      _player?.pause();
      emit(state.copyWith(isPlaying: false));
    } else {
      _player?.resume();
      emit(state.copyWith(isPlaying: true));
    }
  }

  void _play(Track track) {
    if (track.source == MusicSource.spotify) {
      _player ??= SpotifyPlayer(
        _musicRepository,
        onTrackPlayed: () => add(PlayerNextTrackRequested()),
        onPlaybackPositionChange: (pos) =>
            add(PlayerPlaybackPositionChanged(pos)),
      );

      _player!.play(track);
    }
  }

  @override
  Future<void> close() async {
    await super.close();

    if (_player != null) {
      await _player!.dispose();
    }
  }
}

abstract class Player {
  Player(
    this._musicRepository, {
    required void Function() onTrackPlayed,
    required void Function(Duration) onPlaybackPositionChange,
  })  : _onPlaybackPositionChange = onPlaybackPositionChange,
        _onTrackPlayed = onTrackPlayed;

  final MusicRepository _musicRepository;
  final VoidCallback _onTrackPlayed;
  final void Function(Duration position) _onPlaybackPositionChange;

  void play(Track track);

  void pause();

  void resume();

  Future<void> dispose();
}

class SpotifyPlayer extends Player {
  SpotifyPlayer(
    super.musicRepository, {
    required super.onTrackPlayed,
    required super.onPlaybackPositionChange,
  }) {
    _musicRepository.spotifyPlayerState().listen(_onPlayerStateChange);

    // TODO(sergsavchuk): use Ticker ?
    const timerPeriod = Duration(milliseconds: 50);
    _playbackTimer = Timer.periodic(timerPeriod, (_) {
      if (!_isPaused) {
        _playbackPosition += timerPeriod;
        _onPlaybackPositionChange(_playbackPosition);
      }
    });
  }

  late StreamSubscription<PlaybackState> _playbackStateSubscription;
  late Timer _playbackTimer;
  Duration _playbackPosition = Duration.zero;

  bool _isPaused = true;
  Track? _track;

  @override
  void play(Track track) {
    _track = track;
    _musicRepository.spotifyPlay(track);
  }

  @override
  void pause() {
    _musicRepository.spotifyPausePlay();
  }

  @override
  void resume() {
    _musicRepository.spotifyResumePlay();
  }

  @override
  Future<void> dispose() async {
    await _playbackStateSubscription.cancel();
    _playbackTimer.cancel();
  }

  void _onPlayerStateChange(PlaybackState playbackState) {
    _playbackPosition = playbackState.position;
    _onPlaybackPositionChange(playbackState.position);

    _isPaused = playbackState.isPaused;

    if (_playbackPosition > _track!.duration) {
      _onTrackPlayed();
    }
  }
}
