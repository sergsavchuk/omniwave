import 'dart:math';

import 'package:common_models/common_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:omniwave/common/common.dart';
import 'package:omniwave/styles.dart';
import 'package:omniwave/track_collection/track_collection.dart';
import 'package:omniwave/utils.dart';

const gradientBreakPosition = 70;

class TrackCollectionPage extends StatelessWidget {
  const TrackCollectionPage({
    super.key,
    required this.trackCollection,
    required this.category,
  });

  static Route<void> route(
    TrackCollection trackCollection,
    NavBarItem category,
  ) =>
      MaterialPageRoute(
        builder: (_) => TrackCollectionPage(
          trackCollection: trackCollection,
          category: category,
        ),
      );

  final TrackCollection trackCollection;
  final NavBarItem category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrackCollectionBloc(),
      child: AppScaffold(
        noTopPadding: true,
        body: Utils.isSmallScreen
            ? SmallTrackCollectionView(trackCollection: trackCollection)
            : const SizedBox.shrink(),
        category: category,
      ),
    );
  }
}

class SmallTrackCollectionView extends StatefulWidget {
  const SmallTrackCollectionView({super.key, required this.trackCollection});

  final TrackCollection trackCollection;

  @override
  State<SmallTrackCollectionView> createState() =>
      _SmallTrackCollectionViewState();
}

class _SmallTrackCollectionViewState extends State<SmallTrackCollectionView> {
  static const collapsedAppBarHeight = kToolbarHeight;
  static const expandedAppBarHeight = 250.0;

  static const playButtonInset = Insets.extraSmall;
  static const playButtonSize = 50.0;

  final playButtonKey = GlobalKey();
  final appBarKey = GlobalKey();

  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController()
      ..addListener(
        () => context.read<TrackCollectionBloc>().add(
              TrackCollectionScrollPositionChanged(scrollController.offset),
            ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              key: appBarKey,
              pinned: true,
              expandedHeight: expandedAppBarHeight,
              // ignore: avoid_redundant_argument_values
              toolbarHeight: collapsedAppBarHeight,
              title: BlocBuilder<TrackCollectionBloc, TrackCollectionState>(
                builder: (context, state) => Opacity(
                  // TODO(sergsavchuk): use FadeTransition with curved animation
                  opacity: min(state.scrollPosition / expandedAppBarHeight, 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: playButtonSize),
                    child: Text(
                      widget.trackCollection.name,
                      style: const TextStyle(overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
              ),
              flexibleSpace: _ExpandedAppBarContent(
                expandedAppBarHeight: expandedAppBarHeight,
                trackCollection: widget.trackCollection,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                DynamicGradient(
                  imageUrl:
                      widget.trackCollection.imageUrl ?? Urls.defaultCover,
                  blendAmount: gradientBreakPosition,
                  surfaceColor: Theme.of(context).colorScheme.surface,
                  fromBlended: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: Insets.small),
                        child: Text(
                          widget.trackCollection.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: Insets.small),
                        child: Text(
                          Helpers.joinArtists(widget.trackCollection.artists),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: playButtonInset,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => {},
                              icon: const Icon(Icons.favorite_outline),
                            ),
                            _PlayTrackCollectionButton(
                              key: playButtonKey,
                              trackCollection: widget.trackCollection,
                              size: playButtonSize,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _TrackItemView(
                  widget.trackCollection.tracks[index],
                  widget.trackCollection,
                ),
                childCount: widget.trackCollection.tracks.length,
              ),
            ),
          ],
        ),
        BlocBuilder<TrackCollectionBloc, TrackCollectionState>(
          builder: (context, state) => Positioned(
            top: _appBarBottomPos(context) - _calculateAppBarPlayButtonOffset(),
            right: playButtonInset,
            child: Visibility(
              visible: _shouldShowAppBarPlayButton(),
              child: _PlayTrackCollectionButton(
                trackCollection: widget.trackCollection,
                size: playButtonSize,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  double _calculateAppBarPlayButtonOffset() {
    // get the render objects of the play button and the app bar using
    // Global keys
    final playButtonRO =
        playButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final appBarRO = appBarKey.currentContext?.findRenderObject()
        as RenderSliverPersistentHeader?;

    if (playButtonRO != null && appBarRO != null && appBarRO.child != null) {
      // calculate the distance between the app bar and the play button
      final diff = appBarRO.child!.localToGlobal(Offset.zero).dy +
          _appBarBottomPos(context) -
          playButtonRO.localToGlobal(Offset.zero).dy;

      // limit the offset to half the size of the button
      return min(diff, playButtonSize / 2);
    } else {
      return -1;
    }
  }

  double _appBarBottomPos(BuildContext context) =>
      collapsedAppBarHeight + MediaQuery.paddingOf(context).top;

  bool _shouldShowAppBarPlayButton() => _calculateAppBarPlayButtonOffset() >= 0;
}

class _ExpandedAppBarContent extends StatelessWidget {
  const _ExpandedAppBarContent({
    required this.expandedAppBarHeight,
    required this.trackCollection,
  });

  final double expandedAppBarHeight;
  final TrackCollection trackCollection;

  @override
  Widget build(BuildContext context) {
    return DynamicGradient(
      imageUrl: trackCollection.imageUrl ?? Urls.defaultCover,
      blendAmount: gradientBreakPosition,
      surfaceColor: Theme.of(context).colorScheme.surface,
      child: Center(
        child: BlocBuilder<TrackCollectionBloc, TrackCollectionState>(
          builder: (context, state) => Padding(
            padding: EdgeInsets.only(
              top: Insets.large *
                  _invertedScrollPercent(
                    state.scrollPosition,
                    expandedAppBarHeight,
                  ),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Opacity(
                // TODO(sergsavchuk): use FadeTransition with curved animation
                opacity: _invertedScrollPercent(
                  state.scrollPosition,
                  expandedAppBarHeight,
                ),
                child: Image.network(
                  trackCollection.imageUrl ?? Urls.defaultCover,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _scrollPercent(double scroll, double height) =>
      min(scroll / height, 1);

  double _invertedScrollPercent(double scroll, double height) =>
      1 - _scrollPercent(scroll, height);
}

class _PlayTrackCollectionButton extends StatelessWidget {
  const _PlayTrackCollectionButton({
    super.key,
    required this.trackCollection,
    required this.size,
  });

  final TrackCollection trackCollection;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<PlayerBloc>().add(
            PlayerTrackCollectionPlayToggleRequested(trackCollection),
          ),
      child: Container(
        width: size,
        height: size,
        // alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) => Icon(
            state.currentTrackCollection == trackCollection && state.isPlaying
                ? Icons.pause_sharp
                : Icons.play_arrow_sharp,
            size: size * .65,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
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
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              Text(
                Helpers.joinArtists(track.artists),
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
        ),
      ),
    );
  }
}
