import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/env/env.dart';

part 'app_scaffold_event.dart';

part 'app_scaffold_state.dart';

class AppScaffoldBloc extends Bloc<AppScaffoldEvent, AppScaffoldState> {
  AppScaffoldBloc({required MusicRepository musicRepository})
      : _musicRepository = musicRepository,
        super(
          AppScaffoldState(spotifyConnected: musicRepository.spotifyConnected),
        ) {
    on<AppScaffoldSpotifyConnectRequested>(_spotifyConnectRequested);
  }

  final MusicRepository _musicRepository;

  FutureOr<void> _spotifyConnectRequested(
    AppScaffoldSpotifyConnectRequested event,
    Emitter<AppScaffoldState> emit,
  ) async {
    if (_musicRepository.spotifyConnected) {
      return;
    }

    try {
      await _musicRepository.connectSpotify(
        Env.spotifyClientId,
        Env.spotifyRedirectUrl,
      );

      emit(const AppScaffoldState(spotifyConnected: true));
    } catch (_) {
      // TODO(sergsavchuk): handle the error
    }
  }
}
