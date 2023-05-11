import 'package:common_models/common_models.dart';

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
