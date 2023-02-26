import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/common/player_controls/player_controls.dart';
import 'package:omniwave/styles.dart';

class TrackCollectionCard extends StatefulWidget {
  const TrackCollectionCard({
    super.key,
    required this.trackCollection,
  });

  final TrackCollection trackCollection;

  @override
  State<TrackCollectionCard> createState() => _TrackCollectionCardState();
}

class _TrackCollectionCardState extends State<TrackCollectionCard> {
  bool _hovered = false;

  String _trackCollectionImage(String? url) =>
      widget.trackCollection.imageUrl ?? 'some-default-image-url';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context
            .read<PlayerBloc>()
            .add(PlayerTrackCollectionPlayRequested(widget.trackCollection)),
        child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(Insets.small),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Stack(
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            _trackCollectionImage(
                              widget.trackCollection.imageUrl,
                            ),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      if (_hovered) Container(color: Colors.white24),
                      if (_hovered)
                        Container(
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.green,
                            size: 50,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: Insets.small,
                ),
                Text(
                  widget.trackCollection.name,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(
                  height: Insets.small,
                ),
                Text(
                  widget.trackCollection.artists.join(', '),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
