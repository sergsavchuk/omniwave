import 'package:flutter/material.dart';

import 'package:omniwave/common/player/view/fullscreen_player.dart';
import 'package:omniwave/common/player/view/widgets.dart';

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
          const CoverWithTrackName(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  PrevTrackButton(),
                  TogglePlayButton(),
                  NextTrackButton(),
                ],
              ),
              const SizedBox(
                width: 400,
                child: PlaybackProgressIndicator(),
              )
            ],
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class FloatingPlayerControls extends StatelessWidget {
  const FloatingPlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(FullscreenPlayer.route()),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: CoverWithTrackName(iconSize: 50),
                  ),
                ),
                TogglePlayButton(),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: PlaybackProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
