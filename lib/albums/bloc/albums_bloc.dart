import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common_models/common_models.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';

part 'albums_event.dart';

part 'albums_state.dart';

class AlbumsBloc extends Bloc<AlbumsEvent, AlbumsState> {
  AlbumsBloc({required this.musicRepository}) : super(const AlbumsState()) {
    on<AlbumsPageLoadRequested>(_loadRequested);
  }

  final MusicRepository musicRepository;

  FutureOr<void> _loadRequested(
    AlbumsPageLoadRequested event,
    Emitter<AlbumsState> emit,
  ) async {
    if (event.offset < state.albums.length) {
      return;
    }

    emit(AlbumsState(albums: state.albums, loadingNextPage: true));

    final albums = await musicRepository.albums();

    emit(AlbumsState(albums: albums));
  }
}
