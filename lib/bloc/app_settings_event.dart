part of 'app_settings_bloc.dart';

abstract class AppSettingsEvent extends Equatable {
  const AppSettingsEvent();
}

class AppSettingsSpotifyConnectRequested extends AppSettingsEvent {
  @override
  List<Object?> get props => [];
}

class _AppSettingsUserChanged extends AppSettingsEvent {
  const _AppSettingsUserChanged(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

class AppSettingsSyncRequested extends AppSettingsEvent {
  @override
  List<Object?> get props => [];
}

class AppSettingsSyncStateChanged extends AppSettingsEvent {
  const AppSettingsSyncStateChanged({required this.syncInProgress});

  final bool syncInProgress;

  @override
  List<Object?> get props => [syncInProgress];
}

class AppSettingsSyncOnStartupToggled extends AppSettingsEvent {
  const AppSettingsSyncOnStartupToggled({required this.syncOnStartup});

  final bool syncOnStartup;

  @override
  List<Object?> get props => [syncOnStartup];
}
