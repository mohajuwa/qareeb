//  lib/services/running_ride_monitor.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/app_screen/map_screen.dart';
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

      // Check if we have home API data
      if (homeController.homeapimodel?.runnigRide![0].biddingRunStatus == 0) {
        // Reset display flag when no ride
        _hasDisplayedDriverList = false;
        return;
      }

      final runningRide = homeController.homeapimodel!.runnigRide![0];
      final currentRideId = runningRide.id?.toString();
      final currentBiddingStatus = runningRide.biddingStatus;
      final currentBiddingRunStatus = runningRide.biddingRunStatus;
      final rideStatus = runningRide.status;

      // Only log when status changes to reduce console spam
      bool statusChanged = currentRideId != _lastRideId ||
          currentBiddingStatus != _lastBiddingStatus ||
          currentBiddingRunStatus != _lastBiddingRunStatus;

      if (kDebugMode && statusChanged) {
        print("🔍 Ride status changed:");
        print("   ID: $currentRideId (was: $_lastRideId)");
        print(
            "   biddingStatus: $currentBiddingStatus (was: $_lastBiddingStatus)");
        print(
            "   biddingRunStatus: $currentBiddingRunStatus (was: $_lastBiddingRunStatus)");
        print("   status: $rideStatus");
      }

      // Check if we should force display DriverListScreen
      if (_shouldForceDisplayDriverList(runningRide)) {
        if (!_hasDisplayedDriverList) {
          _forceDisplayDriverList(runningRide);
          _hasDisplayedDriverList = true;
        }
      } else {
        // Reset flag when conditions no longer met
        _hasDisplayedDriverList = false;
      }

      // Update tracking variables
      _lastRideId = currentRideId;
      _lastBiddingStatus = currentBiddingStatus;
      _lastBiddingRunStatus = currentBiddingRunStatus;
    } catch (e) {
      if (kDebugMode) print("Monitor error: $e");
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
