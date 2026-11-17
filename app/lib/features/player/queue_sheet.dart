import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cover_art.dart';
import '../../core/player_state.dart';
import '../../core/theme.dart';

void showQueueSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => const QueueSheet(),
  );
}

class QueueSheet extends ConsumerWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(playerProvider);
    final n = ref.read(playerProvider.notifier);
    final current = s.track;
    final upcoming = s.upcoming;
    final accent = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Queue',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ),
                TextButton(
                  onPressed: upcoming.isEmpty ? null : n.clearUpcoming,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          if (current != null)
            ListTile(
              leading: CoverArt(track: current, size: 44),
              title: Text(current.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
              subtitle: const Text('Now playing',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Next up',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            child: upcoming.isEmpty
                ? const Center(
                    child: Text('Nothing queued',
                        style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: upcoming.length,
                    onReorder: n.moveUpcoming,
                    itemBuilder: (_, k) {
                      final t = upcoming[k];
                      return ListTile(
                        key: ValueKey(t.id),
                        onTap: () => n.jumpTo(s.index + 1 + k),
                        leading: CoverArt(track: t, size: 44),
                        title: Text(t.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(t.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => n.removeUpcoming(k),
                            ),
                            ReorderableDragStartListener(
                              index: k,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.drag_handle,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
