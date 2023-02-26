import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/albums/albums.dart';
import 'package:omniwave/bloc/app_settings_bloc.dart';
import 'package:omniwave/common/app_scaffold/app_scaffold.dart';
import 'package:omniwave/common/track_collection_card.dart';
import 'package:omniwave/utils.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const AlbumsPage());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      category: MusicItemCategory.albums,
      body: BlocProvider(
        create: (context) =>
            AlbumsBloc(musicRepository: context.read<MusicRepository>())
              ..add(AlbumsStarted()),
        child: BlocListener<AppSettingsBloc, AppSettingsState>(
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
          crossAxisCount: Utils.isSmallScreen ? 2 : 4,
          childAspectRatio: Utils.isSmallScreen ? 2 : 0.75,
          children: state.albums
              .map((album) => TrackCollectionCard(trackCollection: album))
              .toList(),
        );
      },
    );
  }
}
