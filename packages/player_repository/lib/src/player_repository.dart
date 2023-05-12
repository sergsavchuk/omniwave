import 'dart:async';
import 'dart:ui';

import 'package:common_models/common_models.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class PlayerRepository extends Player {
  PlayerRepository({List<String>? spotifyScope})
      : _spotifyScope = ((spotifyScope ?? <String>[]) + _spotifyPlayerScope)
            .toSet()
            .join(',');

  static const List<String> _spotifyPlayerScope = ['streaming'];

  final Map<MusicSource, Player> _players = {};
  Player? _player;

  final String _spotifyScope;
  bool _spotifySdkConnected = false;
  final StreamController<String> _accessTokenStreamController =
      StreamController();

  bool get spotifyConnected => _spotifySdkConnected;

  Stream<String> get accessTokenStream => _accessTokenStreamController.stream;

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

    _accessTokenStreamController.add(accessToken);
  }

  @override
  Future<void> play(Track track, {Uri? audioUrl}) async {
    if (track.source == MusicSource.spotify) {
      _players[track.source] ??= SpotifyPlayer()
        ..onTrackPlayed = onTrackPlayed
        ..onPlaybackPositionChange = onPlaybackPositionChange;
    } else if (track.source == MusicSource.youtube) {
      _players[track.source] ??= YoutubePlayer()
        ..onTrackPlayed = onTrackPlayed
        ..onPlaybackPositionChange = onPlaybackPositionChange;
    }

    if (_player != null) {
      await _player!.pause();
    }

    _player = _players[track.source];
    await _player!.play(track, audioUrl: audioUrl);
  }

  @override
  Future<void> resume() async {
    await _player?.resume();
  }

  @override
  Future<void> pause() async {
    await _player?.pause();
  }

  @override
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }

    onTrackPlayed = null;
    onPlaybackPositionChange = null;
  }
}

abstract class Player {
  VoidCallback? onTrackPlayed;
  void Function(Duration position)? onPlaybackPositionChange;

  Future<void> play(Track track, {Uri? audioUrl});

  Future<void> pause();

  Future<void> resume();

  Future<void> dispose();
}

class SpotifyPlayer extends Player {
  SpotifyPlayer() {
    // TODO(sergsavchuk): dispose subscription
    SpotifySdk.subscribePlayerState()
        .map(
          (state) => PlaybackState(
            position: Duration(milliseconds: state.playbackPosition),
            isPaused: state.isPaused,
          ),
        )
        .listen(_onPlayerStateChange);

    // TODO(sergsavchuk): use Ticker ?
    const timerPeriod = Duration(milliseconds: 50);
    _playbackTimer = Timer.periodic(timerPeriod, (_) {
      if (!_isPaused) {
        _playbackPosition += timerPeriod;
        onPlaybackPositionChange?.call(_playbackPosition);
      }
    });
  }

  late StreamSubscription<PlaybackState> _playbackStateSubscription;
  late Timer _playbackTimer;
  Duration _playbackPosition = Duration.zero;

  bool _isPaused = true;

  // TODO(sergsavchuk): remove this ignore after nullable logic added to
  //  the field
  // ignore: use_late_for_private_fields_and_variables
  Track? _track;

  @override
  Future<void> play(Track track, {Uri? audioUrl}) async {
    _track = track;

    await SpotifySdk.play(spotifyUri: 'spotify:track:${track.id}');
  }

  @override
  Future<void> pause() async {
    await SpotifySdk.pause();
  }

  @override
  Future<void> resume() async {
    await SpotifySdk.resume();
  }

  @override
  Future<void> dispose() async {
    await _playbackStateSubscription.cancel();
    _playbackTimer.cancel();
  }

  // TODO(sergsavchuk): implement the same logic as in
  //  the AudioPlayer.positionStream
  void _onPlayerStateChange(PlaybackState playbackState) {
    _playbackPosition = playbackState.position;
    onPlaybackPositionChange?.call(playbackState.position);

    _isPaused = playbackState.isPaused;

    if (_playbackPosition >= _track!.duration) {
      onTrackPlayed?.call();
    }
  }
}

class YoutubePlayer extends Player {
  YoutubePlayer() {
    _positionSubscription =
        _player.positionStream.listen(onPlaybackPositionChange);
    _stateSubscription = _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        onTrackPlayed?.call();
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<ProcessingState> _stateSubscription;

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> play(Track track, {Uri? audioUrl}) async {
    await _player.setAudioSource(AudioSource.uri(audioUrl!));
    unawaited(_player.play());
  }

  @override
  Future<void> resume() async {
    await _player.play();
  }

  @override
  Future<void> dispose() async {
    await _positionSubscription.cancel();
    await _stateSubscription.cancel();
    await _player.dispose();
  }
}
