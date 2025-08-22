import 'package:qareeb/common_code/custom_loading_widget.dart';
// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'driver_detail_screen.dart';
import 'home_screen.dart';
import 'pickup_drop_point.dart';
import '../common_code/common_button.dart';
import '../common_code/config.dart';
import '../api_code/add_vehical_api_controller.dart';
import '../api_code/calculate_api_controller.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_flow_screen.dart';
import 'map_screen.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen>
    with TickerProviderStateMixin {
  AddVihicalCalculateController addVihicalCalculateController =
      Get.put(AddVihicalCalculateController());
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());
  CalculateController calculateController = Get.put(CalculateController());

  List<double> progressList = [];
  List<AnimationController> controllers = [];
  Timer? countdownTimer;
  bool _isDisposed = false;

  // ✅ NEW: Enhanced state management
  List<bool> acceptedOffers = [];
  List<bool> declinedOffers = [];
  bool isProcessingOffer = false;

  int d_id = 0;
  String driver_id = "";
  num price = 0;

  @override
  void initState() {
    super.initState();
    print("DriverListScreen initState called");
    _initializeOfferStates();
    socketConnect();
    startTimer();
  }

  @override
  void dispose() {
    if (kDebugMode) print("DriverListScreen dispose called");
    _isDisposed = true;

    // ✅ CRITICAL: Proper cleanup to prevent map screen issues
    _cleanupResources();

    super.dispose();
  }

  // ✅ NEW: Critical cleanup method
  void _cleanupResources() {
    // Cancel timer
    countdownTimer?.cancel();
    countdownTimer = null;

    // Dispose animation controllers
    for (var controller in controllers) {
      try {
        if (!controller.isDismissed) {
          controller.dispose();
        }
      } catch (e) {
        if (kDebugMode) print("Error disposing controller: $e");
      }
    }
    controllers.clear();

    // ✅ CRITICAL: Reset global states that might affect map screen
    buttontimer = false;
    isanimation = false;
    isControllerDisposed = true;

    // Reset bidding data
    vehicle_bidding_driver.clear();
    vehicle_bidding_secounde.clear();

    // ✅ CRITICAL: Disconnect socket events specific to this screen
    try {
      socket.off("Accept_Bidding_Response$useridgloable");
      socket.off("Bidding_decline_Response$useridgloable");
      socket.off("removecustomerdata$useridgloable");
    } catch (e) {
      if (kDebugMode) print("Error removing socket listeners: $e");
    }

    if (kDebugMode) print("✅ DriverListScreen cleanup completed");
  }

  // ✅ NEW: Initialize offer states
  void _initializeOfferStates() {
    if (vehicle_bidding_driver.isNotEmpty) {
      acceptedOffers =
          List.generate(vehicle_bidding_driver.length, (index) => false);
      declinedOffers =
          List.generate(vehicle_bidding_driver.length, (index) => false);

      if (kDebugMode) {
        print(
            "🔧 Bidding mode initialized with ${vehicle_bidding_driver.length} offers");
      }
    }
  }

  // ✅ NEW: Check if offer is expired
  bool isOfferExpired(int remainingSeconds) {
    return remainingSeconds <= 0;
  }

  // ✅ NEW: Show expired offer dialog
  void showOfferExpiredDialog() {
    if (_isDisposed || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.timer_off, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text(
                "Offer Expired".tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.access_time,
                size: 50,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              Text(
                "Sorry, this driver's offer has expired. Please choose another available driver or request new offers.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _refreshDriverList();
              },
              child: Text(
                "OK".tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theamcolore,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ NEW: Refresh driver list (remove expired offers)
  void _refreshDriverList() {
    if (_isDisposed || !mounted) return;

    setState(() {
      // Remove expired drivers from the list
      for (int i = vehicle_bidding_driver.length - 1; i >= 0; i--) {
        if (vehicle_bidding_secounde[i] <= 0) {
          vehicle_bidding_driver.removeAt(i);
          vehicle_bidding_secounde.removeAt(i);
          if (i < acceptedOffers.length) acceptedOffers.removeAt(i);
          if (i < declinedOffers.length) declinedOffers.removeAt(i);
        }
      }
    });

    // If no drivers left, go back with proper cleanup
    if (vehicle_bidding_driver.isEmpty) {
      _handleEmptyDriverList();
    }
  }

  // ✅ NEW: Handle empty driver list
  void _handleEmptyDriverList() {
    if (kDebugMode) print("🔄 All offers expired, returning to map screen");

    // Show snackbar message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("All driver offers have expired. Please try again."),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );

    // Navigate back with proper cleanup
    Navigator.pop(context);
  }

  // ✅ ENHANCED: Socket connection with proper event handling
  socketConnect() async {
    if (_isDisposed) return;

    socket.connect();
    _connectSocket();
  }

  _connectSocket() async {
    if (_isDisposed) return;

    if (kDebugMode) print("DriverListScreen connecting to socket...");

    // ✅ Listen for bidding acceptance confirmation
    socket.on("Accept_Bidding_Response$useridgloable", (response) {
      if (_isDisposed || !mounted) return;

      if (kDebugMode) {
        print("🎯 Accept_Bidding_Response received: $response");
      }

      setState(() {
        isProcessingOffer = false;
      });

      if (response["success"] == true) {
        // Bid accepted successfully
        int driverId = response["driver_id"];
        String requestId = response["request_id"];

        if (!_isDisposed && mounted) {
          // Proceed to driver detail screen
          globalDriverAcceptClass.driverdetailfunction(
            context: context,
            lat: latitudepick,
            long: longitudepick,
            d_id: driverId.toString(),
            request_id: requestId,
          );
        }
      } else {
        // Bid acceptance failed - show error
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Booking Failed"),
              content:
                  Text(response["message"] ?? "Unable to accept this offer."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          );
        }
      }
    });

    // ✅ Listen for bidding decline confirmation
    socket.on("Bidding_decline_Response$useridgloable", (response) {
      if (_isDisposed || !mounted) return;

      if (kDebugMode) {
        print("❌ Bidding_decline_Response received: $response");
      }

      // Update UI to show declined state
      int driverId = response["driver_id"];
      for (int i = 0; i < vehicle_bidding_driver.length; i++) {
        if (vehicle_bidding_driver[i]["id"] == driverId) {
          if (mounted) {
            setState(() {
              declinedOffers[i] = true;
            });
          }
          break;
        }
      }
    });

    // ✅ Handle removal of customer data (ride cancelled/completed)
    socket.on("removecustomerdata$useridgloable", (removecustomerdata) {
      if (_isDisposed || !mounted) return;

      if (kDebugMode) {
        print("🗑️ removecustomerdata received: $removecustomerdata");
      }

      if (removecustomerdata["requestid"] == request_id) {
        if (kDebugMode) print("✅ REQUEST ID MATCH - closing driver list");

        // Proper navigation back to map
        if (mounted) {
          Navigator.pop(context);
        }
      }
    });
  }

  // ✅ ENHANCED: Accept offer with validation
  void acceptsocate(int index) {
    if (_isDisposed || !mounted || isProcessingOffer) return;

    // Final validation before emission
    if (isOfferExpired(vehicle_bidding_secounde[index])) {
      showOfferExpiredDialog();
      return;
    }

    setState(() {
      isProcessingOffer = true;
    });

    if (kDebugMode) {
      print("🚀 Emitting Accept_Bidding:");
      print("   uid: $useridgloable");
      print("   d_id: $d_id");
      print("   request_id: $request_id");
      print("   price: $price");
    }

    socket.emit('Accept_Bidding', {
      'uid': useridgloable,
      'd_id': d_id,
      'request_id': request_id,
      'price': price,
    });

    // Mark as accepted in UI
    setState(() {
      acceptedOffers[index] = true;
    });
  }

  // ✅ ENHANCED: Decline offer
  void declineOffer(int index) {
    if (_isDisposed || !mounted) return;

    int driverId = vehicle_bidding_driver[index]["id"];

    if (kDebugMode) {
      print("❌ Emitting Bidding_decline:");
      print("   uid: $useridgloable");
      print("   id: $driverId");
      print("   request_id: $request_id");
    }

    socket.emit('Bidding_decline', {
      'uid': useridgloable,
      'id': driverId,
      'request_id': request_id,
    });

    // Mark as declined in UI
    setState(() {
      declinedOffers[index] = true;
    });
  }

  // ✅ ENHANCED: Timer with auto-refresh
  void startTimer() {
    if (_isDisposed) return;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        bool hasActiveOffers = false;

        for (int i = 0; i < vehicle_bidding_secounde.length; i++) {
          if (vehicle_bidding_secounde[i] > 0) {
            vehicle_bidding_secounde[i]--;
            hasActiveOffers = true;
          }
        }

        // Auto-remove expired offers after a delay
        if (!hasActiveOffers) {
          Future.delayed(Duration(seconds: 2), () {
            if (mounted && !_isDisposed) {
              _refreshDriverList();
            }
          });
        }
      });
    });
  }

  // ✅ Format time display
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ✅ Timer display widget
  Widget buildTimerDisplay(int index) {
    final seconds = vehicle_bidding_secounde[index];
    final isExpired = seconds <= 0;
    final isAlmostExpired = seconds <= 10;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isExpired
            ? Colors.red.shade100
            : isAlmostExpired
                ? Colors.orange.shade100
                : Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired
              ? Colors.red
              : isAlmostExpired
                  ? Colors.orange
                  : Colors.green,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.timer_off : Icons.timer,
            size: 16,
            color: isExpired
                ? Colors.red
                : isAlmostExpired
                    ? Colors.orange
                    : Colors.green,
          ),
          SizedBox(width: 4),
          Text(
            isExpired ? "Expired" : formatTime(seconds),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isExpired
                  ? Colors.red
                  : isAlmostExpired
                      ? Colors.orange
                      : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Handle accept offer with validation
  void _handleAcceptOffer(int index) {
    if (isProcessingOffer) return;

    // Check if offer is expired
    if (isOfferExpired(vehicle_bidding_secounde[index])) {
      showOfferExpiredDialog();
      return;
    }

    // Double-check timer (race condition protection)
    if (vehicle_bidding_secounde[index] <= 0) {
      showOfferExpiredDialog();
      return;
    }

    // Set driver details
    setState(() {
      d_id = vehicle_bidding_driver[index]["id"];
      driver_id = vehicle_bidding_driver[index]["id"].toString();
      price = vehicle_bidding_driver[index]["price"];
      vihicalrice =
          double.parse(vehicle_bidding_driver[index]["price"].toString());

      // ✅ CRITICAL: Properly disable animations
      buttontimer = false;
      isanimation = false;
      isControllerDisposed = true;

      if (controller != null && controller!.isAnimating) {
        if (kDebugMode) print("🔧 Disposing animation controller");
        try {
          controller!.dispose();
          controller = null;
        } catch (e) {
          if (kDebugMode) print("Error disposing controller: $e");
        }
      }
    });

    if (kDebugMode) {
      print("🎯 Accepting offer:");
      print("   d_id: $d_id");
      print("   price: $price");
      print("   driver_id: $driver_id");
    }

    // Emit accept signal
    acceptsocate(index);

    // Navigate to driver detail
    globalDriverAcceptClass.driverdetailfunction(
      context: context,
      lat: latitudepick,
      long: longitudepick,
      d_id: d_id.toString(),
      request_id: request_id,
    );
  }

  // ✅ Handle decline offer
  void _handleDeclineOffer(int index) {
    if (kDebugMode) {
      print("❌ Declining offer:");
      print("   uid: $useridgloable");
      print("   driver_id: ${vehicle_bidding_driver[index]["id"]}");
    }

    declineOffer(index);
  }

  // ✅ Build action buttons based on offer state
  Widget buildActionButtons(int index) {
    final isExpired = isOfferExpired(vehicle_bidding_secounde[index]);
    final isAccepted = index < acceptedOffers.length && acceptedOffers[index];
    final isDeclined = index < declinedOffers.length && declinedOffers[index];

    if (isAccepted || isProcessingOffer) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isProcessingOffer
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                : Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(
              isProcessingOffer ? "Processing..." : "Accepted",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (isDeclined) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.cancel, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              "Declined",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (isExpired) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.timer_off, color: Colors.grey, size: 20),
            SizedBox(width: 8),
            Text(
              "Expired",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Active offer - show accept/decline buttons
    return Row(
      children: [
        Expanded(
          child: CommonButton(
            containcolore: Colors.red,
            onPressed1: () => _handleDeclineOffer(index),
            context: context,
            txt2: "Decline".tr,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CommonButton(
            containcolore: Colors.green,
            onPressed1: () => _handleAcceptOffer(index),
            context: context,
            txt1: "Accept".tr,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorNotifier notifire = Provider.of<ColorNotifier>(context, listen: true);

    return WillPopScope(
      onWillPop: () async {
        // ✅ CRITICAL: Proper cleanup when back button is pressed
        _cleanupResources();
        return true;
      },
      child: Scaffold(
        backgroundColor: notifire.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: notifire.background,
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              // ✅ CRITICAL: Proper cleanup on manual back
              _cleanupResources();
              Get.back();
            },
            child: Container(
              height: 40,
              width: 40,
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                "assets/close.png",
                height: 40,
                width: 40,
                color: theamcolore,
              ),
            ),
          ),
          title: Text(
            "Choose a driver".tr,
            style: TextStyle(
              fontFamily: 'Gilroy Bold',
              fontSize: 15,
              color: notifire.textColor,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Text(
                "Driver can offer their fare and time".tr,
                style: TextStyle(
                  fontSize: 14,
                  color: notifire.textColor,
                  fontFamily: 'Gilroy Medium',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        body: Container(
          width: Get.size.width,
          height: Get.size.height,
          color: notifire.background,
          child: Column(
            children: [
              Expanded(
                child: vehicle_bidding_driver.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Waiting for driver responses...".tr,
                              style: TextStyle(
                                fontSize: 18,
                                color: notifire.textColor,
                                fontFamily: 'Gilroy Medium',
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Drivers will appear here when they respond".tr,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: vehicle_bidding_driver.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 10,
                              bottom: 5,
                            ),
                            padding: const EdgeInsets.all(15),
                            width: Get.size.width,
                            decoration: BoxDecoration(
                              color: notifire.containercolore,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Driver Info Row
                                Row(
                                  children: [
                                    // Driver Image
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: theamcolore,
                                          width: 2,
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            "${Config.imageurl}${vehicle_bidding_driver[index]["profile_image"]}",
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),

                                    // Driver Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            vehicle_bidding_driver[index]
                                                    ["name"] ??
                                                "Driver",
                                            style: TextStyle(
                                              fontFamily: 'Gilroy Bold',
                                              fontSize: 16,
                                              color: notifire.textColor,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "${vehicle_bidding_driver[index]["rating"] ?? "5.0"}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: notifire.textColor,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "•",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "${vehicle_bidding_driver[index]["distance"] ?? "0.5"} km",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Timer Display
                                    buildTimerDisplay(index),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                // Action Buttons
                                buildActionButtons(index),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
