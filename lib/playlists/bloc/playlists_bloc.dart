import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';

part 'playlists_event.dart';

part 'playlists_state.dart';

class PlaylistsBloc extends Bloc<PlaylistsEvent, PlaylistsState> {
  PlaylistsBloc({required this.musicRepository})
      : super(const PlaylistsState()) {
    on<PlaylistsPageLoadRequested>(_loadRequested);
  }

  final MusicRepository musicRepository;

  FutureOr<void> _loadRequested(
    PlaylistsPageLoadRequested event,
    Emitter<PlaylistsState> emit,
  ) async {
    if (event.offset < state.playlists.length) {
      return;
    }

    emit(PlaylistsState(playlists: state.playlists, loadingNextPage: true));

    // TODO(sergsavchuk): load playlists instead of the youtube search
    final playlistStream =
        musicRepository.searchYoutubePlaylists('Radiohead album');
    final playlistList = List.of(state.playlists);

    await for (final playlist in playlistStream) {
      playlistList.add(playlist);
      emit(
        PlaylistsState(
          playlists: List.of(playlistList),
          loadingNextPage: true,
        ),
      );
    }

    emit(PlaylistsState(playlists: state.playlists));
  }
}
