import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HeatIndexChart extends StatefulWidget {
  const HeatIndexChart({super.key});

  @override
  State<HeatIndexChart> createState() => _HeatIndexChartState();
}

class _HeatIndexChartState extends State<HeatIndexChart> {
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
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
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Heat Index Chart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: _transformationZoomIn,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _transformationReset,
              ),
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: _transformationZoomOut,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return AspectRatio(
      aspectRatio: 1.4,
      child: Padding(
        padding: const EdgeInsets.only(right: 18, left: 12),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 23,
            minY: 20,
            maxY: 125,
            clipData: FlClipData.all(),
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 4,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    int hour = value.toInt();
                    if (hour % 4 != 0) return const Text('');
                    return Text(
                      '${hour.toString().padLeft(2, '0')}:00',
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
                  interval: 20,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value % 20 != 0) return const Text('');
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '°F',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
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
        ),
      ),
    );
  }
  void _transformationReset() {
    _transformationController.value = Matrix4.identity();
  }

  void _transformationZoomIn() {
    _transformationController.value *= Matrix4.diagonal3Values(1.1, 1.1, 1);
  }

  void _transformationZoomOut() {
    _transformationController.value *= Matrix4.diagonal3Values(0.9, 0.9, 1);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}