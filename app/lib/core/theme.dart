import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF000000);
  static const surface = Color(0xFF111113);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9A9AA0);
  static const accent = Color(0xFF8B5CF6);
}

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.accent,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.surface,
      ),
    );
