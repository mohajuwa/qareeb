// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/api_code/global_driver_access_api_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/common_code/socket_service.dart';
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/map_state.dart';
import 'package:qareeb/providers/pricing_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';
import 'package:qareeb/providers/timer_state.dart';
import 'package:qareeb/app_screen/driver_detail_screen.dart';
import 'package:qareeb/app_screen/home_screen.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';
import 'package:qareeb/common_code/common_button.dart';
import 'package:qareeb/common_code/config.dart';
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
  // API Controllers
  AddVihicalCalculateController addVihicalCalculateController =
      Get.put(AddVihicalCalculateController());
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());
  CalculateController calculateController = Get.put(CalculateController());

  // Animation management
  List<AnimationController> controllers = [];
  List<double> progressList = [];
  bool isControllerDisposed = false;
  bool isanimation = false;
  bool buttontimer = false;

  // User data
  var decodeUid;
  var userid;
  var currencyy;
  ColorNotifier notifier = ColorNotifier();

  @override
  void initState() {
    super.initState();
    datagetfunction();
    socketConnect();
  }

  @override
  void dispose() {
    _disposeControllers();
    SocketService.instance.off("accept_bidding_success$useridgloable");
    super.dispose();
  }

  void _disposeControllers() {
    for (var ctrl in controllers) {
      try {
        ctrl.dispose();
      } catch (e) {
        if (kDebugMode) print("Controller disposal error: $e");
      }
    }
    controllers.clear();
  }

  datagetfunction() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("userLogin");
    var currency = preferences.getString("currenci");

    if (uid != null && currency != null) {
      decodeUid = jsonDecode(uid);
      currencyy = jsonDecode(currency);
      userid = decodeUid['id'];

      if (kDebugMode) {
        print("User ID: $userid");
        print("Currency: $currencyy");
      }

      if (mounted) setState(() {});
      _initializeAnimations();
    }
  }

  void _initializeAnimations() {
    final globalDriverClass = globalDriverAcceptClass;

    // Use the global driver class bidding data
    if (globalDriverClass.vehicleBiddingDriver.isNotEmpty) {
      controllers.clear();
      progressList.clear();

      for (int i = 0; i < globalDriverClass.vehicleBiddingDriver.length; i++) {
        final duration = i < globalDriverClass.vehicleBiddingSecounds.length
            ? globalDriverClass.vehicleBiddingSecounds[i] as int? ?? 30
            : 30;

        AnimationController animController = AnimationController(
          duration: Duration(seconds: duration),
          vsync: this,
        );

        controllers.add(animController);
        progressList.add(0.0);

        animController.addListener(() {
          if (mounted) {
            setState(() {
              progressList[i] = animController.value;
            });
          }
        });

        animController.addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            if (kDebugMode) print("Timer completed for driver $i");
          }
        });

        animController.forward();
      }
    }
  }

  socketConnect() async {
    try {
      SocketService.instance.connect();
      _connectSocket();
    } catch (e) {
      if (kDebugMode) print("❌ Socket connection error: $e");
    }
  }

  _connectSocket() async {
    if (kDebugMode) print("Setting up driver list socket listeners...");

    SocketService.instance.on("accept_bidding_success$useridgloable", (data) {
      if (kDebugMode) print("Accept bidding success: $data");
      if (data != null && data["success"] == true) {
        final locationState = context.read<LocationState>();

        globalDriverAcceptClass.driverdetailfunction(
          context: context,
          lat: locationState.latitudePick,
          long: locationState.longitudePick,
          d_id: data["driver_id"]?.toString() ?? d_id.toString(),
          request_id: data["cart_id"]?.toString() ?? request_id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    return Consumer3<LocationState, MapState, PricingState>(
      builder: (context, locationState, mapState, pricingState, child) {
        final globalDriverClass = globalDriverAcceptClass;

        return Scaffold(
          backgroundColor: notifier.background,
          body: Column(
            children: [
              // Header section
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: theamcolore,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Get.back(),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            "Driver Bidding List".tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    locationState.pickupController.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    locationState.dropController.text,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
              ),

              // Driver list section
              Expanded(
                child: globalDriverClass.vehicleBiddingDriver.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.hourglass_empty,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Waiting for drivers...".tr,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Drivers will appear here when they bid for your ride"
                                  .tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount:
                            globalDriverClass.vehicleBiddingDriver.length,
                        itemBuilder: (context, index) {
                          final driver =
                              globalDriverClass.vehicleBiddingDriver[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: notifier.containercolore,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Driver info row
                                Row(
                                  children: [
                                    // Driver image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: driver["driver_image"] != null &&
                                              driver["driver_image"] != ""
                                          ? Image.network(
                                              "${Config.imageurl}${driver["driver_image"]}",
                                              height: 60,
                                              width: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 60,
                                                  width: 60,
                                                  color: Colors.grey[300],
                                                  child:
                                                      const Icon(Icons.person),
                                                );
                                              },
                                            )
                                          : Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                color: theamcolore,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  (driver["driver_name"]
                                                              ?.toString() ??
                                                          "Driver")[0]
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 15),

                                    // Driver details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            driver["driver_name"]?.toString() ??
                                                "Driver",
                                            style: TextStyle(
                                              color: notifier.textColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                driver["driver_rating"]
                                                        ?.toString() ??
                                                    "0.0",
                                                style: TextStyle(
                                                  color: notifier.textColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "${driver["vehicle_type"] ?? ""} • ${driver["vehicle_color"] ?? ""}",
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            driver["vehicle_number"]
                                                    ?.toString() ??
                                                "",
                                            style: TextStyle(
                                              color: notifier.textColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Price
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "$currencyy${driver["price"] ?? "0"}",
                                          style: TextStyle(
                                            color: theamcolore,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Bid Price".tr,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                // Timer progress bar
                                if (index < progressList.length &&
                                    index <
                                        globalDriverClass
                                            .vehicleBiddingSecounds.length)
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Bid expires in".tr,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            "${((1 - progressList[index]) * (globalDriverClass.vehicleBiddingSecounds[index] as int)).round()}s",
                                            style: TextStyle(
                                              color: theamcolore,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: progressList[index],
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                theamcolore),
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 15),

                                // Action buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: CommonOutLineButton(
                                        bordercolore: Colors.red,
                                        onPressed1: () {
                                          // Decline bidding
                                          if (kDebugMode)
                                            print(
                                                "Declining driver: ${driver["id"]}");
                                          if (kDebugMode)
                                            print("User ID: $useridgloable");

                                          SocketService.instance
                                              .emit('Bidding_decline', {
                                            'uid': useridgloable,
                                            'id': driver["id"],
                                            'request_id': request_id,
                                          });

                                          // Remove from UI
                                          setState(() {
                                            if (index < controllers.length) {
                                              try {
                                                if (!controllers[index]
                                                        .isCompleted &&
                                                    !controllers[index]
                                                        .isDismissed) {
                                                  controllers[index].dispose();
                                                }
                                              } catch (e) {
                                                if (kDebugMode)
                                                  print(
                                                      "Controller disposal error: $e");
                                              }
                                              controllers.removeAt(index);
                                              progressList.removeAt(index);
                                            }
                                          });

                                          // Remove from global driver class
                                          globalDriverClass.vehicleBiddingDriver
                                              .removeAt(index);
                                          if (index <
                                              globalDriverClass
                                                  .vehicleBiddingSecounds
                                                  .length) {
                                            globalDriverClass
                                                .vehicleBiddingSecounds
                                                .removeAt(index);
                                          }
                                        },
                                        context: context,
                                        txt1: "Decline".tr,
                                        clore: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: CommonButton(
                                        containcolore: Colors.green,
                                        onPressed1: () {
                                          // Accept bidding
                                          setState(() {
                                            buttontimer = false;
                                            isanimation = false;
                                            isControllerDisposed = true;

                                            // Set global variables
                                            d_id = driver["id"];
                                            driver_id =
                                                driver["id"]?.toString() ?? "";
                                            price =
                                                driver["price"]?.toString() ??
                                                    "0";
                                          });

                                          // Emit accept bidding
                                          SocketService.instance
                                              .emit('Accept_Bidding', {
                                            'uid': useridgloable,
                                            'd_id': driver["id"],
                                            'request_id': request_id,
                                            'price':
                                                driver["price"]?.toString() ??
                                                    "0",
                                          });

                                          if (kDebugMode)
                                            print(
                                                "Accepted driver: ${driver["id"]}");
                                        },
                                        context: context,
                                        txt1: "Accept".tr,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Bottom section with pricing info
              if (pricingState.dropPrice > 0)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: notifier.containercolore,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Estimated Fare".tr,
                        style: TextStyle(
                          color: notifier.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Base Fare".tr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "$currencyy${pricingState.dropPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: notifier.textColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (pricingState.minimumfare > 0) ...[
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Minimum Fare".tr,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "$currencyy${pricingState.minimumfare.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: notifier.textColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (pricingState.maximumfare > 0) ...[
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Maximum Fare".tr,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "$currencyy${pricingState.maximumfare.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: notifier.textColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
