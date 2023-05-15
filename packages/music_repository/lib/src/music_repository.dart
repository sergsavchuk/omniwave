import 'dart:async';
import 'dart:developer';

import 'package:async/async.dart';
import 'package:common_models/common_models.dart';
import 'package:music_repository/src/cache/music_cache.dart';

import 'package:music_repository/src/provider/provider.dart';

// TODO(sergsavchuk): move this constant somewhere?
const unknown = 'Unknown';

class MusicRepository implements MusicProvider {
  MusicRepository({
    required bool useYoutubeProxy,
    required Stream<String> spotifyAccessTokenStream,
    MusicCache? spotifyCache,
    bool synchronizeCacheOnSpotifyConnect = false,
  }) : _providers = [
          CacheMusicProvider(
            SpotifyMusicProvider(spotifyAccessTokenStream),
            spotifyCache,
          ),
          YoutubeMusicProvider(useYoutubeProxy: useYoutubeProxy)
        ] {
    if (synchronizeCacheOnSpotifyConnect) {
      spotifyAccessTokenStream.first.then((value) => synchronizeCache());
    }
  }

  late final List<MusicProvider> _providers;

  final Map<MusicProvider, List<Album>> _albumsMap = {};
  StreamController<List<Album>>? _albumsStreamController;

  final Map<MusicProvider, List<Playlist>> _playlistsMap = {};
  StreamController<List<Playlist>>? _playlistsStreamController;

  final Map<MusicProvider, List<Track>> _tracksMap = {};
  StreamController<List<Track>>? _tracksStreamController;

  final _subscriptions = <StreamSubscription<dynamic>>[];

  void synchronizeCache() {
    for (final provider in _providers) {
      if (provider is CacheMusicProvider) {
        provider.synchronize();
      }
    }
  }

  @override
  List<MusicSource> get supportedSources =>
      [MusicSource.spotify, MusicSource.youtube];

  @override
  Stream<SearchResult<Object>> search(String searchQuery) => StreamGroup.merge(
        _providers.map((element) => element.search(searchQuery)),
      );

  @override
  Future<List<Album>> albums() async {
    final albumsLists = await Future.wait<List<Album>>(
      _providers.map((provider) => provider.albums()),
    );

    return albumsLists.fold<List<Album>>(
      [],
      (previousValue, element) => previousValue + element,
    );
  }

  @override
  Stream<List<Album>> albumsStream() {
    if (_albumsStreamController == null) {
      _albumsStreamController = StreamController.broadcast();

      for (final provider in _providers) {
        _subscribeToSubProviderStream(
          _albumsStreamController!,
          _albumsMap,
          provider,
          provider.albumsStream(),
        );
      }
    }

    return _albumsStreamController!.stream;
  }

  @override
  Stream<List<Playlist>> playlistsStream() {
    if (_playlistsStreamController == null) {
      _playlistsStreamController = StreamController();

      for (final provider in _providers) {
        _subscribeToSubProviderStream(
          _playlistsStreamController!,
          _playlistsMap,
          provider,
          provider.playlistsStream(),
        );
      }
    }

    return _playlistsStreamController!.stream;
  }

  @override
  Stream<List<Track>> tracksStream() {
    if (_tracksStreamController == null) {
      _tracksStreamController = StreamController();

      for (final provider in _providers) {
        _subscribeToSubProviderStream(
          _tracksStreamController!,
          _tracksMap,
          provider,
          provider.tracksStream(),
        );
      }
    }

    return _tracksStreamController!.stream;
  }

  @override
  Future<Uri?> getTrackAudioUrl(Track track) async {
    for (final provider in _providers) {
      if (provider.supportedSources.contains(track.source)) {
        return provider.getTrackAudioUrl(track);
      }
    }

    log('MusicProvider.getTrackAudioUrl() is'
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

  void _subscribeToSubProviderStream<T>(
    StreamController<List<T>> streamController,
    Map<MusicProvider, List<T>> accumulatingMap,
    MusicProvider provider,
    Stream<List<T>> stream,
  ) {
    _subscriptions.add(
      stream.listen((items) {
        accumulatingMap[provider] = items;
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
