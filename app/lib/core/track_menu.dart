import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cover_art.dart';
import 'library_state.dart';
import 'player_state.dart';
import 'playlist_sheets.dart';
import 'theme.dart';
import 'track.dart';

void showTrackMenu(
  BuildContext context,
  Track t, {
  VoidCallback? onRemove,
  String removeLabel = 'Remove',
}) {
  final container = ProviderScope.containerOf(context, listen: false);
  final player = container.read(playerProvider.notifier);
  final library = container.read(libraryProvider.notifier);
  final liked = container.read(libraryProvider).liked.any((x) => x.id == t.id);
  final messenger = ScaffoldMessenger.of(context);

  void done(BuildContext sheet, String message) {
    Navigator.pop(sheet);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CoverArt(track: t, size: 44),
            title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(t.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.playlist_play),
            title: const Text('Play next'),
            onTap: () {
              player.playNext(t);
              done(sheet, 'Playing next');
            },
          ),
          ListTile(
            leading: const Icon(Icons.queue_music),
            title: const Text('Add to queue'),
            onTap: () {
              player.addToQueue(t);
              done(sheet, 'Added to queue');
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to playlist'),
            onTap: () {
              Navigator.pop(sheet);
              showAddToPlaylistSheet(context, t);
            },
          ),
          ListTile(
            leading: Icon(liked ? Icons.favorite : Icons.favorite_border),
            title: Text(liked ? 'Remove from liked songs' : 'Like'),
            onTap: () {
              library.toggleLike(t);
              done(sheet, liked ? 'Removed from liked songs' : 'Liked');
            },
          ),
          if (onRemove != null)
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: Text(removeLabel),
              onTap: () {
                Navigator.pop(sheet);
                onRemove();
              },
            ),
        ],
      ),
    ),
  );
}
