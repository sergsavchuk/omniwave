import 'package:common_models/common_models.dart';
import 'package:music_repository/music_repository.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyMusicRepository implements MusicRepository {
  spotify.SpotifyApi? _spotifyApi;
  bool _spotifySdkConnected = false;

  final String _spotifyScope = [
    'user-library-read',
    'streaming',
    'user-read-email',
    'user-read-private',
  ].join(',');

  bool get spotifyConnected => _spotifyApi != null && _spotifySdkConnected;

  @override
  Stream<List<Album>> albumsStream() async* {
    // TODO(sergsavchuk): implement albumsStream
  }

  @override
  Stream<List<Playlist>> playlistsStream() async* {
    // TODO(sergsavchuk): implement playlistsStream
  }

  @override
  Stream<SearchResult<Object>> search(String searchQuery) async* {
    // TODO(sergsavchuk): implement search
  }

  @override
  Stream<List<Track>> tracksStream() async* {
    // TODO(sergsavchuk): implement tracksStream
  }

  Future<void> connectSpotify(String clientId, String redirectUrl) async {
    _spotifySdkConnected = await SpotifySdk.connectToSpotifyRemote(
      // accessToken: accessToken,
      clientId: clientId,
      redirectUrl: redirectUrl,
      scope: _spotifyScope,
      playerName: 'Omniwave Player',
    );

    // TODO(sergsavchuk): use SpotifyApi instead of
    // SpotifySdk to get the access token, cause
    // SpotifySdk doesn't support desktop platforms
    final accessToken = await SpotifySdk.getAccessToken(
      clientId: clientId,
      redirectUrl: redirectUrl,
      scope: _spotifyScope,
    );

    _spotifyApi = spotify.SpotifyApi.withAccessToken(accessToken);
  }

  Stream<Album> loadAlbumsPage(int offset) async* {
    if (_spotifyApi != null) {
      final page =
          await _spotifyApi!.me.savedAlbums().getPage(pageSize, offset);
      final spotifyAlbums = page.items;
      if (spotifyAlbums != null) {
        for (final spotifyAlbum in spotifyAlbums) {
          yield spotifyAlbum.toOmniwaveAlbum();
        }
      }
    }
  }

  @override
  Future<void> dispose() async {}
}

extension SpotifyAlbumExtension on spotify.AlbumSimple {
  Album toOmniwaveAlbum() {
    final albumId = id ?? unknown;
    return Album(
      id: albumId,
      name: name ?? unknown,
      imageUrl: images?[0].url,
      artists: artists
              ?.where((artist) => artist.name != null)
              .map((artist) => artist.name)
              .toList()
              .cast<String>() ??
          [unknown],
      tracks: tracks
              ?.map(
                (track) => track.toOmniwaveTrack(
                  albumId: albumId,
                  imageUrl: images?[0].url,
                ),
              )
              .toList() ??
          [],
      source: MusicSource.spotify,
    );
  }
}

extension SpotifyTrackExtension on spotify.TrackSimple {
  Track toOmniwaveTrack({required String albumId, required String? imageUrl}) {
    return Track(
      id: id ?? unknown,
      name: name ?? unknown,
      imageUrl: imageUrl,
      artists: artists
              ?.where((artist) => artist.name != null)
              .map((artist) => artist.name)
              .toList()
              .cast<String>() ??
          [unknown],
      duration: duration ?? Duration.zero,
      source: MusicSource.spotify,
      albumId: albumId,
    );
  }
}
