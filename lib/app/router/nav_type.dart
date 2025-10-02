// Enum for the 3 supported navigation types.
enum AppNavType { bottom, top, drawer } // 3 modes we support

// Safe parser from String → enum, with bottom as a fallback.
AppNavType parseNavType(String? raw) {
  // normalize the incoming value to lowercase (null-safe)
  switch ((raw ?? '').toLowerCase().trim()) {
    case 'top': // when backend says "top"
      return AppNavType.top; // use top tabs
    case 'drawer': // when backend says "drawer"
      return AppNavType.drawer; // use side drawer
    case 'bottom': // when backend says "bottom"
      return AppNavType.bottom; // use bottom bar
    default: // any unknown or empty value
      return AppNavType.bottom; // safe fallback
  }
}
