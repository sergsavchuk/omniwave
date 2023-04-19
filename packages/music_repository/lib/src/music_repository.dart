import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:music_repository/src/models/models.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

const webProxyUrl = 'http://localhost:8080/';

class PlaybackState {
  PlaybackState({required this.position, required this.isPaused});

  final bool isPaused;
  final Duration position;
}

class MusicRepository {
  MusicRepository({required bool useYoutubeProxy})
      : _useYoutubeProxy = useYoutubeProxy {
    _youtube = yt.YoutubeExplode(_useYoutubeProxy ? _ProxyHttpClient() : null);
  }

  spotify.SpotifyApi? _spotifyApi;
  bool _spotifySdkConnected = false;
  final String _spotifyScope = [
    'user-library-read',
    'streaming',
    'user-read-email',
    'user-read-private',
  ].join(',');

  final bool _useYoutubeProxy;
  late final yt.YoutubeExplode _youtube;

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

  Stream<Album> loadAlbumsPage(int offset) async* {
    if (_spotifyApi != null) {
      const pageSize = 20;
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

  // TODO(sergsavchuk): add Spotify search
  Stream<SearchResult<Object>> search(String searchQuery) async* {
    final searchList = await _youtube.search.searchContent(searchQuery);

    for (final searchItem in searchList) {
      if (searchItem is yt.SearchPlaylist) {
        final playlistId = searchItem.playlistId.value;
        final tracks = await _youtube.playlists
            .getVideos(playlistId)
            .map((event) => event.toOmniwaveTrack(albumId: playlistId))
            .toList();

        // TODO(sergsavchuk): don't load playlist - use data from the searchItem
        yield SearchResult(
          (await _youtube.playlists.get(playlistId)).toOmniwavePlaylist(tracks),
        );
      } else if (searchItem is yt.SearchVideo) {
        final videoId = searchItem.id.value;
        // TODO(sergsavchuk): don't load video - use data from the searchItem
        final video = await _youtube.videos.get(videoId);

        yield SearchResult(video.toOmniwaveTrack(albumId: 'no-album'));
      }
    }
  }

  Future<Uri> playYoutubeTrack(Track track) async {
    final manifest = await _youtube.videos.streams.getManifest(track.id);
    final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
    return audioStreamInfo.url;
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

  Future<void> spotifyPausePlay() async {
    await SpotifySdk.pause();
  }

  Future<void> spotifyResumePlay() async {
    await SpotifySdk.resume();
  }
}

/// A workaround for web platform. [yt.YoutubeExplode] doesn't work in web
/// because of CORS, so the only solution now is to use any proxy server.
///
/// But even with the proxy there is still a problem with youtube responding
/// 403 Forbidden to any POST request. Maybe this is because http.BrowserClient
/// doesn't support BaseRequest.persistentConnection unlike IOClient.
// TODO(sergsavchuk): investigate the situation further
class _ProxyHttpClient extends yt.YoutubeHttpClient {
  @override
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers = const {},
    bool validate = false,
  }) {
    return super.get(
      Uri.parse('$webProxyUrl$url'),
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

extension PlaylistExtension on yt.Playlist {
  Playlist toOmniwavePlaylist(List<Track> tracks) {
    return Playlist(
      id: id.value,
      name: title,
      imageUrl: tracks.isNotEmpty ? tracks[0].imageUrl : null,
      artists: [author],
      tracks: tracks,
      source: MusicSource.youtube,
    );
  }
}

extension SpotifyAlbumExtension on spotify.AlbumSimple {
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

extension SpotifyTrackExtension on spotify.TrackSimple {
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

extension YoutubeTrackExtension on yt.Video {
  Track toOmniwaveTrack({required String albumId}) {
    return Track(
      id: id.value,
      name: title,
      href: url,
      imageUrl: thumbnails.highResUrl,
      artists: [author],
      duration: duration ?? Duration.zero,
      source: MusicSource.youtube,
      albumId: albumId,
    );
  }
}
