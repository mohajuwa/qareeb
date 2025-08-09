// ✅ MIGRATED - Counter Bottom Sheet with Provider State Management
// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/common_code/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';

// ✅ PROVIDER IMPORTS
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';
import 'package:qareeb/providers/timer_state.dart';
import 'package:qareeb/providers/pricing_state.dart';

import '../api_code/add_vehical_api_controller.dart';
import '../api_code/remove_request.dart';
import '../api_code/resend_request_api_controller.dart';
import '../api_code/timeout_request_api_controller.dart';
import '../api_code/vihical_calculate_api_controller.dart';
import '../api_code/global_driver_access_api_controller.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';
import '../common_code/common_flow_screen.dart';
import '../common_code/config.dart';
import 'home_screen.dart';

class CounterBottomSheet extends StatefulWidget {
  const CounterBottomSheet({
    super.key,
  });

  @override
  State<CounterBottomSheet> createState() => _CounterBottomSheetState();
}

class _CounterBottomSheetState extends State<CounterBottomSheet> {
  // ✅ MIGRATED - Local state variables
  List<double> percentValue = [];
  int currentStoryIndex = 0;
  int durationn = 180; // 3 minutes timer
  Timer? _progressTimer;

  // ✅ MIGRATED - User data variables
  var decodeUid;
  var userid;
  var currencyy;

  // ✅ MIGRATED - GetX controllers for API calls
  TimeoutRequestApiController timeoutRequestApiController =
      Get.put(TimeoutRequestApiController());
  ResendRequestApiController resendRequestApiController =
      Get.put(ResendRequestApiController());
  VihicalCalculateController vihicalCalculateController =
      Get.put(VihicalCalculateController());
  AddVihicalCalculateController addVihicalCalculateController =
      Get.put(AddVihicalCalculateController());
  RemoveRequest removeRequest = Get.put(RemoveRequest());
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());

  // ✅ MIGRATED - Provider for UI theming
  ColorNotifier notifier = ColorNotifier();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeSocket();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProgressTracking();
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    SocketService.instance.disconnect();
    super.dispose();
  }

  // ✅ MIGRATED - Initialize user data
  Future<void> _initializeData() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var uid = preferences.getString("userLogin");
      var currency = preferences.getString("currenci");

      if (uid != null && currency != null) {
        decodeUid = jsonDecode(uid);
        currencyy = jsonDecode(currency);
        userid = decodeUid['id'];

        if (kDebugMode) {
          print("✅ CounterBottomSheet data initialized:");
          print("User ID: $userid");
          print("Currency: $currencyy");
        }
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error initializing data: $e");
    }
  }

  // ✅ MIGRATED - Socket initialization using SocketService
  void _initializeSocket() {
    try {
      if (!SocketService.instance.isConnected) {
        SocketService.instance.connect();
      }
      _setupSocketListeners();
    } catch (e) {
      if (kDebugMode) print("❌ Socket initialization error: $e");
    }
  }

  // ✅ MIGRATED - Socket event listeners for ride request updates
  void _setupSocketListeners() {
    final socketService = SocketService.instance;

    // Listen for driver response updates
    socketService.on('driver_response_update$userid', (data) {
      _handleDriverResponse(data);
    });

    // Listen for request timeout updates
    socketService.on('request_timeout$userid', (data) {
      _handleRequestTimeout(data);
    });

    // Listen for ride request status changes
    socketService.on('ride_request_status$userid', (data) {
      _handleRideRequestStatus(data);
    });

    if (kDebugMode) print("✅ Socket listeners setup for CounterBottomSheet");
  }

  // ✅ NEW - Socket event handlers
  void _handleDriverResponse(dynamic data) {
    if (!mounted) return;

    try {
      if (kDebugMode) print("🚗 Driver response received: $data");

      if (data['status'] == 'accepted') {
        _progressTimer?.cancel();
        Get.back(); // Close the counter bottom sheet

        // Navigate to driver detail screen or update state
        context.read<RideRequestState>().updateAcceptedDriver(data);
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling driver response: $e");
    }
  }

  void _handleRequestTimeout(dynamic data) {
    if (!mounted) return;

    try {
      if (kDebugMode) print("⏰ Request timeout received: $data");

      _progressTimer?.cancel();
      _handleTimeoutCompletion();
    } catch (e) {
      if (kDebugMode) print("❌ Error handling request timeout: $e");
    }
  }

  void _handleRideRequestStatus(dynamic data) {
    if (!mounted) return;

    try {
      if (kDebugMode) print("📊 Ride request status update: $data");

      context.read<RideRequestState>().updateFromVehicleBidding(data);
    } catch (e) {
      if (kDebugMode) print("❌ Error handling ride request status: $e");
    }
  }

  // ✅ MIGRATED - Initialize progress tracking with provider state
  void _initializeProgressTracking() {
    percentValue.clear();
    for (int i = 0; i < 4; i++) {
      percentValue.add(0);
    }
    currentStoryIndex = 0;

    // Initialize timer state in provider
    context.read<TimerState>().initializeController(durationn ~/ 1000);

    _startProgressAnimation();
  }

  // ✅ MIGRATED - Progress animation with provider integration
  void _startProgressAnimation() {
    if (!mounted) return;

    _progressTimer = Timer.periodic(Duration(milliseconds: durationn), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (percentValue[currentStoryIndex] + 0.1 < 1) {
          percentValue[currentStoryIndex] += 0.01;
        } else {
          percentValue[currentStoryIndex] = 1;
          timer.cancel();

          if (currentStoryIndex < 3) {
            // 4 - 1
            currentStoryIndex++;
            _startProgressAnimation(); // Restart for next progress bar
          } else {
            _handleTimeoutCompletion();
          }
        }
      });
    });
  }

  // ✅ MIGRATED - Handle timeout completion with provider state
  void _handleTimeoutCompletion() {
    if (!mounted) return;

    try {
      Get.back(); // Close bottom sheet

      // Reset progress tracking
      percentValue.clear();
      for (int i = 0; i < 4; i++) {
        percentValue.add(0);
      }
      currentStoryIndex = 0;

      // Call timeout API and emit socket event
      if (userid != null) {
        timeoutRequestApiController
            .timeoutrequestApi(
          uid: userid.toString(),
          request_id: globalDriverAcceptClass.request_id.isNotEmpty
              ? globalDriverAcceptClass.request_id
              : request_id,
        )
            .then((value) {
          if (kDebugMode) {
            print("✅ Timeout API response: $value");
            print("Driver IDs: ${value["driverid"]}");
          }

          // Emit timeout socket event using SocketService
          final socketService = SocketService.instance;
          socketService.emit('RequestTimeOut', {
            'requestid': globalDriverAcceptClass.request_id.isNotEmpty
                ? globalDriverAcceptClass.request_id
                : request_id,
            'uid': useridgloable,
            'driverid': value["driverid"] ?? [],
          });

          // Update provider state
          context.read<RideRequestState>().handleTimeout({
            'status': 'timeout',
            'message': 'No drivers responded to your request'
          });

          if (kDebugMode) print("📤 RequestTimeOut event emitted");
        });
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling timeout completion: $e");
    }
  }

  // ✅ MIGRATED - Resend request with provider state
  void _handleResendRequest() {
    if (userid == null) return;

    // Get driver list from VihicalCalculateController which has the driverId list
    List<dynamic> driverList =
        vihicalCalculateController.vihicalCalculateModel?.driverId ?? [];

    resendRequestApiController
        .resendrequestApi(
      uid: userid.toString(),
      driverid: driverList,
    )
        .then((value) {
      if (kDebugMode) {
        print("✅ Resend request API response: $value");
        print("Driver list: ${value["driver_list"]}");
      }

      Get.back(); // Close current bottom sheet

      // Emit vehicle request using SocketService
      final socketService = SocketService.instance;
      socketService.emit('vehiclerequest', {
        'requestid':
            addVihicalCalculateController.addVihicalCalculateModel?.id ??
                globalDriverAcceptClass.request_id,
        'driverid': value["driver_list"] ?? [],
        'c_id': useridgloable
      });

      // Show common bottom sheet flow
      commonbottomsheetflow(context: context);

      if (kDebugMode) print("📤 Vehicle request resent");
    });
  }

  // ✅ MIGRATED - Cancel request with provider state cleanup
  void _handleCancelRequest() {
    if (userid == null) return;

    removeRequest
        .removeApi(
      uid: userid.toString(),
      context: context,
    )
        .then((value) {
      if (kDebugMode) print("✅ Request cancelled: $value");

      Get.back(); // Close bottom sheet

      // Clear provider states
      context.read<RideRequestState>().clearRideRequest();
      context.read<LocationState>().clearLocationData();
      context.read<PricingState>().clearPricingData();
      context.read<TimerState>().disposeController();

      if (kDebugMode) print("🧹 Provider states cleared");
    });
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    // ✅ MIGRATED - Wrap with Consumer for provider state management
    return Consumer3<RideRequestState, TimerState, LocationState>(
      builder: (context, rideRequestState, timerState, locationState, child) {
        return Container(
          height: Get.height * 0.7,
          width: Get.width,
          decoration: BoxDecoration(
            color: notifier.containercolore,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ KEEP - Header with progress indicators
                Row(
                  children: [
                    for (int i = 0; i < 4; i++)
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < 3 ? 5 : 0),
                          height: 4,
                          child: LinearPercentIndicator(
                            padding: EdgeInsets.zero,
                            lineHeight: 4,
                            percent:
                                i < percentValue.length ? percentValue[i] : 0.0,
                            backgroundColor: Colors.grey.shade300,
                            progressColor: currentStoryIndex == i
                                ? theamcolore
                                : (i < currentStoryIndex
                                    ? theamcolore
                                    : Colors.grey.shade300),
                            barRadius: const Radius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // ✅ KEEP - Title
                Text(
                  "Looking for nearby drivers...".tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: notifier.textColor,
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ MIGRATED - Status text with provider state
                Text(
                  rideRequestState.status.isEmpty
                      ? "Please wait while we find the best driver for you.".tr
                      : "Status: ${rideRequestState.status}".tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 30),

                // ✅ KEEP - Loading animation
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(theamcolore),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Searching for drivers...".tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: notifier.textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ✅ MIGRATED - Action buttons
                Column(
                  children: [
                    // Try Again button
                    CommonButton(
                      onPressed1: _handleResendRequest,
                      txt1: "Try Again".tr,
                      containcolore: theamcolore,
                      context: context,
                    ),
                    const SizedBox(height: 10),

                    // Cancel button
                    CommonOutLineButton(
                      bordercolore: theamcolore,
                      onPressed1: _handleCancelRequest,
                      txt1: "Cancel".tr,
                      context: context,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
