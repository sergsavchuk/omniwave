import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:common_models/common_models.dart';
import 'package:music_repository/src/spotify_music_repository.dart';
import 'package:music_repository/src/youtube_music_repository.dart';

const unknown = 'Unknown';

abstract class MusicRepository {
  List<MusicSource> get supportedSources;

  Future<List<Album>> albums();

  Stream<List<Album>> albumsStream();

  Stream<List<Track>> tracksStream();

  Stream<List<Playlist>> playlistsStream();

  Stream<SearchResult<Object>> search(String searchQuery);

  Future<Uri?> getTrackAudioUrl(Track track);

  Future<void> dispose();
}

class MusicRepositoryImpl implements MusicRepository {
  MusicRepositoryImpl({
    required bool useYoutubeProxy,
    required Stream<String> spotifyAccessTokenStream,
  }) : _repositories = [
          SpotifyMusicRepository(spotifyAccessTokenStream),
          YoutubeMusicRepository(useYoutubeProxy: useYoutubeProxy)
        ];

  late final List<MusicRepository> _repositories;

  final Map<MusicRepository, List<Album>> _albumsMap = {};
  StreamController<List<Album>>? _albumsStreamController;

  final Map<MusicRepository, List<Playlist>> _playlistsMap = {};
  StreamController<List<Playlist>>? _playlistsStreamController;

  final Map<MusicRepository, List<Track>> _tracksMap = {};
  StreamController<List<Track>>? _tracksStreamController;

  final _subscriptions = <StreamSubscription<dynamic>>[];

  @override
  List<MusicSource> get supportedSources =>
      [MusicSource.spotify, MusicSource.youtube];

  @override
  Stream<SearchResult<Object>> search(String searchQuery) => StreamGroup.merge(
        _repositories.map((element) => element.search(searchQuery)),
      );

  @override
  Future<List<Album>> albums() async {
    final albumsLists = await Future.wait<List<Album>>(
      _repositories.map((repository) => repository.albums()),
    );

    return albumsLists.fold<List<Album>>(
      [],
      (previousValue, element) => previousValue + element,
    );
  }

  @override
  Stream<List<Album>> albumsStream() {
    if (_albumsStreamController == null) {
      _albumsStreamController = StreamController();

      for (final repository in _repositories) {
        _subscribeToSubrepoStream(
          _albumsStreamController!,
          _albumsMap,
          repository,
          repository.albumsStream(),
        );
      }
    }

    return _albumsStreamController!.stream;
  }

  @override
  Stream<List<Playlist>> playlistsStream() {
    if (_playlistsStreamController == null) {
      _playlistsStreamController = StreamController();

      for (final repository in _repositories) {
        _subscribeToSubrepoStream(
          _playlistsStreamController!,
          _playlistsMap,
          repository,
          repository.playlistsStream(),
        );
      }
    }

    return _playlistsStreamController!.stream;
  }

  @override
  Stream<List<Track>> tracksStream() {
    if (_tracksStreamController == null) {
      _tracksStreamController = StreamController();

      for (final repository in _repositories) {
        _subscribeToSubrepoStream(
          _tracksStreamController!,
          _tracksMap,
          repository,
          repository.tracksStream(),
        );
      }
    }

    return _tracksStreamController!.stream;
  }

  @override
  Future<Uri?> getTrackAudioUrl(Track track) async {
    for (final repository in _repositories) {
      if (repository.supportedSources.contains(track.source)) {
        return repository.getTrackAudioUrl(track);
      }
    }

    log('MusicRepository.getTrackAudioUrl() is'
        ' not supported for ${track.source}');
    return null;
  }

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }

    await _albumsStreamController?.close();
    await _playlistsStreamController?.close();
    await _tracksStreamController?.close();
  }

  void _subscribeToSubrepoStream<T>(
    StreamController<List<T>> streamController,
    Map<MusicRepository, List<T>> accumulatingMap,
    MusicRepository repository,
    Stream<List<T>> stream,
  ) {
    _subscriptions.add(
      stream.listen((items) {
        accumulatingMap[repository] = items;
        streamController.add(
          accumulatingMap.values.fold(
            [],
            (previousValue, element) => previousValue + element,
          ),
        );
      }),
    );
  }
}
