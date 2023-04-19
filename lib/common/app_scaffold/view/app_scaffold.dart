import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:omniwave/albums/albums.dart';
import 'package:omniwave/bloc/app_settings_bloc.dart';
import 'package:omniwave/common/app_logo.dart';
import 'package:omniwave/common/player_controls/player_controls.dart';
import 'package:omniwave/playlists/playlists.dart';
import 'package:omniwave/profile/profile.dart';
import 'package:omniwave/search/search.dart';
import 'package:omniwave/styles.dart';
import 'package:omniwave/tracks/tracks.dart';
import 'package:omniwave/utils.dart';

enum MusicItemCategory {
  albums('Albums', Icons.album_outlined, Icons.album_rounded),
  playlists(
    'Playlists',
    Icons.playlist_play_outlined,
    Icons.playlist_play_rounded,
  ),
  tracks('Tracks', Icons.audiotrack_outlined, Icons.audiotrack_rounded),
  search('Search', Icons.search_outlined, Icons.search_rounded),
  profile('Profile', Icons.person_outline, Icons.person);

  const MusicItemCategory(this.name, this.icon, this.activeIcon);

  final String name;
  final IconData icon;
  final IconData activeIcon;

  BottomNavigationBarItem asNavBarItem() {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      label: name,
    );
  }

  static void navigateTo(MusicItemCategory category, NavigatorState navigator) {
    Route<void> route;
    switch (category) {
      case MusicItemCategory.albums:
        route = AlbumsPage.route();
        break;
      case MusicItemCategory.playlists:
        route = PlaylistsPage.route();
        break;
      case MusicItemCategory.tracks:
        route = TracksPage.route();
        break;
      case MusicItemCategory.search:
        route = SearchPage.route();
        break;
      case MusicItemCategory.profile:
        route = ProfilePage.route();
        break;
    }

    navigator.push(route);
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.body, required this.category});

  final Widget body;
  final MusicItemCategory category;

  @override
  Widget build(BuildContext context) {
    return Utils.isSmallScreen
        ? SmallAppScaffoldView(body: body, category: category)
        : AppScaffoldView(body: body, category: category);
  }
}

class AppScaffoldView extends StatelessWidget {
  const AppScaffoldView({
    super.key,
    required this.body,
    required this.category,
  });

  final Widget body;
  final MusicItemCategory category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO(sergsavchuk): use drawer instead of the MultiSplitView ?
      body: Column(
        children: [
          Flexible(
            child: MultiSplitViewTheme(
              data: MultiSplitViewThemeData(
                dividerThickness: 5,
                dividerPainter: DividerPainters.background(
                  color: Colors.black,
                  highlightedColor: Colors.grey,
                ),
              ),

              // TODO(sergsavchuk): add maximumSize parameter to Area
              // TODO(sergsavchuk): make the gesture area larger than the
              // divider thickness so it would be easier to drag very thin
              // ones / or implement a custom DividerPainter that draws a thin
              // line
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
                        _spotifyConnectButton(),
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
                          category: MusicItemCategory.albums,
                          selectedCategory: category,
                        ),
                        CategoryButton(
                          category: MusicItemCategory.playlists,
                          selectedCategory: category,
                        ),
                        CategoryButton(
                          category: MusicItemCategory.tracks,
                          selectedCategory: category,
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
                    child: body,
                  )
                ],
              ),
            ),
          ),
          const Divider(
            height: 0.5,
            thickness: 0.5,
            color: Colors.grey,
          ),
          const PlayerControls()
        ],
      ),
    );
  }

  Widget _spotifyConnectButton() {
    return BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, state) => state.spotifyConnected
          ? const SizedBox.shrink()
          : TextButton.icon(
              onPressed: () => context.read<AppSettingsBloc>().add(
                    AppSettingsSpotifyConnectRequested(),
                  ),
              icon: Icon(
                state.spotifyConnected ? Icons.link_off : Icons.link,
              ),
              label: const Text(
                'Connect Spotify',
                overflow: TextOverflow.ellipsis,
              ),
            ),
    );
  }
}

class SmallAppScaffoldView extends StatelessWidget {
  const SmallAppScaffoldView({
    super.key,
    required this.body,
    required this.category,
  });

  final Widget body;
  final MusicItemCategory category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            body,
            BlocBuilder<PlayerBloc, PlayerState>(
              builder: (context, state) => state.currentTrack != null
                  ? const Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SmallPlayerControls(),
                    )
                  : const SizedBox.shrink(),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: MusicItemCategory.values.indexOf(category),
        onTap: (index) => MusicItemCategory.navigateTo(
          MusicItemCategory.values.elementAt(index),
          Navigator.of(context),
        ),
        items: MusicItemCategory.values
            .map((category) => category.asNavBarItem())
            .toList(),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  const CategoryButton({
    super.key,
    required this.category,
    required MusicItemCategory selectedCategory,
  }) : isSelected = selectedCategory == category;

  final MusicItemCategory category;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () =>
          MusicItemCategory.navigateTo(category, Navigator.of(context)),
      icon: Icon(isSelected ? category.activeIcon : category.icon),
      label: Text(category.name),
      style: isSelected
          ? Theme.of(context).textButtonTheme.style?.copyWith(
                foregroundColor: const MaterialStatePropertyAll(Colors.white),
              )
          : null,
    );
  }
}
