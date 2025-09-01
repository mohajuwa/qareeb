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

  // Enhanced state management
  List<bool> acceptedOffers = [];
  List<bool> declinedOffers = [];
  bool isProcessingOffer = false;

  int d_id = 0;
  String driver_id = "";
  num price = 0;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) print("DriverListScreen initState called");
    _checkMonitorStatus();

    _initializeOfferStates();

    socketConnect();

    startTimer();
  }

  @override
  void dispose() {
    if (kDebugMode) print("DriverListScreen dispose called");
    _isDisposed = true;
    _cleanupResources();
    super.dispose();
  }

  void _checkMonitorStatus() {
    final rideStatus = RunningRideMonitor.instance.currentRideStatus;

    if (kDebugMode) {
      print("🔍 DriverListScreen - Current ride status:");

      print(rideStatus);
    }

    // If we have an active ride but no bidding data, load it

    if (rideStatus["hasRide"] == true && vehicle_bidding_driver.isEmpty) {
      if (kDebugMode) print("🔄 Loading bidding data from monitor...");

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _loadBiddingDataFromMonitor();
        }
      });
    }
  }

  void _loadBiddingDataFromMonitor() {
    try {
      socket.emit('load_bidding_data', {
        'uid': useridgloable,

        'request_id': request_id,

        'd_id': [] // Will be populated by backend
      });

      if (kDebugMode)
        print("📡 Emitted load_bidding_data from DriverListScreen");
    } catch (e) {
      if (kDebugMode) print("Error loading bidding data: $e");
    }
  }

  // Critical cleanup method
  void _cleanupResources() {
    countdownTimer?.cancel();
    countdownTimer = null;

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

    // Reset global states
    buttontimer = false;
    isanimation = false;
    isControllerDisposed = true;

    // Reset bidding data
    vehicle_bidding_driver.clear();
    vehicle_bidding_secounde.clear();

    // Disconnect socket events
    try {
      socket.off("Accept_Bidding_Response$useridgloable");
      socket.off("Bidding_decline_Response$useridgloable");
      socket.off("removecustomerdata$useridgloable");
    } catch (e) {
      if (kDebugMode) print("Error removing socket listeners: $e");
    }

    if (kDebugMode) print("✅ DriverListScreen cleanup completed");
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
  Widget build(BuildContext context) {
    return Consumer<ColorNotifier>(
      builder: (context, notifire, child) {
        return WillPopScope(
          onWillPop: () async {
            _cleanupResources();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MapScreen(selectvihical: false),
              ),
            );
            return false;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: _buildAppBar(notifire),
            body: _buildBody(notifire),
            bottomNavigationBar: _buildBottomBar(notifire),
          ),
        );
      },
    );
  }

  // Enhanced AppBar with gradient and modern design
  PreferredSizeWidget _buildAppBar(ColorNotifier notifire) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theamcolore,
              theamcolore.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theamcolore.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 20),
              onPressed: () {
                _cleanupResources();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(selectvihical: false),
                  ),
                );
              },
            ),
          ),
          title: Column(
            children: [
              Text(
                "Choose Best Offer".tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${vehicle_bidding_driver.length} ${"offers available".tr}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                onPressed: _refreshOffers,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced body with better error handling
  Widget _buildBody(ColorNotifier notifire) {
    if (vehicle_bidding_driver.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      slivers: [
        // Status bar
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade50,
                  Colors.indigo.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Select the offer that suits you - offers are time limited"
                        .tr,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Driver list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildEnhancedDriverCard(notifire, index),
            childCount: vehicle_bidding_driver.length,
          ),
        ),
        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // Enhanced driver card with modern design
  Widget _buildEnhancedDriverCard(ColorNotifier notifire, int index) {
    final driver = vehicle_bidding_driver[index];
    final seconds = vehicle_bidding_secounde[index];
    final isExpired = isOfferExpired(seconds);
    final isAccepted = index < acceptedOffers.length && acceptedOffers[index];
    final isDeclined = index < declinedOffers.length && declinedOffers[index];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isExpired
              ? Colors.red.withOpacity(0.3)
              : isAccepted
                  ? Colors.green.withOpacity(0.3)
                  : isDeclined
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Status indicator
          if (isAccepted || isDeclined || isExpired)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isExpired
                    ? Colors.red.shade50
                    : isAccepted
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Driver info row
                Row(
                  children: [
                    // Driver image with enhanced design
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            theamcolore.withOpacity(0.1),
                            Colors.blue.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: theamcolore.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          "${Config.imageurl}${driver["profile_image"] ?? ''}",
                          height: 76,
                          width: 76,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: theamcolore,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
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
                    ),

                    const SizedBox(width: 16),

                    // Driver details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver["name"] ?? "Driver".tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: notifire.textColor,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Rating and distance
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${driver["rating"] ?? "5.0"}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.blue.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${driver["distance"] ?? "0.5"} ${"km".tr}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Price with enhanced design
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theamcolore.withOpacity(0.1),
                                  theamcolore.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theamcolore.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  color: theamcolore,
                                  size: 20,
                                ),
                                Text(
                                  "${driver["price"] ?? "0"} $globalcurrency",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theamcolore,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Timer display with enhanced design
                    _buildEnhancedTimer(seconds, isExpired),
                  ],
                ),

                const SizedBox(height: 20),

                // Action buttons
                _buildEnhancedActionButtons(
                    index, isExpired, isAccepted, isDeclined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced timer display
  Widget _buildEnhancedTimer(int seconds, bool isExpired) {
    final isAlmostExpired = seconds <= 10 && seconds > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isExpired
            ? Colors.red.shade50
            : isAlmostExpired
                ? Colors.orange.shade50
                : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired
              ? Colors.red.shade300
              : isAlmostExpired
                  ? Colors.orange.shade300
                  : Colors.green.shade300,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.timer_off : Icons.timer,
            size: 20,
            color: isExpired
                ? Colors.red.shade600
                : isAlmostExpired
                    ? Colors.orange.shade600
                    : Colors.green.shade600,
          ),
          const SizedBox(height: 4),
          Text(
            isExpired ? "Expired".tr : _formatTime(seconds),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isExpired
                  ? Colors.red.shade700
                  : isAlmostExpired
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced action buttons
  Widget _buildEnhancedActionButtons(
      int index, bool isExpired, bool isAccepted, bool isDeclined) {
    if (isAccepted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              "Offer Accepted".tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (isDeclined || isExpired) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpired ? Icons.timer_off : Icons.cancel,
              color: Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isExpired ? "Offer Expired".tr : "Offer Declined".tr,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Active state buttons
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade300, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: MaterialButton(
              onPressed:
                  isProcessingOffer ? null : () => _handleDeclineOffer(index),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.close,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Decline".tr,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theamcolore, theamcolore.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theamcolore.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: MaterialButton(
              onPressed:
                  isProcessingOffer ? null : () => _handleAcceptOffer(index),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: isProcessingOffer
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Accept".tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // Enhanced empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.search_off,
                size: 80,
                color: Colors.orange.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Offers Available".tr,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "No drivers are currently available in your area".tr,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theamcolore, theamcolore.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: MaterialButton(
                onPressed: () => Navigator.pop(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Go Back".tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced bottom bar
  Widget _buildBottomBar(ColorNotifier notifire) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Choose your preferred driver - no waiting, no bidding".tr,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MaterialButton(
                      onPressed: _refreshOffers,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: Colors.grey.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Refresh Offers".tr,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MaterialButton(
                      onPressed: _cancelRequest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cancel,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Cancel Request".tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Utility methods
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _refreshOffers() {
    if (kDebugMode) print("Refreshing offers...");
    // Add refresh logic here
  }

  void _cancelRequest() {
    _cleanupResources();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(selectvihical: false),
      ),
    );
  }

  // Handle accept offer with validation - FIXED
  void _handleAcceptOffer(int index) {
    if (isProcessingOffer) return;

    if (isOfferExpired(vehicle_bidding_secounde[index])) {
      showOfferExpiredDialog();
      return;
    }

    if (vehicle_bidding_driver[index]["id"] == null) {
      if (kDebugMode) print("❌ Invalid driver data");
      return;
    }

    setState(() {
      d_id = vehicle_bidding_driver[index]["id"];
      driver_id = vehicle_bidding_driver[index]["id"].toString();
      price = vehicle_bidding_driver[index]["price"] ?? 0;
      vihicalrice = double.parse(price.toString());
      buttontimer = false;
      isanimation = false;
      isControllerDisposed = true;
    });

    countdownTimer?.cancel();
    acceptsocate(index);
  }

  // Handle decline offer - FIXED
  void _handleDeclineOffer(int index) {
    if (kDebugMode) {
      print("❌ Declining offer:");
      print("   uid: $useridgloable");
      print("   driver_id: ${vehicle_bidding_driver[index]["id"]}");
    }

    declineOffer(index);
  }

  // Filtering variables
  String selectedFilter = "All";
  List<String> filterOptions = [
    "All",
    "Price Low",
    "Price High",
    "Rating High",
    "Nearest"
  ];

  List<dynamic> get filteredDrivers {
    List<dynamic> drivers = List.from(vehicle_bidding_driver);

    switch (selectedFilter) {
      case "Price Low":
        drivers.sort((a, b) => (a["price"] ?? 0).compareTo(b["price"] ?? 0));
        break;
      case "Price High":
        drivers.sort((a, b) => (b["price"] ?? 0).compareTo(a["price"] ?? 0));
        break;
      case "Rating High":
        drivers.sort((a, b) => double.parse(b["rating"]?.toString() ?? "0")
            .compareTo(double.parse(a["rating"]?.toString() ?? "0")));
        break;
      case "Nearest":
        drivers.sort((a, b) => double.parse(a["distance"]?.toString() ?? "999")
            .compareTo(double.parse(b["distance"]?.toString() ?? "999")));
        break;
      default:
        break;
    }
    return drivers;
  }

  void showOfferExpiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.timer_off, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Text("Offer Expired".tr),
          ],
        ),
        content:
            Text("This offer has expired. Please choose another driver.".tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK".tr, style: TextStyle(color: theamcolore)),
          ),
        ],
      ),
    );
  }

  // Socket and timer methods - using original API structure
  void socketConnect() {
    try {
      socket.on("Accept_Bidding_Response$useridgloable", (response) {
        if (_isDisposed || !mounted) return;

        if (kDebugMode) {
          print("++++++ Accept_Bidding_Response ++++ :---  $response");
        }

        setState(() {
          isProcessingOffer = false;
        });

        if (response["success"] == true || response["Result"] == "true") {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (!_isDisposed && mounted) {
              globalDriverAcceptClass.driverdetailfunction(
                context: context,
                lat: latitudepick,
                long: longitudepick,
                d_id: d_id.toString(),
                request_id:
                    response["cart_id"]?.toString() ?? request_id.toString(),
              );
            }
          });
        } else {
          if (mounted) {
            _showOfferExpiredDialog();
          }
        }
      });

      socket.on("Bidding_decline_Response$useridgloable",
          (BiddingDeclineResponse) {
        if (_isDisposed || !mounted) return;

        if (kDebugMode) {
          print(
              "++++++ Bidding_decline_Response ++++ :---  $BiddingDeclineResponse");
        }
      });

      socket.on("removecustomerdata$useridgloable", (removecustomerdata) {
        if (_isDisposed || !mounted) return;

        if (kDebugMode) {
          print("++++++ removecustomerdata ++++ :---  $removecustomerdata");
        }

        setState(() {
          vehicle_bidding_driver.removeAt(removecustomerdata["index"]);
          vehicle_bidding_secounde.removeAt(removecustomerdata["index"]);

          // Update offer states lists
          if (removecustomerdata["index"] < acceptedOffers.length) {
            acceptedOffers.removeAt(removecustomerdata["index"]);
          }
          if (removecustomerdata["index"] < declinedOffers.length) {
            declinedOffers.removeAt(removecustomerdata["index"]);
          }
        });

        if (vehicle_bidding_driver.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MapScreen(selectvihical: false),
            ),
          );
        }
      });
    } catch (e) {
      if (kDebugMode) print("Socket connection error: $e");
    }
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        for (int i = 0; i < vehicle_bidding_secounde.length; i++) {
          if (vehicle_bidding_secounde[i] > 0) {
            vehicle_bidding_secounde[i]--;
          }
        }
      });
    });
  }

  void acceptsocate(int index) {
    if (_isDisposed || !mounted || isProcessingOffer) return;

    if (isOfferExpired(vehicle_bidding_secounde[index])) {
      _showOfferExpiredDialog();
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

    // Using original API structure
    socket.emit('Accept_Bidding', {
      'uid': useridgloable,
      'd_id': d_id,
      'request_id': request_id,
      'price': price,
    });

    setState(() {
      if (index < acceptedOffers.length) {
        acceptedOffers[index] = true;
      }
    });
  }

  void declineOffer(int index) {
    if (_isDisposed || !mounted) return;

    int driverId = vehicle_bidding_driver[index]["id"];

    if (kDebugMode) {
      print("❌ Emitting Bidding_decline:");
      print("   uid: $useridgloable");
      print("   id: $driverId");
      print("   request_id: $request_id");
    }

    // Using original API structure
    socket.emit('Bidding_decline', {
      'uid': useridgloable,
      'id': driverId,
      'request_id': request_id,
    });

    setState(() {
      if (index < declinedOffers.length) {
        declinedOffers[index] = true;
      }
    });
  }

  void _showOfferExpiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.timer_off, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Text("Offer Expired".tr),
          ],
        ),
        content:
            Text("This offer has expired. Please choose another driver.".tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK".tr, style: TextStyle(color: theamcolore)),
          ),
        ],
      ),
    );
  }
}
