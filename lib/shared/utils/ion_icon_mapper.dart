// Flutter 3.35.x — map backend icon keys to Ionicons.
import 'package:flutter/widgets.dart'; // IconData
import 'package:ionicons/ionicons.dart'; // Ionicons pack

// Normalize "color-palette" / "game-controller" / "star" → IconData
IconData iconFromBackend(String? key) {
  if (key == null || key.trim().isEmpty) {
    return Ionicons.ribbon_outline; // default if missing
  }

  // normalize: lowercase + replace '-' with '_' for easy matching
  final k = key.trim().toLowerCase().replaceAll(
    '-',
    '_',
  ); // e.g., color_palette

  // direct known matches (from your payload)
  switch (k) {
    case 'color_palette':
      return Ionicons.color_palette_outline; // Art/Palette
    case 'game_controller':
      return Ionicons.game_controller_outline; // Gaming
    case 'star':
      return Ionicons.star_outline; // Generic star
  }

  // fuzzy contains (safety nets)
  if (k.contains('palette'))
    return Ionicons.color_palette_outline; // any *palette*
  if (k.contains('game') && k.contains('controller')) {
    return Ionicons.game_controller_outline; // any *game* + *controller*
  }
  if (k.contains('camera')) return Ionicons.camera_outline; // camera family
  if (k.contains('video') || k.contains('videocam')) {
    return Ionicons.videocam_outline; // video family
  }
  if (k.contains('music'))
    return Ionicons.musical_notes_outline; // music family
  if (k.contains('book')) return Ionicons.book_outline; // book/open-book
  if (k.contains('code')) return Ionicons.code_slash_outline; // code/robotics
  if (k.contains('globe') || k.contains('earth'))
    return Ionicons.earth_outline; // travel
  if (k.contains('leaf') || k.contains('tree'))
    return Ionicons.leaf_outline; // hiking/nature
  if (k.contains('heart')) return Ionicons.heart_outline; // beauty/heart
  if (k.contains('flower') || k.contains('spa'))
    return Ionicons.flower_outline; // spa/yoga

  return Ionicons.ribbon_outline; // final fallback
}
