import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:music_repository/src/models/models.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicRepository {
  MusicRepository({required bool useYoutubeProxy})
      : _useYoutubeProxy = useYoutubeProxy;

  spotify.SpotifyApi? _spotifyApi;
  final String _spotifyScope = 'user-library-read';

  final bool _useYoutubeProxy;

  bool get spotifyConnected => _spotifyApi != null;

  Future<void> connectSpotify(String clientId, String redirectUrl) async {
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

  Stream<Album> loadAlbums() async* {
    if (_spotifyApi != null) {
      await for (final page in _spotifyApi!.me.savedAlbums().stream()) {
        final spotifyAlbums = page.items;
        if (spotifyAlbums != null) {
          for (final spotifyAlbum in spotifyAlbums) {
            yield spotifyAlbum.toOmniwaveAlbum();
          }
        }
      }
    }
  }

  Stream<Album> youtubePlaylistSearch() async* {
    final yt = YoutubeExplode(_useYoutubeProxy ? _ProxyHttpClient() : null);
    final searchList = await yt.search
        .searchContent('Radiohead album', filter: TypeFilters.playlist);

    for (final searchItem in searchList) {
      yield (await yt.playlists.get(
        (searchItem as SearchPlaylist).playlistId.value,
      ))
          .toOmniwaveAlbum();
    }
  }
}

/// A workaround for web platform. [YoutubeExplode] doesn't work in web because
/// of CORS, so the only solution now is to use any proxy server.
///
/// But even with the proxy there is still a problem with youtube responding
/// 403 Forbidden to any POST request. Maybe this is because http.BrowserClient
/// doesn't support BaseRequest.persistentConnection unlike IOClient.
// TODO(sergsavchuk): investigate the situation further
class _ProxyHttpClient extends YoutubeHttpClient {
  @override
  Future<String> getString(
    dynamic url, {
    Map<String, String> headers = const {},
    bool validate = true,
  }) {
    return super.getString(
      '$webProxyUrl$url',
      headers: headers,
      validate: validate,
    );
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool validate = false,
  }) {
    return super.post(
      Uri.parse('$webProxyUrl$url'),
      headers: headers,
      body: body,
      encoding: encoding,
      validate: validate,
    );
  }
}
