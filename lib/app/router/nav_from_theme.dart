// Convert your theme json → AppNavType in a robust way
import 'nav_type.dart'; // enum + parser

AppNavType navTypeFromTheme(Map<String, dynamic> themeJson) {
  // 0) your API: { "menuType": "bottom" }
  final mt = themeJson['menuType'];
  if (mt is String && mt.trim().isNotEmpty) return parseNavType(mt); // parse

  // 1) nested: { "navigation": { "type": "top" } }
  final navObj = themeJson['navigation'];
  if (navObj is Map && navObj['type'] is String) {
    return parseNavType(navObj['type'] as String); // parse
  }

  // 2) flat alt: { "layout": "drawer" }
  final layout = themeJson['layout'];
  if (layout is String && layout.trim().isNotEmpty) {
    return parseNavType(layout); // parse
  }

  // 3) mobile alt: { "mobileLayout": "bottom" }
  final mobileLayout = themeJson['mobileLayout'];
  if (mobileLayout is String && mobileLayout.trim().isNotEmpty) {
    return parseNavType(mobileLayout); // parse
  }

  // 4) default
  return AppNavType.bottom; // safe default
}
