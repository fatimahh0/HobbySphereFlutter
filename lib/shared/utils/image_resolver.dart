/// Flutter 3.35+
/// One-stop image URL resolver used by Social (Chat/Friends/Posts).
/// - Accepts absolute or relative paths from the backend
/// - Normalizes and returns an absolute URL
/// - Prints helpful logs so you can see exactly what happened
///
/// Example inputs:
///   "http://192.168.1.6:8080/uploads/a.jpg"      -> returns as-is
///   "/uploads/a.jpg"                              -> "http://192.168.1.6:8080/uploads/a.jpg"
///   "uploads/a.jpg"                               -> "http://192.168.1.6:8080/uploads/a.jpg"
///   "//cdn.example.com/a.jpg"                     -> "https://cdn.example.com/a.jpg"
///   "null" or "" or null                          -> null
///
/// NOTE: We read g.appServerRoot and strip a trailing "/api" if present.
/// If your Dio services use baseUrl="http://host:8080" and call "/api/...",
/// this file still works because we only care about turning *image* paths into full URLs.
import 'package:flutter/foundation.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

/// Returns the server root (without trailing `/api`).
/// If g.appServerRoot = "http://192.168.1.6:8080/api",
/// this returns "http://192.168.1.6:8080".
String serverRoot() {
  final base = (g.appServerRoot ?? '').trim();
  final root = base.replaceFirst(RegExp(r'/api/?$'), '');
  if (kDebugMode) {
    debugPrint('[IMG] serverRoot base="$base" -> root="$root"');
  }
  return root;
}

/// Safely join "http://host:8080" and "/uploads/a.jpg"
String _joinBase(String base, String path) {
  final b = base.replaceFirst(RegExp(r'/*$'), ''); // trim trailing /
  final p = path.replaceFirst(RegExp(r'^/*'), ''); // trim leading /
  return '$b/$p';
}

/// Convert any backend-provided image path to an absolute URL.
/// Returns null if input is null/empty/"null".
String? resolveUrl(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return null;

  // Already absolute
  if (s.startsWith('http://') || s.startsWith('https://')) {
    if (kDebugMode) debugPrint('[IMG] raw="$s" -> "$s" (absolute)');
    return s;
  }

  // Protocol-relative, assume HTTPS
  if (s.startsWith('//')) {
    final fixed = 'https:$s';
    if (kDebugMode) debugPrint('[IMG] raw="$s" -> "$fixed" (proto-rel)');
    return fixed;
  }

  // Relative path — join with server root
  final base = serverRoot();
  final joined = _joinBase(base, s);
  if (kDebugMode) debugPrint('[IMG] raw="$s" -> "$joined" (relative->abs)');
  return joined;
}
