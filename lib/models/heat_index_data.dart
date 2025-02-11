import 'dart:async';
import 'package:flutter/foundation.dart';

class HeatIndex extends ChangeNotifier {
  double value;
  final double celsius;
  Timer? _timer;

  HeatIndex({
    this.value = 70.0,
    this.celsius = 20.20,
  }) {
    _startGenerating();
  }

  void _startGenerating() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      value += 5.0;
      if (value > 130.5) {
        value = 70.0;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get formattedValue => '${value.toStringAsFixed(1)}°F';
}