// lib/common_code/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

class SocketService extends GetxController {
  static SocketService get instance => Get.find<SocketService>();

  IO.Socket? _socket;
  IO.Socket get socket => _socket!;

  bool get isConnected => _socket?.connected ?? false;

  void initSocket() {
    if (_socket != null && _socket!.connected) {
      print('Socket already connected');
      return;
    }

    _socket = IO.io('https://qareeb.modwir.com', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
      'extraHeaders': {'Accept': '*/*'},
      'timeout': 30000,
      'forceNew': true,
    });

    _setupEventHandlers();
  }

  void initializeSocket() {
    initSocket(); // Call your existing method
  }

  void _setupEventHandlers() {
    _socket?.onConnect((_) {
      print('Socket connected successfully');
    });

    _socket?.onConnectError((data) {
      print('Socket connection error: $data');
    });

    _socket?.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket?.onError((error) {
      print('Socket error: $error');
    });
  }

  void connect() {
    if (_socket == null) {
      initSocket();
    }
    _socket?.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void emit(String event, dynamic data) {
    if (isConnected) {
      _socket?.emit(event, data);
    } else {
      print('Socket not connected, cannot emit: $event');
    }
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
