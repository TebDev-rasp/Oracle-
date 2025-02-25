import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

enum ConnectionStatus {
  online,
  offline,
  checking
}

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  final Connectivity _connectivity = Connectivity();
  late StreamController<ConnectionStatus> _controller;
  ConnectionStatus _lastStatus = ConnectionStatus.checking;
  Timer? _checkTimer;
  bool _isInitialized = false;

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal() {
    _controller = StreamController<ConnectionStatus>.broadcast();
    _initialize();
  }

  Stream<ConnectionStatus> get statusStream => _controller.stream;
  ConnectionStatus get lastStatus => _lastStatus;
  bool get isInitialized => _isInitialized;
  bool get hasConnection => _lastStatus == ConnectionStatus.online;

  void _initialize() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        _checkStatus(results.first);
      }
    });
    checkConnection();
    _isInitialized = true;
  }

  Future<void> _checkStatus(ConnectivityResult result) async {
    _lastStatus = ConnectionStatus.checking;
    _controller.add(_lastStatus);

    _checkTimer?.cancel();
    _checkTimer = Timer(const Duration(seconds: 5), () {
      _lastStatus = result == ConnectivityResult.none 
          ? ConnectionStatus.offline 
          : ConnectionStatus.online;
      _controller.add(_lastStatus);
      notifyListeners();
    });
  }

  Future<void> checkConnection() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    if (results.isNotEmpty) {
      await _checkStatus(results.first);
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _controller.close();
    super.dispose();
  }
}