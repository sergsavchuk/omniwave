part of 'app_scaffold_bloc.dart';

class AppScaffoldState extends Equatable {
  const AppScaffoldState({
    this.spotifyConnected = false,
  });

  final bool spotifyConnected;

  @override
  List<Object> get props => [];
}
