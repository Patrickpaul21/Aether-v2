import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';
import 'track.dart';

class LibraryState {
  final List<Track> liked;
  final List<Track> history;
  const LibraryState({this.liked = const [], this.history = const []});
}

class LibraryNotifier extends Notifier<LibraryState> {
  @override
  LibraryState build() {
    final prefs = ref.read(prefsProvider);
    return LibraryState(
      liked: _load(prefs, 'liked'),
      history: _load(prefs, 'history'),
    );
  }

  List<Track> _load(SharedPreferences prefs, String key) {
    final raw = prefs.getString(key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  void _save(String key, List<Track> list) {
    ref
        .read(prefsProvider)
        .setString(key, jsonEncode(list.map((t) => t.toJson()).toList()));
  }

  void toggleLike(Track t) {
    final isLiked = state.liked.any((x) => x.id == t.id);
    final liked = isLiked
        ? state.liked.where((x) => x.id != t.id).toList()
        : [t, ...state.liked];
    state = LibraryState(liked: liked, history: state.history);
    _save('liked', liked);
  }

  void addToHistory(Track t) {
    final history = [
      t,
      ...state.history.where((x) => x.id != t.id),
    ].take(30).toList();
    state = LibraryState(liked: state.liked, history: history);
    _save('history', history);
  }
}

final libraryProvider =
    NotifierProvider<LibraryNotifier, LibraryState>(LibraryNotifier.new);
