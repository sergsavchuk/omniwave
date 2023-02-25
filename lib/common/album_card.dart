import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/common/player_controls/player_controls.dart';
import 'package:omniwave/styles.dart';

class AlbumCard extends StatefulWidget {
  const AlbumCard({
    super.key,
    required this.album,
  });

  final Album album;

  @override
  State<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  bool _hovered = false;

  String _albumUrl(String? url) =>
      widget.album.imageUrl ?? 'some-default-image-url';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context
            .read<PlayerBloc>()
            .add(PlayerAlbumPlayRequested(widget.album)),
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
                            _albumUrl(widget.album.imageUrl),
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
                  widget.album.name,
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
                  widget.album.artists.join(', '),
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
