part of 'app_settings_bloc.dart';

class AppSettingsState extends Equatable {
  const AppSettingsState({
    this.spotifyConnected = false,
  });

  final bool spotifyConnected;

  @override
  List<Object> get props => [];
}
