// lib/services/socket_service.dart - COMPLETE IMPLEMENTATION
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxController {
  static SocketService get instance => Get.find();

  IO.Socket? _socket;
  final RxBool _isConnected = false.obs;
  final RxString _connectionStatus = "Disconnected".obs;

  // Getters
  bool get isConnected => _isConnected.value;
  String get connectionStatus => _connectionStatus.value;
  IO.Socket? get socket => _socket;

  // ✅ INITIALIZE SOCKET CONNECTION
  void connect() {
    if (_socket != null && _socket!.connected) {
      if (kDebugMode) {
        print("Socket already connected");
      }
      return;
    }

    try {
      _socket = IO.io('https://qareeb.modwir.com', <String, dynamic>{
        'autoConnect': false,
        'transports': ['websocket'],
        'extraHeaders': {'Accept': '*/*'},
        'timeout': 30000,
        'forceNew': true,
      });

      // Set up connection event listeners
      _setupConnectionListeners();

      // Connect
      _socket!.connect();

      if (kDebugMode) {
        print("🔌 Socket connection initiated");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Socket connection error: $e");
      }
      _connectionStatus.value = "Error: $e";
    }
  }

  // ✅ SETUP CONNECTION LISTENERS
  void _setupConnectionListeners() {
    if (_socket == null) return;

    _socket!.onConnect((data) {
      _isConnected.value = true;
      _connectionStatus.value = "Connected";
      if (kDebugMode) {
        print("✅ Socket connected successfully");
      }
    });

    _socket!.onConnectError((data) {
      _isConnected.value = false;
      _connectionStatus.value = "Connect Error";
      if (kDebugMode) {
        print("❌ Socket connect error: $data");
      }
    });

    _socket!.onDisconnect((data) {
      _isConnected.value = false;
      _connectionStatus.value = "Disconnected";
      if (kDebugMode) {
        print("🔌 Socket disconnected: $data");
      }
    });

    _socket!.onError((data) {
      if (kDebugMode) {
        print("❌ Socket error: $data");
      }
    });

    _socket!.onReconnect((data) {
      _isConnected.value = true;
      if (kDebugMode) {
        print("🔄 Socket reconnected");
      }
    });
  }

  // ✅ EMIT EVENTS SAFELY
  void emit(String event, dynamic data) {
    if (_socket == null || !_socket!.connected) {
      if (kDebugMode) {
        print("❌ Cannot emit '$event': Socket not connected");
      }
      return;
    }

    try {
      _socket!.emit(event, data);
      if (kDebugMode) {
        print("📤 Emitted '$event': $data");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error emitting '$event': $e");
      }
    }
  }

  // ✅ LISTEN TO EVENTS SAFELY
  void on(String event, Function(dynamic) handler) {
    if (_socket == null) {
      if (kDebugMode) {
        print("❌ Cannot listen to '$event': Socket not initialized");
      }
      return;
    }

    _socket!.on(event, (data) {
      if (kDebugMode) {
        print("📥 Received '$event': $data");
      }
      handler(data);
    });
  }

  // ✅ REMOVE LISTENERS
  void off(String event) {
    if (_socket == null) return;
    _socket!.off(event);
    if (kDebugMode) {
      print("🔇 Removed listener for '$event'");
    }
  }

  // ✅ CLEAR ALL LISTENERS
  void clearListeners() {
    if (_socket == null) return;
    _socket!.clearListeners();
    if (kDebugMode) {
      print("🔇 Cleared all socket listeners");
    }
  }

  // ✅ SPECIFIC EMIT METHODS FOR YOUR APP

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

  void emitVehiclePaymentChange(String userid, String dId, int paymentId) {
    emit('Vehicle_P_Change', {
      'userid': userid,
      'd_id': dId,
      'payment_id': paymentId,
    });
  }

  void emitVehicleRideComplete(String dId, String requestId) {
    emit('Vehicle_Ride_Complete', {
      'd_id': dId,
      'request_id': requestId,
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

  void emitVehicleTimeRequest(String uid, String dId) {
    emit('Vehicle_Time_Request', {
      'uid': uid,
      'd_id': dId,
    });
  }

  void emitAcceptRemoveOther(String requestId, dynamic driverId) {
    emit('AcceRemoveOther', {
      'requestid': requestId,
      'driverid': driverId,
    });
  }

  // ✅ DISCONNECT SAFELY
  void disconnect() {
    if (_socket == null) return;

    try {
      clearListeners();
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected.value = false;
      _connectionStatus.value = "Disconnected";

      if (kDebugMode) {
        print("🔌 Socket disconnected and disposed");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error disconnecting socket: $e");
      }
    }
  }

  // ✅ RECONNECT METHOD
  void reconnect() {
    if (kDebugMode) {
      print("🔄 Attempting to reconnect socket...");
    }
    disconnect();
    connect();
  }

  // ✅ CHECK CONNECTION STATUS
  bool isSocketReady() {
    return _socket != null && _socket!.connected;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
