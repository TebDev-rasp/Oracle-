import 'package:flutter/material.dart';
import 'package:oracle/services/chart_data_service.dart';
import 'package:oracle/widgets/chart_data_points.dart';
import 'chart_time_label.dart';
import 'chart_overlay_box.dart';
import 'chart_temp_overlay.dart';

class HTHChart extends StatefulWidget {
  const HTHChart({
    super.key,
  });

  @override
  State<HTHChart> createState() => _HTHChartState();
}

class _HTHChartState extends State<HTHChart> {
  final ChartDataService _chartDataService = ChartDataService();
  Map<String, List<double>>? _chartData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final data = await _chartDataService.fetchHourlyChartData();
      debugPrint('Fetched data: $data'); // Add this line for debugging
      setState(() {
        _chartData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  double _calculateCurrentTimePosition([DateTime? testTime]) {
    final now = testTime ?? DateTime.now();
    final hour = now.hour;
    const startPosition = 15.0;
    const interval = 112.0;
    const overlayBoxWidth = 112.0;
    
    return (startPosition + (interval * hour)) - (overlayBoxWidth / 7);
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = _calculateCurrentTimePosition();
    final scrollController = ScrollController(
      initialScrollOffset: currentPosition,
    );
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _loadChartData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 2680,
              child: Stack(
                children: [
                  // Time labels inside the scrollable area
                  for (final timeLabel in ChartTimeLabel.getAllTimeLabels())
                    Positioned(
                      top: 8,
                      left: timeLabel.left,
                      child: timeLabel,
                    ),
                  if (_chartData != null) ...[
                    ChartDataPoints(
                      temperatures: _chartData!['temperature']!,
                      humidities: _chartData!['humidity']!,
                      heatIndices: _chartData!['heatIndex']!,
                    ),
                  ],
                  Positioned(
                    left: currentPosition,
                    top: 0,
                    bottom: 0,
                    child: ChartOverlayBox(leftPosition: currentPosition),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: ChartTempOverlay(),
        ),
      ],
    );
  }
}