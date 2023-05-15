import 'dart:async';

import 'package:common_models/common_models.dart';
import 'package:music_repository/music_repository.dart';
import 'package:music_repository/src/provider/cache_music_provider.dart';
import 'package:spotify/spotify.dart' as spotify;

class SpotifyMusicProvider implements MusicProviderWithCacheCapability {
  SpotifyMusicProvider(Stream<String> accessTokenStream) {
    _accessTokenSubscription = accessTokenStream.listen(_accessTokenChanged);
  }

  static const maxPageSize = 50;

  spotify.SpotifyApi? _spotifyApi;
  StreamSubscription<String>? _accessTokenSubscription;

  // TODO(sergsavchuk): should we do something with the prev version
  //  of the _spotifyApi when the access token changes?
  void _accessTokenChanged(String accessToken) {
    _spotifyApi = spotify.SpotifyApi.withAccessToken(accessToken);
  }

  @override
  List<MusicSource> get supportedSources => [MusicSource.spotify];

  @override
  Future<List<Album>> albums() async {
    final spotifyApi = _spotifyApi;
    if (spotifyApi == null) {
      return [];
    }

    final albums = <Album>[];

    var page = await spotifyApi.me.savedAlbums().getPage(maxPageSize, 0);

    do {
      if (page.items != null) {
        albums.addAll(page.items!.map((e) => e.toOmniwaveAlbum()));
      }

      if (!page.isLast) {
        page = await spotifyApi.me
            .savedAlbums()
            .getPage(maxPageSize, page.nextOffset);
      }
    } while (!page.isLast);

    return albums;
  }

  @override
  Stream<List<Album>> albumsStream() async* {
    // TODO(sergsavchuk): implement albumsStream
  }

  @override
  Future<bool> albumsCacheOutdated(List<Album> albumsCache) async {
    final spotifyApi = _spotifyApi;
    if (spotifyApi == null) {
      return false;
    }

    final page = await spotifyApi.me.savedAlbums().getPage(1, 0);
    final lengthEqual = page.metadata.total == albumsCache.length;
    final firstItemsEqual = (page.items?.isEmpty ?? true) ||
        page.items?.first.toOmniwaveAlbum() == albumsCache.first;

    return !lengthEqual || !firstItemsEqual;
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

  @override
  Future<Uri?> getTrackAudioUrl(Track track) async {
    // Spotify doesn't provide audio urls - you have to use the SpotifySdk
    // to play a Spotify track
    return null;
  }

  @override
  Future<void> dispose() async {
    await _accessTokenSubscription?.cancel();
  }
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
