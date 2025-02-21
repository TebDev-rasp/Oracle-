import 'package:flutter/material.dart';

class TemperatureControls extends StatelessWidget {
  final bool isCelsius;
  final Function(bool) onUnitChanged;

  const TemperatureControls({
    super.key,
    required this.isCelsius,
    required this.onUnitChanged,
  });
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      color: isDarkMode ? const Color(0xFF1A1A1A) : const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Temperature Unit:'),
            ToggleButtons(
              isSelected: [isCelsius, !isCelsius],
              onPressed: (index) => onUnitChanged(index == 0),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('°C'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('°F'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}