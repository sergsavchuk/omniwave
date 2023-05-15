import 'package:common_models/common_models.dart';
import 'package:hive/hive.dart';

part 'generated/track.g.dart';

@HiveType(typeId: 2)
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

  @HiveField(16)
  final Duration duration;
  @HiveField(17)
  final String albumId;

  @override
  List<Object?> get props =>
      [id, name, imageUrl, artists, duration, source, albumId];
}
