// 🧩 Helper: make relative backend paths ("/img/a.png") absolute.
import 'package:hobby_sphere/core/network/globals.dart' as g; // base url

String? absoluteUrl(String? raw) {
  if (raw == null || raw.isEmpty) return null; // nothing
  if (raw.startsWith('http')) return raw; // already absolute
  final root = (g.appServerRoot ?? '').replaceFirst(
    RegExp(r'/api/?$'),
    '',
  ); // drop /api
  return raw.startsWith('/') ? '$root$raw' : '$root/$raw'; // safe join
}
