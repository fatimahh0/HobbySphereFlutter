// Keep your AppTheme shape the same, but expose ThemeData as getters.
// This way, when Palette updates, AppTheme picks new values automatically.

import 'package:flutter/material.dart'; // ThemeData, TextTheme
import 'app_colors.dart'; // runtime AppColors

// ========== TYPOGRAPHY ==========
class AppTypography {
  // same as before
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
  // Light theme → getter (so values update after backend apply)
  static ThemeData get light => ThemeData(
    useMaterial3: true, // Material 3
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary, // runtime brand
      primary: AppColors.primary, // runtime brand
      onPrimary: AppColors.onPrimary, // runtime contrast
      background: AppColors.background, // runtime bg
      error: AppColors.error, // runtime error
    ),
    scaffoldBackgroundColor: AppColors.background, // runtime bg
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.text, // runtime body
      displayColor: AppColors.text, // runtime headings
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white, // runtime surface/white
      foregroundColor: AppColors.text, // runtime text
      elevation: 0, // flat
      centerTitle: true, // centered title
    ),
    dividerColor: AppColors.border, // runtime border
   
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // radius
        borderSide: BorderSide(color: AppColors.border), // runtime border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // radius
        borderSide: BorderSide(color: AppColors.border), // runtime border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // radius
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 1.6,
        ), // runtime focus
      ),
      labelStyle: TextStyle(color: AppColors.muted), // runtime label
      hintStyle: TextStyle(
        color: AppColors.muted.withOpacity(0.8),
      ), // runtime hint
      fillColor: AppColors.white, // runtime fill
      filled: true, // enable fill
    ),
  );

  // Dark theme → same as before (simple). You can keep static values here.
  static ThemeData get dark => ThemeData(
    useMaterial3: true, // Material 3
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary, // runtime if desired
      brightness: Brightness.dark, // dark scheme
      primary: AppColors.primary, // brand
      onPrimary: AppColors.onPrimary, // contrast
      error: AppColors.error, // error
    ),
    scaffoldBackgroundColor: Colors.black, // dark bg
    textTheme: AppTypography.textTheme.apply(
      bodyColor: Colors.white, // white text
      displayColor: Colors.white, // white headings
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black, // dark app bar
      foregroundColor: Colors.white, // white text
      elevation: 0, // flat
      centerTitle: true, // centered
    ),
  );
}
