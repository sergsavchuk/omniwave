part of 'app_settings_bloc.dart';

class AppSettingsState extends Equatable {
  const AppSettingsState({
    this.user = User.empty,
    this.spotifyConnected = false,
    this.syncInProgress = false,
    this.syncOnStartup = true,
  });

  final bool spotifyConnected;
  final bool syncInProgress;
  final bool syncOnStartup;
  final User user;

  AppSettingsState copyWith({
    User? user,
    bool? spotifyConnected,
    bool? syncInProgress,
    bool? syncOnStartup,
  }) {
    return AppSettingsState(
      user: user ?? this.user,
      spotifyConnected: spotifyConnected ?? this.spotifyConnected,
      syncInProgress: syncInProgress ?? this.syncInProgress,
      syncOnStartup: syncOnStartup ?? this.syncOnStartup,
    );
  }

  @override
  List<Object> get props =>
      [spotifyConnected, syncInProgress, syncOnStartup, user];
}
