import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class HeatIndex extends ChangeNotifier {
  double value;    // This will store Fahrenheit
  double celsius;
  final DatabaseReference _dbRef;

  HeatIndex({
    this.value = 00.0,     // Fahrenheit value
    this.celsius = 00.0,   // Celsius value
  }) : _dbRef = FirebaseDatabase.instance.ref().child('smooth_data/heat_index') {
    _startListening();
  }

  void _startListening() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        value = (data['fahrenheit'] as num).toDouble();    // Store Fahrenheit in value
        celsius = (data['celsius'] as num).toDouble();     // Store Celsius in celsius
        notifyListeners();
      }
    });
  }

  String get formattedValue => '${value.toStringAsFixed(1)}°F';
}
