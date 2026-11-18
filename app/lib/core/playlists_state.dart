import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings.dart';
import 'track.dart';

class Playlist {
  final String id;
  final String name;
  final List<Track> tracks;
  const Playlist({
    required this.id,
    required this.name,
    this.tracks = const [],
  });

  Playlist copyWith({String? name, List<Track>? tracks}) => Playlist(
        id: id,
        name: name ?? this.name,
        tracks: tracks ?? this.tracks,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tracks': tracks.map((t) => t.toJson()).toList(),
      };

  factory Playlist.fromJson(Map<String, dynamic> j) => Playlist(
        id: j['id'] as String,
        name: j['name'] as String,
        tracks: ((j['tracks'] as List?) ?? const [])
            .map((e) => Track.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PlaylistsNotifier extends Notifier<List<Playlist>> {
  @override
  List<Playlist> build() {
    final raw = ref.read(prefsProvider).getString('playlists');
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  void _save(List<Playlist> list) {
    state = list;
    ref
        .read(prefsProvider)
        .setString('playlists', jsonEncode(list.map((p) => p.toJson()).toList()));
  }

  String create(String name, {Track? first}) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final trimmed = name.trim().isEmpty ? 'New playlist' : name.trim();
    _save([
      ...state,
      Playlist(id: id, name: trimmed, tracks: first == null ? const [] : [first]),
    ]);
    return id;
  }

  bool addTrack(String playlistId, Track t) {
    final p = state.where((x) => x.id == playlistId).firstOrNull;
    if (p == null || p.tracks.any((x) => x.id == t.id)) return false;
    _save([
      for (final x in state)
        x.id == playlistId ? x.copyWith(tracks: [...x.tracks, t]) : x
    ]);
    return true;
  }

  void removeTrack(String playlistId, String trackId) {
    _save([
      for (final p in state)
        p.id == playlistId
            ? p.copyWith(
                tracks: p.tracks.where((t) => t.id != trackId).toList())
            : p
    ]);
  }

  void rename(String id, String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    _save([
      for (final p in state) p.id == id ? p.copyWith(name: n) : p
    ]);
  }

  void delete(String id) => _save(state.where((p) => p.id != id).toList());
}

final playlistsProvider =
    NotifierProvider<PlaylistsNotifier, List<Playlist>>(PlaylistsNotifier.new);
