import 'package:flutter/material.dart';

class ChartLine extends StatelessWidget {
  final List<double> dataPoints;
  final Color lineColor;
  final double strokeWidth;
  final double startPosition;
  final double interval;
  final double minValue;
  final double maxValue;
  final bool showValues;
  final int currentHour;

  const ChartLine({
    super.key,
    required this.dataPoints,
    required this.lineColor,
    this.strokeWidth = 2.0,
    this.startPosition = 15.0,
    this.interval = 112.0,
    this.minValue = 20.0,
    this.maxValue = 50.0,
    this.showValues = false,
    required this.currentHour,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ChartLinePainter(
        dataPoints: dataPoints,
        lineColor: lineColor,
        strokeWidth: strokeWidth,
        startPosition: startPosition,
        interval: interval,
        minValue: minValue,
        maxValue: maxValue,
        showValues: showValues,
        currentHour: currentHour,
      ),
    );
  }
}

class ChartLinePainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final double strokeWidth;
  final double startPosition;
  final double interval;
  final double minValue;
  final double maxValue;
  final bool showValues;
  final int currentHour;

  ChartLinePainter({
    required this.dataPoints,
    required this.lineColor,
    required this.strokeWidth,
    required this.startPosition,
    required this.interval,
    required this.minValue,
    required this.maxValue,
    required this.showValues,
    required this.currentHour,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const double startY = 380.0;
    const double interval = 57.0;

    final path = Path();
    bool isFirst = true;
    double lastValidY = startY;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw lines only for current hour's position
    for (int i = 0; i <= currentHour; i++) {
      final x = startPosition + (this.interval * i);
      final y = dataPoints[i] > 0
          ? startY - ((dataPoints[i] - 20) / 5 * interval)
          : lastValidY;

      // Draw horizontal line at 12 AM (hour 0)
      if (i == 0 && dataPoints[i] > 0) {
        canvas.drawLine(
          Offset(0, y),
          Offset(startPosition, y),
          paint..strokeWidth = 2,
        );
      }

      // Draw horizontal line at 11 PM (hour 23)
      if (i == 23 && dataPoints[i] > 0 && currentHour >= 23) {
        final endX = startPosition + (this.interval * 23);
        canvas.drawLine(
          Offset(endX, y),
          Offset(endX + 50, y),
          paint..strokeWidth = 1,
        );
      }

      paint.strokeWidth = strokeWidth; // Reset stroke width for main line

      // Rest of your existing drawing code
      if (isFirst && dataPoints[i] > 0) {
        path.moveTo(x, y);
        isFirst = false;
        lastValidY = y;
      } else if (!isFirst) {
        path.lineTo(x, y);
        if (dataPoints[i] > 0) {
          lastValidY = y;
        }
      }

      if (dataPoints[i] > 0) {
        canvas.drawCircle(
          Offset(x, y),
          4.0,
          Paint()
            ..color = lineColor
            ..style = PaintingStyle.fill,
        );

        if (showValues) {
          final text = TextSpan(
            text: '${dataPoints[i].toStringAsFixed(1)}°',
            style: TextStyle(
              color: lineColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          );

          textPainter.text = text;
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(x - (textPainter.width / 2), y - 20),
          );
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}