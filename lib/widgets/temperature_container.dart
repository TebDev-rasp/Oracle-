import 'package:flutter/material.dart';
import '../models/temperature_data.dart';
import 'temperature_swap_button.dart';

class TemperatureContainer extends StatefulWidget {
  const TemperatureContainer({
    super.key,
    required this.temperature,
    required this.onSwap,
  });

  final Temperature temperature;
  final VoidCallback onSwap;

  @override
  State<TemperatureContainer> createState() => _TemperatureContainerState();
}

class _TemperatureContainerState extends State<TemperatureContainer> {
  static const double valueFontSize = 64.0;
  bool showFahrenheit = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Temperature',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : const Color(0xFF111217),
              ),
            ),
            TemperatureSwapButton(onSwap: () {
              setState(() {
                showFahrenheit = !showFahrenheit;
              });
              widget.onSwap();
            }),
          ],
        ),
        Container(
          width: double.infinity,
          height: 150,
          margin: const EdgeInsets.only(top: 0, bottom: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFFFC8DD),
                Color(0xFFFFAFCC),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                offset: const Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showFahrenheit 
                      ? '${widget.temperature.value.toStringAsFixed(1)}°'
                      : '${widget.temperature.celsius.toStringAsFixed(1)}°',
                  style: const TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111217),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    showFahrenheit ? 'F' : 'C',
                    style: const TextStyle(
                      fontSize: valueFontSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111217),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}