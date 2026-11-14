import 'package:flutter/material.dart';
import '../../core/cover_art.dart';
import '../../core/mock_tracks.dart';
import '../../core/player_state.dart';
import '../../core/theme.dart';
import '../../core/track.dart';

String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 18) return 'Good afternoon';
  return 'Good evening';
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(greeting(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.0,
              children: [
                for (final t in mockTracks.take(6)) QuickTile(track: t)
              ],
            ),
            const SizedBox(height: 28),
            const Text('Made for you',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mockTracks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => ShelfCard(track: mockTracks[i]),
              ),
            ),
          ],
        ),
      );
}

class QuickTile extends StatelessWidget {
  final Track track;
  const QuickTile({super.key, required this.track});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => playTrack(context, track),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              CoverArt(track: track, size: 56),
              const SizedBox(width: 10),
              Expanded(
                child: Text(track.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
}

class ShelfCard extends StatelessWidget {
  final Track track;
  const ShelfCard({super.key, required this.track});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => playTrack(context, track),
        child: SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoverArt(track: track, size: 140),
              const SizedBox(height: 8),
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
      );
}
