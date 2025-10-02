import 'package:flutter/foundation.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

String serverRoot() {
  final base = (g.appServerRoot ?? '');
  final root = base.replaceFirst(RegExp(r'/api/?$'), '');
  if (kDebugMode) {
    debugPrint('[IMG] base="$base" -> root="$root"');
  }
  return root;
}

String? absoluteImageUrl(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return null;

  // absolute
  if (s.startsWith('http://') || s.startsWith('https://')) {
    if (kDebugMode) debugPrint('[IMG] raw="$s" -> "$s" (absolute)');
    return s;
  }

  // protocol-relative
  if (s.startsWith('//')) {
    final fixed = 'https:$s';
    if (kDebugMode) debugPrint('[IMG] raw="$s" -> "$fixed" (proto-rel)');
    return fixed;
  }

  final base = serverRoot();
  final joined = '$base${s.startsWith('/') ? s : '/$s'}';
  if (kDebugMode) debugPrint('[IMG] raw="$s" -> "$joined"');
  return joined;
}
