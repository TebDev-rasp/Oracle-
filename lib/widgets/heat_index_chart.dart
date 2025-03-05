import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:oracle/widgets/time_format_button.dart';
import 'package:oracle/widgets/temperature_unit_button.dart';
import 'package:logging/logging.dart';
import '../services/heat_index_data_service.dart';
import '../models/weather_data_point.dart';  // Updated import
import 'dart:async';

class HeatIndexChart extends StatefulWidget {
  const HeatIndexChart({super.key});

  @override
  State<HeatIndexChart> createState() => _HeatIndexChartState();
}

class _HeatIndexChartState extends State<HeatIndexChart> {
  static final _logger = Logger('HeatIndexChart');
  late TransformationController _transformationController;
  bool _is24Hour = true;
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  List<FlSpot> _heatIndexSpots = [];
  List<FlSpot> _temperatureSpots = [];
  StreamSubscription<List<WeatherDataPoint>>? _realtimeSubscription;

  double _minX = 0;
  double _maxX = 23; // Changed from 24 to 23
  double _minY = 25;
  double _maxY = 50;
  double _zoomLevel = 1.0;
  double _initialZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _loadHeatIndexData();
    _subscribeToRealtimeUpdates();
  }

  Future<void> _loadHeatIndexData() async {
    try {
      setState(() {});

      final points = await WeatherDataService.get24HourHistory();
      _logger.info('Loaded ${points.length} data points');

      if (points.isEmpty) {
        throw Exception('No data available');
      }

      setState(() {
        _heatIndexSpots = points.map((point) {
          final value = _temperatureUnit == TemperatureUnit.celsius
              ? point.heatIndex
              : _convertToFahrenheit(point.heatIndex);
          return FlSpot(point.timestamp.hour.toDouble(), value);
        }).toList();

        _temperatureSpots = points.map((point) {
          final value = _temperatureUnit == TemperatureUnit.celsius
              ? point.temperature
              : _convertToFahrenheit(point.temperature);
          return FlSpot(point.timestamp.hour.toDouble(), value);
        }).toList();

        _heatIndexSpots.sort((a, b) => a.x.compareTo(b.x));
        _temperatureSpots.sort((a, b) => a.x.compareTo(b.x));
      });
      
      _logger.info('Spots created: Heat Index: ${_heatIndexSpots.length}, Temperature: ${_temperatureSpots.length}');
    } catch (e) {
      _logger.severe('Error loading weather data: $e');
      setState(() {});
    }
  }

  void _subscribeToRealtimeUpdates() {
    _realtimeSubscription?.cancel();
    
    _realtimeSubscription = WeatherDataService.getRealtimeWeatherData().listen(
      (dataPoints) {
        if (!mounted) return;
        
        setState(() {
          _heatIndexSpots.clear();
          _temperatureSpots.clear();
          
          for (var point in dataPoints) {
            final heatIndexValue = _temperatureUnit == TemperatureUnit.celsius 
                ? point.heatIndex
                : _convertToFahrenheit(point.heatIndex);
                
            final temperatureValue = _temperatureUnit == TemperatureUnit.celsius 
                ? point.temperature
                : _convertToFahrenheit(point.temperature);
                
            _heatIndexSpots.add(FlSpot(
              point.timestamp.hour.toDouble(),
              heatIndexValue
            ));
            
            _temperatureSpots.add(FlSpot(
              point.timestamp.hour.toDouble(),
              temperatureValue
            ));
          }
          
          _heatIndexSpots.sort((a, b) => a.x.compareTo(b.x));
          _temperatureSpots.sort((a, b) => a.x.compareTo(b.x));
          
          _logger.info('Updated chart with ${_heatIndexSpots.length} data points');
        });
      },
      onError: (error) {
        _logger.severe('Error in real-time updates: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating chart: $error')),
          );
        }
      },
      cancelOnError: false,
    );
  }

  String _formatHourLabel(int hour) {
    if (_is24Hour) {
      return '${hour.toString().padLeft(2, '0')}:00';
    } else {
      if (hour == 0) return '12:AM';
      if (hour == 12) return '12:PM';
      return hour > 12 
          ? '${(hour - 12)}:PM'
          : '$hour:AM';
    }
  }

  double _convertToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  String _formatTemperature(int value) {
    if (_temperatureUnit == TemperatureUnit.celsius) {
      return '$value°C';
    } else {
      return '${_convertToFahrenheit(value.toDouble()).round()}°F';
    }
  }

  void _handleZoom(double scale) {
    setState(() {
      _zoomLevel = scale.clamp(1.0, 3.0);
      
      // Calculate center point
      final centerX = (_minX + _maxX) / 2;
      final centerY = (_minY + _maxY) / 2;
      
      // Calculate new ranges
      final xRange = 23 / _zoomLevel; // Changed from 24 to 23
      final yRange = 25 / _zoomLevel;
      
      // Update ranges around center point
      _minX = centerX - (xRange / 2);
      _maxX = centerX + (xRange / 2);
      _minY = centerY - (yRange / 2);
      _maxY = centerY + (yRange / 2);
      
      // Ensure bounds
      _minX = _minX.clamp(0.0, 22.0); // Changed from 23.0 to 22.0
      _maxX = _maxX.clamp(1.0, 23.0); // Changed from 24.0 to 23.0
      _minY = _minY.clamp(25.0, 45.0);
      _maxY = _maxY.clamp(30.0, 50.0);
    });
  }

  void _handlePanStart(FlPanStartEvent event) {
    _initialZoomLevel = _zoomLevel;
  }

  void _handlePanEnd(FlPanEndEvent event) {
    // Reset or update zoom state if needed
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildChartControls(),
        _buildChart(),
      ],
    );
  }

  Widget _buildChartControls() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        top: 8.0,
        bottom: 8.0
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to spaceBetween
        children: [
          // Legend moved here
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Heat-Index',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Temperature',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Original buttons
          Row(
            children: [
              TimeFormatButton(
                is24Hour: _is24Hour,
                onFormatChanged: (bool is24Hour) {
                  setState(() {
                    _is24Hour = is24Hour;
                  });
                },
              ),
              const SizedBox(width: 2),
              TemperatureUnitButton(
                currentUnit: _temperatureUnit,
                onUnitChanged: (TemperatureUnit unit) {
                  setState(() {
                    _temperatureUnit = unit;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (_heatIndexSpots.isEmpty || _temperatureSpots.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GestureDetector(
      onScaleStart: (_) {
        _initialZoomLevel = _zoomLevel;
      },
      onScaleUpdate: (details) {
        setState(() {
          _handleZoom(_initialZoomLevel * details.scale);
        });
      },
      child: AspectRatio(  // Changed to direct AspectRatio
        aspectRatio: 1.4,
        child: Padding(
          padding: const EdgeInsets.only(right: 18, left: 12),
          child: LineChart(
            LineChartData(
              minX: _minX,
              maxX: _maxX,
              minY: _minY,
              maxY: _maxY,
              clipData: FlClipData.all(),
              gridData: FlGridData(show: true),
              rangeAnnotations: RangeAnnotations(),
              lineTouchData: LineTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                  if (event is FlPanStartEvent) {
                    _handlePanStart(event);
                  } else if (event is FlPanEndEvent) {
                    _handlePanEnd(event);
                  }
                },
                handleBuiltInTouches: true,
                touchSpotThreshold: 20,
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.all(12),
                  tooltipMargin: 16,
                  getTooltipItems: (List<LineBarSpot> spots) {
                    return spots.map((spot) {
                      final hour = spot.x.toInt();
                      final celsius = spot.y;
                      final fahrenheit = _convertToFahrenheit(celsius);
                      return LineTooltipItem(
                        '${_formatHourLabel(hour)}\n',
                        const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: '${celsius.toStringAsFixed(1)}°C\n',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: '${fahrenheit.toStringAsFixed(1)}°F',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                ),
              ),
              lineBarsData: [
                // Heat Index Line
                LineChartBarData(
                  spots: _heatIndexSpots.where((spot) => spot.y > 0).toList(),
                  isCurved: false,
                  color: Colors.orange,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      final hour = spot.x.toInt();
                      return hour % 4 == 0 || hour == 23;
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 2.5,  // Reduced from 4
                        color: Colors.orange,
                        strokeWidth: 1.5,  // Reduced from 2
                        strokeColor: Colors.orange,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.orange.withAlpha(25),
                        Colors.orange.withAlpha(0),
                      ],
                    ),
                  ),
                  isStrokeCapRound: true,
                  isStrokeJoinRound: true,
                  preventCurveOverShooting: false,  // Not needed for straight lines
                  curveSmoothness: 0.0,  // Not needed for straight lines
                  preventCurveOvershootingThreshold: 0.0,  // Not needed for straight lines
                ),
                // Temperature Line
                LineChartBarData(
                  spots: _temperatureSpots.where((spot) => spot.y > 0).toList(),
                  isCurved: false,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      final hour = spot.x.toInt();
                      return hour % 4 == 0 || hour == 23;
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 2.5,  // Reduced from 4
                        color: Colors.blue,
                        strokeWidth: 1.5,  // Reduced from 2
                        strokeColor: Colors.blue,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue.withAlpha(25),  // 0.3 * 255 ≈ 76
                        Colors.blue.withAlpha(0),
                      ],
                    ),
                  ),
                  isStrokeCapRound: true,
                  isStrokeJoinRound: true,
                  preventCurveOverShooting: false,  // Not needed for straight lines
                  curveSmoothness: 0.0,  // Not needed for straight lines
                  preventCurveOvershootingThreshold: 0.0,  // Not needed for straight lines
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 4,
                    reservedSize: 22,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int hour = value.toInt();
                      // Change the condition to include 23
                      if (hour % 4 != 0 && hour != 23) return const Text('');
                      return Text(
                        _formatHourLabel(hour),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    interval: 5,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final List<int> showValues = [25, 30, 35, 40, 45, 50];
                      if (!showValues.contains(value.toInt())) return const Text('');
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          _formatTemperature(value.toInt()),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
            duration: const Duration(milliseconds: 500),  // Increased animation duration
            curve: Curves.easeInOutCubic,  // Changed to more smooth curve
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _transformationController.dispose();
    super.dispose();
  }
}