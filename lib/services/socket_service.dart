// lib/services/socket_service.dart - COMPLETE FIX
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxController {
  static SocketService get instance => Get.find();

  IO.Socket? _socket;
  final RxBool _isConnected = false.obs;
  final RxString _connectionStatus = "Disconnected".obs;
  bool _isConnecting = false;

  // Getters
  bool get isConnected => _isConnected.value;
  String get connectionStatus => _connectionStatus.value;
  IO.Socket? get socket => _socket;

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print("SocketService initialized");
    }
  }

  // ✅ INITIALIZE SOCKET CONNECTION WITH PROPER ERROR HANDLING
  Future<void> connect() async {
    if (_isConnecting) {
      if (kDebugMode) {
        print("Socket connection already in progress");
      }
      return;
    }

    if (_socket != null && _socket!.connected) {
      if (kDebugMode) {
        print("Socket already connected");
      }
      return;
    }

    try {
      _isConnecting = true;
      _connectionStatus.value = "Connecting...";

      // Disconnect existing socket if any
      await disconnect();

      if (kDebugMode) {
        print("🔌 Socket connection initiated to: https://qareeb.modwir.com");
      }

      _socket = IO.io('https://qareeb.modwir.com', <String, dynamic>{
        'autoConnect': false,
        'transports': ['websocket', 'polling'], // Added polling as fallback
        'timeout': 30000,
        'forceNew': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
        'extraHeaders': {
          'Accept': '*/*',
          'User-Agent': 'QareebApp/1.0',
        },
      });

      // Set up all event listeners before connecting
      _setupAllListeners();

      // Connect with timeout
      _socket!.connect();

      // Wait for connection with timeout
      await _waitForConnection();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Socket connection error: $e");
      }
      _connectionStatus.value = "Error: ${e.toString()}";
      _isConnected.value = false;
    } finally {
      _isConnecting = false;
    }
  }

  // ✅ WAIT FOR CONNECTION WITH TIMEOUT
  Future<void> _waitForConnection() async {
    int attempts = 0;
    const maxAttempts = 10; // 10 seconds timeout

    while (!_isConnected.value && attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 1));
      attempts++;

      if (kDebugMode) {
        print("Waiting for connection... attempt $attempts/$maxAttempts");
      }
    }

    if (!_isConnected.value) {
      throw Exception("Connection timeout after ${maxAttempts} seconds");
    }
  }

  // ✅ SETUP ALL EVENT LISTENERS
  void _setupAllListeners() {
    if (_socket == null) return;

    // Connection events
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

    _socket!.onDisconnect((reason) {
      _isConnected.value = false;
      _connectionStatus.value = "Disconnected: $reason";
      if (kDebugMode) {
        print("🔌 Socket disconnected: $reason");
      }

      // Auto-reconnect for certain disconnect reasons
      if (reason == 'io server disconnect' || reason == 'transport close') {
        if (kDebugMode) {
          print("🔄 Attempting auto-reconnect...");
        }
        Future.delayed(const Duration(seconds: 3), () {
          if (!_isConnected.value) {
            connect();
          }
        });
      }
    });

    _socket!.onError((error) {
      if (kDebugMode) {
        print("❌ Socket error: $error");
      }
      _connectionStatus.value = "Error: $error";
    });

    _socket!.onReconnect((data) {
      _isConnected.value = true;
      _connectionStatus.value = "Reconnected";
      if (kDebugMode) {
        print("🔄 Socket reconnected: $data");
      }
    });

    _socket!.onReconnectAttempt((data) {
      if (kDebugMode) {
        print("🔄 Socket reconnection attempt: $data");
      }
      _connectionStatus.value = "Reconnecting... ($data)";
    });

    _socket!.onReconnectError((data) {
      if (kDebugMode) {
        print("❌ Socket reconnect error: $data");
      }
    });

    _socket!.onReconnectFailed((data) {
      if (kDebugMode) {
        print("❌ Socket reconnect failed: $data");
      }
      _connectionStatus.value = "Reconnection failed";
    });
  }

  // ✅ LISTEN TO SPECIFIC EVENTS
  void on(String event, Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on(event, callback);
      if (kDebugMode) {
        print("📡 Listening to event: $event");
      }
    } else {
      if (kDebugMode) {
        print("⚠️ Cannot listen to '$event' - socket not initialized");
      }
    }
  }

  // ✅ EMIT EVENTS
  void emit(String event, [dynamic data]) {
    if (_socket != null && _isConnected.value) {
      _socket!.emit(event, data);
      if (kDebugMode) {
        print("📤 Emitted event: $event with data: $data");
      }
    } else {
      if (kDebugMode) {
        print("⚠️ Cannot emit '$event' - socket not connected");
      }
    }
  }

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

  // ✅ DISCONNECT SOCKET
  Future<void> disconnect() async {
    if (_socket != null) {
      if (kDebugMode) {
        print("🔌 Disconnecting socket...");
      }

      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    _isConnected.value = false;
    _connectionStatus.value = "Disconnected";
    _isConnecting = false;
  }

  // ✅ RECONNECT
  Future<void> reconnect() async {
    if (kDebugMode) {
      print("🔄 Manual reconnect requested");
    }

    await disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect();
  }

  // ✅ CHECK CONNECTION STATUS
  bool get isSocketConnected {
    return _socket != null && _socket!.connected && _isConnected.value;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
