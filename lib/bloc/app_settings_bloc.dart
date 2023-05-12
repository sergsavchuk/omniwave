import 'dart:async';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:omniwave/env/env.dart';
import 'package:player_repository/player_repository.dart';

part 'app_settings_event.dart';

part 'app_settings_state.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  AppSettingsBloc({
    required PlayerRepository playerRepository,
    required AuthenticationRepository authenticationRepository,
  })  : _playerRepository = playerRepository,
        _authRepository = authenticationRepository,
        super(
          AppSettingsState(
            spotifyConnected: playerRepository.spotifyConnected,
            user: authenticationRepository.currentUser,
          ),
        ) {
    on<AppSettingsSpotifyConnectRequested>(_spotifyConnectRequested);
    on<_AppSettingsUserChanged>(_userChanged);

    _userStreamSubscription = _authRepository.userStream
        .listen((user) => add(_AppSettingsUserChanged(user)));
  }

  final PlayerRepository _playerRepository;
  final AuthenticationRepository _authRepository;

  late final StreamSubscription<User> _userStreamSubscription;

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

      emit(const AppSettingsState(spotifyConnected: true));
    } catch (_) {
      // TODO(sergsavchuk): handle the error
    }
  }

  FutureOr<void> _userChanged(
    _AppSettingsUserChanged event,
    Emitter<AppSettingsState> emit,
  ) {
    emit(state.copyWith(user: event.user));
  }

  @override
  Future<void> close() {
    _userStreamSubscription.cancel();

    return super.close();
  }
}
