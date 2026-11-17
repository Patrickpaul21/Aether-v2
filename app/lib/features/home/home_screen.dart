import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/cover_art.dart';
import '../../core/library_state.dart';
import '../../core/player_state.dart';
import '../../core/theme.dart';
import '../../core/track.dart';
import '../../core/track_menu.dart';
import 'shelves.dart';

String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 18) return 'Good afternoon';
  return 'Good evening';
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider);
    final history = lib.history;
    final liked = lib.liked;
    final shelves = buildShelves(history);
    final seen = history.map((t) => t.id).toSet();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => refreshShelves(ref, shelves),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(greeting(),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (history.isNotEmpty)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 3.0,
                children: [
                  for (final t in history.take(6))
                    QuickTile(track: t, queue: history)
                ],
              ),
            if (liked.isNotEmpty) ...[
              const _ShelfTitle('Liked songs'),
              SizedBox(height: 200, child: _TrackRow(tracks: liked)),
            ],
            for (final s in shelves) ShelfSection(shelf: s, exclude: seen),
          ],
        ),
      ),
    );
  }
}

class _ShelfTitle extends StatelessWidget {
  final String text;
  const _ShelfTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 12),
        child: Text(text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      );
}

class ShelfSection extends ConsumerWidget {
  final Shelf shelf;
  final Set<String> exclude;
  const ShelfSection({super.key, required this.shelf, required this.exclude});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(shelfTracksProvider(shelf.query));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShelfTitle(shelf.title),
        SizedBox(
          height: 200,
          child: async.when(
            loading: () => const _SkeletonRow(),
            error: (e, st) => Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Couldn't load this shelf.",
                      style: TextStyle(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(shelfTracksProvider(shelf.query)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (tracks) {
              final list =
                  tracks.where((t) => !exclude.contains(t.id)).toList();
              if (list.isEmpty) {
                return const Center(
                  child: Text('Nothing new here yet.',
                      style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              return _TrackRow(tracks: list);
            },
          ),
        ),
      ],
    );
  }
}

class _TrackRow extends StatelessWidget {
  final List<Track> tracks;
  const _TrackRow({required this.tracks});

  @override
  Widget build(BuildContext context) => ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tracks.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, i) =>
            ShelfCard(track: tracks[i], queue: tracks),
      );
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    Widget bar(double w) => Container(
          width: w,
          height: 10,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4)),
        );
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, i) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4)),
          ),
          bar(110),
          bar(70),
        ],
      ),
    );
  }
}

class QuickTile extends StatelessWidget {
  final Track track;
  final List<Track> queue;
  const QuickTile({super.key, required this.track, required this.queue});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => playTrack(context, track, queue: queue),
        onLongPress: () => showTrackMenu(context, track),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
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
  final List<Track> queue;
  const ShelfCard({super.key, required this.track, required this.queue});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => playTrack(context, track, queue: queue),
        onLongPress: () => showTrackMenu(context, track),
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
