import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFB86B2D),
      brightness: Brightness.light,
    );

    return ThemeData(useMaterial3: true, colorScheme: colorScheme).copyWith(
      appBarTheme: const AppBarTheme(centerTitle: true),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
    );
  }
}
