import 'package:flutter/material.dart';

class ChartOverlayBox extends StatelessWidget {
  final double leftPosition;

  const ChartOverlayBox({
    super.key,
    required this.leftPosition,
  });

  static double calculatePosition([DateTime? testTime]) {
    final now = testTime ?? DateTime.now();
    final hour = now.hour;
    const startPosition = 15.0;
    const interval = 112.0;
    const overlayBoxWidth = 112.0;
    
    return (startPosition + (interval * hour)) - (overlayBoxWidth / 7);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          bottomLeft: Radius.circular(0),
        ),
      ),
    );
  }
}