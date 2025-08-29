// lib/core/nav/nav_type.dart
// Enum for the 3 supported navigation types.

enum AppNavType { bottom, top, drawer } // 3 modes we support

// Safe parser from string → enum, with bottom as a fallback.
AppNavType parseNavType(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    // normalize
    case 'top':
      return AppNavType.top; // top tabs
    case 'drawer':
      return AppNavType.drawer; // sandwich
    case 'bottom':
      return AppNavType.bottom; // bottom bar
    default:
      return AppNavType.bottom; // fallback if missing/unknown
  }
}
