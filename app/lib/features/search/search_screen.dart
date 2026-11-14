import 'package:flutter/material.dart';
import '../../core/cover_art.dart';
import '../../core/mock_tracks.dart';
import '../../core/player_state.dart';
import '../../core/theme.dart';
import '../../core/track.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String _source = 'all';

  static const _sources = {
    'all': 'All',
    'youtube': 'YouTube',
    'audius': 'Audius',
  };

  List<Track> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return mockTracks.where((t) {
      final matches =
          t.title.toLowerCase().contains(q) || t.artist.toLowerCase().contains(q);
      return matches && (_source == 'all' || t.source == _source);
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
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
              onChanged: (v) => setState(() => _query = v),
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
                          setState(() => _query = '');
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
          if (hasQuery)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final e in _sources.entries)
                    ChoiceChip(
                      label: Text(e.value),
                      selected: _source == e.key,
                      showCheckmark: false,
                      selectedColor: AppColors.accent,
                      backgroundColor: AppColors.elevated,
                      side: BorderSide.none,
                      labelStyle: TextStyle(
                        color: _source == e.key ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _source = e.key),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(child: _body(results, hasQuery)),
        ],
      ),
    );
  }

  Widget _body(List<Track> results, bool hasQuery) {
    if (!hasQuery) {
      return const Center(
        child: Text('Search for songs and artists',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Text('No results for "$_query"',
            style: const TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final t = results[i];
        return ListTile(
          onTap: () => playTrack(context, t),
          leading: CoverArt(track: t, size: 48),
          title: Text(t.title,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(t.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary)),
        );
      },
    );
  }
}
