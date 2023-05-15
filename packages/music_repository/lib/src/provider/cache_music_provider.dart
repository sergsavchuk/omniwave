import 'dart:async';

import 'package:common_models/common_models.dart';
import 'package:music_repository/src/cache/cache_capability.dart';
import 'package:music_repository/src/cache/music_cache.dart';
import 'package:music_repository/src/provider/music_provider.dart';

class CacheMusicProvider implements MusicProvider {
  CacheMusicProvider(this._musicProvider, this._musicCache);

  final MusicProviderWithCacheCapability _musicProvider;
  final MusicCache? _musicCache;

  final StreamController<List<Album>> _albumsStreamController =
      StreamController();

  Future<void> synchronize() async {
    final musicCache = _musicCache;
    if (musicCache == null) {
      return;
    }

    if ((await musicCache.hasCachedAlbums()) &&
        await _musicProvider.albumsCacheOutdated(
          await musicCache.cachedAlbums(),
        )) {
      await _musicCache?.clearAlbums();

      // load albums and add put them to the stream
      await albums();
    }
  }

  @override
  List<MusicSource> get supportedSources => _musicProvider.supportedSources;

  @override
  Future<List<Album>> albums() async {
    final musicCache = _musicCache;
    if ((await musicCache?.hasCachedAlbums()) ?? false) {
      return musicCache!.cachedAlbums();
    }

    final albums = await _musicProvider.albums();
    await musicCache?.cacheAlbums(albums);

    _albumsStreamController.add(albums);

    return albums;
  }

  @override
  Stream<List<Album>> albumsStream() => _albumsStreamController.stream;

  @override
  Future<Uri?> getTrackAudioUrl(Track track) {
    return _musicProvider.getTrackAudioUrl(track);
  }

  @override
  Stream<List<Playlist>> playlistsStream() {
    return _musicProvider.playlistsStream();
  }

  @override
  Stream<SearchResult<Object>> search(String searchQuery) {
    return _musicProvider.search(searchQuery);
  }

  @override
  Stream<List<Track>> tracksStream() {
    return _musicProvider.tracksStream();
  }

  @override
  Future<void> dispose() async {
    await _musicProvider.dispose();

    await _albumsStreamController.close();
  }
}

abstract class MusicProviderWithCacheCapability
    with CacheCapability
    implements MusicProvider {}
