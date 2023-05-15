import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/albums/albums.dart';
import 'package:omniwave/bloc/app_settings_bloc.dart';
import 'package:omniwave/common/common.dart';
import 'package:omniwave/utils.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const AlbumsPage());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      category: NavBarItem.albums,
      body: BlocProvider(
        create: (context) =>
            AlbumsBloc(musicRepository: context.read<MusicRepository>()),
        child: const AlbumsView(),
      ),
    );
  }
}

class AlbumsView extends StatefulWidget {
  const AlbumsView({super.key});

  @override
  State<AlbumsView> createState() => _AlbumsViewState();
}

class _AlbumsViewState extends State<AlbumsView> {
  @override
  void initState() {
    super.initState();

    context.read<AlbumsBloc>().add(const AlbumsInitialLoadRequested());

    // TODO(sergsavchuk): request connect on startup only if the user
    //  has been connected before
    context.read<AppSettingsBloc>().add(AppSettingsSpotifyConnectRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumsBloc, AlbumsState>(
      builder: (context, state) {
        return GridWithPagination(
          loadingNextPage: false,
          onGridEndReached: () {},
          crossAxisCount: Utils.isSmallScreen ? 2 : 4,
          childAspectRatio: Utils.isSmallScreen ? 2 : 0.75,
          children: state.albums
              .map(
                (album) => TrackCollectionCard(
                  trackCollection: album,
                  category: NavBarItem.albums,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
