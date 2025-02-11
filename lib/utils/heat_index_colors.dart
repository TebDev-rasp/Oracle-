import 'package:flutter/material.dart';

class HeatIndexColors {
  static List<Color> getGradientColors(double value) {
    if (value <= 79.9) {
      return [
        const Color(0xFF80ef80), // Emerald green
        const Color(0xFFC1F7C1), // Medium spring green
      ];
    }
   
    return [
        const Color(0xFF2ECC71), // Emerald green
        const Color(0xFF82E0AA), // Medium spring green
    ];
  }

  static Color getTextColor(double value) {
    if (value <= 79.9) {
      return const Color(0xFF06402b); // Darker forest green
    }
    return Colors.white;
  }
}