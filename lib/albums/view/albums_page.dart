import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';

import 'package:omniwave/albums/albums.dart';
import 'package:omniwave/common/album_card.dart';
import 'package:omniwave/common/app_scaffold/app_scaffold.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const AlbumsPage());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      category: MusicItemCategory.albums,
      body: BlocProvider(
        create: (_) =>
            AlbumsBloc(musicRepository: context.read<MusicRepository>())
              ..add(AlbumsStarted()),
        child: BlocListener<AppScaffoldBloc, AppScaffoldState>(
          listenWhen: (prev, curr) =>
              prev.spotifyConnected != curr.spotifyConnected,
          listener: (context, __) =>
              context.read<AlbumsBloc>().add(AlbumsStarted()),
          child: const AlbumsView(),
        ),
      ),
    );
  }
}

class AlbumsView extends StatelessWidget {
  const AlbumsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumsBloc, AlbumsState>(
      builder: (context, state) {
        return GridView.count(
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          children:
              state.albums.map((album) => AlbumCard(album: album)).toList(),
        );
      },
    );
  }
}