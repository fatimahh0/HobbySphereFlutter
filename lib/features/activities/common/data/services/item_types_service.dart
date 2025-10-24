// lib/core/catalog/item_types_service.dart
import 'dart:io';
import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';
import 'package:hobby_sphere/config/env.dart';

class ItemTypesService {
  final ApiFetch _fetch = ApiFetch();
  static const String _base = '/item-types';

  String get _projectId => Env.requiredVar(Env.projectId, 'PROJECT_ID');

  // ---------- Primary: list by PROJECT ----------
  Future<List<Map<String, dynamic>>> getItemTypesByProject() async {
    // Preferred endpoint: /api/item-types/by-project/{projectId}
    final primary = '$_base/by-project/$_projectId';

    try {
      final r = await _fetch.fetch(HttpMethod.get, primary);
      _ok(r.statusCode, r.statusMessage);
      return _asListOfMap(r.data);
    } on HttpException {
      rethrow;
    } catch (_) {
      // Fallbacks (older endpoints you had)
      return _fallbackTypes();
    }
  }

  // ---------- Optional: list by CATEGORY ----------
  Future<List<Map<String, dynamic>>> getItemTypesByCategory(
    int categoryId,
  ) async {
    final path = '$_base/by-category/$categoryId';
    final r = await _fetch.fetch(HttpMethod.get, path);
    _ok(r.statusCode, r.statusMessage);
    return _asListOfMap(r.data);
  }

  // ---------- Legacy name kept for compatibility ----------
  // RN: getAllActivityTypes / getActivityTypesCategories
  Future<List<Map<String, dynamic>>> getAllActivityTypes() {
    return getItemTypesByProject(); // project-scoped by default
  }

  // ---------- Internal fallbacks ----------
  Future<List<Map<String, dynamic>>> _fallbackTypes() async {
    // Try /item-types then /item-types/guest
    final paths = <String>[
      _base, // /api/item-types
      '$_base/guest', // /api/item-types/guest
    ];

    HttpException? last;
    for (final p in paths) {
      try {
        final r = await _fetch.fetch(HttpMethod.get, p);
        _ok(r.statusCode, r.statusMessage);
        return _asListOfMap(r.data);
      } catch (e) {
        if (e is HttpException) last = e;
      }
    }
    if (last != null) throw last;
    return const <Map<String, dynamic>>[];
  }

  // ---------- Helpers ----------
  List<Map<String, dynamic>> _asListOfMap(dynamic data) {
    if (data is List) {
      return data
          .cast<dynamic>()
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    if (data is Map && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .cast<dynamic>()
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  void _ok(int? code, String? msg) {
    if (code == null || code < 200 || code >= 300) {
      throw HttpException('Request failed: $code $msg');
    }
  }
}
