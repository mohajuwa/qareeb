//  lib/services/running_ride_monitor.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qareeb/app_screen/map_screen.dart';
import 'package:qareeb/app_screen/my_ride_screen.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';
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
  bool _hasShownRideAlert = false; // Prevent multiple ride alerts

  // Initialize monitoring when app starts
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _hasDisplayedDriverList = false;
    _hasDisplayedDriverDetail = false;
    _hasShownRideAlert = false;

    // Clear any stale ride data from previous sessions
    if (kDebugMode) print("🔧 Clearing stale ride data on monitor start");
    request_id = "0";
    driver_id = "0";

    if (kDebugMode) print("🚗 Starting running ride monitor...");

    // Check every 20 seconds
    _monitorTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
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
    _hasShownRideAlert = false;

    if (kDebugMode) print("🛑 Stopped running ride monitor");
  }

  void _checkRunningRide() {
    try {
      if (kDebugMode) print("🔍 RunningRideMonitor: Starting check...");

      Get.put(HomeApiController());
      final homeController = Get.find<HomeApiController>();

      if (kDebugMode) {
        print(
            "🔍 HomeController found: ${homeController.homeapimodel != null}");
      }

      // STEP 1: Check for pending rides with bidding (ONLY uses homeapimodel data)
      if (homeController.homeapimodel?.runnigRide != null &&
          homeController.homeapimodel!.runnigRide!.isNotEmpty) {
        final runningRide = homeController.homeapimodel!.runnigRide![0];

        if (kDebugMode) {
          print("🔍 Found ride in homeapimodel:");
          print("   ID: ${runningRide.id}");
          print("   Status: ${runningRide.status}");
          print("   Bidding Status: ${runningRide.biddingStatus}");
          print("   Bidding Run Status: ${runningRide.biddingRunStatus}");
        }

        // Check for active bidding scenario
        if (_shouldForceDisplayDriverList(runningRide) &&
            !_hasDisplayedDriverList) {
          if (kDebugMode) {
            print("🚗 Active bidding detected, navigating to DriverListScreen");
          }

          _restoreRideDataFromHomeModel(runningRide);
          _loadBiddingDataFromHomeModel(runningRide);

          Get.offAll(
            () => const DriverListScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 300),
          );

          _hasDisplayedDriverList = true;
          _hasDisplayedDriverDetail = false; // Reset other flag

          // Update tracking variables
          _lastRideId = runningRide.id?.toString();
          _lastBiddingStatus = runningRide.biddingStatus;
          _lastBiddingRunStatus = runningRide.biddingRunStatus;

          if (kDebugMode) {
            print("✅ Navigated to DriverListScreen from homeapimodel");
          }
          return; // Exit early to avoid checking API
        }
      } else {
        if (kDebugMode) {
          print(
              "🔍 No pending rides in homeapimodel - checking for active rides via API");
        }
      }

      // STEP 2: Check for active accepted rides via separate API call
      _checkForActiveRideViaApi();
    } catch (e) {
      if (kDebugMode) print("Error in _checkRunningRide: $e");
    }
  }

  bool _shouldForceDisplayDriverList(dynamic runningRide) {
    try {
      final rideId = runningRide.id?.toString();
      final biddingStatus = runningRide.biddingStatus;
      final biddingRunStatus = runningRide.biddingRunStatus;

      if (rideId == null) return false;

      // Check for changes that should trigger navigation
      bool hasNewRide = _lastRideId != rideId;
      bool hasBiddingStatusChange = _lastBiddingStatus != biddingStatus;
      bool hasBiddingRunStatusChange =
          _lastBiddingRunStatus != biddingRunStatus;

      bool shouldDisplay =
          hasNewRide || hasBiddingStatusChange || hasBiddingRunStatusChange;

      if (kDebugMode && shouldDisplay) {
        print("🔄 Changes detected for ride $rideId:");
        print("   New ride: $hasNewRide");
        print(
            "   Bidding status change: $hasBiddingStatusChange ($_lastBiddingStatus → $biddingStatus)");
        print(
            "   Bidding run status change: $hasBiddingRunStatusChange ($_lastBiddingRunStatus → $biddingRunStatus)");
      }

      return shouldDisplay;
    } catch (e) {
      if (kDebugMode) print("Error in _shouldForceDisplayDriverList: $e");
      return false;
    }
  }

  void _restoreRideDataFromHomeModel(dynamic runningRide) {
    try {
      if (kDebugMode) print("🔧 Restoring ride data from homeapimodel...");

      // Restore global ride variables from homeapimodel data
      request_id = runningRide.id?.toString() ?? "0";
      priceyourfare = runningRide.price ?? 0;

      picktitle = runningRide.pickAdd?.title?.toString() ?? "";
      picksubtitle = runningRide.pickAdd?.subtitle?.toString() ?? "";
      droptitle = runningRide.dropAdd?.title?.toString() ?? "";
      dropsubtitle = runningRide.dropAdd?.subtitle?.toString() ?? "";

      tot_hour = runningRide.totHour?.toString() ?? "0";
      tot_time = runningRide.totMinute?.toString() ?? "0";

      if (kDebugMode) {
        print(
            "✅ Restored ride data from homeapimodel for request_id: $request_id");
      }
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
  static String _actualCurrentScreen = 'MapScreen';
  static void setCurrentScreen(String screenName) {
    _actualCurrentScreen = screenName;
  }

  void _checkForActiveRideViaApi() {
    try {
      if (kDebugMode) print("🔍 Making CheckActiveRide API call");

      final checkActiveRideController = Get.put(CheckActiveRideApiController());

      if (kDebugMode) {
        print("🔍 CheckActiveRide API parameters:");
        print("   uid: $useridgloable");
      }

      // Make API call first
      checkActiveRideController
          .checkActiveRide(uid: useridgloable.toString())
          .then((response) {
        if (kDebugMode) {
          print("✅ CheckActiveRide API response received: $response");
        }

        // Only proceed if we have a successful response with active ride
        if (response["Result"] != true || response["active_ride"] == null) {
          if (kDebugMode) {
            print(
                "🔍 No active ride found or failed response, skipping route logic");
          }
          _resetFlags();
          return;
        }

        // SUCCESS RESPONSE - Now check routes and proceed with logic
        final currentRoute = Get.currentRoute;
        if (kDebugMode) print("🔍 Current route: '$currentRoute'");

        // Determine actual screen
        if (currentRoute == '' || currentRoute == '/') {
          if (request_id != null && request_id != "0") {
            if (kDebugMode)
              print("🔍 Empty route with active ride - assuming ride screen");
            _actualCurrentScreen = 'DriverDetailScreen';
          } else {
            if (kDebugMode)
              print("🔍 Empty route with no active ride - assuming MapScreen");
            _actualCurrentScreen = 'MapScreen';
          }
        } else {
          switch (currentRoute) {
            case '/MapScreen':
              _actualCurrentScreen = 'MapScreen';
              break;
            case '/MyRideScreen':
              _actualCurrentScreen = 'MyRideScreen';
              break;
            case '/DriverListScreen':
              _actualCurrentScreen = 'DriverListScreen';
              break;
            case '/RideCompletePaymentScreen':
              _actualCurrentScreen = 'RideCompletePaymentScreen';
              break;
            case '/ProfileScreen':
              _actualCurrentScreen = 'ProfileScreen';
              break;
            case '/NotificationScreen':
              _actualCurrentScreen = 'NotificationScreen';
              break;
            case '/LanguageScreen':
              _actualCurrentScreen = 'LanguageScreen';
              break;
            case '/TopUpScreen':
              _actualCurrentScreen = 'TopUpScreen';
              break;
            case '/FaqScreen':
              _actualCurrentScreen = 'FaqScreen';
              break;
            case '/ReferAndEarn':
              _actualCurrentScreen = 'ReferAndEarn';
              break;
            default:
              if (_actualCurrentScreen.isEmpty) {
                _actualCurrentScreen = 'MapScreen';
              }
              break;
          }
        }

        if (kDebugMode) print("🔍 Determined screen: '$_actualCurrentScreen'");

        // Only proceed with navigation logic if on MapScreen
        if (_actualCurrentScreen != 'MapScreen') {
          if (kDebugMode) {
            print(
                "🔍 Not on MapScreen ($_actualCurrentScreen), skipping navigation");
          }
          return;
        }

        // Reset flags when on MapScreen
        if (_hasDisplayedDriverDetail || _hasDisplayedDriverList) {
          if (kDebugMode) {
            print("🔄 On MapScreen - resetting flags to allow force display");
          }
          _resetFlags();
        }

        // Handle successful API response with active ride
        final driverDetail =
            checkActiveRideController.activeRideModel!.acceptedDDetail!;
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

          // Update screen tracker when navigating
          _actualCurrentScreen = 'MyRideScreen';

          // Navigate to MyRideScreen
          Get.offAll(
            () => const MyRideScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 300),
          );

          // Show alert after navigation
          if (!_hasShownRideAlert) {
            Future.delayed(const Duration(milliseconds: 2000), () {
              _showActiveRideAlert();
              _hasShownRideAlert = true;
            });
          }

          _hasDisplayedDriverDetail = true;
          _hasDisplayedDriverList = false;
          if (kDebugMode) {
            print("✅ Navigated to MyRideScreen from CheckActiveRide API");
          }
        } else {
          if (kDebugMode) print("🔍 Ride status not active: $statusInt");
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
    _hasShownRideAlert = false;
  }

  void _showActiveRideAlert() {
    // Show the custom notification widget overlay
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: _buildActiveRideAlert(),
      ),
      barrierDismissible: true,
    );

    if (kDebugMode) {
      print("🚨 Shown active ride alert widget to customer");
    }
  }

  Widget _buildActiveRideAlert() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.red.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Active Ride Alert".tr,
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "You have an active ride in progress.".tr,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Please finish or cancel your current ride to start a new ride."
                      .tr,
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "OK".tr,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    _hasShownRideAlert = false;
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
        "hasShownRideAlert": _hasShownRideAlert,
      };
    } catch (e) {
      return {"hasRide": false, "error": e.toString()};
    }
  }
}
