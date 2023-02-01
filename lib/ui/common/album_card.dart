import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:omniwave/models/album.dart';
import 'package:omniwave/styles.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.album,
  });

  final OmniwaveAlbum album;

  String _albumUrl(String? url) => album.imageUrl ?? 'some-default-image-url';

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(Insets.small),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    _albumUrl(album.imageUrl),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: Insets.small,
            ),
            Text(
              album.name ?? 'Unnamed album',
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
              album.artists?.join(', ') ?? 'Unknown artist',
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
