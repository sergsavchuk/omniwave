import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:music_repository/src/models/models.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaybackState {
  PlaybackState({required this.position, required this.isPaused});

  final bool isPaused;
  final Duration position;
}

class MusicRepository {
  MusicRepository({required bool useYoutubeProxy})
      : _useYoutubeProxy = useYoutubeProxy;

  spotify.SpotifyApi? _spotifyApi;
  bool _spotifySdkConnected = false;
  final String _spotifyScope = [
    'user-library-read',
    'streaming',
    'user-read-email',
    'user-read-private',
  ].join(',');

  final bool _useYoutubeProxy;

  bool get spotifyConnected => _spotifyApi != null && _spotifySdkConnected;

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

  Stream<Album> loadAlbums() async* {
    if (_spotifyApi != null) {
      const pageSize = 20;
      var offset = 0;
      spotify.Page<spotify.AlbumSimple> page;
      while (!(page =
              await _spotifyApi!.me.savedAlbums().getPage(pageSize, offset))
          .isLast) {
        final spotifyAlbums = page.items;
        if (spotifyAlbums != null) {
          for (final spotifyAlbum in spotifyAlbums) {
            yield spotifyAlbum.toOmniwaveAlbum();
          }
        }

        offset += pageSize;
      }
    }
  }

  Future<void> spotifyPlay(Track track) {
    return SpotifySdk.play(
      spotifyUri: 'spotify:track:${track.id}',
    );
  }

  Stream<PlaybackState> spotifyPlayerState() {
    return SpotifySdk.subscribePlayerState().map(
      (state) => PlaybackState(
        position: Duration(
          milliseconds: state.playbackPosition,
        ),
        isPaused: state.isPaused,
      ),
    );
  }

  void spotifyPausePlay() {
    SpotifySdk.pause();
  }

  void spotifyResumePlay() {
    SpotifySdk.resume();
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
