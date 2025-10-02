// Flutter 3.35.x
// Palette singleton: keeps all colors at runtime.
// Starts with your current values, then updates from backend JSON.
// Every line has a simple comment.

import 'package:flutter/material.dart'; // Color, ChangeNotifier

class Palette extends ChangeNotifier {
  // private constructor so we control single instance
  Palette._();

  // single global instance used by the whole app
  static final Palette I = Palette._();

  // ====== DEFAULTS (same as your current constants) ======

  // main brand green color
  Color primary = const Color.fromARGB(255, 18, 148, 65);
  // text/icon on primary color
  Color onPrimary = Colors.white;
  // app background color (light)
  Color background = const Color(0xFFF7F7F7);
  // main text color (dark)
  Color text = const Color(0xFF0F172A);
  // secondary text (gray)
  Color muted = const Color(0xFF64748B);
  // error color
  Color error = const Color(0xFFDC2626);
  // "white" surface used by app bar / cards in your current theme
  Color white = const Color(0xFFF7F7F7);
  // borders
  Color border = const Color(0xFFD9D9D9);
  // transparent
  Color transparent = Colors.transparent;

  // ====== HELPERS ======

  // parse "#RRGGBB" or the word "transparent"; fallback if invalid
  Color _hex(String? raw, Color fallback) {
    // if null or empty, return fallback
    final s = (raw ?? '').trim();
    // accept literal "transparent"
    if (s.toLowerCase() == 'transparent') return Colors.transparent;
    // accept hex #RRGGBB
    final re = RegExp(r'^#([0-9a-fA-F]{6})$');
    if (re.hasMatch(s)) {
      final n = int.parse(s.substring(1), radix: 16); // parse hex to int
      return Color(0xFF000000 | n); // add opaque alpha
    }
    // anything else => fallback (keeps your old value)
    return fallback;
  }

  // ====== APPLY JSON FROM BACKEND SAFELY ======

  // json shape (example):
  // {
  //   "menuType":"bottom",
  //   "valuesMobile":{
  //     "colors":{
  //       "primary":"#669933","surface":"#ffffff","background":"#ffffff",
  //       "label":"#6C718B","body":"#494949","border":"#d9d9d9",
  //       "error":"#ff190c","transparent":"transparent"
  //     },
  //     "button":{"background":"#48a050","text":"#ffffff","borderColor":"#48a050"}
  //   }
  // }
  void applyMobileThemeJson(Map<String, dynamic> json) {
    // read valuesMobile object
    final values = (json['valuesMobile'] ?? {}) as Map<String, dynamic>;
    // read colors object
    final colors = (values['colors'] ?? {}) as Map<String, dynamic>;

    // map each color using fallback to current value
    primary = _hex(colors['primary']?.toString(), primary); // brand
    background = _hex(colors['background']?.toString(), background); // page bg
    error = _hex(colors['error']?.toString(), error); // error
    border = _hex(colors['border']?.toString(), border); // borders
    text = _hex(colors['body']?.toString(), text); // main text
    muted = _hex(colors['label']?.toString(), muted); // label text
    transparent = _hex(
      colors['transparent']?.toString(),
      transparent,
    ); // transparent

    // "surface" in backend = your "white" (app bar/cards)
    final surface = _hex(
      colors['surface']?.toString(),
      white,
    ); // parse surface/white
    white = surface; // set it

    // keep onPrimary as white for best contrast (unless you later want to parse it)
    onPrimary = Colors.white;

    // notify listeners (MaterialApp will rebuild through the hook in app.dart)
    notifyListeners();
  }
}
