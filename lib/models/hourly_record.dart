import 'package:logging/logging.dart';

class HourlyRecord {
  static final _logger = Logger('HourlyRecord');
  
  // Updated regex to match exactly HH:00 format
  static final _timeRegex = RegExp(r'^([0-1][0-9]|2[0-3]):00$');
  
  final String time;
  final double heatIndexCelsius;
  final double heatIndexFahrenheit;
  final double humidity;
  final double temperatureCelsius;
  final double temperatureFahrenheit;
  final int timestamp;  // Added timestamp field

  HourlyRecord({
    required this.time,
    required this.heatIndexCelsius,
    required this.heatIndexFahrenheit,
    required this.humidity,
    required this.temperatureCelsius,
    required this.temperatureFahrenheit,
    required this.timestamp,  // Added to constructor
  }) {
    if (!_timeRegex.hasMatch(time)) {
      throw FormatException('Invalid time format. Must be between 00:00 and 23:00');
    }
  }

  factory HourlyRecord.fromJson(String time, Map<dynamic, dynamic> json) {
    try {
      return HourlyRecord(
        time: _formatTime(time),
        heatIndexCelsius: (json['heat_index']?['celsius'] as num?)?.toDouble() ?? 0,
        heatIndexFahrenheit: (json['heat_index']?['fahrenheit'] as num?)?.toDouble() ?? 0,
        humidity: (json['humidity'] as num?)?.toDouble() ?? 0,
        temperatureCelsius: (json['temperature']?['celsius'] as num?)?.toDouble() ?? 0,
        temperatureFahrenheit: (json['temperature']?['fahrenheit'] as num?)?.toDouble() ?? 0,
        timestamp: (json['temperature']?['timestamp'] as num?)?.toInt() ?? 0,  // Added timestamp parsing
      );
    } catch (e) {
      _logger.warning('Error parsing record for time $time: $e');
      rethrow;
    }
  }

  // Add fromMap factory constructor
  factory HourlyRecord.fromMap(String time, Map<String, dynamic> map) {
    return HourlyRecord(
      time: time,
      temperatureCelsius: ((map['temperature']?['celsius'] as num?) ?? 0).toDouble(),
      temperatureFahrenheit: ((map['temperature']?['fahrenheit'] as num?) ?? 0).toDouble(),
      humidity: ((map['humidity'] as num?) ?? 0).toDouble(),
      heatIndexCelsius: ((map['heat_index']?['celsius'] as num?) ?? 0).toDouble(),
      heatIndexFahrenheit: ((map['heat_index']?['fahrenheit'] as num?) ?? 0).toDouble(),
      timestamp: ((map['temperature']?['timestamp'] as num?) ?? 0).toInt(),
    );
  }

  // Helper method to format time string
  static String _formatTime(String time) {
    // If the time is already in correct format, return it
    if (_timeRegex.hasMatch(time)) {
      return time;
    }

    try {
      // Handle cases where time might come without :00
      final cleanTime = time.trim().replaceAll(RegExp(r'[^0-9]'), '');
      final hour = int.parse(cleanTime.padLeft(2, '0'));
      
      if (hour < 0 || hour > 23) {
        throw FormatException('Hour must be between 00 and 23, got: $time');
      }

      // Format to HH:00
      return '${hour.toString().padLeft(2, '0')}:00';
    } catch (e) {
      _logger.warning('Error formatting time: $time');
      throw FormatException('Invalid time format. Expected format 00:00 to 23:00, got: $time');
    }
  }

  @override
  String toString() {
    return 'HourlyRecord{time: $time, heatIndexC: $heatIndexCelsius°C, '
           'heatIndexF: $heatIndexFahrenheit°F, humidity: $humidity%, '
           'tempC: $temperatureCelsius°C, tempF: $temperatureFahrenheit°F, '
           'timestamp: $timestamp}';  // Added timestamp to toString
  }

  Map<String, dynamic> toMap() {
    return {
      'heat_index': {
        'celsius': heatIndexCelsius,
        'fahrenheit': heatIndexFahrenheit,
      },
      'humidity': humidity,
      'temperature': {
        'celsius': temperatureCelsius,
        'fahrenheit': temperatureFahrenheit,
        'timestamp': timestamp,  // Added timestamp to toMap
      },
    };
  }
}