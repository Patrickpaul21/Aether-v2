import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/player_state.dart';

void showSleepSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => const SleepSheet(),
  );
}

class SleepSheet extends ConsumerWidget {
  const SleepSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(playerProvider);
    final n = ref.read(playerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final accent = Theme.of(context).colorScheme.primary;

    String? status;
    if (s.sleepAtTrackEnd) {
      status = 'Playback stops when this track ends';
    } else if (s.sleepEndsAt != null) {
      final secs = s.sleepEndsAt!.difference(DateTime.now()).inSeconds;
      status = 'Playback stops in about ${(secs / 60).ceil()} min';
    }

    void pick(String message, VoidCallback action) {
      action();
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Sleep timer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ),
          if (status != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(status, style: TextStyle(color: accent)),
              ),
            ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final m in const [1, 5, 15, 30, 45, 60])
                  ListTile(
                    title: Text(m == 1 ? '1 minute' : '$m minutes'),
                    onTap: () => pick('Sleep timer set for $m min',
                        () => n.setSleepTimer(Duration(minutes: m))),
                  ),
                ListTile(
                  title: const Text('End of this track'),
                  onTap: () => pick(
                      'Will stop after this track', n.setSleepAtTrackEnd),
                ),
                if (status != null)
                  ListTile(
                    title: const Text('Turn off timer'),
                    onTap: () => pick('Sleep timer off', n.cancelSleep),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
