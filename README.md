# Aether v2

A free, ad-free music player for Android, built with Flutter and a small Python server. I built it to sharpen my skills as both a designer and a programmer.

[LinkedIn](https://linkedin.com/in/patrickdondapati) · [GitHub](https://github.com/Patrickpaul21) · [Behance](https://behance.net/patrickpaul21) · [Portfolio](https://patrickdondapati.framer.website)

> Personal-use project. It isn't affiliated with YouTube, Google, or Spotify, and YouTube's terms of service may restrict this kind of use.

## What is Aether?

Aether is an open-source music app for people who want an alternative to paid streaming. You search, tap a song, and it plays: no ads, no account. Today it plays music from YouTube through a server you run yourself, and it's built so other sources can be added later.

## Why I built it

It started as a fun portfolio project. The idea came from Echo Music and from the add-on concept in Stremio: a music client where you choose your own sources. The first version was a web prototype, built to figure out how an add-on system could work.

Then I rebuilt it from scratch as a real Android app. After showing the prototype to a senior developer, I switched to Flutter and Python, partly for proper Android support (lock-screen controls and background playback were the limits of the first version) and partly because it's an in-demand combination. It's also the first project I've built with Flutter, and I'm proud of the whole thing.

I designed the screens, the layout, and the flows myself.

## What it can do

- **Search** YouTube Music songs and artists, or paste a YouTube link to play it
- **Home** shelves: your recent plays, plus "More from" the artists you play and a few mood shelves
- **Playback** that keeps going with the screen off, with lock-screen and notification controls
- **Queue:** play next, add to queue, reorder, shuffle, and repeat
- **Synced lyrics** that follow the song (from LRCLIB), where available
- **Playlists** and **Liked Songs**, saved on your phone
- **Sleep timer** and **resume where you left off**
- **Customisation:** accent colours and a pure-black (AMOLED) mode

## How it works

When you tap a song, the app asks the Aether server for it. The server uses yt-dlp to find the audio stream, and the phone plays that audio directly, so it's the audio track and not the video. Search goes through YouTube Music's song catalogue, with a plain YouTube search as a fallback, and the server keeps a short cache so Home loads quickly. More detail is in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Running it

You need the server running on your computer, and your phone on the same Wi-Fi network.

**Server** (Python 3.13)
```bash
cd server
python -m venv .venv
.venv\Scripts\activate          # macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```
On Windows, `start-server.bat` does this for you and prints your IP address.

**App** (Flutter, with an Android phone or emulator)
```bash
cd app
flutter pub get
flutter run
```
In the app, open **Settings** (the gear on Home), enter your server address (for example `http://192.168.1.23:8000`), and tap **Test connection**.

## Testing

```bash
cd server && python -m pytest
cd app && flutter test
```

## Limitations

- **The app needs the server running.** It only works while your computer is on and reachable on the same network. Using it away from home would need the server to relay the audio, which I haven't built yet.
- **Search uses YouTube Music's song catalogue** (through the unofficial ytmusicapi library), with plain YouTube search as a fallback. It can still surface covers and live versions.
- **Lyrics** depend on LRCLIB having the track.
- **YouTube changes often**, so the server's yt-dlp and ytmusicapi need updating now and then.
- Sources are limited to YouTube for now. The code is set up for more.

## What I learned

- I started with no FastAPI experience and ended up building a search and streaming server with a cache and tests.
- Getting lock-screen controls working meant swapping audio libraries and writing a small handler between the notification and my player.
- I tested playing audio directly on the phone without a server. It failed, so I measured it and moved the work to the server. Knowing when to stop and change approach saved time.
- Setup problems (Android tooling, Python versions, Windows quirks) took real time, and I'm better at diagnosing them now.
- Next time I'd settle the structure and the shared state before building screens, for a cleaner implementation of features.

## What's next

Ideas for v2.1: casting, switching between audio sources and output devices, offline downloads, and more music sources.

## Credits

Built with Flutter, just_audio, audio_service, Riverpod, go_router, FastAPI, yt-dlp, and ytmusicapi. Lyrics from [LRCLIB](https://lrclib.net). Inspired by Echo Music and Stremio (ideas and structure only, no code copied). The default look follows the familiar dark layout of mainstream music apps. Full list in [CREDITS.md](CREDITS.md).

## Screenshots

*Coming soon.*