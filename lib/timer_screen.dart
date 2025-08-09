// ✅ MIGRATED - Timer Screen with Provider State Management
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/common_code/socket_service.dart';
import 'package:qareeb/common_code/common_button.dart';

// ✅ PROVIDER IMPORTS
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';
import 'package:qareeb/providers/timer_state.dart';
import 'package:qareeb/providers/pricing_state.dart';

import 'app_screen/driver_startride_screen.dart';
import 'app_screen/home_screen.dart';
import 'app_screen/my_ride_screen.dart';
import 'app_screen/ride_complete_payment_screen.dart';
import 'common_code/common_flow_screen.dart';
import 'api_code/global_driver_access_api_controller.dart';

class TimerScreen extends StatefulWidget {
  final int hours;
  final int minutes;
  final int seconds;

  const TimerScreen({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // ✅ MIGRATED - Local state variables
  int hours1 = 0;
  int minutes1 = 0;
  int seconds1 = 0;
  int countdownStart = 0;
  int remainingTime = 0;
  Timer? timer;
  bool isExtraTimeMode = false;
  String extraStatus = "";
  bool isLoading = false;

  // ✅ ADD MISSING VARIABLES
  String statusridestart = "";
  String totaldropmint = "";
  String totaldrophoure = "";

  // ✅ MIGRATED - GetX controllers and providers
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());
  ColorNotifier notifier = ColorNotifier();

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _initializeSocket();
  }

  @override
  void dispose() {
    timer?.cancel();
    SocketService.instance.disconnect();
    super.dispose();
  }

  // ✅ MIGRATED - Initialize timer with provider state
  void _initializeTimer() {
    if (kDebugMode) {
      print("✅ Timer initialization:");
      print(
          "Hours: ${widget.hours}, Minutes: ${widget.minutes}, Seconds: ${widget.seconds}");
      print("OTP Status: $otpstatus");
    }

    hours1 = widget.hours;
    minutes1 = widget.minutes;
    seconds1 = widget.seconds;

    _calculateTotalTime();

    // Initialize timer state in provider
    context.read<TimerState>().initializeController(remainingTime);

    // Start appropriate timer based on plusetimer status
    if (plusetimer == "0") {
      _startExtraTimer();
    } else {
      _startNormalTimer();
    }
  }

  void _calculateTotalTime() {
    countdownStart = (hours1 * 3600) + (minutes1 * 60) + seconds1;
    remainingTime = countdownStart;

    if (kDebugMode) {
      print("📊 Total countdown time: $countdownStart seconds");
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

  // ✅ MIGRATED - Socket event listeners for timer updates
  void _setupSocketListeners() {
    final socketService = SocketService.instance;

    // Listen for time updates from server
    socketService.on('Vehicle_Time_update$useridgloable', (data) {
      _handleTimeUpdate(data);
    });

    // Listen for ride start/end events
    socketService.on('Vehicle_Ride_Start_End$useridgloable', (data) {
      _handleRideStartEnd(data);
    });

    if (kDebugMode) print("✅ Socket listeners setup for TimerScreen");
  }

  // ✅ NEW - Socket event handlers
  void _handleTimeUpdate(dynamic vehicleTimeUpdate) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        print("⏰ Vehicle time update received: $vehicleTimeUpdate");
        print("Time update type: ${vehicleTimeUpdate.runtimeType}");
        print("Time update keys: ${vehicleTimeUpdate.keys}");
      }

      hours1 = 0;
      minutes1 = int.parse(vehicleTimeUpdate["time"].toString());

      if (remainingTime > 0) {
        if (kDebugMode) print("🔄 Updating existing timer");
        _calculateTotalTime();
      } else {
        if (kDebugMode) print("🆕 Starting new timer");
        _calculateTotalTime();
        _startNormalTimer();
      }

      // Update provider state
      context.read<TimerState>().initializeController(remainingTime);

      if (kDebugMode) {
        print("⏱️ Total hour: $tot_hour");
        print("⏱️ Total time: $tot_time");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling time update: $e");
    }
  }

  void _handleRideStartEnd(dynamic vehicleRideStartEnd) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        print("🚗 Vehicle ride start/end received: $vehicleRideStartEnd");
        print("Ride event type: ${vehicleRideStartEnd.runtimeType}");
        print("Current user: $useridgloable");
        print("Event user: ${vehicleRideStartEnd["uid"]}");
        print("Driver ID: ${globalDriverAcceptClass.driver_id}");
      }

      // Reset status variables
      statusridestart = "";
      totaldropmint = "";
      plusetimer = "";

      if (globalDriverAcceptClass.driver_id ==
          vehicleRideStartEnd["uid"].toString()) {
        if (kDebugMode) print("✅ Ride event match - processing");

        statusridestart = vehicleRideStartEnd["status"] ?? "";
        totaldropmint = vehicleRideStartEnd["tot_min"]?.toString() ?? "";
        totaldrophoure = vehicleRideStartEnd["tot_hour"]?.toString() ?? "";

        if (kDebugMode) {
          print("📊 Ride status: $statusridestart");
          print("📊 Total minutes: $totaldropmint");
          print("📊 Total hours: $totaldrophoure");
        }

        // Update provider states
        context.read<RideRequestState>().updateFromVehicleBidding({
          'status': statusridestart,
          'total_minutes': totaldropmint,
          'total_hours': totaldrophoure,
        });

        // Handle different ride statuses
        if (statusridestart == "completed") {
          _handleRideCompletion();
        } else if (statusridestart == "started") {
          _handleRideStart();
        }
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling ride start/end: $e");
    }
  }

  // ✅ MIGRATED - Timer functions with provider integration
  void _startNormalTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (remainingTime > 0) {
          if (otpstatus == true) {
            timer.cancel();
          } else {
            remainingTime--;
          }

          if (kDebugMode) print("⏰ Remaining time: $remainingTime");
        } else {
          if (kDebugMode) print("⏰ Timer completed");

          timer.cancel();

          if (timeincressstatus == "2") {
            _startExtraTimer();
          } else {
            _emitTimeRequest();
            timer.cancel();
          }
        }
      });
    });
  }

  void _startExtraTimer() {
    timer?.cancel();

    setState(() {
      isLoading = true;
      isExtraTimeMode = true;
      extraStatus = "Time's up. Extra charges apply";
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (remainingTime < 1000000000000000000) {
          if (otpstatus == true) {
            timer.cancel();
          } else {
            remainingTime++;
          }

          if (kDebugMode) {
            print("⏰ Extra time: $remainingTime");
            print("📊 OTP Status: $otpstatus");
            print("📊 Extra status: $extraStatus");
          }
        } else {
          timer.cancel();
        }
      });
    });
  }

  // ✅ MIGRATED - Socket emission using SocketService
  void _emitTimeRequest() {
    final socketService = SocketService.instance;

    socketService.emit('Vehicle_Time_Request', {
      'uid': useridgloable,
      'd_id': globalDriverAcceptClass.driver_id.isNotEmpty
          ? globalDriverAcceptClass.driver_id
          : driver_id,
    });

    if (kDebugMode) print("📤 Vehicle time request emitted");
  }

  // ✅ NEW - Handle ride events
  void _handleRideCompletion() {
    timer?.cancel();

    // Navigate to payment screen
    Get.offAll(() => const RideCompletePaymentScreen());

    if (kDebugMode) print("🏁 Ride completed - navigating to payment");
  }

  void _handleRideStart() {
    // Update timer for ride start
    _calculateTotalTime();
    _startNormalTimer();

    if (kDebugMode) print("🚦 Ride started - timer updated");
  }

  // ✅ MIGRATED - Time formatting
  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ✅ NEW - Action handlers
  void _pauseTimer() {
    timer?.cancel();
    context.read<TimerState>().stopAnimation();

    if (kDebugMode) print("⏸️ Timer paused");
  }

  void _resumeTimer() {
    if (isExtraTimeMode) {
      _startExtraTimer();
    } else {
      _startNormalTimer();
    }

    context.read<TimerState>().startAnimation();

    if (kDebugMode) print("▶️ Timer resumed");
  }

  void _resetTimer() {
    timer?.cancel();

    setState(() {
      remainingTime = countdownStart;
      isExtraTimeMode = false;
      extraStatus = "";
      isLoading = false;
    });

    context.read<TimerState>().resetAnimation();

    if (kDebugMode) print("🔄 Timer reset");
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    // ✅ MIGRATED - Wrap with Consumer for provider state management
    return Consumer3<TimerState, RideRequestState, PricingState>(
      builder: (context, timerState, rideRequestState, pricingState, child) {
        return Scaffold(
          backgroundColor: notifier.background,
          appBar: AppBar(
            backgroundColor: notifier.background,
            elevation: 0,
            centerTitle: true,
            leading: InkWell(
              onTap: () => Get.back(),
              child: Icon(
                Icons.arrow_back_ios,
                color: notifier.textColor,
              ),
            ),
            title: Text(
              "Ride Timer".tr,
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ KEEP - Timer display
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: notifier.containercolore,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Timer circle
                      Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isExtraTimeMode ? Colors.red : theamcolore,
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatTime(remainingTime.abs()),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isExtraTimeMode
                                      ? Colors.red
                                      : theamcolore,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isExtraTimeMode
                                    ? "Extra Time".tr
                                    : "Ride Time".tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: notifier.textColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (extraStatus.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            extraStatus.tr,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ✅ MIGRATED - Ride information with provider state
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: notifier.containercolore,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ride Status".tr,
                            style: TextStyle(
                              fontSize: 16,
                              color: notifier.textColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(),
                              style: TextStyle(
                                color: _getStatusColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (globalDriverAcceptClass.driver_name.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Driver".tr,
                              style: TextStyle(
                                fontSize: 16,
                                color: notifier.textColor,
                              ),
                            ),
                            Text(
                              globalDriverAcceptClass.driver_name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: notifier.textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),

                // ✅ MIGRATED - Timer control buttons
                Row(
                  children: [
                    Expanded(
                      child: CommonOutLineButton(
                        bordercolore: theamcolore,
                        onPressed1: () {
                          if (timer?.isActive == true) {
                            _pauseTimer();
                          } else {
                            _resumeTimer();
                          }
                        },
                        txt1:
                            timer?.isActive == true ? "Pause".tr : "Resume".tr,
                        context: context,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: CommonButton(
                        onPressed1: _resetTimer,
                        txt1: "Reset".tr,
                        containcolore: theamcolore,
                        context: context,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ NEW - Helper methods for status display
  Color _getStatusColor() {
    if (isExtraTimeMode) return Colors.red;
    if (statusridestart == "completed") return Colors.green;
    if (statusridestart == "started") return Colors.blue;
    return theamcolore;
  }

  String _getStatusText() {
    if (isExtraTimeMode) return "Extra Time";
    if (statusridestart.isNotEmpty) {
      return statusridestart.capitalizeFirst ?? "Active";
    }
    return "Active";
  }
}
