import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings.dart';

class RecentSearchesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() =>
      ref.read(prefsProvider).getStringList('recent_searches') ?? const [];

  void add(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final list = [
      q,
      ...state.where((x) => x.toLowerCase() != q.toLowerCase()),
    ].take(8).toList();
    state = list;
    ref.read(prefsProvider).setStringList('recent_searches', list);
  }

  void clear() {
    state = const [];
    ref.read(prefsProvider).remove('recent_searches');
  }
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(
        RecentSearchesNotifier.new);
