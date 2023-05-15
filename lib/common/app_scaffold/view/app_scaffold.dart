import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:omniwave/albums/albums.dart';
import 'package:omniwave/bloc/app_settings_bloc.dart';
import 'package:omniwave/common/app_logo.dart';
import 'package:omniwave/common/player/player_controls.dart';
import 'package:omniwave/playlists/playlists.dart';
import 'package:omniwave/profile/profile.dart';
import 'package:omniwave/search/search.dart';
import 'package:omniwave/styles.dart';
import 'package:omniwave/tracks/tracks.dart';
import 'package:omniwave/utils.dart';

enum NavBarItem {
  albums(Icons.album_outlined, Icons.album_rounded),
  playlists(Icons.playlist_play_outlined, Icons.playlist_play_rounded),
  tracks(Icons.audiotrack_outlined, Icons.audiotrack_rounded),
  search(Icons.search_outlined, Icons.search_rounded),
  profile(Icons.person_outline, Icons.person);

  const NavBarItem(this.icon, this.activeIcon);

  final IconData icon;
  final IconData activeIcon;

  BottomNavigationBarItem asNavBarItem(BuildContext context) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      label: name(context),
    );
  }

  String name(BuildContext context) {
    switch (this) {
      case NavBarItem.albums:
        return AppLocalizations.of(context)!.albums;
      case NavBarItem.playlists:
        return AppLocalizations.of(context)!.playlists;
      case NavBarItem.tracks:
        return AppLocalizations.of(context)!.tracks;
      case NavBarItem.search:
        return AppLocalizations.of(context)!.search;
      case NavBarItem.profile:
        return AppLocalizations.of(context)!.profile;
    }
  }

  static void navigateTo(NavBarItem category, NavigatorState navigator) {
    Route<void> route;
    switch (category) {
      case NavBarItem.albums:
        route = AlbumsPage.route();
        break;
      case NavBarItem.playlists:
        route = PlaylistsPage.route();
        break;
      case NavBarItem.tracks:
        route = TracksPage.route();
        break;
      case NavBarItem.search:
        route = SearchPage.route();
        break;
      case NavBarItem.profile:
        route = ProfilePage.route();
        break;
    }

    navigator.push(route);
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    required this.category,
    this.noTopPadding = false,
  });

  final Widget body;
  final NavBarItem category;

  final bool noTopPadding;

  @override
  Widget build(BuildContext context) {
    return Utils.isSmallScreen
        ? SmallAppScaffoldView(
            body: body,
            category: category,
            noTopPadding: noTopPadding,
          )
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
  final NavBarItem category;

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
                        Divider(
                          color: Theme.of(context).colorScheme.onSurface,
                          thickness: 0.5,
                        ),
                        CategoryButton(
                          category: NavBarItem.albums,
                          selectedCategory: category,
                        ),
                        CategoryButton(
                          category: NavBarItem.playlists,
                          selectedCategory: category,
                        ),
                        CategoryButton(
                          category: NavBarItem.tracks,
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
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).colorScheme.surface
                        ],
                        stops: const [0.0, 0.30],
                      ),
                    ),
                    child: body,
                  )
                ],
              ),
            ),
          ),
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: Theme.of(context).colorScheme.onSurface,
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
    required this.noTopPadding,
  });

  final Widget body;
  final NavBarItem category;

  final bool noTopPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: !noTopPadding,
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
                      child: FloatingPlayerControls(),
                    )
                  : const SizedBox.shrink(),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: NavBarItem.values.indexOf(category),
        onTap: (index) => NavBarItem.navigateTo(
          NavBarItem.values.elementAt(index),
          Navigator.of(context),
        ),
        items: NavBarItem.values
            .map((category) => category.asNavBarItem(context))
            .toList(),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  const CategoryButton({
    super.key,
    required this.category,
    required NavBarItem selectedCategory,
  }) : isSelected = selectedCategory == category;

  final NavBarItem category;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => NavBarItem.navigateTo(category, Navigator.of(context)),
      icon: Icon(isSelected ? category.activeIcon : category.icon),
      label: Text(category.name(context)),
      style: isSelected ? Theme.of(context).textButtonTheme.style : null,
    );
  }
}
