import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common_models/common_models.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';
import 'package:player_repository/player_repository.dart';

part 'player_event.dart';

part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({required MusicRepository musicRepository, required Player player})
      : _musicRepository = musicRepository,
        _player = player,
        super(const PlayerState()) {
    on<PlayerToggleRequested>(_toggleRequested);
    on<PlayerTrackPlayRequested>(_trackPlayRequested);
    on<PlayerPlaybackPositionChanged>(_playbackPositionChanged);
    on<PlayerNextTrackRequested>(_nextTrackRequested);
    on<PlayerPrevTrackRequested>(_prevTrackRequested);

    player
      ..onTrackPlayed = (() => add(PlayerNextTrackRequested()))
      ..onPlaybackPositionChange =
          ((pos) => add(PlayerPlaybackPositionChanged(pos)));
  }

  final MusicRepository _musicRepository;
  final Player _player;

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
      await _player.play(
        track,
        audioUrl: await _musicRepository.getTrackAudioUrl(track),
      );
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
      await _player.play(
        track,
        audioUrl: await _musicRepository.getTrackAudioUrl(track),
      );
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
      await _player.play(
        event.track,
        audioUrl: await _musicRepository.getTrackAudioUrl(event.track),
      );
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
      await _player.pause();
      emit(state.copyWith(isPlaying: false));
    } else {
      await _player.resume();
      emit(state.copyWith(isPlaying: true));
    }
  }

  @override
  Future<void> close() async {
    await _player.dispose();

    await super.close();
  }
}
