import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';
import 'package:spotify/spotify.dart' hide Album;

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

extension SpotifyTrackExtension on TrackSimple {
  Track toOmniwaveTrack({required String albumId, String? imageUrl}) {
    return Track(
      id: id ?? 'UNKNOWN_ID',
      name: name ?? 'Unknown track',
      href: href ?? 'NO_TRACK_HREF_PROVIDED',
      imageUrl: imageUrl,
      artists: artists
              ?.where((element) => element.name != null)
              .map((e) => e.name)
              .toList()
              .cast<String>() ??
          ['Unknown artist'],
      duration: duration ?? Duration.zero,
      source: MusicSource.spotify,
      albumId: albumId,
    );
  }
}
