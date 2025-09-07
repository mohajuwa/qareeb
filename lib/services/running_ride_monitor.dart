//  lib/services/running_ride_monitor.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/api_code/vihical_driver_detail_api_controller.dart';
import 'package:qareeb/app_screen/map_screen.dart';
import 'package:qareeb/app_screen/my_ride_screen.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';
import 'package:qareeb/app_screen/driver_detail_screen.dart';
import '../api_code/home_controller.dart';
import '../api_code/check_active_ride_api_controller.dart';
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
  bool _hasDisplayedDriverList =
      false; // Prevent multiple navigations to DriverListScreen
  bool _hasDisplayedDriverDetail =
      false; // Prevent multiple navigations to DriverDetailScreen

  // Initialize monitoring when app starts
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _hasDisplayedDriverList = false;
    _hasDisplayedDriverDetail = false;

    if (kDebugMode) print("🚗 Starting running ride monitor...");

    // Check immediately
    _checkRunningRide();

    // Check every 8 seconds
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
    _hasDisplayedDriverDetail = false;

    if (kDebugMode) print("🛑 Stopped running ride monitor");
  }

  void _checkRunningRide() {
    try {
      if (kDebugMode) print("🔍 RunningRideMonitor: Starting check...");

      Get.put(HomeApiController());
      final homeController = Get.find<HomeApiController>();

      if (kDebugMode)
        print(
            "🔍 HomeController found: ${homeController.homeapimodel != null}");

      // STEP 1: Check for pending rides with bidding (ONLY uses homeapimodel data)
      if (homeController.homeapimodel?.runnigRide != null &&
          homeController.homeapimodel!.runnigRide!.isNotEmpty) {
        final runningRide = homeController.homeapimodel!.runnigRide![0];

        if (runningRide.biddingRunStatus != null &&
            runningRide.biddingRunStatus != 0) {
          if (_shouldForceDisplayDriverList(runningRide)) {
            if (!_hasDisplayedDriverList) {
              _forceDisplayDriverListFromHomeModel(runningRide);
              _hasDisplayedDriverList = true;
              _hasDisplayedDriverDetail = false; // Reset other flag
            }
            return; // Exit early - handling pending ride from homeapimodel
          }
        }
      }

      // STEP 2: If no pending rides in homeapimodel, check for accepted rides via CheckActiveRide API
      if (kDebugMode)
        print(
            "🔍 No pending rides in homeapimodel - checking for active rides via API");

      _checkForActiveRideViaApi();
    } catch (e) {
      if (kDebugMode) print("Monitor error: $e");
    }
  }

  // ====================================================================
  // DRIVER LIST SCREEN LOGIC - ONLY USES homeapimodel DATA
  // ====================================================================

  bool _shouldForceDisplayDriverList(dynamic runningRide) {
    // This method ONLY works with homeapimodel data

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

  void _forceDisplayDriverListFromHomeModel(dynamic runningRide) {
    try {
      if (kDebugMode)
        print("🚀 Forcing display of DriverListScreen from homeapimodel data");

      // Restore ride data from homeapimodel to global variables
      _restoreRideDataFromHomeModel(runningRide);

      // Load bidding data using homeapimodel
      _loadBiddingDataFromHomeModel(runningRide);

      // Navigate to DriverListScreen
      Get.offAll(
        () => const DriverListScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );

      if (kDebugMode)
        print("✅ Navigated to DriverListScreen from homeapimodel data");
    } catch (e) {
      if (kDebugMode) print("❌ Failed to force display DriverListScreen: $e");
    }
  }

  void _restoreRideDataFromHomeModel(dynamic runningRide) {
    try {
      // Extract data from homeapimodel for DriverListScreen
      request_id = runningRide.id?.toString() ?? "0";
      priceyourfare = runningRide.price ?? 0;

      picktitle = runningRide.pickAdd?.title?.toString() ?? "";
      picksubtitle = runningRide.pickAdd?.subtitle?.toString() ?? "";
      droptitle = runningRide.dropAdd?.title?.toString() ?? "";
      dropsubtitle = runningRide.dropAdd?.subtitle?.toString() ?? "";

      tot_hour = runningRide.totHour?.toString() ?? "0";
      tot_time = runningRide.totMinute?.toString() ?? "0";

      if (kDebugMode)
        print(
            "✅ Restored ride data from homeapimodel for request_id: $request_id");
    } catch (e) {
      if (kDebugMode) print("Error restoring ride data from homeapimodel: $e");
    }
  }

  void _loadBiddingDataFromHomeModel(dynamic runningRide) {
    try {
      // Emit socket to load current bidding data from homeapimodel
      socket.emit('load_bidding_data', {
        'uid': useridgloable,
        'request_id': runningRide.id.toString(),
        'd_id': runningRide.dId ?? []
      });

      if (kDebugMode) {
        print(
            "📡 Emitted load_bidding_data from homeapimodel for request: ${runningRide.id}");
      }
    } catch (e) {
      if (kDebugMode) print("Error loading bidding data from homeapimodel: $e");
    }
  }

  // ====================================================================
  // DRIVER DETAIL SCREEN LOGIC - USES CheckActiveRide API
  // ====================================================================

  void _checkForActiveRideViaApi() {
    try {
      // Don't make duplicate calls if we already displayed or are on ride screens
      final currentRoute = Get.currentRoute;
      if (currentRoute.contains('DriverDetailScreen') ||
          currentRoute.contains('DriverStartrideScreen') ||
          currentRoute.contains('RideCompletePaymentScreen') ||
          _hasDisplayedDriverDetail) {
        if (kDebugMode)
          print(
              "🔍 Already on ride screen or displayed DriverDetail, skipping API call");
        return;
      }

      if (kDebugMode) print("🔍 Making CheckActiveRide API call");

      final checkActiveRideController = Get.put(CheckActiveRideApiController());

      if (kDebugMode) {
        print("🔍 CheckActiveRide API parameters:");
        print("   uid: $useridgloable");
      }

      // Make API call with only user ID - this is separate from homeapimodel
      checkActiveRideController
          .checkActiveRide(
        uid: useridgloable.toString(),
      )
          .then((response) {
        if (kDebugMode)
          print("✅ CheckActiveRide API response received: $response");

        // Check if API returned active ride data
        if (checkActiveRideController.activeRideModel != null &&
            checkActiveRideController.activeRideModel!.result == true) {
          final driverDetail =
              checkActiveRideController.activeRideModel!.acceptedDDetail!;

          // Check if this is an active accepted ride (status 1-8)
          final statusInt = int.tryParse(driverDetail.status.toString()) ?? 0;
          if (statusInt >= 1 && statusInt < 9) {
            if (kDebugMode) {
              print("🚗 Found active ride via CheckActiveRide API:");
              print(
                  "   Driver: ${driverDetail.firstName} ${driverDetail.lastName}");
              print("   Status: ${driverDetail.status}");
              print("   Request ID: ${driverDetail.id}");
              print(
                  "   Location: ${driverDetail.latitude}, ${driverDetail.longitude}");
            }

            // Set global variables from API response
            request_id = driverDetail.id?.toString() ?? "0";
            driver_id = driverDetail.dId?.toString() ?? "0";

            // Navigate to DriverDetailScreen with API data
            Get.offAll(
              () => DriverDetailScreen(
                lat: double.tryParse(driverDetail.latitude ?? "0") ?? 0.0,
                long: double.tryParse(driverDetail.longitude ?? "0") ?? 0.0,
              ),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 300),
            );

            Future.delayed(const Duration(milliseconds: 300), () {
              final vihicalDriverDetailApiController =
                  Get.put(VihicalDriverDetailApiController());

              vihicalDriverDetailApiController.vihicaldriverdetailapi(
                uid: useridgloable.toString(),
                d_id: driver_id,
                request_id: request_id,
              );
            });

            _hasDisplayedDriverDetail = true;
            _hasDisplayedDriverList = false; // Reset other flag
            if (kDebugMode)
              print(
                  "✅ Navigated to DriverDetailScreen from CheckActiveRide API");
          } else {
            if (kDebugMode) print("🔍 Ride status not active: $statusInt");
            _resetFlags();
          }
        } else {
          if (kDebugMode)
            print("🔍 No active ride found via CheckActiveRide API");
          _resetFlags();
        }
      }).catchError((error) {
        if (kDebugMode) print("❌ CheckActiveRide API error: $error");
        _resetFlags();
      });
    } catch (e) {
      if (kDebugMode) print("Error in _checkForActiveRideViaApi: $e");
      _resetFlags();
    }
  }

  void _resetFlags() {
    _hasDisplayedDriverList = false;
    _hasDisplayedDriverDetail = false;
  }

  // ====================================================================
  // UTILITY METHODS
  // ====================================================================

  // Manual check method for specific scenarios
  void checkNow() {
    if (kDebugMode) print("🔍 Manual running ride check...");
    _checkRunningRide();
  }

  // Reset display flags for new requests
  void resetDisplayFlags() {
    _hasDisplayedDriverList = false;
    _hasDisplayedDriverDetail = false;
    if (kDebugMode) print("🔄 Reset all display flags");
  }

  // Check if currently has active bidding (only uses homeapimodel)
  bool get hasActiveBidding {
    try {
      Get.put(HomeApiController());
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

  // Get current ride status for debugging (only uses homeapimodel)
  Map<String, dynamic> get currentRideStatus {
    try {
      Get.put(HomeApiController());

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
        "hasDisplayedDriverList": _hasDisplayedDriverList,
        "hasDisplayedDriverDetail": _hasDisplayedDriverDetail,
      };
    } catch (e) {
      return {"hasRide": false, "error": e.toString()};
    }
  }
}
