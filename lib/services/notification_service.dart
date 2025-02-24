import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final _logger = Logger('NotificationService');
  static bool _isInitialized = false;
  
  // Single flag to track if notification was shown this session
  bool _hasShownNotificationThisSession = false;

  // Singleton factory constructor
  factory NotificationService() {
    return _instance;
  }

  // Private constructor
  NotificationService._internal();

  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.info('Notification service already initialized');
      return;
    }

    // Reset notification state on initialization
    _hasShownNotificationThisSession = false;

    _logger.info('Initializing notification service');
    
    try {
      await AwesomeNotifications().initialize(
        'resource://drawable/ic_notification',  // Updated icon path
        [
          NotificationChannel(
            channelKey: 'heat_index_channel',
            channelName: 'Heat Index Alerts',
            channelDescription: 'Notifications for dangerous heat index levels',
            defaultColor: Colors.transparent,
            ledColor: Colors.transparent,
            importance: NotificationImportance.High,
            defaultRingtoneType: DefaultRingtoneType.Notification,
            enableVibration: true,
            criticalAlerts: true,
          ),
        ],
        debug: true,
      );

      await requestPermissions();
      
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: _onActionReceivedMethod,
        onNotificationCreatedMethod: _onNotificationCreatedMethod,
        onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      );

      _isInitialized = true;
      _logger.info('Notification service initialized successfully');
    } catch (e) {
      _logger.severe('Failed to initialize notification service: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(ReceivedAction receivedAction) async {
    _logger.info('Notification action received: ${receivedAction.buttonKeyInput}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    _logger.info('Notification created: ${receivedNotification.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    _logger.info('Notification displayed: ${receivedNotification.title}');
  }

  Future<void> requestPermissions() async {
    _logger.info('Requesting notification permissions');
    
    // Check if permissions are already granted
    final bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Show dialog to request permissions
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    
    // Double check if permissions were granted
    final afterRequest = await AwesomeNotifications().isNotificationAllowed();
    _logger.info('Notification permissions granted: $afterRequest');
  }

  Future<void> showHeatIndexNotification(double heatIndex) async {
    _logger.info('Showing heat index notification for: $heatIndex');
    
    // Simple check - if already shown this session, skip
    if (_hasShownNotificationThisSession) {
      _logger.info('Notification already shown this session, skipping');
      return;
    }

    String title;
    String body;

    if (heatIndex >= 54) {
      title = '🟣 Extreme Danger';
      body = 'Heat index: ${heatIndex.round()}°C - Heat stroke imminent';
    } else if (heatIndex >= 41) {
      title = '🔴 Danger';
      body = 'Heat index: ${heatIndex.round()}°C - Heat cramps/exhaustion likely';
    } else if (heatIndex >= 32) {
      title = '🟠 Extreme Caution';
      body = 'Heat index: ${heatIndex.round()}°C - Heat exhaustion possible';
    } else if (heatIndex >= 27) {
      title = '🟡 Caution';
      body = 'Heat index: ${heatIndex.round()}°C - Fatigue possible';
    } else {
      _logger.info('Normal heat index: $heatIndex, no notification needed');
      return;
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecond,
          channelKey: 'heat_index_channel',
          title: title,
          body: body,
          icon: 'resource://drawable/ic_notification',
          notificationLayout: NotificationLayout.Default,
          criticalAlert: heatIndex >= 41,
          wakeUpScreen: heatIndex >= 41,
        ),
      );
      
      _hasShownNotificationThisSession = true;
      _logger.info('Heat index notification shown successfully');
    } catch (e) {
      _logger.severe('Failed to show notification: $e');
    }
  }
}