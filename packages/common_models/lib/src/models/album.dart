import 'package:common_models/common_models.dart';
import 'package:hive/hive.dart';

part 'generated/album.g.dart';

@HiveType(typeId: 1)
class Album extends TrackCollection {
  const Album({
    required super.id,
    required super.name,
    required super.artists,
    required super.tracks,
    required super.source,
    required super.imageUrl,
  });
}
