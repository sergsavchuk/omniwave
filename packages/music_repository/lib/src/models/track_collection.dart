import 'package:music_repository/music_repository.dart';

class TrackCollection extends MusicEntity {
  const TrackCollection({
    required super.id,
    required super.name,
    required super.artists,
    required super.source,
    required super.imageUrl,
    required this.tracks,
  });

  final List<Track> tracks;

  @override
  List<Object?> get props => [id, name, imageUrl, artists, tracks, source];
}
