import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/player_state.dart';
import '../../core/theme.dart';
import '../../lyrics/lyrics_service.dart';

void showLyricsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => const LyricsSheet(),
  );
}

Widget _message(String text) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );

class LyricsSheet extends ConsumerWidget {
  const LyricsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(playerProvider.select((s) => s.track));
    final lyrics = ref.watch(currentLyricsProvider);
    final n = ref.read(playerProvider.notifier);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(track?.title ?? 'Lyrics',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: lyrics.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) =>
                  _message("Couldn't load lyrics. Check your connection."),
              data: (l) {
                if (l == null) return _message('No lyrics found for this track.');
                if (l.instrumental) return _message('Instrumental.');
                if (l.hasSynced) {
                  return _SyncedLyrics(
                    key: ValueKey(track?.id),
                    lines: l.synced,
                    positions: n.player.positionStream,
                    onSeek: n.seek,
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Text(l.plain ?? '',
                      style: const TextStyle(fontSize: 18, height: 1.6)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncedLyrics extends StatefulWidget {
  final List<LyricLine> lines;
  final Stream<Duration> positions;
  final Future<void> Function(Duration) onSeek;
  const _SyncedLyrics({
    super.key,
    required this.lines,
    required this.positions,
    required this.onSeek,
  });

  @override
  State<_SyncedLyrics> createState() => _SyncedLyricsState();
}

class _SyncedLyricsState extends State<_SyncedLyrics> {
  late final List<GlobalKey> _keys;
  StreamSubscription<Duration>? _sub;
  int _current = -1;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.lines.length, (_) => GlobalKey());
    _sub = widget.positions.listen(_onPosition);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onPosition(Duration p) {
    var idx = -1;
    for (var i = 0; i < widget.lines.length; i++) {
      if (widget.lines[i].time <= p) {
        idx = i;
      } else {
        break;
      }
    }
    if (idx != _current) {
      setState(() => _current = idx);
      _scrollTo(idx);
    }
  }

  void _scrollTo(int i) {
    if (i < 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[i].currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.4,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 120),
            for (var i = 0; i < widget.lines.length; i++)
              GestureDetector(
                key: _keys[i],
                onTap: () => widget.onSeek(widget.lines[i].time),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    widget.lines[i].text.isEmpty ? '♪' : widget.lines[i].text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: i == _current
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 160),
          ],
        ),
      );
}
