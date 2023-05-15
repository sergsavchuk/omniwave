import 'dart:async';
import 'dart:developer';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:common_models/common_models.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/env/env.dart';
import 'package:player_repository/player_repository.dart';

part 'app_settings_event.dart';

part 'app_settings_state.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  AppSettingsBloc({
    required MusicRepository musicRepository,
    required PlayerRepository playerRepository,
    required AuthenticationRepository authenticationRepository,
  })  : _musicRepository = musicRepository,
        _playerRepository = playerRepository,
        _authRepository = authenticationRepository,
        super(
          AppSettingsState(
            spotifyConnected: playerRepository.spotifyConnected,
            user: authenticationRepository.currentUser,
          ),
        ) {
    on<AppSettingsSpotifyConnectRequested>(_spotifyConnectRequested);
    on<_AppSettingsUserChanged>(_userChanged);
    on<AppSettingsSyncRequested>(_syncRequested);
    on<AppSettingsSyncStateChanged>(_syncStateChanged);
    on<AppSettingsSyncOnStartupToggled>(_syncOnStartupToggled);

    _userStreamSubscription = _authRepository.userStream
        .listen((user) => add(_AppSettingsUserChanged(user)));
    _syncInProgressSubscription = _musicRepository.syncInProgressStream.listen(
      (syncInProgress) =>
          add(AppSettingsSyncStateChanged(syncInProgress: syncInProgress)),
    );
  }

  final MusicRepository _musicRepository;
  final PlayerRepository _playerRepository;
  final AuthenticationRepository _authRepository;

  late final StreamSubscription<User> _userStreamSubscription;
  late final StreamSubscription<bool> _syncInProgressSubscription;

  FutureOr<void> _spotifyConnectRequested(
    AppSettingsSpotifyConnectRequested event,
    Emitter<AppSettingsState> emit,
  ) async {
    if (_playerRepository.spotifyConnected) {
      return;
    }

    try {
      await _playerRepository.connectSpotify(
        Env.spotifyClientId,
        Env.spotifyRedirectUrl,
      );

      if (state.syncOnStartup) {
        unawaited(_musicRepository.synchronizeCache());
      }

      emit(state.copyWith(spotifyConnected: true));
    } catch (e) {
      // TODO(sergsavchuk): handle the error
      log('Failed to connect Spotify', error: e);
    }
  }

  FutureOr<void> _userChanged(
    _AppSettingsUserChanged event,
    Emitter<AppSettingsState> emit,
  ) {
    emit(state.copyWith(user: event.user));
  }

  FutureOr<void> _syncRequested(
    AppSettingsSyncRequested event,
    Emitter<AppSettingsState> emit,
  ) {
    _musicRepository.synchronizeCache();
  }

  FutureOr<void> _syncStateChanged(
    AppSettingsSyncStateChanged event,
    Emitter<AppSettingsState> emit,
  ) {
    emit(state.copyWith(syncInProgress: event.syncInProgress));
  }

  FutureOr<void> _syncOnStartupToggled(
    AppSettingsSyncOnStartupToggled event,
    Emitter<AppSettingsState> emit,
  ) {
    emit(state.copyWith(syncOnStartup: event.syncOnStartup));
  }

  @override
  Future<void> close() {
    _userStreamSubscription.cancel();
    _syncInProgressSubscription.cancel();

    return super.close();
  }
}
