import 'package:flutter/material.dart';

class ThemePalette {
  final Color base;
  final Color lighter;
  final Color darker;

  ThemePalette({
    required this.base,
    required this.lighter,
    required this.darker,
  });

  // Factory: dari 1 warna dasar, buat versi terang dan gelap
  factory ThemePalette.fromBase(Color base) {
    final hsl = HSLColor.fromColor(base);
    return ThemePalette(
      base: base,
      lighter: hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor(),
      darker: hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor(),
    );
  }
}
