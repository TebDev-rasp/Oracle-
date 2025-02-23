import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:logging/logging.dart';
import 'package:firebase_database/firebase_database.dart';

class HeatIndexMonitor {
  static final _logger = Logger('HeatIndexMonitor');
  static bool _isMonitoring = false;
  static StreamSubscription<DatabaseEvent>? _subscription;
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  static Future<void> startMonitoring() async {
    if (_isMonitoring) {
      _logger.info('Heat index monitoring already active');
      return;
    }

    _logger.info('Starting heat index monitoring');
    
    _subscription = _database
        .child('sensor_data/smooth/heat_index/celsius')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final heatIndex = double.tryParse(event.snapshot.value.toString());
        if (heatIndex != null) {
          _logger.info('Received heat index update: $heatIndex°C');
          checkHeatIndex(heatIndex);
        }
      }
    }, onError: (error) {
      _logger.severe('Error monitoring heat index: $error');
    });

    _isMonitoring = true;
    _logger.info('Heat index monitoring started');
  }

  static Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;

    await _subscription?.cancel();
    _subscription = null;
    _isMonitoring = false;
    _logger.info('Heat index monitoring stopped');
  }

  static Future<void> checkHeatIndex(double heatIndex) async {
    String title;
    String body;
    bool isCritical;

    if (heatIndex >= 54) {
        title = 'Extreme Danger!';
        body = 'Heat index is extremely high. Heat stroke highly likely.';
        isCritical = true;
    } else if (heatIndex >= 41) {
        title = 'Danger!';
        body = 'Heat cramps or heat exhaustion likely.';
        isCritical = true;
    } else if (heatIndex >= 32) {
        title = 'Extreme Caution';
        body = 'Heat exhaustion possible with prolonged exposure.';
        isCritical = false;
    } else if (heatIndex >= 27) {
        title = 'Caution';
        body = 'Fatigue possible with prolonged exposure.';
        isCritical = false;
    } else {
        return;
    }

    try {
        await AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: DateTime.now().millisecond,
                channelKey: 'heat_index_channel',
                title: title,
                body: body,
                notificationLayout: NotificationLayout.Default,
                criticalAlert: isCritical,
                category: NotificationCategory.Alarm,
            ),
        );
        _logger.info('Heat index notification sent');
    } catch (e) {
        _logger.severe('Failed to send notification: $e');
    }
  }
}

class DataService {
  // ...existing code...

  Future<void> processNewData(Map<String, dynamic> data) async {
    // ...existing data processing...

    // Check heat index and send notification if needed
    if (data.containsKey('heat_index')) {
      final heatIndex = double.tryParse(data['heat_index'].toString());
      if (heatIndex != null) {
        await HeatIndexMonitor.checkHeatIndex(heatIndex);
      }
    }

    // ...rest of existing code...
  }
}