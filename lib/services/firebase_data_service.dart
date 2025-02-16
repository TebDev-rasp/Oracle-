import 'package:firebase_database/firebase_database.dart';

class FirebaseDataService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  FirebaseDataService() {
    FirebaseDatabase.instance.databaseURL = 'https://heat-index-monitoring-b11b0-default-rtdb.firebaseio.com/';
  }

  Stream<Map<String, dynamic>> getRawData() {
    return _database.child('raw_data').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return {
        'temperature': {
          'celsius': data['temperature']['celsius'],
          'fahrenheit': data['temperature']['fahrenheit'],
        },
        'humidity': data['humidity'],
        'heat_index': {
          'celsius': data['heat_index']['celsius'],
          'fahrenheit': data['heat_index']['fahrenheit'],
        },
      };
    });
  }

  Stream<Map<String, dynamic>> getSmoothData() {
    return _database.child('smooth_data').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return {
        'temperature': {
          'celsius': data['temperature']['celsius'],
          'fahrenheit': data['temperature']['fahrenheit'],
        },
        'humidity': data['humidity'],
        'heat_index': {
          'celsius': data['heat_index']['celsius'],
          'fahrenheit': data['heat_index']['fahrenheit'],
        },
      };
    });
  }
}