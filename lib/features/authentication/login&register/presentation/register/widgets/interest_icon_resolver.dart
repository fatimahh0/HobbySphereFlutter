// interest_icon_resolver.dart
// Flutter 3.35.x
// Map Ionicons-like names to Material lookalikes (no extra deps).
// Add the icon keys that appear in your payload.

import 'package:flutter/material.dart'; // Material icons

IconData interestIcon(String lib, String name) {
  final k = name
      .toLowerCase()
      .trim(); // normalize (e.g., "American-Football" → "american-football")
  final isIon = lib.toLowerCase() == 'ionicons'; // check lib

  // If using Ionicons naming, return Material equivalents
  if (isIon) {
    switch (k) {
      // SPORTS
      case 'american-football':
        return Icons.sports_football_outlined; // ball icon
      case 'basketball':
        return Icons.sports_basketball_outlined; // basketball
      case 'walk':
        return Icons.directions_walk_outlined; // walking
      case 'shield':
        return Icons.security_outlined; // shield
      case 'leaf':
        return Icons.eco_outlined; // leaf
      case 'paw':
        return Icons.pets_outlined; // paw
      case 'fish':
        return Icons.set_meal_outlined; // fish-like

      // MUSIC
      case 'musical-notes':
      case 'musical-note':
        return Icons.music_note_outlined; // music

      // ART
      case 'color-palette':
        return Icons.palette_outlined; // palette

      // TECH
      case 'code-slash':
        return Icons.code_off_outlined; // "slash" feel
      case 'hardware-chip':
        return Icons.memory_outlined; // chip
      case 'cube':
        return Icons.view_in_ar_outlined; // cube-like
      case 'flask':
        return Icons.science_outlined; // flask

      // FITNESS
      case 'barbell':
        return Icons.fitness_center_outlined; // barbell

      // FOOD/TRAVEL
      case 'restaurant':
        return Icons.restaurant_outlined; // food
      case 'globe':
        return Icons.public_outlined; // globe
      case 'airplane':
        return Icons.flight_outlined; // plane

      // GAMING
      case 'game-controller':
        return Icons.sports_esports_outlined; // controller

      // THEATER
      case 'happy':
      case 'happy-outline':
        return Icons.emoji_emotions_outlined; // happy
      case 'book':
        return Icons.menu_book_outlined; // book

      // LANGUAGE
      case 'language':
        return Icons.language_outlined; // language
      case 'mic':
      case 'mic-circle':
        return Icons.mic_none_outlined; // mic
      case 'pencil':
        return Icons.edit_outlined; // pencil

      // PHOTO/VIDEO
      case 'camera':
        return Icons.photo_camera_outlined; // camera
      case 'videocam':
        return Icons.videocam_outlined; // videocam

      // DIY/BEAUTY/FINANCE/BIZ
      case 'construct':
        return Icons.handyman_outlined; // tools
      case 'color-wand':
        return Icons.auto_awesome_outlined; // magic wand feel
      case 'stats-chart':
        return Icons.query_stats_outlined; // chart
      case 'briefcase':
        return Icons.work_outline; // briefcase

      // OTHER
      case 'planet':
        return Icons.public_outlined; // planet/globe
      case 'people':
        return Icons.people_outline; // people
      case 'time':
        return Icons.access_time; // clock
      case 'search':
        return Icons.search; // search
      case 'grid':
        return Icons.grid_view_outlined; // grid
      case 'moon':
        return Icons.dark_mode_outlined; // moon

      // fallback for any unknown key
      default:
        return Icons.category_outlined; // generic
    }
  }

  // Not Ionicons? Use a safe default (extend as needed)
  return Icons.category_outlined; // generic icon
}
