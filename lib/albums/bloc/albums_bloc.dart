import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common_models/common_models.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';

part 'albums_event.dart';

part 'albums_state.dart';

class AlbumsBloc extends Bloc<AlbumsEvent, AlbumsState> {
  AlbumsBloc({required this.musicRepository}) : super(const AlbumsState()) {
    on<AlbumsInitialLoadRequested>(_loadRequested);
    on<AlbumsListChanged>(_listChanged);

    _albumsStreamSubscription = musicRepository
        .albumsStream()
        .listen((albums) => add(AlbumsListChanged(albums)));
  }

  final MusicRepository musicRepository;

  StreamSubscription<List<Album>>? _albumsStreamSubscription;

  FutureOr<void> _loadRequested(
    AlbumsInitialLoadRequested event,
    Emitter<AlbumsState> emit,
  ) async {
    final albums = await musicRepository.albums();

    emit(AlbumsState(albums: albums));
  }

  @override
  Future<void> close() async {
    await _albumsStreamSubscription?.cancel();

    await super.close();
  }

  FutureOr<void> _listChanged(
    AlbumsListChanged event,
    Emitter<AlbumsState> emit,
  ) {
    if (event.albums != state.albums) {
      emit(AlbumsState(albums: event.albums));
    }
  }
}
