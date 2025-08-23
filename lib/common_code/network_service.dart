import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:get/get.dart'; // ✅ Added for .tr support

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();

  factory NetworkService() => _instance;

  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isConnected = true;

  String _connectionType = 'unknown';

  // Getters with Arabic support

  bool get isConnected => _isConnected;

  String get connectionType => _getLocalizedConnectionType();

  // ✅ NEW: Localized connection type

  String _getLocalizedConnectionType() {
    switch (_connectionType) {
      case 'WiFi':
        return 'WiFi'.tr;

      case 'Mobile':
        return 'Mobile Data'.tr;

      case 'Ethernet':
        return 'Ethernet'.tr;

      case 'None':
        return 'No Connection'.tr;

      default:
        return 'Unknown'.tr;
    }
  }

  // Stream for connection changes

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;

  // Initialize network monitoring

  Future<void> initialize() async {
    await _checkConnection();

    _startMonitoring();
  }

  // Start monitoring connection

  void _startMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  // Check current connection

  Future<void> _checkConnection() async {
    try {
      List<ConnectivityResult> connectivityResults =
          await _connectivity.checkConnectivity();

      _updateConnectionStatus(connectivityResults);
    } catch (e) {
      if (kDebugMode) print('Connection check error: $e');
    }
  }

  // Update connection status

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool wasConnected = _isConnected;

    ConnectivityResult primaryResult =
        results.isNotEmpty ? results.first : ConnectivityResult.none;

    switch (primaryResult) {
      case ConnectivityResult.wifi:
        _isConnected = true;

        _connectionType = 'WiFi';

        break;

      case ConnectivityResult.mobile:
        _isConnected = true;

        _connectionType = 'Mobile';

        break;

      case ConnectivityResult.ethernet:
        _isConnected = true;

        _connectionType = 'Ethernet';

        break;

      case ConnectivityResult.none:
      default:
        _isConnected = false;

        _connectionType = 'None';

        break;
    }

    if (wasConnected != _isConnected) {
      _connectionController.add(_isConnected);

      if (kDebugMode) {
        print(
            '🌐 Connection status changed: ${_isConnected ? 'Connected'.tr : 'Disconnected'.tr} ($connectionType)');
      }
    }
  }

  // Test actual internet connectivity

  Future<bool> hasInternetConnection() async {
    if (!_isConnected) return false;

    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Internet test failed: $e');

      return false;
    }
  }

  // Dispose resources

  void dispose() {
    _connectivitySubscription?.cancel();

    _connectionController.close();
  }
}
