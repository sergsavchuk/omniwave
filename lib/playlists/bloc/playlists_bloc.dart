import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';

part 'playlists_event.dart';

part 'playlists_state.dart';

class PlaylistsBloc extends Bloc<PlaylistsEvent, PlaylistsState> {
  PlaylistsBloc({required this.musicRepository})
      : super(const PlaylistsState()) {
    on<PlaylistsLoadRequested>(_loadRequested);
  }

  final MusicRepository musicRepository;

  FutureOr<void> _loadRequested(
    PlaylistsLoadRequested event,
    Emitter<PlaylistsState> emit,
  ) async {
    final playlistStream = musicRepository.loadPlaylists();
    final playlistList = <Playlist>[];

    await for (final playlist in playlistStream) {
      playlistList.add(playlist);
      emit(PlaylistsState(playlists: List.of(playlistList)));
    }
  }
}
