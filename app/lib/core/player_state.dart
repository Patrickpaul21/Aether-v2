import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../sources/music_source.dart';
import 'audio_handler.dart';
import 'errors.dart';
import 'library_state.dart';
import 'track.dart';

enum QueueRepeat { off, all, one }

const _keep = Object();

class PlayerStatus {
  final List<Track> queue;
  final int index;
  final bool isPlaying;
  final bool isLoading;
  final String? error;
  final bool shuffle;
  final QueueRepeat repeat;

  const PlayerStatus({
    this.queue = const [],
    this.index = -1,
    this.isPlaying = false,
    this.isLoading = false,
    this.error,
    this.shuffle = false,
    this.repeat = QueueRepeat.off,
  });

  Track? get track =>
      index >= 0 && index < queue.length ? queue[index] : null;

  List<Track> get upcoming =>
      index >= 0 && index < queue.length - 1 ? queue.sublist(index + 1) : const [];

  PlayerStatus copyWith({
    List<Track>? queue,
    int? index,
    bool? isPlaying,
    bool? isLoading,
    Object? error = _keep,
    bool? shuffle,
    QueueRepeat? repeat,
  }) =>
      PlayerStatus(
        queue: queue ?? this.queue,
        index: index ?? this.index,
        isPlaying: isPlaying ?? this.isPlaying,
        isLoading: isLoading ?? this.isLoading,
        error: identical(error, _keep) ? this.error : error as String?,
        shuffle: shuffle ?? this.shuffle,
        repeat: repeat ?? this.repeat,
      );
}

class PlayerNotifier extends Notifier<PlayerStatus> {
  late final AudioPlayer _player;
  late final AetherAudioHandler _handler;
  int _request = 0;
  bool _fetching = false;
  final _random = Random();
  List<Track>? _orderBeforeShuffle;

  AudioPlayer get player => _player;

  @override
  PlayerStatus build() {
    _player = AudioPlayer();
    _handler = ref.read(audioHandlerProvider);
    _player.playerStateStream.listen(_onPlayerState);
    _handler.onPlay = () async {
      if (state.track != null && state.error == null) _player.play();
    };
    _handler.onPause = () async {
      _player.pause();
    };
    _handler.onNext = () async {
      next();
    };
    _handler.onPrev = () async {
      prev();
    };
    _handler.onStop = () async {
      await _player.stop();
    };
    _handler.onSeek = (p) => seek(p);
    ref.onDispose(_player.dispose);
    return const PlayerStatus();
  }

  void _publish() {
    final s = state;
    if (s.track == null) return;
    _handler.playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        s.isPlaying ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: s.isLoading
          ? AudioProcessingState.loading
          : (s.error != null
              ? AudioProcessingState.idle
              : AudioProcessingState.ready),
      playing: s.isPlaying,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: 1.0,
    ));
  }

  void _onPlayerState(PlayerState s) {
    if (_fetching || state.track == null || state.error != null) return;
    final loading = s.processingState == ProcessingState.loading ||
        s.processingState == ProcessingState.buffering;
    state = state.copyWith(isPlaying: s.playing, isLoading: loading);
    _publish();
    if (s.processingState == ProcessingState.completed && s.playing) {
      _onCompleted();
    }
  }

  void _onCompleted() {
    final s = state;
    if (s.repeat == QueueRepeat.one) {
      _player.seek(Duration.zero);
      _player.play();
    } else if (s.index < s.queue.length - 1) {
      _playAt(s.index + 1);
    } else if (s.repeat == QueueRepeat.all && s.queue.isNotEmpty) {
      _playAt(0);
    } else {
      _player.pause();
      _player.seek(Duration.zero);
    }
  }

  List<Track> _dedupe(List<Track> list) {
    final seen = <String>{};
    return [
      for (final t in list)
        if (seen.add(t.id)) t
    ];
  }

  Future<void> _playAt(int i) async {
    final q = state.queue;
    if (i < 0 || i >= q.length) return;
    final t = q[i];
    final id = ++_request;
    _fetching = true;
    final item = MediaItem(
      id: t.id,
      title: t.title,
      artist: t.artist,
      artUri: t.coverUrl.isEmpty ? null : Uri.parse(t.coverUrl),
    );
    _handler.mediaItem.add(item);
    state = state.copyWith(
        index: i, isPlaying: false, isLoading: true, error: null);
    _publish();
    await _player.stop();
    try {
      final info = await ref.read(musicSourceProvider).getStream(t.id);
      if (id != _request) return;
      final dur =
          await _player.setAudioSource(AudioSource.uri(Uri.parse(info.url)));
      if (id != _request) return;
      _fetching = false;
      _handler.mediaItem.add(item.copyWith(duration: dur));
      state = state.copyWith(isPlaying: true, isLoading: false);
      _publish();
      ref.read(libraryProvider.notifier).addToHistory(t);
      _player.play();
    } catch (e) {
      if (id != _request) return;
      _fetching = false;
      state = state.copyWith(
          isPlaying: false, isLoading: false, error: friendlyError(e));
      _publish();
    }
  }

  Future<void> play(Track t, {List<Track>? queue}) async {
    var list = _dedupe(queue ?? [t]);
    var i = list.indexWhere((x) => x.id == t.id);
    if (i < 0) {
      list = [t, ...list];
      i = 0;
    }
    if (state.shuffle && i < list.length - 1) {
      final rest = list.sublist(i + 1)..shuffle(_random);
      list = [...list.sublist(0, i + 1), ...rest];
    }
    state = state.copyWith(queue: list, index: i);
    await _playAt(i);
  }

  void toggle() {
    if (state.track == null || state.error != null || state.isLoading) return;
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _publish();
  }

  void next() {
    final s = state;
    if (s.queue.isEmpty) return;
    if (s.index < s.queue.length - 1) {
      _playAt(s.index + 1);
    } else if (s.repeat == QueueRepeat.all) {
      _playAt(0);
    }
  }

  void prev() {
    final s = state;
    if (s.queue.isEmpty) return;
    if (_player.position > const Duration(seconds: 3) || s.index == 0) {
      seek(Duration.zero);
      return;
    }
    _playAt(s.index - 1);
  }

  void jumpTo(int i) => _playAt(i);

  void playNext(Track t) {
    final s = state;
    if (s.track == null) {
      play(t);
      return;
    }
    if (t.id == s.track!.id) return;
    final q = [...s.queue];
    final at = s.index + 1;
    final dup = q.indexWhere((x) => x.id == t.id, at);
    if (dup >= 0) q.removeAt(dup);
    q.insert(at, t);
    state = s.copyWith(queue: q);
  }

  void addToQueue(Track t) {
    final s = state;
    if (s.track == null) {
      play(t);
      return;
    }
    if (t.id == s.track!.id) return;
    final q = [...s.queue];
    final dup = q.indexWhere((x) => x.id == t.id, s.index + 1);
    if (dup >= 0) q.removeAt(dup);
    q.add(t);
    state = s.copyWith(queue: q);
  }

  void removeUpcoming(int k) {
    final s = state;
    final abs = s.index + 1 + k;
    if (abs <= s.index || abs >= s.queue.length) return;
    final q = [...s.queue]..removeAt(abs);
    state = s.copyWith(queue: q);
  }

  void moveUpcoming(int from, int to) {
    final s = state;
    final base = s.index + 1;
    if (from < 0 || base + from >= s.queue.length) return;
    final q = [...s.queue];
    final item = q.removeAt(base + from);
    final upcomingLen = q.length - base;
    var target = to > from ? to - 1 : to;
    if (target > upcomingLen) target = upcomingLen;
    if (target < 0) target = 0;
    q.insert(base + target, item);
    state = s.copyWith(queue: q);
  }

  void clearUpcoming() {
    final s = state;
    if (s.track == null) return;
    state = s.copyWith(queue: s.queue.sublist(0, s.index + 1));
  }

  void toggleShuffle() {
    final s = state;
    if (!s.shuffle && s.track != null && s.index < s.queue.length - 1) {
      final rest = s.queue.sublist(s.index + 1)..shuffle(_random);
      state = s.copyWith(
        queue: [...s.queue.sublist(0, s.index + 1), ...rest],
        shuffle: true,
      );
    } else {
      state = s.copyWith(shuffle: !s.shuffle);
    }
  }

  void cycleRepeat() {
    final s = state;
    final next = switch (s.repeat) {
      QueueRepeat.off => QueueRepeat.all,
      QueueRepeat.all => QueueRepeat.one,
      QueueRepeat.one => QueueRepeat.off,
    };
    state = s.copyWith(repeat: next);
  }
}

final playerProvider =
    NotifierProvider<PlayerNotifier, PlayerStatus>(PlayerNotifier.new);

void playTrack(BuildContext context, Track t, {List<Track>? queue}) =>
    ProviderScope.containerOf(context, listen: false)
        .read(playerProvider.notifier)
        .play(t, queue: queue);
