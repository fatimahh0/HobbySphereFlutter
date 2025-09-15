// Map Ionicons names to similar Material Icons (no extra package)
import 'package:flutter/material.dart'; // icons

IconData mapIoniconsToMaterial(String? name) {
  // helper
  final key = (name ?? '').toLowerCase().trim(); // normalize
  switch (key) {
    case 'star':
      return Icons.star_border_rounded; // star
    case 'code-slash':
      return Icons.code_rounded; // code
    case 'game-controller':
      return Icons.sports_esports; // gaming
    case 'musical-notes':
      return Icons.music_note_rounded; // music
    case 'barbell':
      return Icons.fitness_center_rounded; // fitness
    case 'basketball':
      return Icons.sports_basketball; // football/basket
    case 'tree':
      return Icons.park_rounded; // hiking
    case 'globe':
      return Icons.public_rounded; // travel
    case 'camera':
      return Icons.photo_camera_outlined; // photo
    case 'videocam':
      return Icons.videocam_outlined; // film
    case 'book':
      return Icons.menu_book_rounded; // book
    case 'restaurant':
      return Icons.restaurant_rounded; // cooking
    case 'happy':
      return Icons.emoji_emotions_outlined; // comedy
    case 'leaf':
      return Icons.eco_rounded; // yoga
    case 'color-palette':
      return Icons.color_lens_rounded; // art
    case 'heart':
      return Icons.favorite_border_rounded; // beauty
    default:
      return Icons.help_outline_rounded; // fallback
  }
}
