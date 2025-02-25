import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:oracle/widgets/time_format_button.dart';
import 'package:oracle/widgets/temperature_unit_button.dart';
import 'package:logging/logging.dart';
import '../services/heat_index_data_service.dart';
import '../models/heat_index_data_point.dart';  // Add this import
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
  List<FlSpot> _spots = [];
  StreamSubscription<List<HeatIndexDataPoint>>? _realtimeSubscription;

  double _minX = 0;
  double _maxX = 24;
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
      setState(() {
      });

      final points = await HeatIndexDataService.get24HourHistory();
      _logger.info('Loaded ${points.length} data points');

      if (points.isEmpty) {
        throw Exception('No data available');
      }

      setState(() {
        _spots = HeatIndexDataService.convertToFlSpots(points);
      });
      
      _logger.info('Spots created: ${_spots.length}');
    } catch (e) {
      _logger.severe('Error loading heat index data: $e');
      setState(() {
      });
    }
  }

  void _subscribeToRealtimeUpdates() {
    _realtimeSubscription?.cancel();
    
    _realtimeSubscription = HeatIndexDataService.getRealtimeHeatIndex().listen(
      (dataPoints) {
        if (!mounted) return;
        
        setState(() {
          // Clear existing spots if needed
          _spots.clear();
          
          // Convert each data point to FlSpot
          for (var point in dataPoints) {
            _spots.add(FlSpot(
              point.timestamp.hour.toDouble(),
              point.value
            ));
          }
          
          // Sort spots by hour
          _spots.sort((a, b) => a.x.compareTo(b.x));
          
          // Create new list reference to force rebuild
          _spots = List<FlSpot>.from(_spots);
          
          _logger.info('Updated chart with ${_spots.length} data points');
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
      return hour == 24 ? '23:00' : '${hour.toString().padLeft(2, '0')}:00';
    } else {
      if (hour == 0 || hour == 24) return '12:AM';
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
      final xRange = 24 / _zoomLevel;
      final yRange = 25 / _zoomLevel;
      
      // Update ranges around center point
      _minX = centerX - (xRange / 2);
      _maxX = centerX + (xRange / 2);
      _minY = centerY - (yRange / 2);
      _maxY = centerY + (yRange / 2);
      
      // Ensure bounds
      _minX = _minX.clamp(0.0, 23.0);
      _maxX = _maxX.clamp(1.0, 24.0);
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
        left: 0.0,
        right: 12.0,  // Reduced right padding to align with chart
        top: 8.0,
        bottom: 8.0
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Heat Index Chart',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TimeFormatButton(
                is24Hour: _is24Hour,
                onFormatChanged: (bool is24Hour) {
                  setState(() {
                    _is24Hour = is24Hour;
                  });
                },
              ),
              const SizedBox(width: 2),  // Reduced space between buttons
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
    if (_spots.isEmpty) {
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
      child: AspectRatio(
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
                LineChartBarData(
                  spots: _spots,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.orange.withAlpha(50),
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withAlpha(45),  // 0.3 opacity (0.3 * 255 ≈ 77)
                        Colors.orange.withAlpha(15),   // 0.1 opacity (0.1 * 255 ≈ 26)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  isStrokeCapRound: true,
                  isStrokeJoinRound: true,
                  preventCurveOverShooting: true,
                  curveSmoothness: 0.5,  // Increased for smoother curves
                  preventCurveOvershootingThreshold: 5.0,  // Added to prevent sharp peaks
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 4,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int hour = value.toInt();
                      if (hour % 4 != 0) return const Text('');
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