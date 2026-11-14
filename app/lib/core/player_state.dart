import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'mock_tracks.dart';
import 'settings.dart';
import 'track.dart';

class PlayerStatus {
  final Track? track;
  final bool isPlaying;
  final bool isLoading;
  final String? error;
  const PlayerStatus({
    this.track,
    this.isPlaying = false,
    this.isLoading = false,
    this.error,
  });
}

class PlayerNotifier extends Notifier<PlayerStatus> {
  late final AudioPlayer _player;
  int _request = 0;
  bool _fetching = false;
  List<Track> _queue = const [];

  AudioPlayer get player => _player;

  @override
  PlayerStatus build() {
    _player = AudioPlayer();
    _player.playerStateStream.listen(_onPlayerState);
    ref.onDispose(_player.dispose);
    return const PlayerStatus();
  }

  void _onPlayerState(PlayerState s) {
    if (_fetching || state.track == null || state.error != null) return;
    final loading = s.processingState == ProcessingState.loading ||
        s.processingState == ProcessingState.buffering;
    state = PlayerStatus(
      track: state.track,
      isPlaying: s.playing,
      isLoading: loading,
    );
    if (s.processingState == ProcessingState.completed) next();
  }

  Future<void> play(Track t, {List<Track>? queue}) async {
    _queue = queue ?? (mockTracks.any((m) => m.id == t.id) ? mockTracks : [t]);
    final id = ++_request;
    _fetching = true;
    state = PlayerStatus(track: t, isLoading: true);
    await _player.stop();
    try {
      final base = ref.read(serverUrlProvider);
      final res = await http
          .get(Uri.parse('$base/stream/${t.id}'))
          .timeout(const Duration(seconds: 30));
      if (id != _request) return;
      if (res.statusCode != 200) {
        throw Exception('Server returned ${res.statusCode}');
      }
      final url =
          (jsonDecode(res.body) as Map<String, dynamic>)['url'] as String;
      await _player.setAudioSource(AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: t.id,
          title: t.title,
          artist: t.artist,
          artUri: t.coverUrl.isEmpty ? null : Uri.parse(t.coverUrl),
        ),
      ));
      if (id != _request) return;
      _fetching = false;
      state = PlayerStatus(track: t, isPlaying: true);
      _player.play();
    } catch (e) {
      if (id != _request) return;
      _fetching = false;
      state = PlayerStatus(track: t, error: 'Play failed: $e');
    }
  }

  void toggle() {
    if (state.track == null || state.error != null || state.isLoading) return;
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  void _step(int delta) {
    final current = state.track;
    if (current == null || _queue.isEmpty) return;
    final i = _queue.indexWhere((t) => t.id == current.id);
    final n = _queue.length;
    play(_queue[((i < 0 ? 0 : i) + delta + n) % n], queue: _queue);
  }

  void next() => _step(1);
  void prev() => _step(-1);
}

final playerProvider =
    NotifierProvider<PlayerNotifier, PlayerStatus>(PlayerNotifier.new);

void playTrack(BuildContext context, Track t, {List<Track>? queue}) =>
    ProviderScope.containerOf(context, listen: false)
        .read(playerProvider.notifier)
        .play(t, queue: queue);
