import 'package:flutter/material.dart';

class ChartTimeLabel extends StatelessWidget {
  final String timeLabel;
  final double left;

  const ChartTimeLabel({
    super.key,
    required this.timeLabel,
    required this.left,
  });

  static List<ChartTimeLabel> getAllTimeLabels() {
    // Decreased startPosition for overlay box alignment
    const double startPosition = 15.0;  // Reduced from 50.0
    const double interval = 112.0;
    
    final List<Map<String, dynamic>> timeLabels = [
      {'time': '12:00 AM', 'left': startPosition + (interval * 0)},  // Added 12:00 AM
      {'time': '1:00 AM', 'left': startPosition + (interval * 1)},
      {'time': '2:00 AM', 'left': startPosition + (interval * 2)},
      {'time': '3:00 AM', 'left': startPosition + (interval * 3)},
      {'time': '4:00 AM', 'left': startPosition + (interval * 4)},
      {'time': '5:00 AM', 'left': startPosition + (interval * 5)},
      {'time': '6:00 AM', 'left': startPosition + (interval * 6)},
      {'time': '7:00 AM', 'left': startPosition + (interval * 7)},
      {'time': '8:00 AM', 'left': startPosition + (interval * 8)},
      {'time': '9:00 AM', 'left': startPosition + (interval * 9)},
      {'time': '10:00 AM', 'left': startPosition + (interval * 10)},
      {'time': '11:00 AM', 'left': startPosition + (interval * 11)},
      {'time': '12:00 PM', 'left': startPosition + (interval * 12)},
      {'time': '1:00 PM', 'left': startPosition + (interval * 13)},
      {'time': '2:00 PM', 'left': startPosition + (interval * 14)},
      {'time': '3:00 PM', 'left': startPosition + (interval * 15)},
      {'time': '4:00 PM', 'left': startPosition + (interval * 16)},
      {'time': '5:00 PM', 'left': startPosition + (interval * 17)},
      {'time': '6:00 PM', 'left': startPosition + (interval * 18)},
      {'time': '7:00 PM', 'left': startPosition + (interval * 19)},
      {'time': '8:00 PM', 'left': startPosition + (interval * 20)},
      {'time': '9:00 PM', 'left': startPosition + (interval * 21)},
      {'time': '10:00 PM', 'left': startPosition + (interval * 22)},
      {'time': '11:00 PM', 'left': startPosition + (interval * 23)},
    ];

    return timeLabels.map((label) => ChartTimeLabel(
      timeLabel: label['time'] as String,
      left: label['left'] as double,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withAlpha(204), // Changed from withOpacity(0.8)
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        timeLabel,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}