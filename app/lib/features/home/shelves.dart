import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/track.dart';
import '../../lyrics/lyrics_service.dart' show cleanArtist;
import '../../sources/music_source.dart';

class Shelf {
  final String title;
  final String query;
  const Shelf(this.title, this.query);
}

const fixedShelves = [
  Shelf('Trending now', 'new music this week'),
  Shelf('Chill', 'chill songs'),
  Shelf('Workout', 'workout songs'),
  Shelf('Late night', 'late night songs'),
];

List<String> topArtists(List<Track> history, {int count = 2}) {
  final counts = <String, int>{};
  for (final t in history) {
    final a = cleanArtist(t.artist);
    if (a.isEmpty || a == 'Unknown') continue;
    counts[a] = (counts[a] ?? 0) + 1;
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(count).map((e) => e.key).toList();
}

List<Shelf> buildShelves(List<Track> history) => [
      for (final a in topArtists(history)) Shelf('More from $a', '$a songs'),
      ...fixedShelves,
    ];

final shelfTracksProvider =
    FutureProvider.family<List<Track>, String>((ref, query) {
  return ref.watch(musicSourceProvider).search(query);
});

Future<void> refreshShelves(WidgetRef ref, List<Shelf> shelves) async {
  ref.invalidate(shelfTracksProvider);
  await Future.wait(
    shelves.map(
      (s) => ref
          .read(shelfTracksProvider(s.query).future)
          .catchError((Object _) => <Track>[]),
    ),
  );
}
