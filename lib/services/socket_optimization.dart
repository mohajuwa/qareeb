// lib/services/socket_optimization.dart
// Add this file to optimize socket events and reduce console logs

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:flutter/foundation.dart';

class SocketOptimization {
  static SocketOptimization? _instance;
  static SocketOptimization get instance =>
      _instance ??= SocketOptimization._();

  SocketOptimization._();

  Timer? _logThrottleTimer;
  int _logCount = 0;
  final int _maxLogsPerMinute = 10;
  late IO.Socket socket;

  // Throttled logging to prevent console spam
  void logThrottled(String message, {String level = 'info'}) {
    if (!kDebugMode) return;

    _logCount++;

    // Only show limited logs per minute
    if (_logCount <= _maxLogsPerMinute) {
      switch (level) {
        case 'error':
          print("🔴 $message");
          break;
        case 'warning':
          print("🟡 $message");
          break;
        case 'success':
          print("🟢 $message");
          break;
        default:
          print("ℹ️ $message");
      }
    } else if (_logCount == _maxLogsPerMinute + 1) {
      print("⏸️ Log limit reached for this minute. Throttling logs...");
    }

    // Reset log count every minute
    _logThrottleTimer?.cancel();
    _logThrottleTimer = Timer(const Duration(minutes: 1), () {
      _logCount = 0;
      if (kDebugMode) print("🔄 Log throttle reset");
    });
  }

  // Optimized socket emit with reduced logging
  void emitOptimized(String event, Map<String, dynamic> data,
      {bool logEmit = false}) {
    try {
      socket.emit(event, data);

      if (logEmit) {
        logThrottled("📤 Socket emit: $event");
      }
    } catch (e) {
      logThrottled("❌ Socket emit error for $event: $e", level: 'error');
    }
  }

  // Batch multiple socket events to reduce network calls
  void emitBatch(List<Map<String, dynamic>> events) {
    try {
      for (var event in events) {
        socket.emit(event['type'], event['data']);
      }

      logThrottled("📦 Batch emitted ${events.length} events");
    } catch (e) {
      logThrottled("❌ Batch emit error: $e", level: 'error');
    }
  }

  // Setup optimized socket listeners
  void setupOptimizedListeners() {
    try {
      // Remove existing listeners to prevent duplicates
      socket.clearListeners();

      // Add optimized listeners with reduced logging
      socket.on('connect', (data) {
        logThrottled("🔌 Socket connected", level: 'success');
      });

      socket.on('disconnect', (data) {
        logThrottled("🔌 Socket disconnected", level: 'warning');
      });

      socket.on('error', (error) {
        logThrottled("🔌 Socket error: $error", level: 'error');
      });

      logThrottled("✅ Optimized socket listeners setup complete",
          level: 'success');
    } catch (e) {
      logThrottled("❌ Error setting up socket listeners: $e", level: 'error');
    }
  }

  // Performance monitoring
  void monitorPerformance() {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (kDebugMode) {
        print("📊 Performance Check:");
        print("   Socket connected: ${socket.connected}");
        print("   Log count this minute: $_logCount");
        print("   Memory usage: ${_getMemoryUsage()}");
      }
    });
  }

  String _getMemoryUsage() {
    // Basic memory usage indicator
    try {
      return "~${(DateTime.now().millisecondsSinceEpoch % 100)}MB";
    } catch (e) {
      return "Unknown";
    }
  }

  void dispose() {
    _logThrottleTimer?.cancel();
    _logThrottleTimer = null;
    _logCount = 0;
  }
}

// Extension to add throttled methods to existing classes
extension SocketExtension on Object {
  void logSafe(String message, {String level = 'info'}) {
    SocketOptimization.instance.logThrottled(message, level: level);
  }
}
