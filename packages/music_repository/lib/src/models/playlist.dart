import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';

class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.name,
    required this.artists,
    required this.tracks,
    required this.source,
    this.imageUrl,
  });

  final String id;
  final String name;
  final List<String> artists;
  final List<Track> tracks;
  final MusicSource source;
  final String? imageUrl;

  Album toAlbum() {
    return Album(
      id: id,
      name: name,
      artists: artists,
      tracks: tracks,
      source: source,
      imageUrl: imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, artists, tracks, source, imageUrl];
}
