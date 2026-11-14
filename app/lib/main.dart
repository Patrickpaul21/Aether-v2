import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/settings.dart';
import 'core/theme.dart';
import 'sources/device_youtube_source.dart';
import 'sources/music_source.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.patrickdondapati.aether.audio',
    androidNotificationChannelName: 'Aether playback',
    androidNotificationOngoing: true,
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      musicSourceProvider.overrideWithValue(DeviceYoutubeSource()),
    ],
    child: const AetherApp(),
  ));
}

class AetherApp extends StatelessWidget {
  const AetherApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Aether',
        theme: buildTheme(),
        routerConfig: router,
      );
}
