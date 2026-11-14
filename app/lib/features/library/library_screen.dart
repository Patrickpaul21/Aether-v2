import 'package:flutter/material.dart';
import '../../core/cover_art.dart';
import '../../core/mock_tracks.dart';
import '../../core/player_state.dart';
import '../../core/theme.dart';
import '../../core/track.dart';

class _Playlist {
  final String name;
  final List<Track> tracks;
  const _Playlist(this.name, this.tracks);
}

final _likedSongs = mockTracks.take(4).toList();

final _playlists = [
  _Playlist('Late Night Drive', mockTracks.sublist(0, 5)),
  _Playlist('Focus', mockTracks.sublist(3, 8)),
  _Playlist('Road Trip', mockTracks.sublist(5, 10)),
];

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const Text('Your Library',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _LikedRow(
              count: _likedSongs.length,
              onTap: () => playTrack(context, _likedSongs.first),
            ),
            for (final p in _playlists)
              _PlaylistRow(
                playlist: p,
                onTap: () => playTrack(context, p.tracks.first),
              ),
          ],
        ),
      );
}

class _LikedRow extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _LikedRow({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFFA5B4FC)],
            ),
          ),
          child: const Icon(Icons.favorite, color: Colors.white),
        ),
        title: const Text('Liked Songs',
            style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('Playlist · $count songs',
            style: const TextStyle(color: AppColors.textSecondary)),
      );
}

class _PlaylistRow extends StatelessWidget {
  final _Playlist playlist;
  final VoidCallback onTap;
  const _PlaylistRow({required this.playlist, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: CoverArt(track: playlist.tracks.first, size: 56),
        title: Text(playlist.name,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('Playlist · ${playlist.tracks.length} songs',
            style: const TextStyle(color: AppColors.textSecondary)),
      );
}
