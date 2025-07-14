import 'package:flutter/material.dart';
import 'theme_pallete.dart';

class ThemeNotifier extends ChangeNotifier {
ThemePalette _palette = ThemePalette.fromBase(const Color(0xFF8BB6F0));

  ThemePalette get palette => _palette;

  void setThemeColor(Color baseColor) {
    _palette = ThemePalette.fromBase(baseColor);
    notifyListeners();
  }
}
