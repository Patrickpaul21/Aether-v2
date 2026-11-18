import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/cover_art.dart';
import '../../core/player_state.dart';
import '../../core/playlist_sheets.dart';
import '../../core/playlists_state.dart';
import '../../core/theme.dart';
import '../../core/track_menu.dart';

class PlaylistScreen extends ConsumerWidget {
  final String id;
  const PlaylistScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist =
        ref.watch(playlistsProvider).where((p) => p.id == id).firstOrNull;
    if (playlist == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Playlist not found',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final notifier = ref.read(playlistsProvider.notifier);
    final tracks = playlist.tracks;
    final accent = Theme.of(context).colorScheme.primary;

    Future<void> onMenu(String v) async {
      if (v == 'rename') {
        final name = await promptPlaylistName(
          context,
          title: 'Rename playlist',
          initial: playlist.name,
        );
        if (name != null) notifier.rename(id, name);
      } else if (v == 'delete') {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Delete "${playlist.name}"?'),
            content: const Text('The songs stay in your other playlists.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (ok == true && context.mounted) {
          context.pop();
          notifier.delete(id);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text(playlist.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<String>(
            onSelected: onMenu,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rename', child: Text('Rename')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('${tracks.length} songs',
                      style: const TextStyle(color: AppColors.textSecondary)),
                ),
                IconButton(
                  icon: const Icon(Icons.shuffle),
                  onPressed: tracks.isEmpty
                      ? null
                      : () {
                          final list = [...tracks]..shuffle();
                          playTrack(context, list.first, queue: list);
                        },
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  onPressed: tracks.isEmpty
                      ? null
                      : () =>
                          playTrack(context, tracks.first, queue: tracks),
                ),
              ],
            ),
          ),
          if (tracks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Center(
                child: Text(
                  'This playlist is empty.\nUse the ⋮ menu on any song to add it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            for (final t in tracks)
              ListTile(
                onTap: () => playTrack(context, t, queue: tracks),
                leading: CoverArt(track: t, size: 48),
                title: Text(t.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(t.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary)),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => showTrackMenu(
                    context,
                    t,
                    removeLabel: 'Remove from playlist',
                    onRemove: () => notifier.removeTrack(id, t.id),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
