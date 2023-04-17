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
