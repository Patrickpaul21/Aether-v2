import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/cover_art.dart';
import '../../core/player_state.dart';
import '../../core/theme.dart';

String _fmt(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(playerProvider);
    final track = s.track;
    if (track == null) return const Scaffold();

    final notifier = ref.read(playerProvider.notifier);
    final hue = (track.id.hashCode % 360).abs().toDouble();
    final artSize = MediaQuery.of(context).size.width - 48;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              HSLColor.fromAHSL(1, hue, 0.45, 0.28).toColor(),
              AppColors.background,
            ],
            stops: const [0, 0.75],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Spacer(),
                CoverArt(track: track, size: artSize),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(track.title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(s.error ?? track.artist,
                      style: TextStyle(
                          fontSize: 16,
                          color: s.error != null
                              ? Colors.redAccent
                              : AppColors.textSecondary)),
                ),
                const SizedBox(height: 16),
                _ProgressBar(player: notifier.player),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.shuffle, color: AppColors.textSecondary),
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: notifier.prev,
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: s.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(
                                  strokeWidth: 3, color: Colors.black),
                            )
                          : IconButton(
                              iconSize: 40,
                              color: Colors.black,
                              icon: Icon(
                                  s.isPlaying ? Icons.pause : Icons.play_arrow),
                              onPressed: notifier.toggle,
                            ),
                    ),
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.skip_next),
                      onPressed: notifier.next,
                    ),
                    const Icon(Icons.repeat, color: AppColors.textSecondary),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatefulWidget {
  final AudioPlayer player;
  const _ProgressBar({required this.player});

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar> {
  double? _drag;

  @override
  Widget build(BuildContext context) => StreamBuilder<Duration>(
        stream: widget.player.positionStream,
        builder: (_, snap) {
          final pos = snap.data ?? Duration.zero;
          final dur = widget.player.duration ?? Duration.zero;
          final maxMs = dur.inMilliseconds.toDouble();
          final ready = maxMs > 0;
          final current = _drag ??
              (ready
                  ? pos.inMilliseconds.clamp(0, dur.inMilliseconds).toDouble()
                  : 0.0);
          return Column(
            children: [
              Slider(
                value: current,
                max: ready ? maxMs : 1,
                onChanged: ready ? (v) => setState(() => _drag = v) : null,
                onChangeEnd: (v) async {
                  await widget.player.seek(Duration(milliseconds: v.round()));
                  if (mounted) setState(() => _drag = null);
                },
                activeColor: Colors.white,
                inactiveColor: Colors.white24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmt(Duration(milliseconds: current.round())),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  Text(_fmt(dur),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          );
        },
      );
}
