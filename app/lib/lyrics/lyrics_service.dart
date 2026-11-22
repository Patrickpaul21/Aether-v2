import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/player_state.dart';
import '../core/text_clean.dart';
import '../core/track.dart';

class LyricLine {
  final Duration time;
  final String text;
  const LyricLine(this.time, this.text);
}

class Lyrics {
  final List<LyricLine> synced;
  final String? plain;
  final bool instrumental;
  const Lyrics({
    this.synced = const [],
    this.plain,
    this.instrumental = false,
  });
  bool get hasSynced => synced.isNotEmpty;
}

const _headers = {
  'User-Agent': 'Aether/2.0 (https://github.com/Patrickpaul21/Aether-v2)',
};

List<(String, String)> _candidates(Track t) {
  final out = <(String, String)>[];
  final title = cleanTitle(t.title);
  final artist = cleanArtist(t.artist);
  final parts = title.split(RegExp(r'\s[-–]\s'));
  if (parts.length >= 2) {
    out.add((parts.first.trim(), parts.sublist(1).join(' - ').trim()));
  }
  out.add((artist, title));
  return out;
}

List<LyricLine> parseLrc(String lrc) {
  final stamp = RegExp(r'\[(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]');
  final out = <LyricLine>[];
  for (final raw in lrc.split('\n')) {
    final matches = stamp.allMatches(raw).toList();
    if (matches.isEmpty) continue;
    final text = raw.replaceAll(stamp, '').trim();
    for (final m in matches) {
      final min = int.parse(m.group(1)!);
      final sec = int.parse(m.group(2)!);
      final frac = m.group(3);
      final ms =
          frac == null ? 0 : int.parse(frac.padRight(3, '0').substring(0, 3));
      out.add(LyricLine(
        Duration(minutes: min, seconds: sec, milliseconds: ms),
        text,
      ));
    }
  }
  out.sort((a, b) => a.time.compareTo(b.time));
  return out;
}

Lyrics? _fromJson(dynamic j) {
  if (j is! Map<String, dynamic>) return null;
  if (j['instrumental'] == true) return const Lyrics(instrumental: true);
  final synced = j['syncedLyrics'] as String?;
  final plain = j['plainLyrics'] as String?;
  final lines = synced == null ? <LyricLine>[] : parseLrc(synced);
  if (lines.isEmpty && (plain == null || plain.trim().isEmpty)) return null;
  return Lyrics(synced: lines, plain: plain);
}

Future<Lyrics?> _lookup(String artist, String title, int? duration) async {
  const timeout = Duration(seconds: 10);

  final get = await http
      .get(
        Uri.https('lrclib.net', '/api/get', {
          'artist_name': artist,
          'track_name': title,
          if (duration != null) 'duration': '$duration',
        }),
        headers: _headers,
      )
      .timeout(timeout);
  if (get.statusCode == 200) {
    final hit = _fromJson(jsonDecode(get.body));
    if (hit != null) return hit;
  } else if (get.statusCode != 404) {
    throw Exception('LRCLIB returned ${get.statusCode}');
  }

  final search = await http
      .get(
        Uri.https('lrclib.net', '/api/search', {
          'artist_name': artist,
          'track_name': title,
        }),
        headers: _headers,
      )
      .timeout(timeout);
  if (search.statusCode == 404) return null;
  if (search.statusCode != 200) {
    throw Exception('LRCLIB returned ${search.statusCode}');
  }
  final list = (jsonDecode(search.body) as List)
      .whereType<Map<String, dynamic>>()
      .where((h) =>
          (h['syncedLyrics'] as String?)?.isNotEmpty == true ||
          (h['plainLyrics'] as String?)?.isNotEmpty == true)
      .toList();
  if (list.isEmpty) return null;

  Map<String, dynamic>? best;
  if (duration != null) {
    final close = list.where((h) {
      final d = (h['duration'] as num?)?.toDouble();
      return d != null && (d - duration).abs() <= 5;
    }).toList();
    if (close.isNotEmpty) {
      best = close.firstWhere(
        (h) => (h['syncedLyrics'] as String?)?.isNotEmpty == true,
        orElse: () => close.first,
      );
    }
  }
  best ??= list.firstWhere(
    (h) => (h['syncedLyrics'] as String?)?.isNotEmpty == true,
    orElse: () => list.first,
  );
  return _fromJson(best);
}

Future<Lyrics?> fetchLyrics(Track t) async {
  for (final (artist, title) in _candidates(t)) {
    if (artist.isEmpty || title.isEmpty) continue;
    final hit = await _lookup(artist, title, t.duration);
    if (hit != null) return hit;
  }
  return null;
}

final _lyricsCache = <String, Lyrics?>{};

final currentLyricsProvider = FutureProvider<Lyrics?>((ref) async {
  final track = ref.watch(playerProvider.select((s) => s.track));
  if (track == null) return null;
  if (_lyricsCache.containsKey(track.id)) return _lyricsCache[track.id];
  final result = await fetchLyrics(track);
  _lyricsCache[track.id] = result;
  return result;
});
