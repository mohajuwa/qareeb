// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/api_code/global_driver_access_api_controller.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/common_code/modern_loading_widget.dart';
import 'package:qareeb/common_code/socket_service.dart';
import 'package:qareeb/common_code/type_utils.dart';
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/map_state.dart';
import 'package:qareeb/providers/pricing_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/app_screen/my_ride_detail_screen.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';
import 'package:qareeb/app_screen/ride_complete_payment_screen.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import '../api_code/all_request_data_api_controller.dart';
import '../api_code/vihical_ride_complete_order_api_controller.dart';
import '../common_code/common_flow_screen.dart';
import '../common_code/config.dart';
import '../timer_screen.dart';
import 'driver_startride_screen.dart';
import 'home_screen.dart';

// ✅ KEEP - Global variables for ride status (as per migration requirements)
String appstatus = "";
String appstatusid = "";
String runtimestatusid = "";
String plusetimer = "";

class MyRideScreen extends StatefulWidget {
  const MyRideScreen({super.key});

  @override
  State<MyRideScreen> createState() => _MyRideScreenState();
}

class _MyRideScreenState extends State<MyRideScreen>
    with TickerProviderStateMixin {
  // ✅ MIGRATED - Tab controller for ride history tabs
  late final TabController _tabController;

  // ✅ MIGRATED - API Controllers
  AllRequestDataApiController allRequestDataApiController =
      Get.put(AllRequestDataApiController());
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());

  // ✅ KEEP - UI state variables
  ColorNotifier notifier = ColorNotifier();
  var decodeUid;
  var userid;
  var currencyy;
  bool loader = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    datagetfunction();

    // ✅ MIGRATED - Initialize socket connection for real-time updates
    _initializeSocket();
  }

  @override
  void dispose() {
    _tabController.dispose();
    SocketService.instance.disconnect();
    super.dispose();
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

  // ✅ MIGRATED - Socket event listeners for ride updates
  void _setupSocketListeners() {
    final socketService = SocketService.instance;

    // Listen for ride status updates
    socketService.on('ride_status_update$useridgloable', (data) {
      _handleRideStatusUpdate(data);
    });

    // Listen for ride completion updates
    socketService.on('ride_completed$useridgloable', (data) {
      _handleRideCompleted(data);
    });

    // Listen for ride cancellation updates
    socketService.on('ride_cancelled$useridgloable', (data) {
      _handleRideCancelled(data);
    });

    if (kDebugMode) print("✅ Socket listeners setup for MyRideScreen");
  }

  // ✅ NEW - Socket event handlers
  void _handleRideStatusUpdate(dynamic data) {
    if (!mounted) return;

    try {
      if (kDebugMode) print("🔄 Ride status update received: $data");

      // Refresh ride data when status changes
      _refreshRideData();
    } catch (e) {
      if (kDebugMode) print("❌ Error handling ride status update: $e");
    }
  }

  void _handleRideCompleted(dynamic data) {
    if (!mounted) return;

    try {
      if (kDebugMode) print("✅ Ride completed update received: $data");

      // Refresh ride data and show completion message
      _refreshRideData();

      Get.snackbar(
        "Ride Completed".tr,
        "Your ride has been completed successfully!".tr,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) print("❌ Error handling ride completion: $e");
    }
  }

  void _handleRideCancelled(dynamic data) {
    if (!mounted) return;

    try {
      if (kDebugMode) print("❌ Ride cancelled update received: $data");

      // Refresh ride data and show cancellation message
      _refreshRideData();

      Get.snackbar(
        "Ride Cancelled".tr,
        "Your ride has been cancelled.".tr,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) print("❌ Error handling ride cancellation: $e");
    }
  }

  // ✅ NEW - Refresh ride data method
  void _refreshRideData() {
    if (userid != null) {
      allRequestDataApiController
          .allrequestApi(uid: userid.toString(), status: "upcoming")
          .then((_) {
        allRequestDataApiController
            .allrequestApi(uid: userid.toString(), status: "completed")
            .then((_) {
          allRequestDataApiController
              .allrequestApi(uid: userid.toString(), status: "cancelled")
              .then((_) {
            if (mounted) {
              setState(() {});
            }
          });
        });
      });
    }
  }

  // ✅ MIGRATED - Data loading with enhanced error handling
  datagetfunction() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var uid = preferences.getString("userLogin");
      var currency = preferences.getString("currenci");

      if (uid == null) {
        if (kDebugMode) print("❌ No user login data found");
        setState(() {
          loader = false;
        });
        return;
      }

      decodeUid = jsonDecode(uid);
      if (currency != null) {
        currencyy = jsonDecode(currency);
      }
      userid = decodeUid['id'];

      if (kDebugMode) {
        print("✅ User data loaded: $userid");
        print("✅ Currency loaded: $currencyy");
      }

      setState(() {});

      // ✅ IMPROVED - Sequential API calls with better error handling
      await _loadRideData();
    } catch (e) {
      if (kDebugMode) print("❌ Error loading user data: $e");
      setState(() {
        loader = false;
      });
    }
  }

  // ✅ NEW - Centralized ride data loading
  Future<void> _loadRideData() async {
    try {
      // Load upcoming rides
      await allRequestDataApiController.allrequestApi(
        uid: userid.toString(),
        status: "upcoming",
      );

      if (!mounted) return;
      setState(() {});

      // Load completed rides
      await allRequestDataApiController.allrequestApi(
        uid: userid.toString(),
        status: "completed",
      );

      if (!mounted) return;
      setState(() {});

      // Load cancelled rides
      await allRequestDataApiController.allrequestApi(
        uid: userid.toString(),
        status: "cancelled",
      );

      if (!mounted) return;
      setState(() {
        loader = false;
      });

      if (kDebugMode) print("✅ All ride data loaded successfully");
    } catch (e) {
      if (kDebugMode) print("❌ Error loading ride data: $e");
      if (mounted) {
        setState(() {
          loader = false;
        });
      }
    }
  }

  // ✅ NEW - Navigate to ride detail with enhanced data
  void _navigateToRideDetail(String requestId, String status, int index) {
    // ✅ MIGRATED - Update global variables for ride detail screen
    if (status == "upcoming") {
      final ride = allRequestDataApiController
          .allRequestDataModelupcoming!.reuqestList![index];

      // Set global timer variables for upcoming rides
      if (ride.runTime != null) {
        tot_time = ride.runTime!.minute.toString();
        extratime = ride.runTime!.hour.toString();
        tot_secound = ride.runTime!.second.toString();
      }

      // Set global location variables
      if (ride.pickup != null) {
        picktitle = ride.pickup!.title.toString();
        picksubtitle = ride.pickup!.subtitle.toString();
      }

      if (ride.drop != null) {
        droptitle = ride.drop!.title.toString();
        dropsubtitle = ride.drop!.subtitle.toString();
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyRideDetailScreen(
          request_id: requestId,
          status: status,
        ),
      ),
    );
  }

  // ✅ NEW - Handle ride action (complete/cancel)
  void _handleRideAction(String requestId, String action, int index) {
    if (action == "complete") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RideCompletePaymentScreen(),
        ),
      );
    } else {
      if (kDebugMode) print("Action: $action for ride: $requestId");
    }
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    // ✅ MIGRATED - Wrap with Consumer for provider state management
    return Consumer4<LocationState, MapState, PricingState, RideRequestState>(
      builder: (context, locationState, mapState, pricingState,
          rideRequestState, child) {
        return Scaffold(
          backgroundColor: notifier.background,
          appBar: AppBar(
            backgroundColor: notifier.background,
            automaticallyImplyLeading: false,
            elevation: 0,
            leading: InkWell(
              onTap: () {
                Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Image(
                  image: const AssetImage("assets/arrow-left.png"),
                  color: notifier.textColor,
                ),
              ),
            ),
            title: Transform.translate(
              offset: const Offset(-10, 0),
              child: Text(
                "My Rides".tr,
                style: TextStyle(color: notifier.textColor, fontSize: 18),
              ),
            ),
          ),
          body: GetBuilder<AllRequestDataApiController>(
            builder: (allRequestDataApiController) {
              return loader
                  ? const Center(
                      child: ModernLoadingWidget(
                        size: 60,
                        message: "جاري تحميل الرحلات...", // Loading rides...
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 15),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0, right: 0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 5),

                                  // ✅ ENHANCED - Tab bar with improved styling
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, bottom: 10),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Colors.grey.withOpacity(0.4)),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(16)),
                                      ),
                                      child: TabBar(
                                        indicator: BoxDecoration(
                                          color: theamcolore,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        controller: _tabController,
                                        indicatorColor: Colors.red,
                                        labelColor: Colors.white,
                                        unselectedLabelColor:
                                            notifier.textColor,
                                        dividerColor: Colors.transparent,
                                        labelStyle:
                                            const TextStyle(fontSize: 14),
                                        tabs: <Widget>[
                                          Tab(text: 'Upcoming'.tr),
                                          Tab(text: 'Completed'.tr),
                                          Tab(text: 'Cancelled'.tr),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // ✅ ENHANCED - Tab bar view with improved content
                                  Expanded(
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: <Widget>[
                                        // ✅ UPCOMING RIDES TAB
                                        _buildRidesList(
                                          allRequestDataApiController
                                                  .allRequestDataModelupcoming
                                                  ?.reuqestList ??
                                              [],
                                          "upcoming",
                                        ),

                                        // ✅ COMPLETED RIDES TAB
                                        _buildRidesList(
                                          allRequestDataApiController
                                                  .allRequestDataModelcompleted
                                                  ?.reuqestList ??
                                              [],
                                          "completed",
                                        ),

                                        // ✅ CANCELLED RIDES TAB
                                        _buildRidesList(
                                          allRequestDataApiController
                                                  .allRequestDataModelcancelled
                                                  ?.reuqestList ??
                                              [],
                                          "cancelled",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
            },
          ),
        );
      },
    );
  }

  // ✅ NEW - Reusable rides list builder
  Widget _buildRidesList(List<dynamic> rides, String status) {
    if (rides.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 0),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: rides.length,
      itemBuilder: (BuildContext context, int index) {
        final ride = rides[index];
        return _buildRideCard(ride, status, index);
      },
    );
  }

  // ✅ NEW - Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/emptyOrder.png"),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "No Order Found!".tr,
            style: TextStyle(
              color: notifier.textColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Currently you don't have order.".tr,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW - Enhanced ride card widget
  Widget _buildRideCard(dynamic ride, String status, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: InkWell(
        onTap: () {
          _navigateToRideDetail(
            ride.id.toString(),
            status == "completed" ? "complete" : status,
            index,
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Ride header with status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "#${ride.id}",
                      style: TextStyle(
                        color: notifier.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ✅ Pickup location
                if (ride.pickup != null) ...[
                  Row(
                    children: [
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${ride.pickup.title}",
                          style: TextStyle(
                            color: notifier.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],

                // ✅ Drop location
                if (ride.drop != null) ...[
                  Row(
                    children: [
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${ride.drop.title}",
                          style: TextStyle(
                            color: notifier.textColor,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // ✅ Additional drop locations if any
                if (ride.dropList != null && ride.dropList.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  for (int i = 0; i < ride.dropList.length; i++) ...[
                    Row(
                      children: [
                        Container(
                          height: 6,
                          width: 6,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "${ride.dropList[i].title}",
                            style: TextStyle(
                              color: notifier.textColor.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                  ],
                ],

                const SizedBox(height: 10),

                // ✅ Ride metadata
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (ride.bookingDate != null)
                      Text(
                        "${ride.bookingDate}",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    if (ride.total != null)
                      Text(
                        "${ride.total} ${currencyy ?? 'SAR'}",
                        style: TextStyle(
                          color: theamcolore,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ NEW - Get status color helper
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
