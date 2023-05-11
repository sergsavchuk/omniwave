import 'dart:async';
import 'package:async/async.dart';
import 'package:common_models/common_models.dart';
import 'package:music_repository/src/spotify_music_repository.dart';
import 'package:music_repository/src/youtube_music_repository.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

const unknown = 'Unknown';
const pageSize = 20;

abstract class MusicRepository {
  Stream<List<Album>> albumsStream();

  Stream<List<Track>> tracksStream();

  Stream<List<Playlist>> playlistsStream();

  Stream<SearchResult<Object>> search(String searchQuery);

  Future<void> dispose();
}

class MusicRepositoryImpl implements MusicRepository {
  MusicRepositoryImpl({required bool useYoutubeProxy})
      : _youtubeMusicRepository =
            YoutubeMusicRepository(useYoutubeProxy: useYoutubeProxy);

  final SpotifyMusicRepository _spotifyMusicRepository =
      SpotifyMusicRepository();
  late final YoutubeMusicRepository _youtubeMusicRepository;

  late final List<MusicRepository> _repositories = [
    _spotifyMusicRepository,
    _youtubeMusicRepository
  ];

  late final yt.YoutubeExplode _youtube;

  bool get spotifyConnected => _spotifyMusicRepository.spotifyConnected;

  final Map<MusicRepository, List<Album>> _albumsMap = {};
  StreamController<List<Album>>? _albumsStreamController;

  final Map<MusicRepository, List<Playlist>> _playlistsMap = {};
  StreamController<List<Playlist>>? _playlistsStreamController;

  final Map<MusicRepository, List<Track>> _tracksMap = {};
  StreamController<List<Track>>? _tracksStreamController;

  final _subscriptions = <StreamSubscription<dynamic>>[];

  Future<void> connectSpotify(String clientId, String redirectUrl) =>
      _spotifyMusicRepository.connectSpotify(clientId, redirectUrl);

  Stream<Album> loadAlbumsPage(int offset) async* {
    yield* _spotifyMusicRepository.loadAlbumsPage(offset);
  }

  @override
  Stream<SearchResult<Object>> search(String searchQuery) => StreamGroup.merge(
        _repositories.map((element) => element.search(searchQuery)),
      );

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

  @override
  Stream<List<Album>> albumsStream() {
    if (_albumsStreamController == null) {
      _albumsStreamController = StreamController();

      for (final repository in _repositories) {
        _subscribeToSubrepoStream(
          _albumsStreamController!,
          _albumsMap,
          repository,
          repository.albumsStream(),
        );
      }
    }

    return _albumsStreamController!.stream;
  }

  @override
  Stream<List<Playlist>> playlistsStream() {
    if (_playlistsStreamController == null) {
      _playlistsStreamController = StreamController();

      for (final repository in _repositories) {
        _subscribeToSubrepoStream(
          _playlistsStreamController!,
          _playlistsMap,
          repository,
          repository.playlistsStream(),
        );
      }
    }

    return _playlistsStreamController!.stream;
  }

  @override
  Stream<List<Track>> tracksStream() {
    if (_tracksStreamController == null) {
      _tracksStreamController = StreamController();

      for (final repository in _repositories) {
        _subscribeToSubrepoStream(
          _tracksStreamController!,
          _tracksMap,
          repository,
          repository.tracksStream(),
        );
      }
    }

    return _tracksStreamController!.stream;
  }

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
  }

  void _subscribeToSubrepoStream<T>(
    StreamController<List<T>> streamController,
    Map<MusicRepository, List<T>> accumulatingMap,
    MusicRepository repository,
    Stream<List<T>> stream,
  ) {
    _subscriptions.add(
      stream.listen((items) {
        accumulatingMap[repository] = items;
        streamController.add(
          accumulatingMap.values.fold(
            [],
            (previousValue, element) => previousValue + element,
          ),
        );
      }),
    );
  }
}
