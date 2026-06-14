import 'package:flutter/material.dart';

/// Palette aligned with the WaqfLand web dashboard charts.
abstract final class ChartColors {
  static const List<Color> palette = [
    Color(0xFF2F6F80),
    Color(0xFFD5A069),
    Color(0xFF4D889A),
    Color(0xFF8BB9C4),
    Color(0xFF1E3540),
    Color(0xFFE8C18A),
    Color(0xFF64748B),
    Color(0xFF0F766E),
    Color(0xFFB45309),
    Color(0xFF7C3AED),
  ];

  static Color at(int index) => palette[index % palette.length];
}
