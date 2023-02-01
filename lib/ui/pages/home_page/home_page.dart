import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multi_split_view/multi_split_view.dart';
import 'package:omniwave/env/env.dart';
import 'package:omniwave/models/album.dart';
import 'package:omniwave/styles.dart';
import 'package:omniwave/ui/common/album_card.dart';
import 'package:omniwave/ui/common/app_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

const webProxyUrl = 'http://localhost:443/';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<OmniwaveAlbum> _albums = [];

  final _streamController = StreamController<List<OmniwaveAlbum>>();
  late final Stream<List<OmniwaveAlbum>> _albumsStream;
  late final StreamSubscription<List<OmniwaveAlbum>> _albumsStreamSubscription;

  @override
  void initState() {
    super.initState();

    _albumsStream = _streamController.stream.asBroadcastStream();
    _albumsStreamSubscription = _albumsStream.listen(_albums.addAll);
  }

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
                children: [
                  const AppLogo(),
                  _spotifyConnectButton(),
                  _youtubeSearchButton()
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
              child: StreamBuilder<List<OmniwaveAlbum>>(
                stream: _albumsStream,
                builder: (_, __) {
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

  Widget _spotifyConnectButton() {
    const accessTokenKey = 'accessToken';

    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        var connectedToSpotify = false;
        if (snapshot.hasData || snapshot.hasError) {
          final sharedPrefs = snapshot.data;
          if (sharedPrefs != null &&
              sharedPrefs.getString(accessTokenKey) != null) {
            final spotifyAccessToken = sharedPrefs.getString(accessTokenKey)!;

            final spotifyApi = spotify.SpotifyApi.withAccessToken(
              spotifyAccessToken,
            );
            _streamController.addStream(
              spotifyApi.me.savedAlbums().stream().map(
                    (albumsPage) =>
                        albumsPage.items
                            ?.map((e) => e.toOmniwaveAlbum())
                            .toList() ??
                        List.empty(),
                  ),
            );
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

              final spotifyApi =
                  spotify.SpotifyApi.withAccessToken(accessToken);
              unawaited(
                _streamController.addStream(
                  spotifyApi.me.savedAlbums().stream().map(
                        (albumsPage) =>
                            albumsPage.items
                                ?.map(
                                  (spotifyAlbum) =>
                                      spotifyAlbum.toOmniwaveAlbum(),
                                )
                                .toList() ??
                            List.empty(),
                      ),
                ),
              );
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

  Widget _youtubeSearchButton() {
    return TextButton(
      onPressed: () async {
        final yt = YoutubeExplode(kIsWeb ? ProxyHttpClient() : null);
        final searchList = await yt.search
            .searchContent('Radiohead album', filter: TypeFilters.playlist);

        final playlists = await Future.wait(
          searchList.map(
            (playlist) => yt.playlists.get(
              (playlist as SearchPlaylist).playlistId.value,
            ),
          ),
        );

        _streamController
            .add(playlists.map((e) => e.toOmniwaveAlbum()).toList());
      },
      child: const Text(
        'Youtube search',
        // softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  void dispose() {
    _albumsStreamSubscription.cancel();
    super.dispose();
  }
}

/// A workaround for web platform. [YoutubeExplode] doesn't work in web because
/// of CORS, so the only solution now is to use any proxy server.
///
/// But even with the proxy there is still a problem with youtube responding
/// 403 Forbidden to any POST request. Maybe this is because http.BrowserClient
/// doesn't support BaseRequest.persistentConnection unlike IOClient.
// TODO(sergsavchuk): investigate the situation further
class ProxyHttpClient extends YoutubeHttpClient {
  @override
  Future<String> getString(
    dynamic url, {
    Map<String, String> headers = const {},
    bool validate = true,
  }) {
    return super.getString(
      '$webProxyUrl$url',
      headers: headers,
      validate: validate,
    );
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool validate = false,
  }) {
    return super.post(
      Uri.parse('$webProxyUrl$url'),
      headers: headers,
      body: body,
      encoding: encoding,
      validate: validate,
    );
  }
}
