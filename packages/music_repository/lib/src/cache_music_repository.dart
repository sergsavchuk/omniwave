import 'dart:async';

import 'package:common_models/common_models.dart';
import 'package:music_repository/music_repository.dart';
import 'package:music_repository/src/cache/cache_capability.dart';
import 'package:music_repository/src/cache/music_cache.dart';

class CacheMusicRepository implements MusicRepository {
  CacheMusicRepository(this._musicRepository, this._musicCache);

  final MusicRepositoryWithCacheCapability _musicRepository;
  final MusicCache? _musicCache;

  final StreamController<List<Album>> _albumsStreamController =
      StreamController();

  Future<void> synchronize() async {
    final musicCache = _musicCache;
    if (musicCache == null) {
      return;
    }

    if ((await musicCache.hasCachedAlbums()) &&
        await _musicRepository.albumsCacheOutdated(
          await musicCache.cachedAlbums(),
        )) {
      await _musicCache?.clearAlbums();

      // load albums and add put them to the stream
      await albums();
    }
  }

  @override
  List<MusicSource> get supportedSources => _musicRepository.supportedSources;

  @override
  Future<List<Album>> albums() async {
    final musicCache = _musicCache;
    if ((await musicCache?.hasCachedAlbums()) ?? false) {
      return musicCache!.cachedAlbums();
    }

    final albums = await _musicRepository.albums();
    await musicCache?.cacheAlbums(albums);

    _albumsStreamController.add(albums);

    return albums;
  }

  @override
  Stream<List<Album>> albumsStream() => _albumsStreamController.stream;

  @override
  Future<Uri?> getTrackAudioUrl(Track track) {
    return _musicRepository.getTrackAudioUrl(track);
  }

  @override
  Stream<List<Playlist>> playlistsStream() {
    return _musicRepository.playlistsStream();
  }

  @override
  Stream<SearchResult<Object>> search(String searchQuery) {
    return _musicRepository.search(searchQuery);
  }

  @override
  Stream<List<Track>> tracksStream() {
    return _musicRepository.tracksStream();
  }

  @override
  Future<void> dispose() async {
    await _musicRepository.dispose();

    await _albumsStreamController.close();
  }
}

abstract class MusicRepositoryWithCacheCapability
    with CacheCapability
    implements MusicRepository {}
