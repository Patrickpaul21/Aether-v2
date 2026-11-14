import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_tracks.dart';
import 'track.dart';

class PlayerState {
  final Track? track;
  final bool isPlaying;
  const PlayerState({this.track, this.isPlaying = false});
}

class PlayerNotifier extends Notifier<PlayerState> {
  @override
  PlayerState build() => const PlayerState();

  void play(Track t) => state = PlayerState(track: t, isPlaying: true);

  void toggle() {
    if (state.track == null) return;
    state = PlayerState(track: state.track, isPlaying: !state.isPlaying);
  }

  void _step(int delta) {
    final current = state.track;
    if (current == null) return;
    final i = mockTracks.indexWhere((t) => t.id == current.id);
    final next = mockTracks[(i + delta) % mockTracks.length];
    state = PlayerState(track: next, isPlaying: true);
  }

  void next() => _step(1);
  void prev() => _step(-1);
}

final playerProvider =
    NotifierProvider<PlayerNotifier, PlayerState>(PlayerNotifier.new);

void playTrack(BuildContext context, Track t) =>
    ProviderScope.containerOf(context, listen: false)
        .read(playerProvider.notifier)
        .play(t);
