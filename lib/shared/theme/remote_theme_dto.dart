// lib/theme/remote_theme_dto.dart
import 'package:flutter/material.dart';

class RemoteThemeDto {
  final String? menuType;
  final RemoteThemeValuesMobile? valuesMobile;

  RemoteThemeDto({required this.menuType, required this.valuesMobile});

  factory RemoteThemeDto.fromJson(Map<String, dynamic> json) {
    return RemoteThemeDto(
      menuType: json['menuType']?.toString(),
      valuesMobile: json['valuesMobile'] == null
          ? null
          : RemoteThemeValuesMobile.fromJson(
              json['valuesMobile'] as Map<String, dynamic>,
            ),
    );
  }
}

class RemoteThemeValuesMobile {
  final RemoteThemeColors? colors;

  RemoteThemeValuesMobile({required this.colors});

  factory RemoteThemeValuesMobile.fromJson(Map<String, dynamic> json) {
    return RemoteThemeValuesMobile(
      colors: json['colors'] == null
          ? null
          : RemoteThemeColors.fromJson(json['colors'] as Map<String, dynamic>),
    );
  }
}

class RemoteThemeColors {
  final String? primary;
  final String? surface;
  final String? background;
  final String? label;
  final String? body;
  final String? border;
  final String? error;
  final String? transparent;

  RemoteThemeColors({
    this.primary,
    this.surface,
    this.background,
    this.label,
    this.body,
    this.border,
    this.error,
    this.transparent,
  });

  factory RemoteThemeColors.fromJson(Map<String, dynamic> json) {
    return RemoteThemeColors(
      primary: json['primary']?.toString(),
      surface: json['surface']?.toString(),
      background: json['background']?.toString(),
      label: json['label']?.toString(),
      body: json['body']?.toString(),
      border: json['border']?.toString(),
      error: json['error']?.toString(),
      transparent: json['transparent']?.toString(),
    );
  }
}

/// Small helper to convert backend hex/transparent to Color safely.
Color parseHexColor(String? raw, Color fallback) {
  final s = (raw ?? '').trim();
  if (s.isEmpty) return fallback;

  if (s.toLowerCase() == 'transparent') {
    return Colors.transparent;
  }

  // supports "#RRGGBB"
  final re = RegExp(r'^#([0-9a-fA-F]{6})$');
  if (!re.hasMatch(s)) return fallback;

  final n = int.parse(s.substring(1), radix: 16);
  return Color(0xFF000000 | n);
}
