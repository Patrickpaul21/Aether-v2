import 'package:flutter/material.dart';
import 'track.dart';

class CoverArt extends StatelessWidget {
  final Track track;
  final double size;
  const CoverArt({super.key, required this.track, required this.size});

  @override
  Widget build(BuildContext context) {
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
}
