import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends ChangeNotifier {
  static SocketService? _instance;

  // ADD THIS GETTER:
  static SocketService get instance {
    _instance ??= SocketService();
    return _instance!;
  }

  IO.Socket? _socket;
  bool _isConnected = false;
  bool _isInitialized = false;

  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;
  IO.Socket? get socket => _socket;

  // ADD CONNECT METHOD:
  void connect() {
    if (_socket == null) {
      initSocket();
    }
    _socket?.connect();
  }

  // EXISTING initSocket method stays the same
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

  void _setupEventHandlers() {
    _socket?.onConnect((_) {
      _isConnected = true;
      _isInitialized = true;
      notifyListeners();
      if (kDebugMode) print('Socket connected successfully');
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      notifyListeners();
      if (kDebugMode) print('Socket disconnected');
    });

    _socket?.onConnectError((data) {
      print('Socket connection error: $data');
    });

    _socket?.onError((error) {
      print('Socket error: $error');
    });
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

  void off(String event) {
    _socket?.off(event);
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
