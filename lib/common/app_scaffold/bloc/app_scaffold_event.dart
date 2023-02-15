part of 'app_scaffold_bloc.dart';

abstract class AppScaffoldEvent extends Equatable {
  const AppScaffoldEvent();
}

class AppScaffoldSpotifyConnectRequested extends AppScaffoldEvent {
  @override
  List<Object?> get props => [];
}
