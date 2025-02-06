// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// 
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// 
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDWz9QwowGuP9h4iX74x6gy_cDlBVWNO48',
    appId: '1:28956293501:web:7cb9676a059fa9c9e93414',
    messagingSenderId: '28956293501',
    projectId: 'heat-index-monitoring-b11b0',
    authDomain: 'heat-index-monitoring-b11b0.firebaseapp.com',
    databaseURL: 'https://heat-index-monitoring-b11b0-default-rtdb.firebaseio.com',
    storageBucket: 'heat-index-monitoring-b11b0.firebasestorage.app',
    measurementId: 'G-3CXH1X3LB2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDXUBWc-zjqd6zkwIR_4M47KJhwCLydB7Q',
    appId: '1:28956293501:android:c86c3a7c08623b83e93414',
    messagingSenderId: '28956293501',
    projectId: 'heat-index-monitoring-b11b0',
    databaseURL: 'https://heat-index-monitoring-b11b0-default-rtdb.firebaseio.com',
    storageBucket: 'heat-index-monitoring-b11b0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAxiQZyDW7qHDDmN9BqgUUmoPHNYRh35EU',
    appId: '1:28956293501:ios:dc356bbf909a27b4e93414',
    messagingSenderId: '28956293501',
    projectId: 'heat-index-monitoring-b11b0',
    databaseURL: 'https://heat-index-monitoring-b11b0-default-rtdb.firebaseio.com',
    storageBucket: 'heat-index-monitoring-b11b0.firebasestorage.app',
    iosBundleId: 'com.example.oracle',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAxiQZyDW7qHDDmN9BqgUUmoPHNYRh35EU',
    appId: '1:28956293501:ios:dc356bbf909a27b4e93414',
    messagingSenderId: '28956293501',
    projectId: 'heat-index-monitoring-b11b0',
    databaseURL: 'https://heat-index-monitoring-b11b0-default-rtdb.firebaseio.com',
    storageBucket: 'heat-index-monitoring-b11b0.firebasestorage.app',
    iosBundleId: 'com.example.oracle',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDWz9QwowGuP9h4iX74x6gy_cDlBVWNO48',
    appId: '1:28956293501:web:dfe5e46f04b98fd0e93414',
    messagingSenderId: '28956293501',
    projectId: 'heat-index-monitoring-b11b0',
    authDomain: 'heat-index-monitoring-b11b0.firebaseapp.com',
    storageBucket: 'heat-index-monitoring-b11b0.firebasestorage.app',
    measurementId: 'G-RX3VLRZXEE',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDWz9QwowGuP9h4iX74x6gy_cDlBVWNO48',
    appId: '1:28956293501:web:7cb9676a059fa9c9e93414',
    messagingSenderId: '28956293501',
    projectId: 'heat-index-monitoring-b11b0',
    authDomain: 'heat-index-monitoring-b11b0.firebaseapp.com',
    databaseURL: 'https://heat-index-monitoring-b11b0-default-rtdb.firebaseio.com',
    storageBucket: 'heat-index-monitoring-b11b0.firebasestorage.app',
  );
}