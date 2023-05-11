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

  final MusicRepositoryImpl musicRepository;

  FutureOr<void> _loadRequested(
    PlaylistsPageLoadRequested event,
    Emitter<PlaylistsState> emit,
  ) async {
    if (event.offset < state.playlists.length) {
      return;
    }

    // TODO(sergsavchuk): load playlists
  }
}
