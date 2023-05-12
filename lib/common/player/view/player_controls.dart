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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CoverWithTrackName(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrevTrackButton(),
                  TogglePlayButton(),
                  NextTrackButton(),
                ],
              ),
              SizedBox(
                width: 400,
                child: PlaybackProgressIndicator(),
              )
            ],
          ),
          SizedBox.shrink(),
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
      child: const Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: CoverWithTrackName(iconSize: 50),
                  ),
                ),
                TogglePlayButton(),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: PlaybackProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
