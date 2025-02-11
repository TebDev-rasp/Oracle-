import 'package:flutter/material.dart';
import '../models/heat_index_data.dart';
import '../models/comfort_level.dart';
import '../models/risk_level.dart';
import '../utils/heat_index_colors.dart';
import 'temperature_swap_button.dart';

class HeatIndexContainer extends StatefulWidget {
  static const double _valueFontSize = 64.0;

  final HeatIndex heatIndex;
  final ComfortLevel comfortLevel;
  final VoidCallback onSwap;

  const HeatIndexContainer({
    super.key,
    this.heatIndex = const HeatIndex(),
    this.comfortLevel = const ComfortLevel(),
    required this.onSwap,
  });

  @override
  State<HeatIndexContainer> createState() => _HeatIndexContainerState();
}

class _HeatIndexContainerState extends State<HeatIndexContainer> {
  bool showFahrenheit = true;

  String _getComfortStatus() {
    return ComfortLevel.getStatus(widget.heatIndex.value);
  }

  String _getRiskLevel() {
    return RiskLevel.getStatus(widget.heatIndex.value);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = HeatIndexColors.getGradientColors(widget.heatIndex.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Heat-Index',
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
          margin: const EdgeInsets.only(top: 8, bottom: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: gradientColors,
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
          child: Stack(
            children: [
              Positioned(
                top: 8,
                left: 8,
                child: Text(
                  _getComfortStatus(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HeatIndexColors.getTextColor(widget.heatIndex.value),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showFahrenheit 
                          ? '${widget.heatIndex.celsius.toStringAsFixed(1)}°'
                          : '${widget.heatIndex.value.toStringAsFixed(1)}°',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: HeatIndexColors.getTextColor(widget.heatIndex.value),
                      ),
                    ),
                    Text(
                      showFahrenheit ? 'C' : 'F',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: HeatIndexColors.getTextColor(widget.heatIndex.value),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showFahrenheit 
                          ? '${widget.heatIndex.value.toStringAsFixed(1)}°'
                          : '${widget.heatIndex.celsius.toStringAsFixed(1)}°',
                      style: const TextStyle(
                        fontSize: HeatIndexContainer._valueFontSize,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF06402B),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        showFahrenheit ? 'F' : 'C',
                        style: TextStyle(
                          fontSize: HeatIndexContainer._valueFontSize * 0.6,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF06402B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _getRiskLevel(),
                    style: TextStyle(
                      fontSize: 16,
                      color: HeatIndexColors.getTextColor(widget.heatIndex.value),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}