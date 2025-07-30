//  lib/common_code/socket_mixin.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'socket_service.dart';

mixin SocketMixin {
  SocketService get socketService => SocketService.instance;

  IO.Socket get socket => socketService.socket;

  void initializeSocket() {
    socketService.initSocket();

    socketService.connect();
  }

  void connectSocket() {
    socketService.connect();
  }

  void disconnectSocket() {
    socketService.disconnect();
  }

  void emitSocket(String event, dynamic data) {
    socketService.emit(event, data);
  }

  void onSocket(String event, Function(dynamic) handler) {
    socketService.on(event, handler);
  }

  void offSocket(String event) {
    socketService.off(event);
  }

  bool get isSocketConnected => socketService.isConnected;
}
