import 'package:equatable/equatable.dart';
import 'package:spotify/spotify.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

const webProxyUrl = 'http://localhost:443/';

class Album extends Equatable {
  const Album({this.name, this.imageUrl, this.artists});

  final String? name;
  final String? imageUrl;
  final List<String>? artists;

  Album copyWith({
    String? name,
    String? imageUrl,
    List<String>? artists,
  }) {
    return Album(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      artists: artists ?? this.artists,
    );
  }

  @override
  List<Object?> get props => [name, imageUrl, artists];
}

extension SpotifyAlbumExtension on AlbumSimple {
  Album toOmniwaveAlbum() {
    return Album(
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
  Album toOmniwaveAlbum({required bool useProxy}) {
    return Album(
      name: playlistTitle,
      imageUrl: thumbnails.isNotEmpty
          ? (useProxy ? webProxyUrl : '') + thumbnails.last.url.toString()
          : null,
      artists: const ['TODO use yt Playlist'],
    );
  }
}

extension PlaylistExtension on yt.Playlist {
  Album toOmniwaveAlbum() {
    return Album(
      name: title,
      imageUrl: thumbnails.highResUrl,
      artists: [author],
    );
  }
}
