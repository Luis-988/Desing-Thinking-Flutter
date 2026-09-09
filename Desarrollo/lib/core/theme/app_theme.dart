import 'package:flutter/material.dart';

class AppTheme {
  static const navy = Color(0xFF1B3A6B);
  static const background = Color(0xFFF5F7FA);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: navy,
        primary: navy,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF1F4F8),
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }
}
