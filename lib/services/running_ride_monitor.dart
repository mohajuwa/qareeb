//  lib/services/running_ride_monitor.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/app_screen/map_screen.dart';
import 'package:qareeb/app_screen/my_ride_screen.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';
import '../api_code/home_controller.dart';
import '../app_screen/driver_list_screen.dart';
import '../app_screen/home_screen.dart';

class RunningRideMonitor {
  static RunningRideMonitor? _instance;
  static RunningRideMonitor get instance =>
      _instance ??= RunningRideMonitor._();

  RunningRideMonitor._();

  Timer? _monitorTimer;
  bool _isMonitoring = false;
  String? _lastRideId;
  String? _lastBiddingStatus;
  int? _lastBiddingRunStatus;
  bool _hasDisplayedDriverList = false; // Prevent multiple navigations
  bool _hasDisplayedMyRide = false; // Add flag for MyRideScreen

  // Initialize monitoring when app starts
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _hasDisplayedDriverList = false;

    if (kDebugMode) print("🚗 Starting running ride monitor...");

    // Check immediately
    _checkRunningRide();

    // Increase interval to reduce performance impact
    _monitorTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      _checkRunningRide();
    });
  }

  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _isMonitoring = false;
    _lastRideId = null;
    _lastBiddingStatus = null;
    _lastBiddingRunStatus = null;
    _hasDisplayedDriverList = false;

    if (kDebugMode) print("🛑 Stopped running ride monitor");
  }

  void _checkRunningRide() {
    try {
      final homeController = Get.find<HomeApiController>();

      if (homeController.homeapimodel?.runnigRide![0].biddingRunStatus == 0) {
        _hasDisplayedDriverList = false;
        _hasDisplayedMyRide = false; // Reset both flags
        return;
      }

      final runningRide = homeController.homeapimodel!.runnigRide![0];
      final currentRideId = runningRide.id?.toString();
      final currentBiddingStatus = runningRide.biddingStatus;
      final currentBiddingRunStatus = runningRide.biddingRunStatus;
      final rideStatus = runningRide.status;

      // Check if we should force display DriverListScreen
      if (_shouldForceDisplayDriverList(runningRide)) {
        if (!_hasDisplayedDriverList) {
          _forceDisplayDriverList(runningRide);
          _hasDisplayedDriverList = true;
        }
      }
      // Check if we should force display MyRideScreen for accepted rides
      else if (_shouldForceDisplayMyRide(runningRide)) {
        if (!_hasDisplayedMyRide) {
          _forceDisplayMyRide(runningRide);
          _hasDisplayedMyRide = true;
        }
      } else {
        _hasDisplayedDriverList = false;
        _hasDisplayedMyRide = false;
      }

      // Update tracking variables...
    } catch (e) {
      if (kDebugMode) print("Monitor error: $e");
    }
  }

  bool _shouldForceDisplayMyRide(dynamic runningRide) {
    // Conditions to force display MyRideScreen:

    // 1. Must have active ride
    if (runningRide.biddingRunStatus == null ||
        runningRide.biddingRunStatus == 0) {
      return false;
    }

    // 2. Request must be accepted (status 1 or higher, but not completed)
    if (runningRide.status == null || runningRide.status == "0") {
      return false; // Still pending
    }

    // 3. Don't display if already on MyRideScreen or ride-related screens
    final currentRoute = Get.currentRoute;
    if (currentRoute.contains('MyRideScreen') ||
        currentRoute.contains('MapScreen') ||
        currentRoute.contains('DriverStartrideScreen') ||
        currentRoute.contains('RideCompletePaymentScreen')) {
      return false;
    }

    // 4. Status should be between 1-8 (accepted but not completed)
    final statusInt = int.tryParse(runningRide.status.toString()) ?? 0;
    if (statusInt < 1 || statusInt >= 9) {
      return false;
    }

    return true;
  }

  void _forceDisplayMyRide(dynamic runningRide) {
    try {
      if (kDebugMode) {
        print("🚗 Forcing display of MyRideScreen for accepted ride");
      }

      // Set global variables needed for MyRideScreen
      request_id = runningRide.id?.toString() ?? "0";
      driver_id = runningRide.acceptedDriverId?.toString() ??
          "0"; // Adjust field name as needed

      // Navigate to MyRideScreen
      Get.offAll(
        () => const MyRideScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );

      if (kDebugMode) print("✅ Navigated to MyRideScreen successfully");
    } catch (e) {
      if (kDebugMode) print("❌ Failed to force display MyRideScreen: $e");
    }
  }

  bool _shouldForceDisplayDriverList(dynamic runningRide) {
    // Conditions to force display DriverListScreen:

    // 1. Must have bidding enabled and active
    if (runningRide.biddingRunStatus == null ||
        runningRide.biddingRunStatus == 0) {
      return false;
    }

    // 2. Bidding must be enabled
    if (runningRide.biddingStatus != "1") {
      return false;
    }

    // 3. Request must be pending (not accepted yet)
    if (runningRide.status != "0" && runningRide.status != null) {
      return false;
    }

    // 4. Must have available drivers
    try {
      List<dynamic> driverIds = runningRide.dId ?? [];
      if (driverIds.isEmpty) {
        return false;
      }
    } catch (e) {
      return false;
    }

    // 5. Don't display if already on DriverListScreen
    if (Get.currentRoute.contains('DriverListScreen')) {
      return false;
    }

    return true;
  }

  void _forceDisplayDriverList(dynamic runningRide) {
    try {
      if (kDebugMode) print("🚀 Forcing display of DriverListScreen");

      // Restore the ride data to global variables
      _restoreRideData(runningRide);

      // Load bidding data
      _loadBiddingData(runningRide);

      // Navigate to DriverListScreen with proper cleanup
      Get.offAll(
        () => const DriverListScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );

      if (kDebugMode) print("✅ Navigated to DriverListScreen successfully");
    } catch (e) {
      if (kDebugMode) print("❌ Failed to force display DriverListScreen: $e");
    }
  }

  void _restoreRideData(dynamic runningRide) {
    try {
      request_id = runningRide.id?.toString() ?? "0";
      priceyourfare = runningRide.price ?? 0;

      picktitle = runningRide.pickAdd?.title?.toString() ?? "";
      picksubtitle = runningRide.pickAdd?.subtitle?.toString() ?? "";
      droptitle = runningRide.dropAdd?.title?.toString() ?? "";
      dropsubtitle = runningRide.dropAdd?.subtitle?.toString() ?? "";

      tot_hour = runningRide.totHour?.toString() ?? "0";
      tot_time = runningRide.totMinute?.toString() ?? "0";

      if (kDebugMode) print("✅ Restored ride data for request_id: $request_id");
    } catch (e) {
      if (kDebugMode) print("Error restoring ride data: $e");
    }
  }

  void _loadBiddingData(dynamic runningRide) {
    try {
      // Emit socket to load current bidding data
      socket.emit('load_bidding_data', {
        'uid': useridgloable,
        'request_id': runningRide.id.toString(),
        'd_id': runningRide.dId ?? []
      });

      if (kDebugMode) {
        print("📡 Emitted load_bidding_data for request: ${runningRide.id}");
      }
    } catch (e) {
      if (kDebugMode) print("Error loading bidding data: $e");
    }
  }

  // Manual check method for specific scenarios
  void checkNow() {
    if (kDebugMode) print("🔍 Manual running ride check...");
    _checkRunningRide();
  }

  // Reset display flag for new requests
  void resetDisplayFlag() {
    _hasDisplayedDriverList = false;
    if (kDebugMode) print("🔄 Reset display flag");
  }

  // Check if currently has active bidding
  bool get hasActiveBidding {
    try {
      final homeController = Get.find<HomeApiController>();
      if (homeController.homeapimodel?.runnigRide?.isEmpty != false) {
        return false;
      }

      final runningRide = homeController.homeapimodel!.runnigRide![0];
      return _shouldForceDisplayDriverList(runningRide);
    } catch (e) {
      return false;
    }
  }

  // Get current ride status for debugging
  Map<String, dynamic> get currentRideStatus {
    try {
      final homeController = Get.find<HomeApiController>();
      if (homeController.homeapimodel?.runnigRide?.isEmpty != false) {
        return {"hasRide": false};
      }

      final runningRide = homeController.homeapimodel!.runnigRide![0];
      return {
        "hasRide": true,
        "rideId": runningRide.id?.toString(),
        "biddingStatus": runningRide.biddingStatus,
        "biddingRunStatus": runningRide.biddingRunStatus,
        "status": runningRide.status,
        "shouldForceDisplay": _shouldForceDisplayDriverList(runningRide),
        "hasDisplayed": _hasDisplayedDriverList,
      };
    } catch (e) {
      return {"hasRide": false, "error": e.toString()};
    }
  }
}
