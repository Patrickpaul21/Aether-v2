import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cover_art.dart';
import '../../core/player_state.dart';
import '../../core/theme.dart';
import 'now_playing_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(playerProvider);
    final track = s.track;
    if (track == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const NowPlayingScreen(),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            CoverArt(track: track, size: 44),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(s.isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () => ref.read(playerProvider.notifier).toggle(),
            ),
          ],
        ),
      ),
    );
  }
}
