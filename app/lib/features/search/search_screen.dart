import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/cover_art.dart';
import '../../core/player_state.dart';
import '../../core/settings.dart';
import '../../core/theme.dart';
import '../../core/track.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  int _request = 0;
  String _query = '';
  bool _loading = false;
  String? _error;
  List<Track> _results = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    setState(() => _query = v);
    _debounce?.cancel();
    final q = v.trim();
    if (q.isEmpty) {
      _request++;
      setState(() {
        _results = const [];
        _loading = false;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(q));
  }

  Future<void> _search(String q) async {
    final id = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final base = ref.read(serverUrlProvider);
      final res = await http
          .get(Uri.parse('$base/search').replace(queryParameters: {'q': q}))
          .timeout(const Duration(seconds: 20));
      if (id != _request) return;
      if (res.statusCode != 200) {
        throw Exception('Server returned ${res.statusCode}');
      }
      final list =
          (jsonDecode(res.body) as Map<String, dynamic>)['results'] as List;
      setState(() {
        _results = list.map((r) {
          final m = r as Map<String, dynamic>;
          return Track(
            id: m['id'] as String,
            title: (m['title'] as String?) ?? 'Untitled',
            artist: (m['artist'] as String?) ?? 'Unknown',
            coverUrl: (m['cover'] as String?) ?? '',
            source: 'youtube',
          );
        }).toList();
        _loading = false;
      });
    } catch (_) {
      if (id != _request) return;
      setState(() {
        _results = const [];
        _error = "Couldn't reach the server. Check the address in Settings.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.trim().isNotEmpty;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text('Search',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'What do you want to listen to?',
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                suffixIcon: hasQuery
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () {
                          _controller.clear();
                          _onChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _body(hasQuery)),
        ],
      ),
    );
  }

  Widget _body(bool hasQuery) {
    if (!hasQuery) {
      return const Center(
        child: Text('Search for songs and artists',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    if (_loading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent)),
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Text('No results for "$_query"',
            style: const TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final t = _results[i];
        return ListTile(
          onTap: () => playTrack(context, t, queue: _results),
          leading: CoverArt(track: t, size: 48),
          title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(t.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary)),
        );
      },
    );
  }
}
