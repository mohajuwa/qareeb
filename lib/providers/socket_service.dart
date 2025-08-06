import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;
  bool _isInitialized = false;

  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;
  IO.Socket? get socket => _socket;

  Future<void> initializeSocket() async {
    if (_isInitialized) return;

    _socket = IO.io('https://qareeb.modwir.com', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
      'extraHeaders': {'Accept': '*/*'},
      'timeout': 30000,
      'forceNew': true,
    });

    _socket!.onConnect((_) {
      _isConnected = true;
      _isInitialized = true;
      notifyListeners();
      if (kDebugMode) print('Socket connected successfully');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      notifyListeners();
      if (kDebugMode) print('Socket disconnected');
    });

    _socket!.connect();
  }

  void emit(String event, Map<String, dynamic> data) {
    if (_socket?.connected == true) {
      _socket!.emit(event, data);
    } else {
      if (kDebugMode) print('Socket not connected, cannot emit: $event');
    }
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void disconnect() {
    _socket?.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}
