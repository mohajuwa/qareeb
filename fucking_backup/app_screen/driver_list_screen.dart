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
import 'package:http/http.dart' as http;
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
  bool _rideAccepted = false; // Add this flag

  int d_id = 0;
  num price = 0;
  ColorNotifier notifier = ColorNotifier();

  // Add method to stop timer when accepting
  void stopTimerAndAccept() {
    if (countdownTimer != null && countdownTimer!.isActive) {
      countdownTimer!.cancel();
      if (kDebugMode) print("Timer stopped for immediate acceptance");
    }

    // Stop the main controller too
    if (controller != null && controller!.isAnimating) {
      controller!.stop();
      if (kDebugMode) print("Main animation controller stopped");
    }

    _rideAccepted = true;
  }

  // Updated timer method
  void startTimer() {
    if (_isDisposed || _rideAccepted) return;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !mounted || _rideAccepted) {
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

      // Check if all timers finished and no acceptance happened
      bool allTimersFinished =
          vehicle_bidding_secounde.every((time) => time <= 0);
      if (allTimersFinished && !_rideAccepted) {
        timer.cancel();
        if (mounted && !_rideAccepted) {
          if (kDebugMode) print("All timers finished, going back");
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    socketConnect();
    startTimer();
    if (kDebugMode) print("Initializing with duration ($durationInSeconds)");
    buttontimer = true;
    if (kDebugMode) print("========= BUTTONTIMER :- $buttontimer");

    if (controller == null || !controller!.isAnimating) {
      controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: durationInSeconds),
      );

      controller!.addStatusListener((status) {
        if (status == AnimationStatus.completed && !_rideAccepted) {
          if (kDebugMode) print("Main timer finished!");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_rideAccepted) {
              Get.back();
            }
          });
        }
      });

      controller!.forward();
    }
  }

  @override
  void dispose() {
    if (kDebugMode) print("DriverListScreen dispose called");
    _isDisposed = true;

    // Cancel timer
    countdownTimer?.cancel();

    // Dispose main controller safely
    if (controller != null && !controller!.isDismissed) {
      try {
        controller!.dispose();
      } catch (e) {
        if (kDebugMode) print("Error disposing main controller: $e");
      }
    }

    // Dispose all animation controllers
    for (var controller in controllers) {
      if (!controller.isDismissed) {
        try {
          controller.dispose();
        } catch (e) {
          if (kDebugMode) print("Error disposing controller: $e");
        }
      }
    }
    controllers.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.driverlistcolore,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Column(
          children: [
            AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: InkWell(
                onTap: () {
                  setState(() {
                    Get.back();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SvgPicture.asset("assets/svgpicture/BackIcon.svg"),
                ),
              ),
              backgroundColor: notifier.containercolore,
              centerTitle: true,
              title: Text(
                "Choose a driver".tr,
                style: TextStyle(color: notifier.textColor),
              ),
            ),
            Container(
              height: 50,
              width: Get.width,
              color: theamcolore.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Text("👋", style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        "Driver can offer their fare and time".tr,
                        style:
                            TextStyle(color: notifier.textColor, fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                clipBehavior: Clip.none,
                itemCount: vehicle_bidding_driver.length,
                itemBuilder: (context, index) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        width: Get.width,
                        decoration: BoxDecoration(
                          color: notifier.containercolore,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Your fare indicator
                              priceyourfare ==
                                      vehicle_bidding_driver[index]["price"]
                                  ? Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: theamcolore,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Center(
                                            child: Text(
                                              "Your fare",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              const SizedBox(height: 10),

                              // Driver info
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    driver_id = vehicle_bidding_driver[index]
                                            ["id"]
                                        .toString();
                                    driverdetailbottomsheet();
                                  });
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                "${Config.imageurl}${vehicle_bidding_driver[index]["profile_image"]}"),
                                            fit: BoxFit.cover)),
                                  ),
                                  title: Text(
                                    "${vehicle_bidding_driver[index]["car_name"]}",
                                    style: TextStyle(color: notifier.textColor),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${vehicle_bidding_driver[index]["first_name"]} ${vehicle_bidding_driver[index]["last_name"]}",
                                        style: TextStyle(
                                            color: notifier.textColor),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                              "assets/svgpicture/star-fill.svg"),
                                          const SizedBox(width: 5),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 6),
                                            child: Text(
                                              "${vehicle_bidding_driver[index]["avg_star"]}",
                                              style: TextStyle(
                                                  color: notifier.textColor),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$globalcurrency${vehicle_bidding_driver[index]["price"]}",
                                        style: TextStyle(
                                            fontSize: 14.5,
                                            color: notifier.textColor),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "${vehicle_bidding_driver[index]["tot_km"]} km",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: notifier.textColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Accept button
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: CommonButton(
                                        containcolore: Colors.green,
                                        onPressed1: () async {
                                          // FIXED: Stop timer immediately when accepting
                                          stopTimerAndAccept();

                                          setState(() {
                                            d_id = vehicle_bidding_driver[index]
                                                ["id"];
                                            driver_id =
                                                vehicle_bidding_driver[index]
                                                        ["id"]
                                                    .toString();
                                            price =
                                                vehicle_bidding_driver[index]
                                                    ["price"];
                                            vihicalrice = double.parse(
                                                vehicle_bidding_driver[index]
                                                        ["price"]
                                                    .toString());
                                          });

                                          if (kDebugMode) {
                                            print(
                                                "Customer accepting driver bid immediately:");
                                            print(
                                                "  Customer ID: $useridgloable");
                                            print("  Driver ID: $d_id");
                                            print("  Request ID: $request_id");
                                            print("  Price: $price");
                                          }

                                          bool acceptanceSuccess =
                                              await acceptsocate();

                                          if (acceptanceSuccess) {
                                            globalDriverAcceptClass
                                                .driverdetailfunction(
                                              context: context,
                                              lat: latitudepick,
                                              long: longitudepick,
                                              d_id: d_id.toString(),
                                              request_id: request_id.toString(),
                                            );
                                          } else {
                                            // Reset flag if acceptance failed
                                            setState(() {
                                              _rideAccepted = false;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Failed to accept driver. Please try again.")));
                                          }
                                        },
                                        context: context,
                                        txt1: "Accept".tr),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Timer display
                      Positioned(
                        right: 0,
                        top: -15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theamcolore),
                            color: Colors.white,
                          ),
                          child: Text(
                            formatTime(vehicle_bidding_secounde[index]),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theamcolore,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  socketConnect() async {
    socket.connect();
    _connectSocket();
  }

  _connectSocket() async {
    if (kDebugMode) print("DRIVER LIST SOCKET CONNECTED");
  }

  Future<bool> acceptsocate() async {
    if (kDebugMode) {
      print("Customer accepting driver bid: $d_id for request: $request_id");
    }

    try {
      // FIXED: Correct endpoint URL - add 'customer/' prefix
      final response = await http.post(
        Uri.parse('${Config.baseurl}accept_driver_bid'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'uid': useridgloable.toString(), // Customer ID
          'd_id': d_id.toString(), // Driver ID being accepted
          'request_id': request_id.toString(),
          'price': price.toString(),
        }),
      );

      if (kDebugMode) {
        print('Accept bid body: ${json.encode({
              'uid': useridgloable.toString(),
              'd_id': d_id.toString(),
              'request_id': request_id.toString(),
              'price': price.toString(),
            })}');
        print('Accept bid response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['ResponseCode'] == 200 &&
            responseData['Result'] == true) {
          // Emit socket events for real-time updates
          socket.emit('Accept_Bidding', {
            'uid': useridgloable,
            'd_id': d_id,
            'request_id': request_id,
            'price': price,
          });

          // Notify the driver that their bid was accepted
          socket.emit('acceptvehrequest', {
            'uid': d_id,
            'request_id': responseData['cart_id'],
            'c_id': useridgloable,
          });

          if (kDebugMode) {
            print(
                "Driver bid accepted successfully - Cart ID: ${responseData['cart_id']}");
          }
          return true;
        } else {
          if (kDebugMode) print("Accept failed: ${responseData['message']}");
          return false;
        }
      } else {
        if (kDebugMode) print("HTTP error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      if (kDebugMode) print("Accept error: $e");
      return false;
    }
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
