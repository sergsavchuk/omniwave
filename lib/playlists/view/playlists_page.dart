import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omniwave/common/app_scaffold/app_scaffold.dart';

import 'package:omniwave/playlists/playlists.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const PlaylistsPage());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      category: MusicItemCategory.playlists,
      body: BlocProvider(
        create: (_) => PlaylistsBloc(),
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
        return const SizedBox.shrink();
      },
    );
  }
}
