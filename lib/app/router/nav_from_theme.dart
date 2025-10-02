// Extract the navigation type from the theme API response.

import 'nav_type.dart'; // AppNavType + parseNavType()

// Try multiple common shapes so backend stays flexible.
// Order matters: we FIRST read "menuType" (your actual API),
// then fall back to other possible keys.
AppNavType navTypeFromTheme(Map<String, dynamic> themeJson) {
  // 0) Top-level "menuType" from your backend:
  //    { "menuType": "bottom" }
  final mt = themeJson['menuType'];
  if (mt is String && mt.trim().isNotEmpty) {
    // parse and return immediately if present
    return parseNavType(mt);
  }

  // 1) Nested object:
  //    { "navigation": { "type": "bottom" } }
  final navObj = themeJson['navigation'];
  if (navObj is Map && navObj['type'] is String) {
    // parse nested "type"
    return parseNavType(navObj['type'] as String);
  }

  // 2) Flat alternative:
  //    { "layout": "top" }
  final layout = themeJson['layout'];
  if (layout is String && layout.trim().isNotEmpty) {
    // parse "layout"
    return parseNavType(layout);
  }

  // 3) Mobile-specific alternative:
  //    { "mobileLayout": "drawer" }
  final mobileLayout = themeJson['mobileLayout'];
  if (mobileLayout is String && mobileLayout.trim().isNotEmpty) {
    // parse "mobileLayout"
    return parseNavType(mobileLayout);
  }

  // 4) Default if nothing matched
  return AppNavType.bottom; // safe fallback
}
