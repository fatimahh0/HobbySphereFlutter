// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'theme_extensions.dart';

class AppTypography {
  static const textTheme = TextTheme(
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );
}

class AppTheme {
  /// Build a ThemeData from the tokens
  static ThemeData fromTokens(AppThemeTokens tokens) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: tokens.primary,
      primary: tokens.primary,
      onPrimary: tokens.onPrimary,
      background: tokens.background,
      surface: tokens.surface,
      error: tokens.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.background,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: tokens.text,
        displayColor: tokens.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.surface,
        foregroundColor: tokens.text,
        elevation: 0,
        centerTitle: true,
      ),
      dividerColor: tokens.border,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide(color: tokens.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide(color: tokens.error),
        ),
        labelStyle: TextStyle(color: tokens.muted),
        hintStyle: TextStyle(color: tokens.muted.withOpacity(0.8)),
        fillColor: tokens.surface,
        filled: true,
      ),
      cardTheme: CardThemeData(
        color: tokens.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
        margin: EdgeInsets.all(tokens.spacingSm),
      ),
      extensions: <ThemeExtension<dynamic>>[tokens],
    );
  }

  /// Dark theme: simple fallback for now
  static ThemeData dark() {
    final tokens = AppThemeTokens.fallback();
    return ThemeData.dark().copyWith(
      textTheme: AppTypography.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      extensions: <ThemeExtension<dynamic>>[tokens],
    );
  }
}
