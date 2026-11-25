# Credits

Aether is an independent project. It is not affiliated with YouTube, Google, or Spotify.

## Libraries and tools
- Flutter and Dart
- just_audio and just_audio_background (audio playback and lock screen controls)
- flutter_riverpod (state), go_router (navigation), shared_preferences (local storage), http
- FastAPI and Uvicorn (the Aether server)
- yt-dlp (stream and search extraction on the server)

- LRCLIB (lrclib.net): synced and plain lyrics

- ytmusicapi (YouTube Music song search on the server)

## Inspiration (ideas and structure only, no code copied)
- Echo Music (EchoMusicApp/Echo-Music): how responsibilities are split into modules
- Orpheon (kota-zo/Orpheon): extension system design
- Dark, minimal player layouts common to modern music apps

## Learning references
- "How yt-dlp actually works" (endoffile-academy.pages.dev)
- Community write-ups on YouTube's InnerTube API
- The youtubei.js project (MIT), read for ideas only

## Evaluated, not shipped
- youtube_explode_dart: tried for on-device extraction; search and stream both failed, so Aether uses its own server instead
