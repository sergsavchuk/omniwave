import 'package:common_models/common_models.dart';

abstract interface class MusicCache {
  Future<void> cacheAlbums(List<Album> albums);

  Future<List<Album>> cachedAlbums();

  Future<bool> hasCachedAlbums();

  Future<void> clearAlbums();

  Future<void> clearCache();

  Future<void> close();
}
