import 'package:flutter/material.dart';

class AppColors {
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
}

ThemeData buildTheme({required Color accent, required bool amoled}) {
  final background = amoled ? Colors.black : const Color(0xFF121212);
  final surface = amoled ? const Color(0xFF0A0A0A) : const Color(0xFF181818);
  final elevated = amoled ? const Color(0xFF1A1A1A) : const Color(0xFF282828);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.dark(
      primary: accent,
      surface: surface,
      surfaceContainerHigh: elevated,
    ),
    appBarTheme: AppBarTheme(backgroundColor: background),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: background,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? accent
              : AppColors.textSecondary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          color: states.contains(WidgetState.selected)
              ? accent
              : AppColors.textSecondary,
        ),
      ),
    ),
  );
}
