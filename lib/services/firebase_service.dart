import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import '../models/hourly_record.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'heat_index_monitor.dart';

class FirebaseService {
  static final _logger = Logger('FirebaseService');
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static bool _isInitialized = false;

  Stream<List<HourlyRecord>> getHourlyRecords() {
    return _database.child('hourly_records').onValue.map((event) {
      final Map<dynamic, dynamic> data = 
          event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      
      List<HourlyRecord> records = [];
      
      data.forEach((time, value) {
        if (value is Map) {
          try {
            records.add(HourlyRecord.fromMap(time.toString(), 
                Map<String, dynamic>.from(value)));
          } catch (e) {
            _logger.warning('Error parsing record for time $time: $e');
          }
        }
      });

      // Sort records chronologically by hour (00:00 to 23:00)
      records.sort((a, b) {
        int hourA = int.parse(a.time.split(':')[0]);
        int hourB = int.parse(b.time.split(':')[0]);
        return hourA.compareTo(hourB);
      });
      
      // Log the sorted order for debugging
      _logger.fine('Sorted records: ${records.map((r) => r.time).join(', ')}');
      
      return records;
    });
  }

  // Method to get a specific hour's record
  Future<HourlyRecord?> getHourlyRecord(String time) async {
    try {
      final event = await _database.child('hourly_records/$time').once();
      final data = event.snapshot.value;
      
      if (data == null || data is! Map) {
        _logger.warning('No data found for time: $time');
        return null;
      }

      return HourlyRecord.fromMap(time, Map<String, dynamic>.from(data));
    } catch (e) {
      _logger.severe('Error fetching record for time $time: $e');
      rethrow;
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if (!Firebase.apps.isNotEmpty) {
      await Firebase.initializeApp();
    }

    if (message.data.containsKey('heat_index')) {
      final heatIndex = double.tryParse(message.data['heat_index']);
      if (heatIndex != null) {
        await HeatIndexMonitor.checkHeatIndex(heatIndex);
      }
    }
  }

  static Future<void> initialize() async {
    _logger.info('Initializing Firebase connection...');
    
    // Monitor heat index path
    _database.child('sensor_data/smooth/heat_index/celsius').onValue.listen(
      (event) {
        _logger.info('Received heat index: ${event.snapshot.value}');
        if (event.snapshot.value != null) {
          final heatIndex = double.tryParse(event.snapshot.value.toString());
          if (heatIndex != null) {
            _logger.info('Processing heat index: $heatIndex°C');
            HeatIndexMonitor.checkHeatIndex(heatIndex);
          }
        }
      },
      onError: (error) {
        _logger.severe('Database error: $error');
      }
    );

    if (_isInitialized) return;

    try {
      // Set persistence enabled (remove await and duplicate call)
      FirebaseDatabase.instance.setPersistenceEnabled(true);

      // Listen to your actual sensor data path in Firebase
      _database.child('sensors/your_sensor_path').onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          if (data.containsKey('heat_index')) {
            final heatIndex = double.tryParse(data['heat_index'].toString());
            if (heatIndex != null) {
              HeatIndexMonitor.checkHeatIndex(heatIndex);
            }
          }
        }
      });

      // Initialize FCM for background notifications
      await FirebaseMessaging.instance.requestPermission();
      
      // Get FCM token for this device
      final token = await FirebaseMessaging.instance.getToken();
      _logger.info('FCM Token: $token');

      // Initialize Firebase Messaging
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.data.containsKey('heat_index')) {
          final heatIndex = double.tryParse(message.data['heat_index']);
          if (heatIndex != null) {
            HeatIndexMonitor.checkHeatIndex(heatIndex);
          }
        }
      });

      // Request notification permissions
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
      );

      // Subscribe to heat index updates
      await FirebaseMessaging.instance.subscribeToTopic('heat_index_updates');

      _isInitialized = true;
      _logger.info('Firebase service initialized successfully');
    } catch (e) {
      _logger.severe('Failed to initialize Firebase service: $e');
      // Don't rethrow - allow app to continue without Firebase
    }
  }

  static Future<void> testConnection() async {
    try {
      final snapshot = await _database
          .child('sensor_data/smooth/heat_index/celsius')
          .get();
      
      _logger.info('Test connection value: ${snapshot.value}');
      
      if (snapshot.value != null) {
        final heatIndex = double.tryParse(snapshot.value.toString());
        if (heatIndex != null) {
          _logger.info('Test heat index: $heatIndex°C');
          await HeatIndexMonitor.checkHeatIndex(heatIndex);
        }
      }
    } catch (e) {
      _logger.severe('Test connection failed: $e');
    }
  }

  // Initialize logging
  static void initializeLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // Use logger instead of print
      _logger.log(record.level, 
          '${record.loggerName}: ${record.time}: ${record.message}');
    });
  }
}