// lib/app/bindings/initial_binding.dart - FIXED VERSION
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/controllers/app_controller.dart';
import 'package:qareeb/services/socket_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    if (kDebugMode) {
      print("🔧 InitialBinding: Starting dependency injection...");
    }

    // ✅ Initialize ONLY core services during app startup
    // Other controllers will be initialized when needed

    // Core app controller
    Get.put<AppController>(
      AppController(),
      permanent: true,
    );

    if (kDebugMode) {
      print("✅ AppController initialized");
    }

    // Socket service (but don't connect yet)
    Get.put<SocketService>(
      SocketService(),
      permanent: true,
    );

    if (kDebugMode) {
      print("✅ SocketService initialized (not connected)");
    }

    if (kDebugMode) {
      print("🔧 InitialBinding: Core dependencies ready");
    }
  }
}
