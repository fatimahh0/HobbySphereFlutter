// lib/core/nav/nav_from_theme.dart
// Extract the navigation type from the theme API response.

import 'nav_type.dart'; // enum + parser

// Try multiple common shapes so backend is flexible.
AppNavType navTypeFromTheme(Map<String, dynamic> themeJson) {
  // 1) Prefer nested: { "navigation": { "type": "bottom" } }
  final navObj = themeJson['navigation'];
  if (navObj is Map && navObj['type'] is String) {
    return parseNavType(navObj['type'] as String);
  }

  // 2) Or flat key: { "layout": "top" }
  if (themeJson['layout'] is String) {
    return parseNavType(themeJson['layout'] as String);
  }

  // 3) Or mobile-specific key: { "mobileLayout": "drawer" }
  if (themeJson['mobileLayout'] is String) {
    return parseNavType(themeJson['mobileLayout'] as String);
  }

  // 4) Default if nothing found
  return AppNavType.bottom;
}
