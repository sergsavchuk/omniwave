import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:omniwave/common/player/player_controls.dart';
import 'package:omniwave/styles.dart';
import 'package:omniwave/utils.dart';

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
              state.currentTrack?.imageUrl ?? Urls.defaultCover,
              width: iconSize,
              height: iconSize,
            ),
          const SizedBox(width: Insets.extraSmall),
          Flexible(
            child: TrackWithArtist(
              trackName: state.currentTrack?.name ?? '',
              artist: Helpers.joinArtists(state.currentTrack?.artists),
            ),
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
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        Text(
          artist,
          style: Theme.of(context).textTheme.bodySmall,
          overflow: TextOverflow.fade,
          softWrap: false,
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
