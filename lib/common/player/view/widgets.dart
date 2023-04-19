import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:omniwave/common/player/player_controls.dart';
import 'package:omniwave/styles.dart';

class PlaybackProgressIndicator extends StatelessWidget {
  const PlaybackProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => BlocBuilder<PlayerBloc, PlayerState>(
        buildWhen: (prev, curr) =>
            prev.playbackPosition != curr.playbackPosition,
        builder: (_, state) => Stack(
          children: [
            const Divider(
              thickness: 2,
              color: Colors.grey,
            ),
            Positioned(
              width: constraints.maxWidth * state.playbackProgress,
              child: const Divider(
                thickness: 2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CoverWithTrackName extends StatelessWidget {
  const CoverWithTrackName({super.key, this.iconSize = 100});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (prev, curr) => prev.currentTrack != curr.currentTrack,
      builder: (context, state) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.currentTrack != null)
            Image.network(
              state.currentTrack?.imageUrl ?? 'default-image',
              width: iconSize,
              height: iconSize,
            ),
          const SizedBox(width: Insets.extraSmall),
          TrackWithArtist(
            trackName: state.currentTrack?.name ?? '',
            artist: state.currentTrack?.artists.join(', ') ?? '',
          ),
        ],
      ),
    );
  }
}

class TrackWithArtist extends StatelessWidget {
  const TrackWithArtist({
    super.key,
    required this.trackName,
    required this.artist,
  });

  final String trackName;
  final String artist;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trackName,
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          artist,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class TogglePlayButton extends StatelessWidget {
  const TogglePlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (prev, curr) => prev.isPlaying != curr.isPlaying,
      builder: (context, state) {
        return IconButton(
          onPressed: () =>
              context.read<PlayerBloc>().add(PlayerToggleRequested()),
          icon: Icon(
            state.isPlaying
                ? Icons.pause_circle_filled
                : Icons.play_circle_fill,
            size: 40,
          ),
          padding: EdgeInsets.zero,
          color: Colors.white,
        );
      },
    );
  }
}

class PrevTrackButton extends StatelessWidget {
  const PrevTrackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () =>
          context.read<PlayerBloc>().add(PlayerPrevTrackRequested()),
      icon: const Icon(
        Icons.skip_previous_rounded,
        size: 40,
      ),
      padding: EdgeInsets.zero,
      color: Colors.white,
    );
  }
}

class NextTrackButton extends StatelessWidget {
  const NextTrackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () =>
          context.read<PlayerBloc>().add(PlayerNextTrackRequested()),
      icon: const Icon(
        Icons.skip_next_rounded,
        size: 40,
      ),
      padding: EdgeInsets.zero,
      color: Colors.white,
    );
  }
}
