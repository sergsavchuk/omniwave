import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';

class Track extends Equatable {
  const Track({
    required this.id,
    required this.name,
    required this.href,
    required this.artists,
    required this.duration,
    required this.source,
    required this.albumId,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String href;
  final String? imageUrl;
  final List<String> artists;
  final Duration duration;
  final MusicSource source;
  final String albumId;

  @override
  List<Object?> get props =>
      [id, name, href, imageUrl, artists, duration, source, albumId];
}
