import 'package:common_models/common_models.dart';
import 'package:hive/hive.dart';
import 'package:music_repository/src/cache/music_cache.dart';

class HiveMusicCache implements MusicCache {
  HiveMusicCache(MusicSource source)
      : _albumsBoxFuture = Hive.openBox<Album>('${source.name}_albums');

  final Future<Box<Album>> _albumsBoxFuture;

  @override
  Future<void> cacheAlbums(List<Album> albums) async {
    final albumsBox = await _albumsBoxFuture;
    await albumsBox.clear();
    await albumsBox.addAll(albums);
  }

  @override
  Future<List<Album>> cachedAlbums() async {
    final albumsBox = await _albumsBoxFuture;
    return albumsBox.values.toList();
  }

  @override
  Future<bool> hasCachedAlbums() async {
    final albumsBox = await _albumsBoxFuture;
    return albumsBox.isNotEmpty;
  }

  @override
  Future<void> clearAlbums() async {
    final albumsBox = await _albumsBoxFuture;
    await albumsBox.clear();
  }

  @override
  Future<void> clearCache() async {
    await clearAlbums();
  }

  @override
  Future<void> close() async {
    final albumsBox = await _albumsBoxFuture;
    await albumsBox.close();
  }
}
