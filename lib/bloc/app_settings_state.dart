part of 'app_settings_bloc.dart';

class AppSettingsState extends Equatable {
  const AppSettingsState({
    this.user = User.empty,
    this.spotifyConnected = false,
  });

  final bool spotifyConnected;
  final User user;

  AppSettingsState copyWith({User? user, bool? spotifyConnected}) {
    return AppSettingsState(
      user: user ?? this.user,
      spotifyConnected: spotifyConnected ?? this.spotifyConnected,
    );
  }

  @override
  List<Object> get props => [spotifyConnected, user];
}
