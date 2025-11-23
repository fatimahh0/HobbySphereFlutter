// lib/theme/theme_extensions.dart
import 'package:flutter/material.dart';
import 'remote_theme_dto.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  // ===== COLORS =====
  final Color primary;
  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color text;
  final Color muted;
  final Color border;
  final Color error;

  // ===== SPACING =====
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;

  // ===== RADII =====
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  const AppThemeTokens({
    // colors
    required this.primary,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.muted,
    required this.border,
    required this.error,
    // spacing
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    // radii
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
  });

 
  factory AppThemeTokens.fallback() {
    return const AppThemeTokens(
      primary: Color(0xFF1D4ED8), // blue
      onPrimary: Colors.white,
      background: Color(0xFFF8FAFC),
      surface: Color(0xFFFFFFFF),
      surfaceAlt: Color(0xFFF1F5F9),
      text: Color(0xFF0F172A),
      muted: Color(0xFF64748B),
      border: Color(0xFFE2E8F0),
      error: Color(0xFFDC2626),
      spacingXs: 4,
      spacingSm: 8,
      spacingMd: 12,
      spacingLg: 16,
      spacingXl: 24,
      radiusSm: 8,
      radiusMd: 12,
      radiusLg: 20,
    );
  }

  /// Build tokens from backend/CI RemoteThemeDto
  factory AppThemeTokens.fromRemote(RemoteThemeDto remote) {
    final base = AppThemeTokens.fallback();
    final colors = remote.valuesMobile?.colors;
    if (colors == null) return base;

    final primary = parseHexColor(colors.primary, base.primary);
    final background = parseHexColor(colors.background, base.background);
    final surface = parseHexColor(colors.surface, base.surface);
    final text = parseHexColor(colors.body, base.text);
    final muted = parseHexColor(colors.label, base.muted);
    final border = parseHexColor(colors.border, base.border);
    final error = parseHexColor(colors.error, base.error);

 
    final onPrimary = primary.computeLuminance() < 0.5
        ? Colors.white
        : Colors.black;

    return AppThemeTokens(
      primary: primary,
      onPrimary: onPrimary,
      background: background,
      surface: surface,
      surfaceAlt: surface,
      text: text,
      muted: muted,
      border: border,
      error: error,
      spacingXs: base.spacingXs,
      spacingSm: base.spacingSm,
      spacingMd: base.spacingMd,
      spacingLg: base.spacingLg,
      spacingXl: base.spacingXl,
      radiusSm: base.radiusSm,
      radiusMd: base.radiusMd,
      radiusLg: base.radiusLg,
    );
  }

  @override
  AppThemeTokens copyWith({
    Color? primary,
    Color? onPrimary,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? text,
    Color? muted,
    Color? border,
    Color? error,
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
  }) {
    return AppThemeTokens(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      error: error ?? this.error,
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;

    Color lc(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    double ld(double a, double b) => a + (b - a) * t;

    return AppThemeTokens(
      primary: lc(primary, other.primary),
      onPrimary: lc(onPrimary, other.onPrimary),
      background: lc(background, other.background),
      surface: lc(surface, other.surface),
      surfaceAlt: lc(surfaceAlt, other.surfaceAlt),
      text: lc(text, other.text),
      muted: lc(muted, other.muted),
      border: lc(border, other.border),
      error: lc(error, other.error),
      spacingXs: ld(spacingXs, other.spacingXs),
      spacingSm: ld(spacingSm, other.spacingSm),
      spacingMd: ld(spacingMd, other.spacingMd),
      spacingLg: ld(spacingLg, other.spacingLg),
      spacingXl: ld(spacingXl, other.spacingXl),
      radiusSm: ld(radiusSm, other.radiusSm),
      radiusMd: ld(radiusMd, other.radiusMd),
      radiusLg: ld(radiusLg, other.radiusLg),
    );
  }
}
