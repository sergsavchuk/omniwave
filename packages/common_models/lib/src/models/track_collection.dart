import 'package:common_models/common_models.dart';
import 'package:hive/hive.dart';

class TrackCollection extends MusicEntity {
  const TrackCollection({
    required super.id,
    required super.name,
    required super.artists,
    required super.source,
    required super.imageUrl,
    required this.tracks,
  });

  @HiveField(16)
  final List<Track> tracks;

  @override
  List<Object?> get props => [id, name, imageUrl, artists, tracks, source];
}
