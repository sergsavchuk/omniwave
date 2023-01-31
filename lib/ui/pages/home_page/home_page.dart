import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:omniwave/env/env.dart';
import 'package:omniwave/styles.dart';
import 'package:omniwave/ui/common/album_card.dart';
import 'package:omniwave/ui/common/app_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:spotify_sdk/spotify_sdk.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _spotifyAccessToken = '';
  final List<spotify.AlbumSimple> _albums = [];
  Stream<spotify.Page<spotify.AlbumSimple>>? _albumsStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                children: [const AppLogo(), spotifyConnectButton()],
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
              child: StreamBuilder<spotify.Page<spotify.AlbumSimple>>(
                stream: _albumsStream,
                builder: (context, snapshot) {
                  final page = snapshot.data;
                  if (page != null) {
                    final newAlbums = page.items;
                    if (newAlbums != null) {
                      _albums.addAll(newAlbums);
                    }
                  }

                  return GridView.count(
                    crossAxisCount: 4,
                    childAspectRatio: 0.75,
                    children: _albums
                        .map((album) => AlbumCard(album: album))
                        .toList(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget spotifyConnectButton() {
    const accessTokenKey = 'accessToken';

    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        var connectedToSpotify = false;
        if (snapshot.hasData || snapshot.hasError) {
          final sharedPrefs = snapshot.data;
          if (sharedPrefs != null &&
              sharedPrefs.getString(accessTokenKey) != null) {
            _spotifyAccessToken = sharedPrefs.getString(accessTokenKey)!;

            final spotifyApi = spotify.SpotifyApi.withAccessToken(
              _spotifyAccessToken,
            );
            _albumsStream = spotifyApi.me.savedAlbums().stream();
            connectedToSpotify = true;
          }

          return TextButton.icon(
            onPressed: () async {
              if (connectedToSpotify) {
                return;
              }

              // TODO(sergsavchuk): use SpotifyApi instead of
              // SpotifySdk to get the access token, cause
              // SpotifySdk doesn't support desktop platforms
              final accessToken = await SpotifySdk.getAccessToken(
                clientId: Env.spotifyClientId,
                redirectUrl: Env.spotifyRedirectUrl,
                scope: 'user-library-read',
              );

              final sharedPrefs = await SharedPreferences.getInstance();
              await sharedPrefs.setString(
                accessTokenKey,
                accessToken,
              );

              setState(() {
                _spotifyAccessToken = accessToken;
              });

              final spotifyApi =
                  spotify.SpotifyApi.withAccessToken(accessToken);
              setState(() {
                _albumsStream = spotifyApi.me.savedAlbums().stream();
              });
            },
            icon: Icon(
              connectedToSpotify ? Icons.link_off : Icons.link,
            ),
            label: Text(
              "${connectedToSpotify ? 'Disconnect' : 'Connect'} Spotify",
              // softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }

        return Container(
          height: 20,
          width: double.infinity,
          color: Colors.grey,
        );
      },
    );
  }
}
