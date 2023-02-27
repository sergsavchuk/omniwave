import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/common/common.dart';

import 'package:omniwave/playlists/playlists.dart';
import 'package:omniwave/utils.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const PlaylistsPage());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      category: MusicItemCategory.playlists,
      body: BlocProvider(
        create: (context) =>
            PlaylistsBloc(musicRepository: context.read<MusicRepository>())
              ..add(const PlaylistsPageLoadRequested(0)),
        child: const PlaylistsView(),
      ),
    );
  }
}

class PlaylistsView extends StatelessWidget {
  const PlaylistsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistsBloc, PlaylistsState>(
      builder: (context, state) {
        return GridWithPagination(
          crossAxisCount: Utils.isSmallScreen ? 2 : 4,
          childAspectRatio: Utils.isSmallScreen ? 2 : 0.75,
          onGridEndReached: () {
            if (!state.loadingNextPage) {
              context
                  .read<PlaylistsBloc>()
                  .add(PlaylistsPageLoadRequested(state.playlists.length));
            }
          },
          loadingNextPage: state.loadingNextPage,
          children: state.playlists
              .map(
                (playlist) => TrackCollectionCard(
                  trackCollection: playlist,
                  category: MusicItemCategory.playlists,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
