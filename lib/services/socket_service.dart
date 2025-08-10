// lib/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class SocketService extends GetxController {
  static SocketService get instance => Get.find();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentUserId;

  bool get isConnected => _isConnected && (_socket?.connected ?? false);

  void initSocket(String userId) {
    if (_socket?.connected == true && _currentUserId == userId) {
      if (kDebugMode) {
        print('🔌 Socket already connected for user $userId');
      }
      return;
    }

    // Disconnect existing socket if user changed
    if (_currentUserId != userId) {
      disconnect();
    }

    _currentUserId = userId;

    _socket = IO.io('https://qareeb.modwir.com', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
      'extraHeaders': {'Accept': '*/*'},
      'timeout': 30000,
      'forceNew': true,
    });

    _setupEventHandlers(userId);
    _socket?.connect();
  }

  void _setupEventHandlers(String userId) {
    _socket?.onConnect((_) {
      if (kDebugMode) {
        print('✅ Socket connected successfully for user $userId');
      }
      _isConnected = true;
      _socket?.emit('message', 'Hello from Flutter');
    });

    _socket?.onDisconnect((_) {
      if (kDebugMode) {
        print('❌ Socket disconnected');
      }
      _isConnected = false;
    });

    _socket?.onConnectError((error) {
      if (kDebugMode) {
        print('💥 Socket connection error: $error');
      }
      _isConnected = false;
    });

    // Add ride-specific listeners
    _socket?.on('home', (data) {
      if (kDebugMode) {
        print('🏠 Home event received: $data');
      }
      // Handle home event - you can add callback here
    });

    _socket?.on('acceptvehrequest$userId', (data) {
      if (kDebugMode) {
        print('🚗 Vehicle request accepted: $data');
      }
      // Handle vehicle request acceptance
    });
  }

  void emit(String event, dynamic data) {
    if (isConnected) {
      _socket?.emit(event, data);
      if (kDebugMode) {
        print('📤 Emitted $event: $data');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ Cannot emit $event - socket not connected');
      }
    }
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  // Helper methods for specific events
  void emitVehicleRequest(String requestId, List driverId, String cId) {
    emit('vehiclerequest', {
      'requestid': requestId,
      'driverid': driverId,
      'c_id': cId,
    });
  }

  void emitVehicleRideCancel(String uid, dynamic driverId) {
    emit('Vehicle_Ride_Cancel', {
      'uid': uid,
      'driverid': driverId,
    });
  }

  void emitAcceptBidding(
      String uid, String dId, String requestId, String price) {
    emit('Accept_Bidding', {
      'uid': uid,
      'd_id': dId,
      'request_id': requestId,
      'price': price,
    });
  }

  void disconnect() {
    if (kDebugMode) {
      print('🔌 Disconnecting socket...');
    }

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _currentUserId = null;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
