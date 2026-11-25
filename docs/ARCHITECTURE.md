# Aether architecture

Aether is a Flutter music app (Android) backed by a small FastAPI server. The phone plays audio; the server does the YouTube work.

## Folder map
- `app/lib/core/`: models, theme, settings, and the shared state (player, library, playlists)
- `app/lib/sources/`: the `MusicSource` interface and the server-backed source
- `app/lib/lyrics/`: lyrics lookup (LRCLIB) and the LRC parser
- `app/lib/features/`: screens (home, search, library, player, settings)
- `app/test/`: unit tests for the link parser, text cleaning, and LRC parsing
- `server/main.py`: FastAPI app (`/search`, `/stream/{id}`, `/health`) with a 30-minute search cache
- `server/ytm.py`: YouTube Music song search (ytmusicapi)
- `server/test_main.py`: server tests

## How a tap becomes sound
1. A screen calls `playTrack(track, queue)`.
2. `PlayerNotifier` (Riverpod) updates the queue and asks the current `MusicSource` for a stream.
3. The source calls the server's `/stream/{id}`; the server uses yt-dlp to find the best audio URL.
4. `just_audio` plays that URL directly from the phone.
5. An `audio_service` handler publishes the track and state to the notification and lock screen, and passes button presses (play, pause, next, previous, seek) back to `PlayerNotifier`.

## How search works
1. The app calls the server's `/search`.
2. The server checks its cache (30 minutes, keyed by the query).
3. On a miss it asks ytmusicapi for songs. If that fails or finds nothing, it falls back to a plain yt-dlp search, ranking song-length results first.
4. Results go back as one shape (id, title, artist, duration, cover), so the app doesn't care which path produced them.

## State and storage
- State is Riverpod notifiers: player, library (likes, history), playlists, appearance, server address, recent searches.
- Everything persists locally as JSON or simple values in `shared_preferences`, including the last queue and position, so the app resumes where you left off. There is no account and no database.

## Decisions
- **Server-side extraction.** I tested on-device extraction (a Dart package); search and stream both failed, so the server runs yt-dlp. An advantage: when YouTube changes something, updating yt-dlp on the server fixes every install.
- **A `MusicSource` interface.** The UI never knows where tracks come from, which keeps room for other sources.
- **Song search through ytmusicapi,** with yt-dlp search as an automatic fallback if it fails. It returns real songs with artist names, durations, and square covers.
- **Search results are ranked, not filtered,** on the fallback path, so a search is never empty.
- **A 30-minute cache on `/search`.** Keeps Home fast and is gentle on YouTube.
- **Not built:** cloud hosting (YouTube often blocks data-centre addresses), offline downloads, personalised recommendations, animated canvas video.

## Testing
- Server: `cd server && python -m pytest` (health, cache behaviour, input validation)
- App: `cd app && flutter test` (link parsing, text cleaning, LRC parsing)

## Known limits
- The app needs the server running and reachable on the same network.
- Stream links are tied to the requesting address, so remote use would need the server to proxy audio.
- Lyrics depend on LRCLIB having the track.
- YouTube changes often, so the server needs yt-dlp and ytmusicapi updates now and then.