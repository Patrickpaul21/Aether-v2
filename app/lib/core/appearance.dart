import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings.dart';

const accentPresets = <String, Color>{
  'Green': Color(0xFF1DB954),
  'Purple': Color(0xFF8B5CF6),
  'Blue': Color(0xFF3B82F6),
  'Orange': Color(0xFFF97316),
  'Pink': Color(0xFFEC4899),
};

class Appearance {
  final String accent;
  final bool amoled;
  const Appearance({required this.accent, required this.amoled});
}

class AppearanceNotifier extends Notifier<Appearance> {
  @override
  Appearance build() {
    final p = ref.read(prefsProvider);
    final saved = p.getString('accent');
    return Appearance(
      accent: accentPresets.containsKey(saved) ? saved! : 'Green',
      amoled: p.getBool('amoled') ?? false,
    );
  }

  void setAccent(String name) {
    ref.read(prefsProvider).setString('accent', name);
    state = Appearance(accent: name, amoled: state.amoled);
  }

  void setAmoled(bool value) {
    ref.read(prefsProvider).setBool('amoled', value);
    state = Appearance(accent: state.accent, amoled: value);
  }
}

final appearanceProvider =
    NotifierProvider<AppearanceNotifier, Appearance>(AppearanceNotifier.new);
