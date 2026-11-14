import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/theme.dart';

void main() => runApp(const ProviderScope(child: AetherApp()));

class AetherApp extends StatelessWidget {
  const AetherApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Aether',
        theme: buildTheme(),
        routerConfig: router,
      );
}
