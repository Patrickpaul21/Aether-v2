import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cover_art.dart';
import '../../core/player_state.dart';
import '../../core/theme.dart';

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
                  child: Text(track.artist,
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: 0.3,
                  onChanged: (_) {},
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1:12',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    Text('3:45',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
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
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: IconButton(
                        iconSize: 40,
                        color: Colors.black,
                        icon: Icon(s.isPlaying ? Icons.pause : Icons.play_arrow),
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
