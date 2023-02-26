import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';

import 'package:omniwave/common/app_scaffold/app_scaffold.dart';
import 'package:omniwave/common/player_controls/bloc/player_bloc.dart';
import 'package:omniwave/styles.dart';
import 'package:omniwave/track_collection/track_collection.dart';
import 'package:omniwave/utils.dart';

class TrackCollectionPage extends StatelessWidget {
  const TrackCollectionPage({
    super.key,
    required this.trackCollection,
    required this.category,
  });

  static Route<void> route(
    TrackCollection trackCollection,
    MusicItemCategory category,
  ) =>
      MaterialPageRoute(
        builder: (_) => TrackCollectionPage(
          trackCollection: trackCollection,
          category: category,
        ),
      );

  final TrackCollection trackCollection;
  final MusicItemCategory category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrackCollectionBloc(),
      child: AppScaffold(
        body: Utils.isSmallScreen
            ? SmallTrackCollectionView(trackCollection: trackCollection)
            : const SizedBox.shrink(),
        category: category,
      ),
    );
  }
}

class SmallTrackCollectionView extends StatelessWidget {
  const SmallTrackCollectionView({super.key, required this.trackCollection});

  final TrackCollection trackCollection;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackCollectionBloc, TrackCollectionState>(
      builder: (context, state) {
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: Insets.small,
                      left: Insets.large,
                      right: Insets.large,
                      top: Insets.large,
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        trackCollection.imageUrl ?? 'some-default-image-url',
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: Insets.small),
                  child: Text(
                    trackCollection.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: Insets.small),
                  child: Text(
                    trackCollection.artists.join(', '),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    itemCount: trackCollection.tracks.length,
                    itemBuilder: (context, index) => _TrackItemView(
                      trackCollection.tracks[index],
                      trackCollection,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 50,
              left: 10,
              child: IconButton(
                iconSize: 30,
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            )
          ],
        );
      },
    );
  }
}

class _TrackItemView extends StatelessWidget {
  const _TrackItemView(this.track, this.trackCollection);

  final Track track;
  final TrackCollection trackCollection;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<PlayerBloc>().add(
            PlayerTrackPlayRequested(track, trackCollection: trackCollection),
          ),
      child: Padding(
        padding: const EdgeInsets.all(Insets.small),
        child: BlocBuilder<PlayerBloc, PlayerState>(
          buildWhen: (prev, curr) => prev.currentTrack != curr.currentTrack,
          builder: (context, state) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: state.currentTrack == track
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.white,
                    ),
              ),
              Text(
                track.artists.join(', '),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}
