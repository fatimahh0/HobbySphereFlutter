import 'package:hobby_sphere/core/network/globals.dart' as g;

/// Turn relative paths like "ds/..jpg" or "/ds/..jpg" into absolute URLs.
/// If base ends with /api, we strip it to serve static files cleanly.
String? resolveUrl(String? raw) {
  if (raw == null) return null;
  final u = raw.trim();
  if (u.isEmpty) return null;
  if (u.startsWith('http://') || u.startsWith('https://')) return u;

  String base = (g.appServerRoot ?? g.appDio?.options.baseUrl ?? '').trim();
  if (base.isEmpty) return u; // last resort
  base = base.replaceFirst(RegExp(r'/api/?$'), '');

  if (u.startsWith('/')) return '$base$u';
  return '$base/$u';
}
