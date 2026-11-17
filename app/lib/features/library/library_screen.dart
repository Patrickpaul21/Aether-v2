import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cover_art.dart';
import '../../core/library_state.dart';
import '../../core/player_state.dart';
import '../../core/theme.dart';
import '../../core/track_menu.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = ref.watch(libraryProvider).liked;
    final accent = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const Text('Your Library',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: liked.isEmpty
                ? null
                : () => playTrack(context, liked.first, queue: liked),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4F46E5), Color(0xFFA5B4FC)],
                ),
              ),
              child: const Icon(Icons.favorite, color: Colors.white),
            ),
            title: const Text('Liked Songs',
                style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('Playlist · ${liked.length} songs',
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 8),
          if (liked.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Tap the heart on a track to save it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            for (final t in liked)
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => playTrack(context, t, queue: liked),
                leading: CoverArt(track: t, size: 48),
                title: Text(t.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(t.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.favorite, color: accent),
                      onPressed: () =>
                          ref.read(libraryProvider.notifier).toggleLike(t),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => showTrackMenu(context, t),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
