import 'package:flutter/material.dart';
import 'package:omniwave/styles.dart';
import 'package:spotify/spotify.dart' as spotify;

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.album,
  });

  final spotify.AlbumSimple album;

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
                child: Image.network(
                  album.images?[0].url ?? 'some-default-image',
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
              album.artists?[0].name ?? 'Unknown artist',
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
