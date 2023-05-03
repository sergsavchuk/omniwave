import 'package:music_repository/src/models/track_collection.dart';

class Playlist extends TrackCollection {
  const Playlist({
    required super.id,
    required super.name,
    required super.artists,
    required super.tracks,
    required super.source,
    required super.imageUrl,
  });
}
