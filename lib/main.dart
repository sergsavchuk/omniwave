import 'dart:developer';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:common_models/common_models.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/albums/albums.dart';
import 'package:omniwave/bloc/app_settings_bloc.dart';
import 'package:omniwave/common/player/player_controls.dart';
import 'package:omniwave/firebase_options.dart';
import 'package:omniwave/track_collection/bloc/track_collection_bloc.dart';
import 'package:player_repository/player_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = OmniwaveAppBlocObserver();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authRepository = AuthenticationRepository();
  await authRepository.anonymousAuth();
  await authRepository.userStream.first;

  await Hive.initFlutter();
  Hive
    ..registerAdapter(AlbumAdapter())
    ..registerAdapter(TrackAdapter())
    ..registerAdapter(MusicSourceAdapter())
    ..registerAdapter(DurationAdapter());

  runApp(
    OmniwaveApp(
      authenticationRepository: authRepository,
      // TODO(sergsavchuk): store the spotifyScope inside MusicRepository ?
      playerRepository: PlayerRepository(
        spotifyScope: [
          'user-library-read',
          'user-read-email',
          'user-read-private',
        ],
      ),
    ),
  );
}

class OmniwaveApp extends StatelessWidget {
  const OmniwaveApp({
    super.key,
    required AuthenticationRepository authenticationRepository,
    required PlayerRepository playerRepository,
  })  : _authenticationRepository = authenticationRepository,
        _playerRepository = playerRepository;

  final AuthenticationRepository _authenticationRepository;
  final PlayerRepository _playerRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MusicRepository>(
          create: (_) => MusicRepositoryImpl(
            useYoutubeProxy: kIsWeb,
            spotifyAccessTokenStream: _playerRepository.accessTokenStream,
            spotifyCache: HiveMusicCache(MusicSource.spotify),
            synchronizeCacheOnSpotifyConnect: true,
          ),
        ),
        RepositoryProvider.value(value: _playerRepository),
        RepositoryProvider.value(value: _authenticationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppSettingsBloc(
              playerRepository: _playerRepository,
              authenticationRepository: _authenticationRepository,
            ),
          ),
          BlocProvider<PlayerBloc>(
            create: (context) => PlayerBloc(
              musicRepository: context.read<MusicRepository>(),
              player: context.read<PlayerRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Omniwave Music Player',
          themeMode: ThemeMode.dark,
          darkTheme: FlexThemeData.dark(scheme: FlexScheme.jungle),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AlbumsPage(),
        ),
      ),
    );
  }
}

class OmniwaveAppBlocObserver extends BlocObserver {
  OmniwaveAppBlocObserver({this.logAll = false});

  static const filterTypes = [
    PlayerPlaybackPositionChanged,
    TrackCollectionScrollPositionChanged
  ];

  final bool logAll;

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    if (!filterTypes.contains((transition.event as Object?).runtimeType) ||
        logAll) {
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

    if (!filterTypes.contains(event.runtimeType) || logAll) {
      log('onEvent(${bloc.runtimeType}, $event');
    }
  }
}
