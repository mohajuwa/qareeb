import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/services/running_ride_monitor.dart';
import 'home_screen.dart';
import 'pickup_drop_point.dart';
import '../common_code/config.dart';
import '../api_code/add_vehical_api_controller.dart';
import '../api_code/calculate_api_controller.dart';
import '../api_code/remove_request.dart'; // Add this import
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
  RemoveRequest removeRequest = Get.put(RemoveRequest()); // Add this controller

  List<double> progressList = [];
  List<AnimationController> controllers = [];
  Timer? _biddingTimer;
  Timer? _progressTimer;
  bool _disposed = false;
  bool _cancelLoading = false; // Add loading state for cancel
  int _lastDriverCount = 0;
  String _lastRequestId = "";
  List<bool> acceptedOffers = [];
  List<bool> declinedOffers = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupSocketListeners();
    _startBiddingTimer();

    // Initialize progress only when we have drivers
    if (vehicle_bidding_driver.isNotEmpty) {
      _initializeProgress();
      _initializeOfferStates();
    }
  }

  void _initializeData() {
    try {
      // Load existing bidding data
      if (vehicle_bidding_driver.isNotEmpty) {
        _updateProgressList();
      }

      if (kDebugMode) {
        print("🚗 DriverListScreen initialized");
        print("   Request ID: $request_id");
        print("   Driver count: ${vehicle_bidding_driver.length}");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error initializing driver data: $e");
    }
  }

  void _setupSocketListeners() {
    try {
      // Listen for bidding updates
      socket.on('Accept_Bidding_Response$useridgloable', (data) {
        if (!mounted || _disposed) return;

        try {
          if (kDebugMode) print("📢 Received bidding update");

          // Update driver list and seconds
          if (data['bidding_list'] != null) {
            setState(() {
              vehicle_bidding_driver = data['bidding_list'];
              vehicle_bidding_secounde = List.generate(
                  vehicle_bidding_driver.length,
                  (index) =>
                      vehicle_bidding_driver[index]['diff_second'] ?? 120);
              _updateProgressList();
            });
          }
        } catch (e) {
          if (kDebugMode) print("❌ Error handling bidding response: $e");
        }
      });

      // Listen for driver acceptance
      socket.on('acceptvehrequest$useridgloable', (data) {
        if (!mounted || _disposed) return;

        try {
          if (kDebugMode) print("✅ Driver accepted the ride");
          _navigateToMapScreen(data);
        } catch (e) {
          if (kDebugMode) print("❌ Error handling acceptance: $e");
        }
      });

      // Listen for bid decline response
      socket.on('Bidding_decline_Response$useridgloable', (data) {
        if (!mounted || _disposed) return;

        try {
          if (kDebugMode) print("❌ Driver bid declined");

          // Update the driver list
          if (data['bidding_list'] != null) {
            setState(() {
              vehicle_bidding_driver = data['bidding_list'];
              vehicle_bidding_secounde = List.generate(
                  vehicle_bidding_driver.length,
                  (index) =>
                      vehicle_bidding_driver[index]['diff_second'] ?? 120);
              _updateProgressList();
            });
          }
        } catch (e) {
          if (kDebugMode) print("❌ Error handling decline: $e");
        }
      });

      // Listen for customer data removal
      socket.on('removecustomerdata$useridgloable', (data) {
        if (!mounted || _disposed) return;

        try {
          if (kDebugMode) print("🗑️ Request cancelled/timeout");
          _handleTimeout();
        } catch (e) {
          if (kDebugMode) print("❌ Error handling removal: $e");
        }
      });
    } catch (e) {
      if (kDebugMode) print("❌ Error setting up socket listeners: $e");
    }
  }

  void _initializeProgress() {
    if (_disposed || !mounted) return;

    try {
      // Clear existing controllers to prevent memory leaks
      _disposeControllers();

      int driverCount = vehicle_bidding_driver.length;

      progressList = List.generate(driverCount, (index) => 0.0);
      controllers = List.generate(driverCount, (index) {
        return AnimationController(
          duration: Duration(
              seconds: vehicle_bidding_secounde.isNotEmpty &&
                      index < vehicle_bidding_secounde.length
                  ? vehicle_bidding_secounde[index]
                  : 120),
          vsync: this,
        );
      });

      // Start animations
      for (int i = 0; i < controllers.length; i++) {
        if (!_disposed && mounted) {
          controllers[i].addListener(() {
            if (mounted && !_disposed) {
              setState(() {
                progressList[i] = controllers[i].value;
              });
            }
          });
          controllers[i].forward();
        }
      }

      _lastDriverCount = driverCount;
      _lastRequestId = request_id;

      if (kDebugMode) print("✅ Initialized progress for $driverCount drivers");
    } catch (e) {
      if (kDebugMode) print("❌ Error initializing progress: $e");
    }
  }

  void _updateProgressList() {
    if (_disposed || !mounted) return;

    try {
      int currentCount = vehicle_bidding_driver.length;

      // Only reinitialize if driver count changed or request changed
      if (currentCount != _lastDriverCount || request_id != _lastRequestId) {
        if (kDebugMode) {
          print("🔄 Driver count changed: $_lastDriverCount → $currentCount");
        }
        _initializeProgress();
        _initializeOfferStates();
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error updating progress: $e");
    }
  }

  void _startBiddingTimer() {
    if (_disposed) return;

    // Reduced frequency to improve performance
    _biddingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_disposed || !mounted) {
        timer.cancel();
        return;
      }

      try {
        // Emit socket to refresh bidding data
        socket.emit('vehiclerequest',
            {'requestid': request_id, 'driverid': '', 'c_id': useridgloable});

        // Only log occasionally to reduce console spam
        if (timer.tick % 10 == 0) {
          if (kDebugMode) {
            print("📡 Refreshed bidding data (tick ${timer.tick})");
          }
        }
      } catch (e) {
        if (kDebugMode) print("❌ Timer error: $e");
      }
    });
  }

  void _navigateToMapScreen(dynamic data) {
    try {
      // Stop monitoring and timers
      _stopAllTimers();

      // Update global variables
      driver_id = data['uid']?.toString() ?? "";
      request_id = data['request_id']?.toString() ?? request_id;

      if (kDebugMode) {
        print("🚗 Navigating to MapScreen with driver: $driver_id");
      }

      Get.offAll(() => const MapScreen(selectvihical: false));
    } catch (e) {
      if (kDebugMode) print("❌ Navigation error: $e");
    }
  }

  void _handleTimeout() {
    try {
      _showTimeoutDialog();
    } catch (e) {
      if (kDebugMode) print("❌ Timeout handling error: $e");
    }
  }

  void _showTimeoutDialog() {
    if (!mounted || _disposed) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Request Timeout".tr),
        content: Text("No drivers accepted your request. Please try again.".tr),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offAll(() => const MapScreen(selectvihical: false));
            },
            child: Text("OK".tr),
          ),
        ],
      ),
    );
  }

  void _onDeclineDriver(int index) async {
    try {
      if (index >= vehicle_bidding_driver.length) return;

      var driver = vehicle_bidding_driver[index];
      String driverId = driver['id']?.toString() ?? "";

      if (kDebugMode) print("❌ Declining driver: $driverId");

      // Update local state immediately
      setState(() {
        if (index < declinedOffers.length) {
          declinedOffers[index] = true;
        }
      });

      // Emit decline socket
      socket.emit('Bidding_decline', {
        'uid': driverId,
        'request_id': request_id,
        'c_id': useridgloable,
        'price': driver['price']?.toString() ?? "0",
        'status': "0"
      });
    } catch (e) {
      if (kDebugMode) print("❌ Error declining driver: $e");
    }
  }

  void _onAcceptDriver(int index) {
    try {
      if (index >= vehicle_bidding_driver.length) return;

      var driver = vehicle_bidding_driver[index];
      String driverId = driver['id']?.toString() ?? "";

      if (kDebugMode) print("✅ Accepting driver: $driverId");

      // Update local state immediately
      setState(() {
        if (index < acceptedOffers.length) {
          acceptedOffers[index] = true;
        }
      });

      // Emit accept socket
      socket.emit('Bidding_accept', {
        'uid': driverId,
        'request_id': request_id,
        'c_id': useridgloable,
        'price': driver['price']?.toString() ?? "0",
        'status': "1"
      });
    } catch (e) {
      if (kDebugMode) print("❌ Error accepting driver: $e");
    }
  }

  void _onCancelRequest() {
    try {
      if (kDebugMode) print("❌ Cancelling request: $request_id");

      // Show confirmation dialog first
      _showCancelConfirmationDialog();
    } catch (e) {
      if (kDebugMode) print("❌ Error cancelling request: $e");
    }
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Force user to make a choice
      builder: (context) => AlertDialog(
        title: Text("Cancel Request?".tr),
        content: Text("Are you sure you want to cancel this ride request?".tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Just close dialog
            child: Text("No".tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              _performCancelRequest(); // Actually cancel
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              "Yes, Cancel".tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _performCancelRequest() async {
    try {
      if (kDebugMode) print("❌ Actually cancelling request: $request_id");

      setState(() {
        _cancelLoading = true;
      });

      // Use the exact same API call and socket emit pattern as MapScreen

      await removeRequest.removeApi(uid: useridgloable.toString());

      // Send the same socket event with driverid from calculateController like MapScreen

      socket.emit('AcceRemoveOther', {
        'requestid': request_id,
        'driverid': calculateController.calCulateModel?.driverId ?? '',
      });

      // Reset the same state variables as MapScreen

      setState(() {
        isanimation = false;

        buttontimer = false;
      });

      if (kDebugMode) print("✅ Request cancelled successfully");

      // Use the same delay timing as MapScreen (500ms)

      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to MapScreen (same as MapScreen does)

      Get.offAll(() => const MapScreen(selectvihical: false));
    } catch (e) {
      if (kDebugMode) print("❌ Error performing cancel: $e");

      setState(() {
        _cancelLoading = false;
      });

      // Still navigate to MapScreen even on error (like MapScreen behavior)

      Get.offAll(() => const MapScreen(selectvihical: false));
    }
  }

  void _stopAllTimers() {
    try {
      _biddingTimer?.cancel();
      _biddingTimer = null;

      _progressTimer?.cancel();
      _progressTimer = null;

      if (kDebugMode) print("⏹️ Stopped all timers");
    } catch (e) {
      if (kDebugMode) print("❌ Error stopping timers: $e");
    }
  }

  void _disposeControllers() {
    try {
      for (var controller in controllers) {
        if (!controller.isAnimating) {
          controller.dispose();
        }
      }
      controllers.clear();
      progressList.clear();

      if (kDebugMode) print("🧹 Disposed ${controllers.length} controllers");
    } catch (e) {
      if (kDebugMode) print("❌ Error disposing controllers: $e");
    }
  }

  // Initialize offer states
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

  // Check if offer is expired
  bool isOfferExpired(int seconds) => seconds <= 0;

  @override
  void dispose() {
    if (kDebugMode) print("🗑️ Disposing DriverListScreen");

    _disposed = true;
    _stopAllTimers();
    _disposeControllers();

    // Remove socket listeners
    try {
      socket.off('Accept_Bidding_Response$useridgloable');
      socket.off('Bidding_decline_Response$useridgloable');
      socket.off('removecustomerdata$useridgloable');
      socket.off('acceptvehrequest$useridgloable');
    } catch (e) {
      if (kDebugMode) print("❌ Error removing socket listeners: $e");
    }

    // Reset global states
    buttontimer = false;
    isanimation = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorNotifier>(
      builder: (context, notifire, child) {
        return PopScope(
          // Use PopScope instead of WillPopScope for Flutter 3.12+
          canPop: false, // Prevent back navigation - force user to stay
          onPopInvoked: (didPop) {
            if (!didPop) {
              // Show dialog instead of allowing back navigation
              _showMustChooseDialog();
            }
          },
          child: Scaffold(
            backgroundColor: notifire.backgroundallscreenColor,
            appBar: AppBar(
              backgroundColor: notifire.backgroundallscreenColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close,
                    color: Colors.red), // Use close icon to show it's cancel
                onPressed: _onCancelRequest,
              ),
              title: Text(
                "Choose Your Driver".tr, // More compelling title
                style: TextStyle(
                  color: notifire.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false, // Prevent default back button
            ),
            body: _buildBody(notifire),
          ),
        );
      },
    );
  }

  // New method to show "must choose" dialog when user tries to go back
  void _showMustChooseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: theamcolore),
            const SizedBox(width: 8),
            Text("Choose Required".tr),
          ],
        ),
        content: Text(
          "You must either accept a driver offer or cancel the request to continue."
              .tr,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Got it".tr,
              style: TextStyle(color: theamcolore),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ColorNotifier notifire) {
    if (vehicle_bidding_driver.isEmpty) {
      return _buildLoadingState(notifire);
    }

    return Column(
      children: [
        // Trip details header
        _buildTripHeader(notifire),

        Divider(height: 1, color: notifire.dividerColor),

        // Drivers list
        Expanded(
          child: _buildDriversList(notifire),
        ),

        // Cancel button
        _buildCancelButton(notifire),
      ],
    );
  }

  Widget _buildLoadingState(ColorNotifier notifire) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theamcolore),
          const SizedBox(height: 16),
          Text(
            "Looking for available drivers...".tr,
            style: TextStyle(
              fontSize: 16,
              color: notifire.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripHeader(ColorNotifier notifire) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifire.containercolore,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From location
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "From".tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: notifire.secondaryTextColor,
                      ),
                    ),
                    Text(
                      picktitle.isNotEmpty ? picktitle : "Pickup Location",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: notifire.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // To location
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "To".tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: notifire.secondaryTextColor,
                      ),
                    ),
                    Text(
                      droptitle.isNotEmpty ? droptitle : "Drop Location",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: notifire.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Price
          Text(
            "$globalcurrency ${priceyourfare.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theamcolore,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriversList(ColorNotifier notifire) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: vehicle_bidding_driver.length,
      itemBuilder: (context, index) {
        return _buildDriverCard(index, notifire);
      },
    );
  }

  Widget _buildDriverCard(int index, ColorNotifier notifire) {
    if (index >= vehicle_bidding_driver.length) {
      return const SizedBox.shrink();
    }

    var driver = vehicle_bidding_driver[index];
    double progress = index < progressList.length ? progressList[index] : 0.0;
    int seconds = index < vehicle_bidding_secounde.length
        ? vehicle_bidding_secounde[index]
        : 120;

    bool isExpired = isOfferExpired(seconds);
    bool isAccepted =
        index < acceptedOffers.length ? acceptedOffers[index] : false;
    bool isDeclined =
        index < declinedOffers.length ? declinedOffers[index] : false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: notifire.containercolore,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.borderColor),
        boxShadow: [
          BoxShadow(
            color: notifire.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status banner
          if (isExpired || isAccepted || isDeclined)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isExpired
                    ? Colors.red.shade50
                    : isAccepted
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                isExpired
                    ? "Offer Expired".tr
                    : isAccepted
                        ? "Offer Accepted".tr
                        : "Offer Declined".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isExpired
                      ? Colors.red.shade700
                      : isAccepted
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Driver image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        "${Config.imageurl}${driver["profile_image"] ?? ''}",
                        height: 76,
                        width: 76,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 76,
                            width: 76,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: theamcolore,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 76,
                            width: 76,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.grey.shade600,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Driver details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver["name"] ?? "Driver",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: notifire.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${driver["rating"] ?? "0.0"}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: notifire.secondaryTextColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "${driver["distance"] ?? "0"} km",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: notifire.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            driver["vehicle_name"] ?? "Vehicle",
                            style: TextStyle(
                              fontSize: 13,
                              color: notifire.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bid price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "$globalcurrency ${driver["price"] ?? priceyourfare}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theamcolore,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Bid Price".tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: notifire.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress bar (only show if not expired/accepted/declined)
                if (!isExpired && !isAccepted && !isDeclined)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Waiting for response...".tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: notifire.secondaryTextColor,
                            ),
                          ),
                          Text(
                            "${((1 - progress) * seconds).toInt()}s",
                            style: TextStyle(
                              fontSize: 12,
                              color: notifire.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.8 ? Colors.red : theamcolore,
                        ),
                        minHeight: 4,
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                // Action buttons (only show if not expired/accepted/declined)
                if (!isExpired && !isAccepted && !isDeclined)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _onDeclineDriver(index),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Decline".tr,
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _onAcceptDriver(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theamcolore,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Accept".tr,
                            style: const TextStyle(color: Colors.white),
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

  Widget _buildCancelButton(ColorNotifier notifire) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifire.containercolore,
        border: Border(
          top: BorderSide(color: notifire.borderColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Accept a driver offer or cancel to continue".tr,
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cancel button with loading state
          SizedBox(
            width: double.infinity,
            child: _cancelLoading
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Cancelling...".tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton(
                    onPressed: _onCancelRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Cancel Request".tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
