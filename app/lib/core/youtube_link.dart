import 'dart:convert';
import 'package:http/http.dart' as http;
import 'track.dart';

String? parseVideoId(String input) {
  var text = input.trim();
  if (text.isEmpty || text.contains(' ')) return null;
  if (!text.contains('://') && text.toLowerCase().contains('youtu')) {
    text = 'https://$text';
  }
  final uri = Uri.tryParse(text);
  if (uri == null || !uri.hasAuthority) return null;

  final host = uri.host.toLowerCase();
  String? candidate;
  if (host == 'youtu.be') {
    if (uri.pathSegments.isNotEmpty) candidate = uri.pathSegments.first;
  } else if (host == 'youtube.com' || host.endsWith('.youtube.com')) {
    final v = uri.queryParameters['v'];
    if (v != null) {
      candidate = v;
    } else if (uri.pathSegments.length >= 2 &&
        const {'shorts', 'embed', 'live', 'v'}.contains(uri.pathSegments.first)) {
      candidate = uri.pathSegments[1];
    }
  }
  if (candidate == null) return null;
  return RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(candidate) ? candidate : null;
}

Future<Track> trackFromVideoId(String id) async {
  var title = 'YouTube video';
  var artist = 'YouTube';
  try {
    final res = await http
        .get(Uri.https('www.youtube.com', '/oembed', {
          'url': 'https://www.youtube.com/watch?v=$id',
          'format': 'json',
        }))
        .timeout(const Duration(seconds: 8));
    if (res.statusCode == 200) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      title = (j['title'] as String?) ?? title;
      artist = (j['author_name'] as String?) ?? artist;
    }
  } catch (_) {}
  return Track(
    id: id,
    title: title,
    artist: artist,
    coverUrl: 'https://i.ytimg.com/vi/$id/hqdefault.jpg',
    source: 'youtube',
  );
}
