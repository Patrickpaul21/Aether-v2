import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AetherAudioHandler extends BaseAudioHandler {
  Future<void> Function()? onPlay;
  Future<void> Function()? onPause;
  Future<void> Function()? onNext;
  Future<void> Function()? onPrev;
  Future<void> Function()? onStop;
  Future<void> Function(Duration position)? onSeek;

  @override
  Future<void> play() async => onPlay?.call();

  @override
  Future<void> pause() async => onPause?.call();

  @override
  Future<void> skipToNext() async => onNext?.call();

  @override
  Future<void> skipToPrevious() async => onPrev?.call();

  @override
  Future<void> seek(Duration position) async => onSeek?.call(position);

  @override
  Future<void> stop() async {
    await onStop?.call();
    await super.stop();
  }
}

final audioHandlerProvider = Provider<AetherAudioHandler>(
  (ref) => throw UnimplementedError('audioHandlerProvider must be overridden'),
);
