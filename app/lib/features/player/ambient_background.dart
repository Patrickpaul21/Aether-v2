import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/track.dart';

const double _blur = 20;

class AmbientBackground extends StatelessWidget {
  final Track track;
  final Widget child;
  const AmbientBackground({
    super.key,
    required this.track,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).scaffoldBackgroundColor;
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: base),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          layoutBuilder: (current, previous) => Stack(
            fit: StackFit.expand,
            children: [...previous, ?current],
          ),
          child: _Backdrop(key: ValueKey(track.id), track: track),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                base.withValues(alpha: 0.35),
                base.withValues(alpha: 0.7),
                base,
              ],
              stops: const [0, 0.55, 1],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _Backdrop extends StatefulWidget {
  final Track track;
  const _Backdrop({super.key, required this.track});

  @override
  State<_Backdrop> createState() => _BackdropState();
}

class _BackdropState extends State<_Backdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _fallback() {
    final hue = (widget.track.id.hashCode % 360).abs().toDouble();
    return ColoredBox(color: HSLColor.fromAHSL(1, hue, 0.45, 0.28).toColor());
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.track.coverUrl;
    final image = url.isEmpty
        ? _fallback()
        : Image.network(
            url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            cacheWidth: 48,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stack) => _fallback(),
          );
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final v = Curves.easeInOut.transform(_c.value);
          return FractionalTranslation(
            translation: Offset(-0.05 + 0.10 * v, 0.04 - 0.08 * v),
            child: Transform.scale(scale: 1.35, child: child),
          );
        },
        child: RepaintBoundary(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
            child: image,
          ),
        ),
      ),
    );
  }
}
