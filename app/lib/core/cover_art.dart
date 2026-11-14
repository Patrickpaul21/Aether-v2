import 'package:flutter/material.dart';
import 'track.dart';

class CoverArt extends StatelessWidget {
  final Track track;
  final double size;
  const CoverArt({super.key, required this.track, required this.size});

  Widget _fallback() {
    final hue = (track.id.hashCode % 360).abs().toDouble();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue, 0.5, 0.35).toColor(),
            HSLColor.fromAHSL(1, (hue + 40) % 360, 0.5, 0.2).toColor(),
          ],
        ),
      ),
      child: const Icon(Icons.music_note, color: Colors.white54),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (track.coverUrl.isEmpty) return _fallback();
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        track.coverUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _fallback(),
        errorBuilder: (_, __, ___) => _fallback(),
      ),
    );
  }
}
