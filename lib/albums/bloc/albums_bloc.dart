import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';

part 'albums_event.dart';

part 'albums_state.dart';

class AlbumsBloc extends Bloc<AlbumsEvent, AlbumsState> {
  AlbumsBloc({required this.musicRepository}) : super(const AlbumsState()) {
    on<AlbumsLoadRequested>(_loadRequested);
  }

  final MusicRepository musicRepository;

  FutureOr<void> _loadRequested(
    AlbumsLoadRequested event,
    Emitter<AlbumsState> emit,
  ) async {
    final albumStream = musicRepository.loadAlbums();
    final albumList = <Album>[];

    await for (final album in albumStream) {
      albumList.add(album);
      emit(AlbumsState(albums: List.of(albumList)));
    }
  }
}
