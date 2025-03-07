import 'package:flutter/material.dart';

class ChartTempOverlay extends StatelessWidget {
  const ChartTempOverlay({super.key});

  static List<Map<String, dynamic>> _getTempLabels() {
    const List<int> temperatures = [20, 25, 30, 35, 40, 45, 50];
    const double startY = 380.0;  // Increased from 280.0 to match new height
    const double interval = 57.0;  // Adjusted interval for new height
    
    return temperatures.asMap().map((index, temp) => MapEntry(
      index,
      {
        'temp': '$temp°C',
        'top': startY - (interval * index),
      }
    )).values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50, // Add fixed width
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Stack(
        children: [
          for (final label in _getTempLabels())
            Positioned(
              top: label['top'] as double,
              left: 0, // Align to left
              child: Text(
                label['temp'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}