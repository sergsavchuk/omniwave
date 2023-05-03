import 'package:flutter/material.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/common/app_scaffold/app_scaffold.dart';
import 'package:omniwave/styles.dart';
import 'package:omniwave/track_collection/track_collection.dart';
import 'package:omniwave/utils.dart';

class TrackCollectionCard extends StatefulWidget {
  const TrackCollectionCard({
    super.key,
    required this.trackCollection,
    required this.category,
  });

  final TrackCollection trackCollection;
  final MusicItemCategory category;

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
        onTap: () => Navigator.of(context).push(
          TrackCollectionPage.route(
            widget.trackCollection,
            widget.category,
          ),
        ),
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
            imageUrl: collection.imageUrl ?? Urls.defaultCover,
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
          Helpers.joinArtists(collection.artists),
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
          imageUrl: collection.imageUrl ?? Urls.defaultCover,
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
                Helpers.joinArtists(collection.artists),
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
