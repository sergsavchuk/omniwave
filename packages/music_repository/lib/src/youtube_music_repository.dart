import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:music_repository/music_repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

const webProxyUrl = 'http://localhost:8080/';

class YoutubeMusicRepository implements MusicRepository {
  YoutubeMusicRepository({required bool useYoutubeProxy})
      : _youtube =
            yt.YoutubeExplode(useYoutubeProxy ? _ProxyHttpClient() : null);

  late final yt.YoutubeExplode _youtube;

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

        yield SearchResult(video.toOmniwaveTrack(albumId: unknown));
      }
    }
  }

  @override
  Stream<List<Track>> tracksStream() async* {
    // TODO(sergsavchuk): implement tracksStream
  }

  @override
  Future<void> dispose() async {}
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

extension YoutubeTrackExtension on yt.Video {
  Track toOmniwaveTrack({required String albumId}) {
    return Track(
      id: id.value,
      name: title,
      imageUrl: thumbnails.highResUrl,
      artists: [author],
      duration: duration ?? Duration.zero,
      source: MusicSource.youtube,
      albumId: albumId,
    );
  }
}
