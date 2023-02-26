import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';

class TrackCollection extends Equatable {
  const TrackCollection({
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

  @override
  List<Object?> get props => [id, name, imageUrl, artists, tracks, source];
}
