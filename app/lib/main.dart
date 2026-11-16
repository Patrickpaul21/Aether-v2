import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/appearance.dart';
import 'core/settings.dart';
import 'core/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.patrickdondapati.aether.audio',
    androidNotificationChannelName: 'Aether playback',
    androidNotificationOngoing: true,
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const AetherApp(),
  ));
}

class AetherApp extends ConsumerWidget {
  const AetherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(appearanceProvider);
    return MaterialApp.router(
      title: 'Aether',
      theme: buildTheme(accent: accentPresets[a.accent]!, amoled: a.amoled),
      routerConfig: router,
    );
  }
}
