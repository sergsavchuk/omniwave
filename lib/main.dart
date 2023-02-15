import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/albums/albums.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = OmniwaveAppBlocObserver();
  runApp(const OmniwaveApp());
}

class OmniwaveApp extends StatelessWidget {
  const OmniwaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => MusicRepository(useYoutubeProxy: kIsWeb),
      child: MaterialApp(
        title: 'Omniwave Music Player',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
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
    );
  }
}

class OmniwaveAppBlocObserver extends BlocObserver {
  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    log('onTransition(${bloc.runtimeType}, $transition)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    log('onEvent(${bloc.runtimeType}, $event');
  }
}
