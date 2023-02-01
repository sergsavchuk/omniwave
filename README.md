# OmniWave Music Player
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

Cross platform open-source music player

## Setup
Add Spotify app params to the `.env` file([see spotify_sdk setup guide](https://github.com/brim-borium/spotify_sdk#setup)):
```dotenv
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_REDIRECT_URL=your_spotify_redirect_url
```

### web
Because of [this issue](https://github.com/Hexer10/youtube_explode_dart/issues/119) before running 
the web version start the proxy server:
```shell
cd web_proxy
npm install
node serv.js
```
