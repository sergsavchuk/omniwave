import 'package:flutter/foundation.dart';
import 'package:omniwave/ui/pages/home_page/home_page.dart';
import 'package:spotify/spotify.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

@immutable
class OmniwaveAlbum {
  const OmniwaveAlbum({this.name, this.imageUrl, this.artists});

  final String? name;
  final String? imageUrl;
  final List<String>? artists;

  OmniwaveAlbum copyWith({
    String? name,
    String? imageUrl,
    List<String>? artists,
  }) {
    return OmniwaveAlbum(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      artists: artists ?? this.artists,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OmniwaveAlbum &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          imageUrl == other.imageUrl &&
          artists == other.artists;

  @override
  int get hashCode => Object.hash(name, imageUrl, artists);
}

extension SpotifyAlbumExtension on AlbumSimple {
  OmniwaveAlbum toOmniwaveAlbum() {
    return OmniwaveAlbum(
      name: name,
      imageUrl: images?[0].url,
      artists: artists
          ?.where((element) => element.name != null)
          .map((e) => e.name)
          .toList()
          .cast<String>(),
    );
  }
}

extension SearchPlaylistExtension on yt.SearchPlaylist {
  OmniwaveAlbum toOmniwaveAlbum() {
    return OmniwaveAlbum(
      name: playlistTitle,
      imageUrl: thumbnails.isNotEmpty
          ? (kIsWeb ? webProxyUrl : '') + thumbnails.last.url.toString()
          : null,
      artists: const ['TODO use yt Playlist'],
    );
  }
}

extension PlaylistExtension on yt.Playlist {
  OmniwaveAlbum toOmniwaveAlbum() {
    return OmniwaveAlbum(
      name: title,
      imageUrl: thumbnails.highResUrl,
      artists: [author],
    );
  }
}
