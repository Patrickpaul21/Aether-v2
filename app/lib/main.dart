import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/appearance.dart';
import 'core/audio_handler.dart';
import 'core/player_state.dart';
import 'core/settings.dart';
import 'core/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final handler = await AudioService.init(
    builder: () => AetherAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.patrickdondapati.aether.audio',
      androidNotificationChannelName: 'Aether playback',
      androidNotificationOngoing: true,
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      audioHandlerProvider.overrideWithValue(handler),
    ],
    child: const AetherApp(),
  ));
}

class AetherApp extends ConsumerWidget {
  const AetherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(appearanceProvider);
    ref.listen<PlayerStatus>(playerProvider, (prev, next) {
      if (prev == null) return;
      if (!identical(prev.queue, next.queue) ||
          prev.index != next.index ||
          prev.shuffle != next.shuffle ||
          prev.repeat != next.repeat) {
        ref.read(playerProvider.notifier).persistSession(
              resetPosition: prev.track?.id != next.track?.id,
            );
      }
    });
    return MaterialApp.router(
      title: 'Aether',
      theme: buildTheme(accent: accentPresets[a.accent]!, amoled: a.amoled),
      routerConfig: router,
    );
  }
}
