import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:oracle/services/connectivity_service.dart';
import 'package:oracle/services/heat_index_monitor.dart';
import 'package:oracle/widgets/connection_overlay.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';
import 'dart:developer' as developer;
import 'screens/splash_screen.dart';
import 'providers/user_profile_provider.dart';
import 'providers/historical_data_provider.dart';
import 'services/notification_service.dart';
import 'services/firebase_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  if (message.data.containsKey('heat_index')) {
    final heatIndex = double.tryParse(message.data['heat_index']);
    if (heatIndex != null) {
      await HeatIndexMonitor.checkHeatIndex(heatIndex);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications with no sound
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'heat_index_channel',
        channelName: 'Heat Index Alerts',
        channelDescription: 'Notifications for heat index warnings',
        defaultColor: Colors.red,
        ledColor: Colors.red,
        playSound: false,
        enableVibration: true,
        importance: NotificationImportance.High
      ),
    ],
    debug: true
  );

  try {
    // Initialize notifications first
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    // Explicitly request permissions
    await notificationService.requestPermissions();
    
    // Check if permissions were granted
    final bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      developer.log('Notification permissions not granted');
    }
    
    // Initialize logging first
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      developer.log(
        record.message,
        time: record.time,
        level: record.level.value,
        name: record.loggerName,
        error: record.error,
        stackTrace: record.stackTrace,
      );
    });

    await Firebase.initializeApp();
    
    // Initialize services with error handling
    try {
      await NotificationService().initialize();
    } catch (e) {
      developer.log('Notification service initialization failed: $e');
    }
    
    try {
      await FirebaseService.initialize();  // Changed to static call
    } catch (e) {
      developer.log('Firebase service initialization failed: $e');
    }

    // Only set up messaging if Google Play Services are available
    try {
      await FirebaseMessaging.instance.getToken();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
      );
      
      await FirebaseMessaging.instance.subscribeToTopic('heat_index_updates');
    } catch (e) {
      developer.log('Firebase Messaging setup failed: $e');
      // Continue without messaging
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ConnectivityService(),
          ),
          ChangeNotifierProvider(create: (_) => UserProfileProvider()),
          ChangeNotifierProvider(create: (_) => HistoricalDataProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    developer.log(
      'Error initializing app',
      error: e,
      stackTrace: stackTrace,
    );
    // Show error UI instead of crashing
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oracle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return NetworkAwareWidget(child: child ?? const SizedBox());
      },
      home: const SplashScreen(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('An error occurred during initialization.'),
        ),
      ),
    );
  }
}