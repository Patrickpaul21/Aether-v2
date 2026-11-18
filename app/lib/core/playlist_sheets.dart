import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'playlists_state.dart';
import 'theme.dart';
import 'track.dart';

Future<String?> promptPlaylistName(
  BuildContext context, {
  String title = 'New playlist',
  String initial = '',
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Playlist name'),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void showAddToPlaylistSheet(BuildContext context, Track t) {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);

  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (sheet) => Consumer(
      builder: (context, ref, child) {
        final playlists = ref.watch(playlistsProvider);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Add to playlist',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New playlist'),
                onTap: () async {
                  final name = await promptPlaylistName(sheet);
                  if (name == null) return;
                  container
                      .read(playlistsProvider.notifier)
                      .create(name, first: t);
                  if (sheet.mounted) Navigator.pop(sheet);
                  messenger.showSnackBar(SnackBar(
                    content: Text(
                        'Added to ${name.trim().isEmpty ? 'New playlist' : name.trim()}'),
                  ));
                },
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final p in playlists)
                      ListTile(
                        leading: const Icon(Icons.queue_music),
                        title: Text(p.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${p.tracks.length} songs',
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        onTap: () {
                          final added = container
                              .read(playlistsProvider.notifier)
                              .addTrack(p.id, t);
                          Navigator.pop(sheet);
                          messenger.showSnackBar(SnackBar(
                            content: Text(added
                                ? 'Added to ${p.name}'
                                : 'Already in ${p.name}'),
                          ));
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
