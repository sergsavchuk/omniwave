import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';

part 'albums_event.dart';

part 'albums_state.dart';

class AlbumsBloc extends Bloc<AlbumsEvent, AlbumsState> {
  AlbumsBloc({required this.musicRepository}) : super(const AlbumsState()) {
    on<AlbumsStarted>(_albumsStarted);
  }

  final MusicRepository musicRepository;

  FutureOr<void> _albumsStarted(
    AlbumsStarted event,
    Emitter<AlbumsState> emit,
  ) async {
    final albumsStream = musicRepository.loadAlbums();
    final albumsList = <Album>[];

    await for (final album in albumsStream) {
      albumsList.add(album);
      emit(AlbumsState(albums: List.of(albumsList)));
    }
  }
}
