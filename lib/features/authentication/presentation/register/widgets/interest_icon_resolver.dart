import 'package:flutter/material.dart'; // Material icons
// import 'package:ionicons/ionicons.dart';                // ← add pkg if you want true Ionicons

// pick an IconData based on lib + icon name
IconData interestIcon(String lib, String name) {
  final k = name.toLowerCase().trim(); // normalize

  // when backend says Ionicons, try mapping (fallback to Material)
  if (lib.toLowerCase() == 'ionicons') {
    // Real Ionicons mapping (uncomment when package added)
    // switch (k) {
    //   case 'basketball': return Ionicons.basketball_outline;
    //   case 'musical-notes': return Ionicons.musical_notes_outline;
    //   case 'color-palette': return Ionicons.color_palette_outline;
    //   case 'laptop': return Ionicons.laptop_outline;
    //   case 'barbell': return Ionicons.barbell_outline;
    //   case 'restaurant': return Ionicons.restaurant_outline;
    //   case 'airplane': return Ionicons.airplane_outline;
    //   case 'game-controller': return Ionicons.game_controller_outline;
    //   case 'happy': return Ionicons.happy_outline;
    //   case 'language': return Ionicons.language_outline;
    //   case 'camera': return Ionicons.camera_outline;
    //   case 'construct': return Ionicons.construct_outline;
    //   case 'rose': return Ionicons.rose_outline;
    //   case 'wallet': return Ionicons.wallet_outline;
    //   case 'star': return Ionicons.star_outline;
    //   default: return Icons.category_outlined;
    // }

    // Material lookalikes (compile now, no extra deps)
    switch (k) {
      case 'basketball':
        return Icons.sports_basketball_outlined;
      case 'musical-notes':
        return Icons.music_note_outlined;
      case 'color-palette':
        return Icons.palette_outlined;
      case 'laptop':
        return Icons.laptop_outlined;
      case 'barbell':
        return Icons.fitness_center_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'airplane':
        return Icons.flight_outlined;
      case 'game-controller':
        return Icons.sports_esports_outlined;
      case 'happy':
        return Icons.emoji_emotions_outlined;
      case 'language':
        return Icons.language_outlined;
      case 'camera':
        return Icons.photo_camera_outlined;
      case 'construct':
        return Icons.handyman_outlined;
      case 'rose':
        return Icons.local_florist_outlined;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'star':
        return Icons.star_border;
      default:
        return Icons.category_outlined;
    }
  }

  // default for other libs (extend later)
  return Icons.category_outlined; // generic
}
