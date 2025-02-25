import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/heat_index_data_point.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HeatIndexDataService {
  static final _logger = Logger('HeatIndexDataService');
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get real-time heat index updates
  static Stream<List<HeatIndexDataPoint>> getRealtimeHeatIndex() {
    return _database
        .child('hourly_records')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) {
        throw Exception('No heat index data available');
      }

      try {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        List<HeatIndexDataPoint> points = [];

        // Process all hours
        data.forEach((hourKey, value) {
          if (value is Map && 
              value['heat_index'] is Map && 
              value['heat_index']['celsius'] != null) {
            
            final hour = int.parse(hourKey.split(':')[0]);
            final celsius = double.parse(
              value['heat_index']['celsius'].toString()
            );
            
            final now = DateTime.now();
            final timestamp = DateTime(
              now.year, 
              now.month, 
              now.day, 
              hour
            );
            
            points.add(HeatIndexDataPoint(timestamp, celsius));
            _logger.fine('Real-time value received for $hourKey: $celsius°C');
          }
        });

        // Sort points by hour
        points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        return points;
      } catch (e) {
        _logger.warning('Error parsing real-time data: $e');
        rethrow;
      }
    });
  }

  // Get historical heat index data for the past 24 hours
  static Future<List<HeatIndexDataPoint>> get24HourHistory() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        _logger.warning('User not authenticated');
        return [];
      }

      final event = await _database
          .child('hourly_records')
          .get();
      
      _logger.info('Firebase response received: ${event.value != null}');

      if (event.value == null) {
        _logger.warning('No data available from Firebase');
        return [];
      }

      final Map<dynamic, dynamic> data = 
          event.value as Map<dynamic, dynamic>;
      
      List<HeatIndexDataPoint> points = [];

      data.forEach((key, value) {
        try {
          if (value is Map && 
              value['heat_index'] is Map && 
              value['heat_index']['celsius'] != null) {
            final hour = int.parse(key.split(':')[0]);
            final celsius = double.parse(
              value['heat_index']['celsius'].toString()
            );
            
            final now = DateTime.now();
            final timestamp = DateTime(
              now.year, 
              now.month, 
              now.day, 
              hour
            );
            
            points.add(HeatIndexDataPoint(timestamp, celsius));
            _logger.fine('Added data point for hour $hour: $celsius°C');
          }
        } catch (e) {
          _logger.warning('Error processing data for hour $key: $e');
        }
      });

      _logger.info('Processed ${points.length} data points');
      
      points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return points;
    } catch (e) {
      _logger.severe('Error fetching heat index history: $e');
      return [];
    }
  }

  // Get hourly average heat index data
  static Stream<Map<int, double>> getHourlyAverages() {
    return _database
        .child('hourly_records')
        .onValue
        .map((event) {
          final Map<int, double> hourlyData = {};

          if (event.snapshot.value == null) {
            return hourlyData;
          }

          final Map<dynamic, dynamic> data = 
              event.snapshot.value as Map<dynamic, dynamic>;

          data.forEach((key, value) {
            if (value is Map && value.containsKey('heat_index')) {
              final hour = DateTime.fromMillisecondsSinceEpoch(int.parse(key)).hour;
              final heatIndex = double.parse(value['heat_index'].toString());
              hourlyData[hour] = heatIndex;
            }
          });

          return hourlyData;
        });
  }

  // Convert HeatIndexDataPoint list to FlSpot list for FL Chart
  static List<FlSpot> convertToFlSpots(List<HeatIndexDataPoint> points) {
    _logger.info('Converting ${points.length} points to spots');
    
    final spots = points.map((point) {
      final hour = point.timestamp.hour.toDouble();
      _logger.fine('Converting point: hour=$hour, value=${point.value}');
      return FlSpot(hour, point.value);
    }).toList();

    // Sort spots by x value (hour)
    spots.sort((a, b) => a.x.compareTo(b.x));
    
    _logger.info('Created ${spots.length} spots');
    return spots;
  }
}