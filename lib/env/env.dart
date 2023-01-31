import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SPOTIFY_CLIENT_ID', obfuscate: true)
  static final String spotifyClientId = _Env.spotifyClientId;

  @EnviedField(varName: 'SPOTIFY_REDIRECT_URL', obfuscate: true)
  static final String spotifyRedirectUrl = _Env.spotifyRedirectUrl;
}
