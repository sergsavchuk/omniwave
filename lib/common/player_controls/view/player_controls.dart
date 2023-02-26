import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:omniwave/common/player_controls/player_controls.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _CoverWithTrackName(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => context
                        .read<PlayerBloc>()
                        .add(PlayerPrevTrackRequested()),
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                      size: 40,
                    ),
                    padding: EdgeInsets.zero,
                    color: Colors.white,
                  ),
                  const _TogglePlayButton(),
                  IconButton(
                    onPressed: () => context
                        .read<PlayerBloc>()
                        .add(PlayerNextTrackRequested()),
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      size: 40,
                    ),
                    padding: EdgeInsets.zero,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(
                width: 400,
                child: _PlaybackProgressIndicator(),
              )
            ],
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class SmallPlayerControls extends StatelessWidget {
  const SmallPlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Padding(
                padding: EdgeInsets.all(10),
                child: _CoverWithTrackName(iconSize: 50),
              ),
              _TogglePlayButton(),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: _PlaybackProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

class _PlaybackProgressIndicator extends StatelessWidget {
  const _PlaybackProgressIndicator();

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

class _CoverWithTrackName extends StatelessWidget {
  const _CoverWithTrackName({this.iconSize = 100});

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
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.currentTrack?.name ?? '',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                state.currentTrack?.artists.join(', ') ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TogglePlayButton extends StatelessWidget {
  const _TogglePlayButton();

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
