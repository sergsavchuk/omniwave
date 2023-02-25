import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/env/env.dart';

part 'app_settings_event.dart';

part 'app_settings_state.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  AppSettingsBloc({required MusicRepository musicRepository})
      : _musicRepository = musicRepository,
        super(
          AppSettingsState(spotifyConnected: musicRepository.spotifyConnected),
        ) {
    on<AppSettingsSpotifyConnectRequested>(_spotifyConnectRequested);
  }

  final MusicRepository _musicRepository;

  FutureOr<void> _spotifyConnectRequested(
    AppSettingsSpotifyConnectRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    if (_musicRepository.spotifyConnected) {
      return;
    }

    try {
      await _musicRepository.connectSpotify(
        Env.spotifyClientId,
        Env.spotifyRedirectUrl,
      );

      emit(const AppSettingsState(spotifyConnected: true));
    } catch (_) {
      // TODO(sergsavchuk): handle the error
    }
  }
}
