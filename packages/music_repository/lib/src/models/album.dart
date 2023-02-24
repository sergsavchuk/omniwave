import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';
import 'package:spotify/spotify.dart' hide Track;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

const webProxyUrl = 'http://localhost:443/';

class Album extends Equatable {
  const Album({
    required this.id,
    required this.name,
    required this.artists,
    required this.tracks,
    required this.source,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final List<String> artists;
  final List<Track> tracks;
  final MusicSource source;

  Album copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<String>? artists,
    List<Track>? tracks,
    MusicSource? source,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      artists: artists ?? this.artists,
      tracks: tracks ?? this.tracks,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [name, imageUrl, artists];
}

extension SpotifyAlbumExtension on AlbumSimple {
  Album toOmniwaveAlbum() {
    return Album(
      id: id ?? 'UNKNOWN_ID',
      name: name ?? 'Unknown album',
      imageUrl: images?[0].url,
      artists: artists
              ?.where((element) => element.name != null)
              .map((e) => e.name)
              .toList()
              .cast<String>() ??
          ['Unknown artist'],
      tracks: tracks
              ?.map(
                (track) => track.toOmniwaveTrack(
                  albumId: id ?? 'UNKNOWN_ID',
                  imageUrl: images?[0].url,
                ),
              )
              .toList() ??
          [],
      source: MusicSource.spotify,
    );
  }
}

extension SearchPlaylistExtension on yt.SearchPlaylist {
  Album toOmniwaveAlbum({required bool useProxy}) {
    return Album(
      id: playlistId.value,
      name: playlistTitle,
      imageUrl: thumbnails.isNotEmpty
          ? (useProxy ? webProxyUrl : '') + thumbnails.last.url.toString()
          : null,
      artists: const ['TODO use yt Playlist'],
      tracks: const [],
      source: MusicSource.youtube,
    );
  }
}

extension PlaylistExtension on yt.Playlist {
  Album toOmniwaveAlbum() {
    return Album(
      id: id.value,
      name: title,
      imageUrl: thumbnails.highResUrl,
      artists: [author],
      tracks: const [],
      source: MusicSource.youtube,
    );
  }
}
