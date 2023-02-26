import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_repository/music_repository.dart';

part 'player_event.dart';

part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({required MusicRepository musicRepository})
      : _musicRepository = musicRepository,
        super(const PlayerState()) {
    on<PlayerToggleRequested>(_toggleRequested);
    on<PlayerTrackPlayRequested>(_trackPlayRequested);
    on<PlayerPlaybackPositionChanged>(_playbackPositionChanged);
    on<PlayerNextTrackRequested>(_nextTrackRequested);
    on<PlayerPrevTrackRequested>(_prevTrackRequested);
  }

  final MusicRepository _musicRepository;
  final Map<MusicSource, Player> _players = {};
  Player? _player;

  FutureOr<void> _prevTrackRequested(
    PlayerPrevTrackRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.currentTrackCollection == null) {
      return null;
    }

    final tracks = state.currentTrackCollection!.tracks;
    if (state.currentTrack != null && tracks.indexOf(state.currentTrack!) > 0) {
      final track = tracks[tracks.indexOf(state.currentTrack!) - 1];
      emit(
        state.copyWith(
          isPlaying: true,
          currentTrack: track,
        ),
      );
      await _play(track);
    }
  }

  FutureOr<void> _nextTrackRequested(
    PlayerNextTrackRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.currentTrackCollection == null) {
      return null;
    }

    final tracks = state.currentTrackCollection!.tracks;
    if (state.currentTrack != null &&
        tracks.indexOf(state.currentTrack!) < tracks.length - 1) {
      final track = tracks[tracks.indexOf(state.currentTrack!) + 1];
      emit(
        state.copyWith(
          isPlaying: true,
          playbackPosition: Duration.zero,
          currentTrack: track,
        ),
      );
      await _play(track);
    }
  }

  FutureOr<void> _playbackPositionChanged(
    PlayerPlaybackPositionChanged event,
    Emitter<PlayerState> emit,
  ) async {
    if (event.position != state.playbackPosition) {
      emit(state.copyWith(playbackPosition: event.position));
    }
  }

  FutureOr<void> _trackPlayRequested(
    PlayerTrackPlayRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (event.track != state.currentTrack) {
      emit(
        PlayerState(
          isPlaying: true,
          currentTrack: event.track,
          currentTrackCollection: event.trackCollection,
        ),
      );
      await _play(event.track);
    }
  }

  FutureOr<void> _toggleRequested(
    PlayerToggleRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.currentTrack == null) {
      return null;
    }

    if (state.isPlaying) {
      await _player?.pause();
      emit(state.copyWith(isPlaying: false));
    } else {
      await _player?.resume();
      emit(state.copyWith(isPlaying: true));
    }
  }

  Future<void> _play(Track track) async {
    if (track.source == MusicSource.spotify) {
      _players[track.source] ??= SpotifyPlayer(
        _musicRepository,
        onTrackPlayed: () => add(PlayerNextTrackRequested()),
        onPlaybackPositionChange: (pos) =>
            add(PlayerPlaybackPositionChanged(pos)),
      );
    } else if (track.source == MusicSource.youtube) {
      _players[track.source] ??= YoutubePlayer(
        _musicRepository,
        onTrackPlayed: () => add(PlayerNextTrackRequested()),
        onPlaybackPositionChange: (pos) =>
            add(PlayerPlaybackPositionChanged(pos)),
      );
    }

    if (_player != null) {
      await _player!.pause();
    }

    _player = _players[track.source];
    await _player!.play(track);
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

  Future<void> play(Track track);

  Future<void> pause();

  Future<void> resume();

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
  Future<void> play(Track track) async {
    _track = track;
    await _musicRepository.spotifyPlay(track);
  }

  @override
  Future<void> pause() async {
    await _musicRepository.spotifyPausePlay();
  }

  @override
  Future<void> resume() async {
    await _musicRepository.spotifyResumePlay();
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

class YoutubePlayer extends Player {
  YoutubePlayer(
    super.musicRepository, {
    required super.onTrackPlayed,
    required super.onPlaybackPositionChange,
  }) {
    _positionSubscription =
        _player.positionStream.listen(_onPlaybackPositionChange);
    _stateSubscription = _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onTrackPlayed();
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<ProcessingState> _stateSubscription;

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> play(Track track) async {
    final uri = await _musicRepository.playYoutubeTrack(track);
    await _player.setAudioSource(AudioSource.uri(uri));
    unawaited(_player.play());
  }

  @override
  Future<void> resume() async {
    await _player.play();
  }

  @override
  Future<void> dispose() async {
    await _positionSubscription.cancel();
    await _stateSubscription.cancel();
    await _player.dispose();
  }
}
