// lib/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SocketService extends GetxController {
  static SocketService get instance => Get.find();

  IO.Socket? _socket;
  final RxBool _isConnected = false.obs;
  int reconnectCount = 0;

  bool get isConnected => _isConnected.value;

  @override
  void onInit() {
    super.onInit();
    _initializeSocket();
  }

  void _initializeSocket() {
    if (_socket != null) {
      if (kDebugMode) {
        print("⚠️ Socket already initialized, skipping");
      }
      return;
    }

    if (kDebugMode) {
      print("🔌 Initializing socket connection...");
    }

    _socket = IO.io('https://qareeb.modwir.com', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
      'extraHeaders': {'Accept': '*/*'},
      'timeout': 30000,
      'forceNew': false, // Prevent multiple connections
    });

    _setupSocketListeners();
    connect();
  }

  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      if (kDebugMode) {
        print("✅ Socket connected successfully");
      }
      _isConnected.value = true;
      reconnectCount = 0;
    });

    _socket?.onDisconnect((_) {
      if (kDebugMode) {
        print("❌ Socket disconnected");
      }
      _isConnected.value = false;
    });

    _socket?.onConnectError((data) {
      if (kDebugMode) {
        print("🚫 Socket connection error: $data");
      }
      _isConnected.value = false;
      _handleReconnect();
    });

    _socket?.onError((data) {
      if (kDebugMode) {
        print("💥 Socket error: $data");
      }
    });
  }

  void _handleReconnect() {
    if (reconnectCount < 5) {
      reconnectCount++;
      if (kDebugMode) {
        print("🔄 Attempting reconnect #$reconnectCount");
      }
      Future.delayed(Duration(seconds: 2 * reconnectCount), () {
        connect();
      });
    }
  }

  void connect() {
    if (_socket?.connected == true) {
      if (kDebugMode) {
        print("✅ Socket already connected");
      }
      return;
    }

    _socket?.connect();
  }

  void disconnect() {
    if (kDebugMode) {
      print("🔌 Disconnecting socket...");
    }
    _socket?.disconnect();
    _isConnected.value = false;
  }

  void emit(String event, dynamic data) {
    if (_socket?.connected == true) {
      _socket?.emit(event, data);
      if (kDebugMode) {
        print("📤 Emitted: $event with data: $data");
      }
    } else {
      if (kDebugMode) {
        print("⚠️ Cannot emit $event - socket not connected");
      }
    }
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  // Specific emit methods for common events
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

  void emitSendChat(
      String senderId, String receiverId, String message, String status) {
    emit('Send_Chat', {
      'sender_id': senderId,
      'recevier_id': receiverId,
      'message': message,
      'status': status,
    });
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print("🗑️ SocketService disposing...");
    }
    disconnect();
    _socket?.dispose();
    _socket = null;
    super.onClose();
  }
}
