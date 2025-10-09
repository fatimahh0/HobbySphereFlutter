// Enum for 3 navigation types
enum AppNavType { bottom, top, drawer } // supported modes

// Parse string to enum safely
AppNavType parseNavType(String? raw) {
  switch ((raw ?? '').toLowerCase().trim()) {
    // normalize
    case 'top':
      return AppNavType.top; // top tabs
    case 'drawer':
      return AppNavType.drawer; // side drawer
    case 'bottom':
      return AppNavType.bottom; // bottom bar
    default:
      return AppNavType.bottom; // fallback
  }
}
