// Same API you already use: AppColors.primary, AppColors.text, etc.
// We only change implementation to read from Palette.I at runtime.

import 'package:flutter/material.dart'; // Color
import 'palette.dart'; // Palette.I singleton

class AppColors {
  // base colors now come from the palette (runtime)
  static Color get primary => Palette.I.primary; // brand color
  static Color get onPrimary => Palette.I.onPrimary; // text on primary
  static Color get background => Palette.I.background; // app background
  static Color get text => Palette.I.text; // main text
  static Color get muted => Palette.I.muted; // secondary text
  static Color get error => Palette.I.error; // error red
  static Color get white => Palette.I.white; // surface/white
  static Color get border => Palette.I.border; // border color
  static Color get transparent => Palette.I.transparent; // transparent

  // semantic status colors remain constants (unchanged)
  static const pending = Color(0xFFF59E0B); // amber
  static const completed = Color(0xFF16A34A); // green
  static const rejected = Color(0xFFDC2626); // red
  static const canceled = Color(0xFF6B7280); // gray
  static const paid = Color(0xFF2563EB); // blue
}
