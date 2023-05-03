import 'package:music_repository/music_repository.dart';

class Track extends MusicEntity {
  const Track({
    required super.id,
    required super.name,
    required super.artists,
    required super.source,
    required super.imageUrl,
    required this.duration,
    required this.albumId,
  });

  final Duration duration;
  final String albumId;

  @override
  List<Object?> get props =>
      [id, name, imageUrl, artists, duration, source, albumId];
}
