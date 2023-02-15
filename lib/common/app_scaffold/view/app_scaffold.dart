import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:music_repository/music_repository.dart';
import 'package:omniwave/albums/albums.dart';
import 'package:omniwave/common/app_logo.dart';
import 'package:omniwave/common/app_scaffold/bloc/app_scaffold_bloc.dart';
import 'package:omniwave/playlists/playlists.dart';
import 'package:omniwave/styles.dart';
import 'package:omniwave/tracks/tracks.dart';

enum MusicItemCategory {
  albums('Albums'),
  playlists('Playlists'),
  tracks('Tracks');

  const MusicItemCategory(this.name);

  final String name;
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, this.body, required this.category});

  final Widget? body;
  final MusicItemCategory category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AppScaffoldBloc(musicRepository: context.read<MusicRepository>()),
      child: AppScaffoldView(body: body, category: category),
    );
  }
}

class AppScaffoldView extends StatelessWidget {
  const AppScaffoldView({super.key, this.body, required this.category});

  final Widget? body;
  final MusicItemCategory category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO(sergsavchuk): use drawer instead of the MultiSplitView ?
      body: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerThickness: 5,
          dividerPainter: DividerPainters.background(
            color: Colors.black,
            highlightedColor: Colors.grey,
          ),
        ),

        // TODO(sergsavchuk): add maximumSize parameter to Area
        // TODO(sergsavchuk): make the gesture area larger than the divider
        // thickness so it would be easier to drag very thin ones / or
        // implement a custom DividerPainter that draws a thin line
        child: MultiSplitView(
          initialAreas: [
            Area(minimalSize: 128, weight: 0.25),
            Area(minimalWeight: 0.7),
          ],
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.only(
                left: Insets.small,
                top: Insets.small,
                right: Insets.small,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(),
                  BlocBuilder<AppScaffoldBloc, AppScaffoldState>(
                    builder: (_, state) => state.spotifyConnected
                        ? const SizedBox.shrink()
                        : TextButton.icon(
                            onPressed: () => context
                                .read<AppScaffoldBloc>()
                                .add(AppScaffoldSpotifyConnectRequested()),
                            icon: Icon(
                              state.spotifyConnected
                                  ? Icons.link_off
                                  : Icons.link,
                            ),
                            label: const Text(
                              'Connect Spotify',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),
                  TextButton(
                    onPressed: () async {},
                    child: const Text(
                      'Youtube search',
                      // softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                  CategoryButton(
                    onPressed: () =>
                        Navigator.of(context).push(AlbumsPage.route()),
                    category: MusicItemCategory.albums,
                    icon: Icons.album_outlined,
                    selectedIcon: Icons.album,
                    selected: category == MusicItemCategory.albums,
                  ),
                  CategoryButton(
                    onPressed: () =>
                        Navigator.of(context).push(PlaylistsPage.route()),
                    category: MusicItemCategory.playlists,
                    icon: Icons.playlist_play_outlined,
                    selectedIcon: Icons.playlist_play,
                    selected: category == MusicItemCategory.playlists,
                  ),
                  CategoryButton(
                    onPressed: () =>
                        Navigator.of(context).push(TracksPage.route()),
                    category: MusicItemCategory.tracks,
                    icon: Icons.audiotrack_outlined,
                    selectedIcon: Icons.audiotrack,
                    selected: category == MusicItemCategory.tracks,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: Insets.medium,
                top: Insets.medium,
                right: Insets.medium,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Theme.of(context).primaryColor, Colors.black],
                  stops: const [0.0, 0.30],
                ),
              ),
              child: body ?? const SizedBox.shrink(),
            )
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  const CategoryButton({
    super.key,
    required this.onPressed,
    required this.category,
    required this.selected,
    required this.icon,
    required this.selectedIcon,
  });

  final VoidCallback onPressed;
  final MusicItemCategory category;
  final bool selected;
  final IconData icon;
  final IconData selectedIcon;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(selected ? selectedIcon : icon),
      label: Text(category.name),
      style: selected
          ? Theme.of(context).textButtonTheme.style?.copyWith(
                foregroundColor: const MaterialStatePropertyAll(Colors.white),
              )
          : null,
    );
  }
}
