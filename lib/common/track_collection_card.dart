import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/common/player_controls/player_controls.dart';
import 'package:omniwave/styles.dart';
import 'package:omniwave/utils.dart';

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
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: Utils.isSmallScreen
                ? EdgeInsets.zero
                : const EdgeInsets.all(Insets.small),
            child: Utils.isSmallScreen
                ? _SmallCollectionInfo(
                    collection: widget.trackCollection,
                    hovered: _hovered,
                  )
                : _CollectionInfo(
                    collection: widget.trackCollection,
                    hovered: _hovered,
                  ),
          ),
        ),
      ),
    );
  }
}

class _CollectionInfo extends StatelessWidget {
  const _CollectionInfo({required this.collection, required this.hovered});

  final TrackCollection collection;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: _TrackCollectionCover(
            imageUrl: collection.imageUrl ?? 'some-default-image-url',
            hovered: hovered,
          ),
        ),
        const SizedBox(
          height: Insets.small,
        ),
        Text(
          collection.name,
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
          collection.artists.join(', '),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SmallCollectionInfo extends StatelessWidget {
  const _SmallCollectionInfo({required this.collection, required this.hovered});

  final TrackCollection collection;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TrackCollectionCover(
          imageUrl: collection.imageUrl ?? 'some-default-image-url',
          hovered: hovered,
        ),
        const SizedBox(
          width: Insets.extraSmall,
        ),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                collection.name,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
              Text(
                collection.artists.join(', '),
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
        const SizedBox(
          width: Insets.extraSmall,
        ),
      ],
    );
  }
}

class _TrackCollectionCover extends StatelessWidget {
  const _TrackCollectionCover({required this.imageUrl, required this.hovered});

  final String imageUrl;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              imageUrl,
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
        if (hovered) Container(color: Colors.white24),
        if (hovered)
          Container(
            alignment: Alignment.center,
            child: const Icon(
              Icons.play_circle_fill,
              color: Colors.green,
              size: 50,
            ),
          ),
      ],
    );
  }
}
