import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class ChartDataService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  bool _initialized = false;

  ChartDataService() {
    _initializeDatabase();
  }

  void _initializeDatabase() {
    if (!_initialized) {
      _database.databaseURL = 'https://heat-index-monitoring-b11b0-default-rtdb.firebaseio.com/';
      _database.setPersistenceEnabled(true);
      _database.setPersistenceCacheSizeBytes(10000000); // 10MB cache
      _initialized = true;
    }
  }

  Future<Map<String, List<double>>> fetchHourlyChartData() async {
    try {
      // Initialize empty lists for 24 hours with zeros
      List<double> temperatures = List.filled(24, 0.0);
      List<double> humidities = List.filled(24, 0.0);
      List<double> heatIndices = List.filled(24, 0.0);

      final hourlyRef = _database.ref('hourly_records');
      final Query query = hourlyRef.orderByKey().limitToLast(24);
      final DataSnapshot snapshot = await query.get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> data = snapshot.value as Map;
        
        // Debug print raw data
        debugPrint('Raw Firebase Data: ${data.toString()}');
        
        final sortedHours = data.keys.toList()..sort();
        debugPrint('Sorted Hours: $sortedHours');

        for (final hour in sortedHours) {
          debugPrint('Processing hour: $hour');
          final values = data[hour] as Map;
          debugPrint('Values for $hour: $values');
          
          try {
            final hourIndex = int.parse(hour.toString().split(':')[0]);
            debugPrint('Hour Index: $hourIndex');
            
            // Print raw values before processing
            debugPrint('Temperature raw: ${values['temperature']}');
            debugPrint('Humidity raw: ${values['humidity']}');
            debugPrint('Heat Index raw: ${values['heat_index']}');

            temperatures[hourIndex] = ((values['temperature'] as Map)['celsius'] as num).toDouble();
            humidities[hourIndex] = (values['humidity'] as num).toDouble();
            heatIndices[hourIndex] = ((values['heat_index'] as Map)['celsius'] as num).toDouble();
          } catch (e) {
            debugPrint('Error processing hour $hour: $e');
          }
        }
      } else {
        debugPrint('No data found in snapshot');
      }

      // Print final processed data
      debugPrint('Final Temperatures: $temperatures');
      debugPrint('Final Humidities: $humidities');
      debugPrint('Final Heat Indices: $heatIndices');

      return {
        'temperature': temperatures,
        'humidity': humidities,
        'heatIndex': heatIndices,
      };
    } catch (e) {
      debugPrint('Error fetching chart data: $e');
      throw Exception('Failed to fetch hourly chart data: $e');
    }
  }
}