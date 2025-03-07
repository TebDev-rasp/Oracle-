import 'package:flutter/material.dart';
import 'chart_line.dart';

class ChartDataPoints extends StatelessWidget {
  final List<double> temperatures;
  final List<double> humidities;
  final List<double> heatIndices;
  // Change these default values to adjust starting position and spacing
  final double startPosition;
  final double interval;

  const ChartDataPoints({
    super.key,
    required this.temperatures,
    required this.humidities,
    required this.heatIndices,
    this.startPosition = 50.0,  // Adjust this value to move start position
    this.interval = 112.0,      // Adjust this value to change spacing between points
  });

  @override
  Widget build(BuildContext context) {
    final currentHour = DateTime.now().hour;
    
    return Stack(
      children: [
        ChartLine(
          dataPoints: temperatures,
          lineColor: Colors.red,
          startPosition: startPosition,
          interval: interval,
          minValue: 20.0,
          maxValue: 50.0,
          showValues: false, // Don't show temperature values
          currentHour: currentHour,
        ),
        ChartLine(
          dataPoints: heatIndices,
          lineColor: Colors.orange,
          startPosition: startPosition,
          interval: interval,
          minValue: 20.0,
          maxValue: 50.0,
          showValues: true, // Only show heat index values
          currentHour: currentHour,
        ),
      ],
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> temperatures;
  final List<double> humidities;
  final List<double> heatIndices;
  final double startPosition;
  final double interval;

  ChartPainter({
    required this.temperatures,
    required this.humidities,
    required this.heatIndices,
    required this.startPosition,
    required this.interval,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint temperaturePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint humidityPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint heatIndexPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw temperature line
    _drawDataLine(canvas, temperatures, temperaturePaint, size);
    
    // Draw humidity line
    _drawDataLine(canvas, humidities, humidityPaint, size);
    
    // Draw heat index line
    _drawDataLine(canvas, heatIndices, heatIndexPaint, size);
  }

  void _drawDataLine(Canvas canvas, List<double> data, Paint paint, Size size) {
    final path = Path();
    bool isFirst = true;

    for (int i = 0; i < data.length; i++) {
      final x = startPosition + (interval * i);
      // Convert value to y coordinate (assuming 50°C max, 20°C min)
      final y = size.height - ((data[i] - 20) * (size.height / 30));

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}