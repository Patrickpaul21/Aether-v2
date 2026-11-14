import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/settings.dart';
import '../core/track.dart';

class StreamInfo {
  final String url;
  const StreamInfo(this.url);
}

abstract class MusicSource {
  Future<List<Track>> search(String query);
  Future<StreamInfo> getStream(String trackId);
}

class ServerYoutubeSource implements MusicSource {
  final String baseUrl;
  const ServerYoutubeSource(this.baseUrl);

  @override
  Future<List<Track>> search(String query) async {
    final res = await http
        .get(Uri.parse('$baseUrl/search').replace(queryParameters: {'q': query}))
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw Exception('Server returned ${res.statusCode}');
    }
    final list =
        (jsonDecode(res.body) as Map<String, dynamic>)['results'] as List;
    return list.map((r) {
      final m = r as Map<String, dynamic>;
      return Track(
        id: m['id'] as String,
        title: (m['title'] as String?) ?? 'Untitled',
        artist: (m['artist'] as String?) ?? 'Unknown',
        coverUrl: (m['cover'] as String?) ?? '',
        source: 'youtube',
      );
    }).toList();
  }

  @override
  Future<StreamInfo> getStream(String trackId) async {
    final res = await http
        .get(Uri.parse('$baseUrl/stream/$trackId'))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw Exception('Server returned ${res.statusCode}');
    }
    final url =
        (jsonDecode(res.body) as Map<String, dynamic>)['url'] as String;
    return StreamInfo(url);
  }
}

final musicSourceProvider = Provider<MusicSource>(
  (ref) => ServerYoutubeSource(ref.watch(serverUrlProvider)),
);
