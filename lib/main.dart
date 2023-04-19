import 'dart:developer';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/albums/albums.dart';
import 'package:omniwave/bloc/app_settings_bloc.dart';
import 'package:omniwave/common/player/player_controls.dart';
import 'package:omniwave/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = OmniwaveAppBlocObserver();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authRepository = AuthenticationRepository();
  await authRepository.anonymousAuth();
  await authRepository.userStream.first;

  runApp(OmniwaveApp(authenticationRepository: authRepository));
}

class OmniwaveApp extends StatelessWidget {
  const OmniwaveApp({
    super.key,
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository;

  final AuthenticationRepository _authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => MusicRepository(useYoutubeProxy: kIsWeb),
        ),
        RepositoryProvider.value(value: _authenticationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppSettingsBloc(
              musicRepository: context.read<MusicRepository>(),
              authenticationRepository: _authenticationRepository,
            ),
          ),
          BlocProvider<PlayerBloc>(
            create: (context) =>
                PlayerBloc(musicRepository: context.read<MusicRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Omniwave Music Player',
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSwatch(
              brightness: Brightness.dark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.white;
                  }
                  return Colors.grey;
                }),
                textStyle: MaterialStateProperty.all(
                  Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
          home: const AlbumsPage(),
        ),
      ),
    );
  }
}

class OmniwaveAppBlocObserver extends BlocObserver {
  OmniwaveAppBlocObserver({this.logAll = false});

  final bool logAll;

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    if (transition.event is! PlayerPlaybackPositionChanged || logAll) {
      log('onTransition(${bloc.runtimeType}, $transition)');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);

    if (event is! PlayerPlaybackPositionChanged || logAll) {
      log('onEvent(${bloc.runtimeType}, $event');
    }
  }
}
