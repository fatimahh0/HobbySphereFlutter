// lib/theme/theme_cubit.dart
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hobby_sphere/config/env.dart';

import 'remote_theme_dto.dart';
import 'theme_extensions.dart';
import 'app_theme.dart';

/// State of the theme: we keep tokens + ready ThemeData
class ThemeState {
  final AppThemeTokens tokens;
  final ThemeData themeData;

  const ThemeState({required this.tokens, required this.themeData});

  factory ThemeState.initial() {
    final tokens = AppThemeTokens.fallback();
    return ThemeState(tokens: tokens, themeData: AppTheme.fromTokens(tokens));
  }

  ThemeState copyWith({AppThemeTokens? tokens, ThemeData? themeData}) {
    final newTokens = tokens ?? this.tokens;
    return ThemeState(
      tokens: newTokens,
      themeData: themeData ?? this.themeData,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  final Dio dio;
  final String themeEndpoint; // e.g. "$baseUrl/themes/active/mobile"

  ThemeCubit({required this.dio, required this.themeEndpoint})
    : super(ThemeState.initial()) {
    _loadFromEnvIfPresent();
  }

  /// 1) First try to load theme JSON from build-time (Env.THEME_JSON)
  void _loadFromEnvIfPresent() {
    final map = Env.themeJson;
    if (map == null) return;

    try {
      final dto = RemoteThemeDto.fromJson(map);
      final tokens = AppThemeTokens.fromRemote(dto);
      final theme = AppTheme.fromTokens(tokens);

      emit(ThemeState(tokens: tokens, themeData: theme));
    } catch (_) {
      // If invalid JSON: ignore and keep fallback
    }
  }

  /// 2) Optionally call backend to refresh/override theme at runtime.
  Future<void> loadRemoteTheme() async {
    try {
      final resp = await dio.get(themeEndpoint);

      dynamic data = resp.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      final dto = RemoteThemeDto.fromJson(data as Map<String, dynamic>);
      final tokens = AppThemeTokens.fromRemote(dto);
      final theme = AppTheme.fromTokens(tokens);

      emit(ThemeState(tokens: tokens, themeData: theme));
    } catch (_) {
      // Keep current theme
    }
  }
}
