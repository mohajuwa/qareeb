//  lib/services/running_ride_monitor.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qareeb/app_screen/map_screen.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';
import '../api_code/home_controller.dart';
import '../app_screen/driver_list_screen.dart';
import '../app_screen/home_screen.dart';
import '../common_code/config.dart';

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

  // Initialize monitoring when app starts
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;

    if (kDebugMode) print("🚗 Starting running ride monitor...");

    // Check immediately
    _checkRunningRide();

    // Then check every 5 seconds
    _monitorTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
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

    if (kDebugMode) print("🛑 Stopped running ride monitor");
  }

  void _checkRunningRide() {
    try {
      final homeController = Get.find<HomeApiController>();

      // Check if we have home API data
      if (homeController.homeapimodel?.runnigRide?.isEmpty != false) {
        return;
      }

      final runningRide = homeController.homeapimodel!.runnigRide![0];
      final currentRideId = runningRide.id?.toString();
      final currentBiddingStatus = runningRide.biddingStatus;
      final currentBiddingRunStatus = runningRide.biddingRunStatus;
      final rideStatus = runningRide.status;

      if (kDebugMode) {
        print("🔍 Monitoring ride: $currentRideId");
        print("   biddingStatus: $currentBiddingStatus");
        print("   biddingRunStatus: $currentBiddingRunStatus");
        print("   status: $rideStatus");
      }

      // Check if we should force display DriverListScreen
      if (_shouldForceDisplayDriverList(runningRide)) {
        _forceDisplayDriverList(runningRide);
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

    // 2. Bidding must be in active states
    final biddingStatus = runningRide.biddingStatus?.toLowerCase();
    final rideStatus = runningRide.status?.toLowerCase();

    // Force display if:
    // - Bidding is pending/active
    // - Ride is not yet accepted by driver
    // - Status indicates waiting for driver response

    final shouldDisplay = (biddingStatus == "pending" ||
            biddingStatus == "active" ||
            biddingStatus == "waiting" ||
            rideStatus == "pending" ||
            rideStatus == "waiting" ||
            rideStatus == "0" ||
            rideStatus == "1") &&
        (rideStatus != "accepted" &&
            rideStatus != "completed" &&
            rideStatus != "cancelled" &&
            rideStatus != "2" &&
            rideStatus != "3" &&
            rideStatus != "4" &&
            rideStatus != "5");

    if (kDebugMode && shouldDisplay) {
      print("🚨 Should force display DriverListScreen");
    }

    return shouldDisplay;
  }

  void _forceDisplayDriverList(dynamic runningRide) {
    if (!Get.context!.mounted) return;

    // Check if DriverListScreen is already displayed
    if (Get.currentRoute.contains('DriverListScreen')) {
      if (kDebugMode) print("DriverListScreen already displayed");
      return;
    }

    if (kDebugMode) print("🔄 Force displaying DriverListScreen...");

    // Restore ride data to global variables
    _restoreRideData(runningRide);

    // Navigate to DriverListScreen
    Get.to(() => const DriverListScreen());

    // Emit socket to load bidding data
    _loadBiddingData(runningRide);
  }

  void _restoreRideData(dynamic runningRide) {
    try {
      // Restore global variables
      request_id = runningRide.id.toString();

      pickupcontroller.text = runningRide.pickAdd?.title?.toString() ?? "";
      dropcontroller.text = runningRide.dropAdd?.title?.toString() ?? "";

      if (runningRide.pickLatlon != null) {
        latitudepick =
            double.parse(runningRide.pickLatlon!.latitude.toString());
        longitudepick =
            double.parse(runningRide.pickLatlon!.longitude.toString());
      }

      if (runningRide.dropLatlon != null) {
        latitudedrop =
            double.parse(runningRide.dropLatlon!.latitude.toString());
        longitudedrop =
            double.parse(runningRide.dropLatlon!.longitude.toString());
      }

      maximumfare = runningRide.maximumFare;
      minimumfare = runningRide.minimumFare;
      dropprice = runningRide.price?.toString() ?? "0";
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
        print("📡 Emitted load_bidding_data:");
        print("   uid: $useridgloable");
        print("   request_id: ${runningRide.id}");
        print("   d_id: ${runningRide.dId}");
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
      };
    } catch (e) {
      return {"hasRide": false, "error": e.toString()};
    }
  }
}
