import 'package:flutter/material.dart';
import '../../core/mock_tracks.dart';
import '../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Good evening',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            for (final t in mockTracks)
              ListTile(
                title: Text(t.title),
                subtitle: Text(t.artist,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
          ],
        ),
      );
}
