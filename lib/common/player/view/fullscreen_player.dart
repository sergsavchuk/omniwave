import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omniwave/common/common.dart';
import 'package:omniwave/common/player/view/widgets.dart';
import 'package:omniwave/styles.dart';

class FullscreenPlayer extends StatelessWidget {
  const FullscreenPlayer({super.key});

  static Route<void> route() => PageRouteBuilder(
        pageBuilder: (_, __, ___) => const FullscreenPlayer(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
              .chain(CurveTween(curve: Curves.ease));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Insets.extraSmall / 2),
              child: IconButton(
                iconSize: 35,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Insets.large,
                horizontal: Insets.medium,
              ),
              child: BlocBuilder<PlayerBloc, PlayerState>(
                builder: (context, state) => AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    state.currentTrack?.imageUrl ?? 'default-image',
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Insets.medium),
              child: BlocBuilder<PlayerBloc, PlayerState>(
                builder: (context, state) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TrackWithArtist(
                      trackName: state.currentTrack?.name ?? '',
                      artist: state.currentTrack?.artists.join(', ') ?? '',
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Insets.medium,
                vertical: Insets.small,
              ),
              child: PlaybackProgressIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Insets.medium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SizedBox.shrink(),
                  PrevTrackButton(),
                  TogglePlayButton(),
                  NextTrackButton(),
                  SizedBox.shrink(),
                ],
              ),
            ),
            const SizedBox(height: Insets.medium),
          ],
        ),
      ),
    );
  }
}
