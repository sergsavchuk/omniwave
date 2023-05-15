import 'package:common_models/common_models.dart';

abstract class MusicProvider {
  List<MusicSource> get supportedSources;

  Future<List<Album>> albums();

  Stream<List<Album>> albumsStream();

  Stream<List<Track>> tracksStream();

  Stream<List<Playlist>> playlistsStream();

  Stream<SearchResult<Object>> search(String searchQuery);

  Future<Uri?> getTrackAudioUrl(Track track);

  Future<void> dispose();
}
