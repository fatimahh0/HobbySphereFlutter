import 'package:flutter/material.dart';

// ========== COLORS ==========
class AppColors {
  static const primary = Color.fromARGB(255, 18, 148, 65); // brand green color
  static const onPrimary = Colors.white; // text/icon on primary color
  static const background = Color(0xFFF7F7F7); // app background
  static const text = Color(0xFF0F172A); // main text color (dark)
  static const muted = Color(0xFF64748B); // secondary text (gray)
  static const error = Color(0xFFDC2626); // error red
}

// ========== TYPOGRAPHY ==========
class AppTypography {
  static const textTheme = TextTheme(
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ), // titles
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ), // medium title
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ), // normal text
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ), // labels/buttons
  );
}

// ========== THEME ==========
class AppTheme {
  // Light theme
  static final ThemeData light = ThemeData(
    useMaterial3: true, // use Material 3 design
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      background: AppColors.background,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: AppTypography.textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: true,
    ),
  );

  // Dark theme
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark, // tells Flutter this is dark
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: Colors.black, // dark background
    textTheme: AppTypography.textTheme.apply(
      bodyColor: Colors.white, // text white in dark
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
