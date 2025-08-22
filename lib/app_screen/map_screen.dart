import 'package:qareeb/common_code/custom_notification.dart';
import 'package:qareeb/common_code/custom_loading_widget.dart';
// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../api_code/coupon_payment_api_contoller.dart';
import '../api_code/home_controller.dart';
import 'home_screen.dart';
import 'pagelist_description.dart';
import 'pickup_drop_point.dart';
import 'profile_screen.dart';
import 'refer_and_earn.dart';
import 'top_up_screen.dart';
import 'dart:ui' as ui;
import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';
import '../common_code/common_flow_screen.dart';
import '../common_code/config.dart';
import '../api_code/add_vehical_api_controller.dart';
import '../api_code/calculate_api_controller.dart';
import '../api_code/delete_api_controller.dart';
import '../api_code/home_map_api_controller.dart';
import '../api_code/home_wallet_api_controller.dart';
import '../api_code/login_controller.dart';
import '../api_code/modual_calculate_api_controller.dart';
import '../api_code/pagelist_api_controller.dart';
import '../api_code/remove_request.dart';
import '../api_code/resend_request_api_controller.dart';
import '../api_code/timeout_request_api_controller.dart';
import '../api_code/vihical_calculate_api_controller.dart';
import '../api_code/vihical_information.dart';
import '../auth_screen/onbording_screen.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../common_code/push_notification.dart';
import 'counter_bottom_sheet.dart';
import 'driver_list_screen.dart';
import 'driver_startride_screen.dart';
import 'faq_screen.dart';
import 'language_screen.dart';
import 'my_ride_screen.dart';
import 'notification_screen.dart';

// bool bottomshhetopen = false;

bool buttontimer = false;

bool darkMode = false;
num priceyourfare = 0;
bool isControllerDisposed = false;
bool isanimation = false;
String mid = "";
String mroal = "";
int select1 = 0;
String globalcurrency = "";
List vehicle_bidding_driver = [];
List vehicle_bidding_secounde = [];
num walleteamount = 0.00;
late IO.Socket socket;
var lathomecurrent;
var longhomecurrent;
String biddautostatus = "false";

AnimationController? controller;
late Animation<Color?> colorAnimation;

int durationInSeconds = 0;

class MapScreen extends StatefulWidget {
  final bool selectvihical;
  const MapScreen({super.key, required this.selectvihical});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final List<LatLng> vihicallocations = [];
  final List<String> _iconPaths = [];
  final List<String> _iconPathsbiddingon = [];
  final List<LatLng> vihicallocationsbiddingon = [];
  List<PointLatLng> _dropOffPoints = [];
  List<bool> couponadd = [];

  // bool timeout = false;

  String themeForMap = "";

  bool isLoad = false;

  bool light = false;
  bool switchValue = false;
  // int pricecounr = 0;
  int toast = 0;
  int payment = 0;
  String paymentname = "";
  String selectedOption = "";
  String selectBoring = "";
  int couponAmt = 0;
  String couponId = "";
  String couponname = "";
  String mainamount = "";

  var lathome;
  var longhome;
  var addresshome;
  var decodeUid;
  var userid;
  var currencyy;
  String username = "";

  final DraggableScrollableController sheetController =
      DraggableScrollableController();
  ResendRequestApiController resendRequestApiController =
      Get.put(ResendRequestApiController());
  RemoveRequest removeRequest = Get.put(RemoveRequest());
  TimeoutRequestApiController timeoutRequestApiController =
      Get.put(TimeoutRequestApiController());

  HomeApiController homeApiController = Get.put(HomeApiController());
  DeleteAccount deleteAccount = Get.put(DeleteAccount());
  PaymentGetApiController paymentGetApiController =
      Get.put(PaymentGetApiController());
  HomeMapController homeMapController = Get.put(HomeMapController());
  CalculateController calculateController = Get.put(CalculateController());
  Modual_CalculateController modual_calculateController =
      Get.put(Modual_CalculateController());
  HomeWalletApiController homeWalletApiController =
      Get.put(HomeWalletApiController());
  AddVihicalCalculateController addVihicalCalculateController =
      Get.put(AddVihicalCalculateController());
  VihicalInformationApiController vihicalInformationApiController =
      Get.put(VihicalInformationApiController());
  VihicalCalculateController vihicalCalculateController =
      Get.put(VihicalCalculateController());
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());
  TextEditingController amountcontroller = TextEditingController();

  // late AnimationController controller;
  // late Animation<Color?> colorAnimation;
  Timer? _mainTimer;
  Timer? _socketTimer;
  Timer? _animationTimer;
  bool _isDisposed = false;

  void resetMapScreenState() {
    if (kDebugMode) print("🔄 Resetting map screen state...");

    if (mounted) {
      setState(() {
        // Reset animation states

        isanimation = false;

        isControllerDisposed = true;

        buttontimer = false;

        loadertimer = false;

        // Reset bidding data

        vehicle_bidding_driver.clear();

        vehicle_bidding_secounde.clear();

        // Reset driver data

        driveridloader = false;

        // Reset request state

        if (calculateController.calCulateModel != null) {
          calculateController.calCulateModel!.driverId?.clear();
        }
      });
    }

    // Cancel any running timers

    _mainTimer?.cancel();

    _mainTimer = null;

    // Cancel animation timer if exists

    _animationTimer?.cancel();

    _animationTimer = null;

    // Dispose animation controller safely

    if (controller != null && !isControllerDisposed) {
      try {
        if (controller!.isAnimating) {
          controller!.stop();
        }

        controller!.dispose();

        controller = null;

        isControllerDisposed = true;
      } catch (e) {
        if (kDebugMode) print("Error disposing controller in reset: $e");
      }
    }

    // Reset socket listeners if needed

    _reconnectSocketIfNeeded();

    if (kDebugMode) print("✅ Map screen state reset completed");
  }

  // ✅ NEW: Method to safely reconnect socket

  void _reconnectSocketIfNeeded() {
    try {
      if (!socket.connected) {
        if (kDebugMode) print("🔌 Reconnecting socket...");

        socket.connect();

        // Re-establish critical socket listeners

        _connectSocket();
      }
    } catch (e) {
      if (kDebugMode) print("Socket reconnection error: $e");
    }
  }
  // socate code

  socketConnect() async {
    if (_isDisposed) return;

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var uid = preferences.getString("userLogin");

      if (uid == null || _isDisposed) return;

      decodeUid = jsonDecode(uid);
      userid = decodeUid['id'];
      username = decodeUid["name"];
      useridgloable = decodeUid['id'];

      if (kDebugMode) {
        print("++++:---  $userid");
        print("++ currencyy ++:---  $currencyy");
      }

      if (_isDisposed) return;

      setState(() {});

      socket = IO.io(Config.imageurl, <String, dynamic>{
        'autoConnect': false,
        'transports': ['websocket'],
      });
      socket.connect();

      socket.onConnect((_) {
        if (kDebugMode) print('Connected');
        if (!_isDisposed) {
          socket.emit('message', 'Hello from Flutter');
        }
      });

      _connectSocket();
    } catch (e) {
      if (kDebugMode) print("Socket connection error: $e");
    }
  }

  _connectSocket() async {
    if (_isDisposed) return;

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      socket.onConnect((data) {
        if (kDebugMode) print('Connection established Connected map screen');
      });

      socket.onConnectError((data) {
        if (kDebugMode) print('Connect Error map screen: $data');
      });

      socket.onDisconnect((data) {
        if (kDebugMode) print('Socket.IO server disconnected map screen');
      });

      // ✅ NEW: Listen for screen state reset events
      socket.on("reset_customer_state$useridgloable", (data) {
        if (_isDisposed || !mounted) return;

        if (kDebugMode) print("🔄 Received reset state command");
        resetMapScreenState();
      });

      // Wallet API call with safety checks
      if (!_isDisposed && userid != null) {
        homeWalletApiController
            .homwwalleteApi(uid: userid.toString(), context: context)
            .then((value) {
          if (!_isDisposed && mounted && value != null) {
            if (kDebugMode) {
              print("{{{{{[wallete}}}}}]:-- ${value["wallet_amount"]}");
            }
            walleteamount = double.parse(value["wallet_amount"]);
            if (kDebugMode) {
              print(
                  "[[[[[[[[[[[[[walleteamount]]]]]]]]]]]]]:-- ($walleteamount)");
            }
          }
        }).catchError((error) {
          if (kDebugMode) print("Wallet API error: $error");
        });
      }

      // Home API call with safety checks
      if (!_isDisposed &&
          userid != null &&
          lathome != null &&
          longhome != null) {
        homeApiController
            .homeApi(
                uid: userid.toString(),
                lat: lathome.toString(),
                lon: longhome.toString())
            .then((value) {
          if (_isDisposed || !mounted) return;

          mid = homeApiController.homeapimodel!.categoryList![0].id.toString();
          mroal =
              homeApiController.homeapimodel!.categoryList![0].role.toString();
        }).catchError((error) {
          if (kDebugMode) print("Socket home event error: $error");
        });
      }

      // ✅ ENHANCED: Driver location updates
      socket.on("Driver_location_On", (Driver_location_On) async {
        if (_isDisposed || !mounted) return;

        try {
          if (kDebugMode) {
            print("++++++ Driver_location_On ++++ :---  $Driver_location_On");
          }

          List zonelist = Driver_location_On["zone_list"];

          if (zonelist.contains(homeMapController.homeMapApiModel!.zoneId)) {
            LatLng postion = LatLng(
                double.parse(Driver_location_On["latitude"]),
                double.parse(Driver_location_On["longitude"]));
            final Uint8List markIcon = await getNetworkImage(
                "${Config.imageurl}${Driver_location_On["image"]}");
            MarkerId markerId = MarkerId(Driver_location_On["id"].toString());
            Marker marker = Marker(
              markerId: markerId,
              icon: BitmapDescriptor.fromBytes(markIcon),
              position: postion,
            );

            if (!_isDisposed && mounted) {
              markers[markerId] = marker;
              markers11[markerId] = marker;
              setState(() {});
            }
          }
        } catch (e) {
          if (kDebugMode) print("Driver location on error: $e");
        }
      });

      // ✅ ENHANCED: Driver location updates
      socket.on("Driver_location_Update", (Driver_location_Update) async {
        if (_isDisposed || !mounted) return;

        try {
          if (kDebugMode) {
            print(
                "++++++ Driver_location_Update ++++ :---  $Driver_location_Update");
          }

          LatLng postion = LatLng(
              double.parse(Driver_location_Update["latitude"]),
              double.parse(Driver_location_Update["longitude"]));
          final Uint8List markIcon = await getNetworkImage(
              "${Config.imageurl}${Driver_location_Update["image"]}");

          MarkerId markerId = MarkerId(Driver_location_Update["id"].toString());
          Marker marker = Marker(
            markerId: markerId,
            icon: BitmapDescriptor.fromBytes(markIcon),
            position: postion,
          );

          if (!_isDisposed && mounted) {
            markers[markerId] = marker;
            if (markers.containsKey(markerId)) {
              final Marker oldMarker = markers[markerId]!;
              final Marker updatedMarker = oldMarker.copyWith(
                positionParam: postion,
              );
              markers[markerId] = updatedMarker;
            }

            // Update markers11 as well
            markers11[markerId] = marker;
            if (markers11.containsKey(markerId)) {
              final Marker oldMarker = markers11[markerId]!;
              final Marker updatedMarker = oldMarker.copyWith(
                positionParam: postion,
              );
              markers11[markerId] = updatedMarker;
            }

            setState(() {});
          }
        } catch (e) {
          if (kDebugMode) print("Driver location update error: $e");
        }
      });
      socket.on("Vehicle_Bidding$userid", (Vehicle_Bidding) {
        if (_isDisposed || !mounted) return;

        if (kDebugMode) {
          print("++++++ Vehicle_Bidding ++++ :---  $Vehicle_Bidding");
        }

        setState(() {
          vehicle_bidding_driver = Vehicle_Bidding["bidding_list"];

          vehicle_bidding_secounde = [];

          for (int i = 0; i < vehicle_bidding_driver.length; i++) {
            vehicle_bidding_secounde
                .add(Vehicle_Bidding["bidding_list"][i]["diff_second"]);
          }
        });

        // ✅ CRITICAL: Ensure proper navigation cleanup before going to DriverList

        if (Get.isDialogOpen == true) {
          Get.back();
        }

        // ✅ FIXED: Use regular Navigator.push instead of pushReplacement

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DriverListScreen()),
        ).then((_) {
          // ✅ CRITICAL: Reset state when returning from DriverListScreen

          if (kDebugMode) {
            print("📱 Returned from DriverListScreen, resetting state");
          }

          resetMapScreenState();
        });

        if (vehicle_bidding_driver.isEmpty) {
          Get.back();

          Buttonpresebottomshhet();
        }
      });
      // ✅ ENHANCED: Vehicle request acceptance with cleanup
      socket.on('acceptvehrequest$useridgloable', (acceptvehrequest) {
        if (_isDisposed || !mounted) return;

        // ✅ CRITICAL: Cleanup before processing acceptance
        resetMapScreenState();

        socket.close();

        if (kDebugMode) {
          print("++++++ /acceptvehrequest map/ ++++ :---  $acceptvehrequest");
          print(
              "acceptvehrequest is of type map: ${acceptvehrequest.runtimeType}");
        }

        setState(() {
          isanimation = false;
          isControllerDisposed = true;
          loadertimer = true;
        });

        // Safely dispose controller
        if (controller != null && controller!.isAnimating) {
          try {
            controller!.dispose();
            controller = null;
          } catch (e) {
            if (kDebugMode) print("Error disposing controller in socket: $e");
          }
        }

        try {
          vihicalrice = double.parse(amountcontroller.text);
        } catch (a) {
          if (kDebugMode) print("Price parsing error:-- $a");
        }

        if (acceptvehrequest["c_id"]
            .toString()
            .contains(useridgloable.toString())) {
          if (kDebugMode) print("condition done");
          driveridloader = false;

          if (!_isDisposed && mounted) {
            globalDriverAcceptClass.driverdetailfunction(
                context: context,
                lat: latitudepick,
                long: longitudepick,
                d_id: acceptvehrequest["uid"].toString(),
                request_id: acceptvehrequest["request_id"].toString());
          }
        } else {
          if (kDebugMode) print("condition not done");
        }
      });

      // ✅ NEW: Listen for bidding responses from drivers
      socket.on("Accept_Bidding_Response$useridgloable", (response) {
        if (_isDisposed || !mounted) return;

        if (kDebugMode) {
          print("🎯 Accept_Bidding_Response received in map: $response");
        }

        // This will be handled by DriverListScreen, but we can log it here
      });

      socket.on("Bidding_decline_Response$useridgloable", (response) {
        if (_isDisposed || !mounted) return;

        if (kDebugMode) {
          print("❌ Bidding_decline_Response received in map: $response");
        }

        // This will be handled by DriverListScreen, but we can log it here
      });

      // ✅ NEW: Handle customer data removal (ride cancelled/completed)
      socket.on("removecustomerdata$useridgloable", (removecustomerdata) {
        if (_isDisposed || !mounted) return;

        if (kDebugMode) {
          print("🗑️ removecustomerdata received in map: $removecustomerdata");
        }

        // Reset map state when ride is removed
        resetMapScreenState();

        // Close any open dialogs
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      });

      // ✅ EXISTING: Your other socket listeners (add any others you have)
      // Add any other socket.on() listeners you might have in your original code here...
    } catch (e) {
      if (kDebugMode) print("_connectSocket error: $e");
    }
  }

  Timer? timer;

  bool isTimerRunning = false;

  void startTimer() {
    if (isTimerRunning || _isDisposed) return;

    isTimerRunning = true;

    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !mounted) {
        timer.cancel();

        isTimerRunning = false;

        return;
      }

      setState(() {
        // Your timer logic here
      });
    });
  }

  void cancelTimer() {
    if (kDebugMode) print("Canceling timer");

    _mainTimer?.cancel();

    _mainTimer = null;

    if (controller != null && !isControllerDisposed) {
      try {
        if (controller!.isAnimating) {
          controller!.stop();
        }

        controller!.dispose();

        controller = null;

        isControllerDisposed = true;
      } catch (e) {
        if (kDebugMode) print("Error in cancelTimer: $e");
      }
    }

    if (isTimerRunning) {
      isTimerRunning = false;

      if (kDebugMode) print("Timer canceled");
    }
  }

  requesttime() {
    if (_isDisposed) return;

    durationInSeconds = int.parse(
        calculateController.calCulateModel!.offerExpireTime.toString());
    if (kDebugMode) print("DURATION IN SECONDS : - $durationInSeconds");

    startTimer();

    if (_isDisposed) return;

    controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: int.parse(
          calculateController.calCulateModel!.offerExpireTime.toString(),
        ),
      ),
    );

    colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.green,
    ).animate(controller!);

    if (kDebugMode) print('Animation Duration: $durationInSeconds seconds');

    controller!.addStatusListener((status) {
      if (_isDisposed || !mounted) return;

      if (status == AnimationStatus.completed) {
        if (kDebugMode) print("Timer finished!");

        if (isControllerDisposed) {
          if (kDebugMode) {
            print(
                "Controller has already been disposed. Skipping further actions.");
          }
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _isDisposed) return;

          cancelTimer();
          if (kDebugMode) print("Timer finished 111 !");

          setState(() {
            isanimation = false;
          });

          Get.back();

          timeoutRequestApiController
              .timeoutrequestApi(
                  uid: userid.toString(), request_id: request_id.toString())
              .then((value) {
            if (_isDisposed || !mounted) return;

            if (kDebugMode) {
              print("*****value data******:--- $value");
              print("*****value data******:--- ${value["driverid"]}");
            }

            // Your existing bottom sheet code here, but wrap any setState calls with setState
            Get.bottomSheet(
              isDismissible: false,
              enableDrag: false,
              StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/svgpicture/exclamation-circle.svg",
                                height: 25,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Captains are busy".tr,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16, bottom: 20, left: 0),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.green, width: 4),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Container(
                                          height: 10,
                                          width: 3,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Container(
                                          height: 10,
                                          width: 3,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        textfieldlist.isNotEmpty
                                            ? const SizedBox()
                                            : Container(
                                                height: 10,
                                                width: 3,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                              ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.red, width: 4)),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        textfieldlist.isEmpty
                                            ? const SizedBox()
                                            : Container(
                                                height: 10,
                                                width: 3,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  flex: 12,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Transform.translate(
                                          offset: picktitle == ""
                                              ? const Offset(0, 0)
                                              : const Offset(0, -10),
                                          child: ListTile(
                                            // isThreeLine: true,
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(
                                                "${picktitle == "" ? addresspickup : picktitle}"),
                                            subtitle: Text(
                                              picksubtitle,
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Transform.translate(
                                          offset: const Offset(0, -30),
                                          child: ListTile(
                                            // isThreeLine: true,
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(droptitle),
                                            subtitle: Text(
                                              dropsubtitle,
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          textfieldlist.isEmpty
                              ? const SizedBox()
                              : Transform.translate(
                                  offset: const Offset(0, -30),
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: textfieldlist.length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              clipBehavior: Clip.none,
                                              shrinkWrap: true,
                                              itemCount: 1,
                                              itemBuilder: (context, index) {
                                                return Transform.translate(
                                                  offset: const Offset(-5, -25),
                                                  child: Column(
                                                    children: [
                                                      // const SizedBox(height: 4,),
                                                      Container(
                                                        height: 10,
                                                        width: 3,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey
                                                              .withOpacity(0.4),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 4,
                                                      ),
                                                      Container(
                                                        height: 10,
                                                        width: 3,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey
                                                              .withOpacity(0.4),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 4,
                                                      ),
                                                      Container(
                                                        height: 15,
                                                        width: 15,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color:
                                                                    Colors.red,
                                                                width: 4)),
                                                      ),
                                                      const SizedBox(
                                                        height: 4,
                                                      ),
                                                      Container(
                                                        height: 10,
                                                        width: 3,
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.4),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            flex: 9,
                                            child: Transform.translate(
                                              offset: const Offset(0, -15),
                                              child: Column(
                                                children: [
                                                  // Transform.translate(
                                                  //   offset: const Offset(0, -7),
                                                  //   child: Text("${droptitlelist[index]["title"]}"),
                                                  // ),
                                                  // const SizedBox(height: 5,),
                                                  ListTile(
                                                    // isThreeLine: true,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: Text(
                                                        "${droptitlelist[index]["title"]}"),
                                                    subtitle: Text(
                                                      "${droptitlelist[index]["subt"]}",
                                                      style: const TextStyle(
                                                          color: Colors.grey),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                          // SizedBox(height: 30,),
                          CommonButton(
                              containcolore: theamcolore,
                              onPressed1: () {
                                Get.back();

                                // removeRequest.removeApi(uid: userid.toString()).then((value) {
                                //   Get.back();
                                //   print("+++ removeApi +++:- ${value["driver_list"]}");
                                //   socket.emit('Vehicle_Ride_Cancel',{
                                //     'uid': "$useridgloable",
                                //     'driverid' : value["driver_list"],
                                //   });
                                // },);

                                // isanimation = true;
                                // resendRequestApiController.resendrequestApi(uid: userid.toString(), driverid: calculateController.calCulateModel!.driverId!).then((value) {
                                //   print("+++ resendrequestApi +++ :- ${value["driver_list"]}");
                                //   Get.back();
                                //   socket.emit('vehiclerequest',{
                                //     'requestid': addVihicalCalculateController.addVihicalCalculateModel!.id,
                                //     'driverid' : value["driver_list"],
                                //   });
                                //   if (controller != null && controller.isAnimating) {
                                //     controller.dispose();
                                //   }
                                //   requesttime();
                                // },);
                              },
                              txt1: "Try Again".tr,
                              context: context),
                          const SizedBox(
                            height: 10,
                          ),
                          CommonOutLineButton(
                              bordercolore: theamcolore,
                              onPressed1: () {
                                removeRequest
                                    .removeApi(uid: userid.toString())
                                    .then(
                                  (value) {
                                    Get.back();
                                    print(
                                        "+++ removeApi +++:- ${value["driver_list"]}");

                                    socket.emit('Vehicle_Ride_Cancel', {
                                      'uid': "$useridgloable",
                                      'driverid': value["driver_list"],
                                    });
                                  },
                                );
                              },
                              txt1: "Cancel".tr.tr,
                              context: context),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).catchError((error) {
            if (kDebugMode) print("Timeout API error: $error");
          });
        });
      }
    });

    if (!_isDisposed) {
      controller!.forward();
    }
  }

  pagelistApiController pagelistcontroller = Get.put(pagelistApiController());

  Future<Uint8List> getNetworkImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        // Return default marker icon as bytes if network image fails
        final ByteData data = await rootBundle.load('assets/logo.png');
        return data.buffer.asUint8List();
      }
    } catch (e) {
      if (kDebugMode) print("Error loading network image: $e");
      // Return default marker icon as bytes
      final ByteData data = await rootBundle.load('assets/logo.png');
      return data.buffer.asUint8List();
    }
  }

  void updateBiddingMode(bool isAutomatic) {
    setState(() {
      switchValue = isAutomatic;
      biddautostatus = isAutomatic ? "true" : "false";
    });

    if (kDebugMode) {
      print("🔧 Bidding mode updated:");
      print("   Switch Value: $switchValue");
      print("   Bidding Status: $biddautostatus");
      print("   Mode: ${isAutomatic ? 'Automatic' : 'Manual'}");
    }
  }

  @override
  void initState() {
    super.initState();

    _isDisposed = false; // Initialize disposal flag
    WidgetsBinding.instance.addObserver(this);

    // Your existing initState code, but replace setState calls with setState

    if (widget.selectvihical == true) {
      if (kDebugMode) {
        print("TRUETRUETRUTRUETRUETRUETRUETRUEWTRUWEUETEWUETRUETR");
      }

      select1 = 0;

      homeApiController
          .homeApi(
              uid: userid.toString(),
              lat: lathome.toString(),
              lon: longhome.toString())
          .then((value) {
        if (_isDisposed || !mounted) return;

        mid = homeApiController.homeapimodel!.categoryList![0].id.toString();

        mroal =
            homeApiController.homeapimodel!.categoryList![0].role.toString();

        calculateController
            .calculateApi(
                context: context,
                uid: userid.toString(),
                mid: mid,
                mrole: mroal,
                pickup_lat_lon: "$latitudepick,$longitudepick",
                drop_lat_lon: "$latitudedrop,$longitudedrop",
                drop_lat_lon_list: onlypass)
            .then((value) {
          if (_isDisposed || !mounted) return;

          dropprice = 0;

          minimumfare = 0;

          maximumfare = 0;

          if (value["Result"] == true) {
            amountresponse = "true";

            dropprice = value["drop_price"];

            minimumfare = value["vehicle"]["minimum_fare"];

            maximumfare = value["vehicle"]["maximum_fare"];

            responsemessage = value["message"];

            tot_hour = value["tot_hour"].toString();

            tot_time = value["tot_minute"].toString();

            vehicle_id = value["vehicle"]["id"].toString();

            vihicalrice = double.parse(value["drop_price"].toString());

            totalkm = double.parse(value["tot_km"].toString());

            tot_secound = "0";

            vihicalimage = value["vehicle"]["map_img"].toString();

            vihicalname = value["vehicle"]["name"].toString();

            setState(() {});
          } else {
            amountresponse = "false";

            if (kDebugMode) {
              print("jojojojojojojojojojojojojojojojojojojojojojojojo");
            }

            setState(() {});
          }

          if (kDebugMode) {
            print("********** dropprice **********:----- $dropprice");

            print("********** minimumfare **********:----- $minimumfare");

            print("********** maximumfare **********:----- $maximumfare");
          }
        }).catchError((error) {
          if (kDebugMode) print("Calculate API error in initState: $error");
        });
      }).catchError((error) {
        if (kDebugMode) print("Home API error in initState: $error");
      });
    }

    if (controller == null || !controller!.isAnimating) {
      if (kDebugMode) print("DURATION SECOUNDE : - $durationInSeconds");

      controller = AnimationController(
        duration: Duration(seconds: durationInSeconds),
        vsync: this,
      );
    }

    mapThemeStyle(context: context);

    isControllerDisposed = false;

    plusetimer = "";

    calculateController
        .calculateApi(
            context: context,
            uid: useridgloable.toString(),
            mid: mid,
            mrole: mroal,
            pickup_lat_lon: "$latitudepick,$longitudepick",
            drop_lat_lon: "$latitudedrop,$longitudedrop",
            drop_lat_lon_list: onlypass)
        .then((value) {
      if (kDebugMode) print("eeeeeeeeeeeeee");
    }).catchError((error) {
      if (kDebugMode) print("Calculate API error: $error");
    });

    setState(() {});

    fun().then((value) {
      if (_isDisposed || !mounted) return;

      setState(() {});

      getCurrentLatAndLong(lathome, longhome);

      socketConnect();
    }).catchError((error) {
      if (kDebugMode) print("Fun error: $error");
    });

    // Continue with rest of your initState but replace setState with setState

    paymentGetApiController.paymentlistApi(context).then((value) {
      if (_isDisposed || !mounted) return;

      for (int i = 1;
          i < paymentGetApiController.paymentgetwayapi!.paymentList!.length;
          i++) {
        if (int.parse(paymentGetApiController.paymentgetwayapi!.defaultPayment
                .toString()) ==
            paymentGetApiController.paymentgetwayapi!.paymentList![i].id) {
          setState(() {
            payment =
                paymentGetApiController.paymentgetwayapi!.paymentList![i].id!;

            paymentname =
                paymentGetApiController.paymentgetwayapi!.paymentList![i].name!;

            if (kDebugMode) {
              print("+++++$payment");

              print("+++++$i");
            }
          });
        }
      }
    }).catchError((error) {
      if (kDebugMode) print("Payment API error: $error");
    });

    // Rest of your initState code...

    _dropOffPoints = [];

    _dropOffPoints = destinationlat;

    if (kDebugMode) print("****////***:-----  $_dropOffPoints");

    /// origin marker

    _addMarker11(LatLng(latitudepick, longitudepick), "origin",
        BitmapDescriptor.defaultMarker);

    /// destination marker

    _addMarker2(LatLng(latitudedrop, longitudedrop), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));

    for (int a = 0; a < _dropOffPoints.length; a++) {
      _addMarker3("destination");
    }

    getDirections11(
        lat1: PointLatLng(latitudepick, longitudepick),
        lat2: PointLatLng(latitudedrop, longitudedrop),
        dropOffPoints: _dropOffPoints);

    pagelistcontroller.pagelistttApi(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      resetMapScreenState();
    });
  }

  @override
  void dispose() {
    if (kDebugMode) print("MapScreen dispose called");

    _isDisposed = true;

    // ✅ NEW: Remove observer

    WidgetsBinding.instance.removeObserver(this);

    // ✅ CRITICAL: Comprehensive cleanup

    resetMapScreenState();

    // Remove socket listeners

    try {
      socket.off("Vehicle_Bidding$userid");

      socket.off("acceptvehrequest$useridgloable");

      socket.off("reset_customer_state$useridgloable");

      socket.off("Vehicle_Location_update$userid");

      socket.off("Accept_Bidding_Response$useridgloable");

      socket.off("Bidding_decline_Response$useridgloable");

      socket.off("removecustomerdata$useridgloable");

      socket.off("Driver_location_On");

      socket.off("Driver_location_Update");
    } catch (e) {
      if (kDebugMode) print("Error removing socket listeners: $e");
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:

        // App came back to foreground

        if (kDebugMode) print("🔄 App resumed, checking map state");

        resetMapScreenState();

        break;

      case AppLifecycleState.paused:

        // App went to background

        if (kDebugMode) print("⏸️ App paused");

        break;

      case AppLifecycleState.detached:

        // App is being terminated

        if (kDebugMode) print("🔚 App detached");

        break;

      case AppLifecycleState.inactive:

        // App is inactive (e.g., phone call)

        if (kDebugMode) print("😴 App inactive");

        break;

      case AppLifecycleState.hidden:

        // App is hidden

        if (kDebugMode) print("🙈 App hidden");

        break;
    }
  }

// Replace your existing mapThemeStyle method:
  mapThemeStyle({required BuildContext context}) {
    if (_isDisposed) return;

    final stylePath = darkMode == true
        ? "assets/map_styles/dark_style.json"
        : "assets/map_styles/light_style.json";

    DefaultAssetBundle.of(context).loadString(stylePath).then((value) {
      if (!_isDisposed && mounted) {
        setState(() {
          themeForMap = value;
        });
      }
    }).catchError((error) {
      if (kDebugMode) print("Map theme loading error: $error");
    });
  }

  // Poliline Map Code

  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  late GoogleMapController mapController11;

  Map<MarkerId, Marker> markers11 = {};
  Map<PolylineId, Polyline> polylines11 = {};
  List<LatLng> polylineCoordinates11 = [];
  PolylinePoints polylinePoints11 = PolylinePoints();

  void _onMapCreated11(GoogleMapController controller) async {
    mapController11 = controller;
  }

  Future<Uint8List> getImages11(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // Multiple pin function

  _addMarker11(LatLng position, String id, BitmapDescriptor descriptor) async {
    final Uint8List markIcon = await getImages("assets/pickup_marker.png", 80);
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: BitmapDescriptor.fromBytes(markIcon),
      position: position,
      onTap: () {
        showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  alignment: const Alignment(0, -0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  child: Container(
                    width: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          picktitle == "" ? pickupcontroller.text : picktitle,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        picksubtitle == ""
                            ? const SizedBox()
                            : Text(
                                picksubtitle,
                                maxLines: 3,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
    markers11[markerId] = marker;
  }

  Future _addMarker2(
      LatLng position, String id, BitmapDescriptor descriptor) async {
    final Uint8List markIcon = await getImages("assets/drop_marker.png", 80);
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: BitmapDescriptor.fromBytes(markIcon),
      position: position,
      onTap: () {
        showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  alignment: const Alignment(0, -0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  child: Container(
                    width: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          droptitle,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          dropsubtitle,
                          maxLines: 3,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
    markers11[markerId] = marker;
  }

  _addMarker3(String id) async {
    for (int a = 0; a < _dropOffPoints.length; a++) {
      final Uint8List markIcon = await getImages("assets/drop_marker.png", 80);
      MarkerId markerId = MarkerId(id[a]);

      // Assuming _dropOffPoints[a] is of type PointLatLng, convert it to LatLng
      LatLng position =
          LatLng(_dropOffPoints[a].latitude, _dropOffPoints[a].longitude);

      Marker marker = Marker(
        markerId: markerId,
        icon: BitmapDescriptor.fromBytes(markIcon),
        position: position,
        onTap: () {
          showDialog(
            barrierColor: Colors.transparent,
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return Dialog(
                    alignment: const Alignment(0, -0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                    child: Container(
                      width: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${droptitlelist[a]["title"]}",
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${droptitlelist[a]["subt"]}",
                            maxLines: 3,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );

      markers11[markerId] = marker;
    }
  }

  Future getDirections11(
      {required PointLatLng lat1,
      required PointLatLng lat2,
      required List<PointLatLng> dropOffPoints}) async {
    markers.remove(const MarkerId("my_1"));

    // polylines11.clear();

    // pickupcontroller.text.isEmpty || dropcontroller.text.isEmpty ?  polylines11.clear() : "";

    List<LatLng> polylineCoordinates = [];
    List<PointLatLng> allPoints = [lat1, lat2, ...dropOffPoints];

    for (int i = 0; i < allPoints.length - 1; i++) {
      PointLatLng point1 = allPoints[i];
      PointLatLng point2 = allPoints[i + 1];

      PolylineResult result = await polylinePoints11.getRouteBetweenCoordinates(
        Config.mapkey,
        point1,
        point2,
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        // Handle the case where no route is found
      }
    }

    addPolyLine11(polylineCoordinates);
  }

  addPolyLine11(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: theamcolore,
      // points: [...polylineCoordinates,..._dropOffPoints],
      points: polylineCoordinates,
      width: 3,
    );
    polylines11[id] = polyline;
    setState(() {});
  }

  void _addMarkers() async {
    // Future<BitmapDescriptor> _loadIcon(String url) async {
    //   try {
    //     if (url.isEmpty || url.contains("undefined")) {
    //       // Fallback to a default icon if the URL is invalid
    //       return BitmapDescriptor.defaultMarker;
    //     }
    //
    //     final http.Response response = await http.get(Uri.parse(url));
    //     if (response.statusCode == 200) {
    //       final Uint8List bytes = response.bodyBytes;
    //
    //       // Decode image and resize it
    //       final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 30,targetHeight: 50);
    //       final ui.FrameInfo frameInfo = await codec.getNextFrame();
    //       final ByteData? byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    //
    //       return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    //     } else {
    //       throw Exception('Failed to load image from $url');
    //     }
    //   } catch (e) {
    //     // Log the error and return a default icon
    //     print("Error loading icon from $url: $e");
    //     return BitmapDescriptor.defaultMarker;
    //   }
    // }

    Future<BitmapDescriptor> _loadIcon(String url,
        {int targetWidth = 30, int targetHeight = 50}) async {
      try {
        if (url.isEmpty || url.contains("undefined")) {
          // Fallback to a default icon if the URL is invalid
          return BitmapDescriptor.defaultMarker;
        }

        final http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;

          // Decode image and resize it
          final ui.Codec codec = await ui.instantiateImageCodec(bytes,
              targetWidth: targetWidth, targetHeight: targetHeight);
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          final ByteData? byteData =
              await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

          return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
        } else {
          throw Exception('Failed to load image from $url');
        }
      } catch (e) {
        // Log the error and return a default icon
        print("Error loading icon from $url: $e");
        return BitmapDescriptor.defaultMarker;
      }
    }

    // Load all icons
    final List<BitmapDescriptor> _icons = await Future.wait(
      _iconPaths.map((path) => _loadIcon(path)),
    );

    setState(() {
      pickupcontroller.text.isEmpty || dropcontroller.text.isEmpty
          ? setState(() {
              polylines11.clear();
            })
          : "";

      // vihicallocations = [];
      for (var i = 0; i < vihicallocations.length; i++) {
        print("qqqqqqqqq:-- ${homeMapController.homeMapApiModel!.list![i].id}");
        print("aaaaaaaaa:-- ${vihicallocations.length}");
        MarkerId markerId =
            MarkerId("${homeMapController.homeMapApiModel!.list![i].id}");
        Marker marker = Marker(
          markerId: markerId,
          icon: _icons[i],
          position: LatLng(
              double.parse(homeMapController.homeMapApiModel!.list![i].latitude
                  .toString()),
              double.parse(homeMapController.homeMapApiModel!.list![i].longitude
                  .toString())),
        );
        markers[markerId] = marker;
        setState(() {});
      }
    });
  }

  void _addMarkers2() async {
    Future<BitmapDescriptor> _loadIcon(String url) async {
      try {
        if (url.isEmpty || url.contains("undefined")) {
          // Fallback to a default icon if the URL is invalid
          return BitmapDescriptor.defaultMarker;
        }

        final http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;

          // Decode image and resize it
          final ui.Codec codec = await ui.instantiateImageCodec(bytes,
              targetWidth: 30, targetHeight: 50);
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          final ByteData? byteData =
              await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

          return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
        } else {
          throw Exception('Failed to load image from $url');
        }
      } catch (e) {
        // Log the error and return a default icon
        print("Error loading icon from $url: $e");
        return BitmapDescriptor.defaultMarker;
      }
    }

    // Load all icons
    final List<BitmapDescriptor> _icons = await Future.wait(
      _iconPathsbiddingon.map((path) => _loadIcon(path)),
    );

    setState(() {
      markers11.clear();

      _addMarker11(LatLng(latitudepick, longitudepick), "origin",
          BitmapDescriptor.defaultMarker);

      /// destination marker
      _addMarker2(LatLng(latitudedrop, longitudedrop), "destination",
          BitmapDescriptor.defaultMarkerWithHue(90));

      for (int a = 0; a < _dropOffPoints.length; a++) {
        _addMarker3("destination");
      }

      getDirections11(
          lat1: PointLatLng(latitudepick, longitudepick),
          lat2: PointLatLng(latitudedrop, longitudedrop),
          dropOffPoints: _dropOffPoints);

      for (var i = 0; i < vihicallocationsbiddingon.length; i++) {
        // final markerId = MarkerId('marker_$i');
        final markerId =
            MarkerId('${homeMapController.homeMapApiModel!.list![i].id}');
        final marker = Marker(
          markerId: markerId,
          // position: vihicallocationsbiddingon[i],
          position: LatLng(
              double.parse(homeMapController.homeMapApiModel!.list![i].latitude
                  .toString()),
              double.parse(homeMapController.homeMapApiModel!.list![i].longitude
                  .toString())),
          icon: _icons[i],
        );
        markers11[markerId] = marker; // Add marker to the map
      }
    });
  }

  Map<MarkerId, Marker> markers = {};

  late GoogleMapController mapController1;

  Future fun() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {}
    var currentLocation = await locateUser();
    debugPrint('location: ${currentLocation.latitude}');
    _onAddMarkerButtonPressed(
        currentLocation.latitude, currentLocation.longitude);
    getCurrentLatAndLong(
      currentLocation.latitude,
      currentLocation.longitude,
    );
    print("????????????${currentLocation.longitude}");
    // print("SECOND USER CURRENT LOCATION : --  ${addresshome}");
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

// Optimized version with offline fallback

  Future getCurrentLatAndLong(double latitude, double longitude) async {
    if (_isDisposed) return;

    lathome = latitude;

    longhome = longitude;

    lathomecurrent = latitude;

    longhomecurrent = longitude;

    // First set coordinate-based fallback immediately

    String fallbackAddress =
        "Location ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}";

    if (pickupcontroller.text.isEmpty && !_isDisposed) {
      pickupcontroller.text = fallbackAddress;

      if (!_isDisposed && mounted) {
        setState(() {}); // Update UI immediately with coordinates
      }
    }

    try {
      // Try to get detailed address in background

      List<Placemark> placemarks =
          await placemarkFromCoordinates(lathome, longhome)
              .timeout(const Duration(seconds: 6));

      if (placemarks.isNotEmpty && !_isDisposed) {
        final placemark = placemarks.first;

        String detailedAddress =
            '${placemark.name ?? "Unknown Location"}, ${placemark.locality ?? "Unknown Area"}, ${placemark.country ?? "Unknown Country"}';

        // Update with detailed address if we got one

        addresshome = detailedAddress;

        // Update pickup controller if it still has the fallback text

        if (pickupcontroller.text == fallbackAddress && !_isDisposed) {
          pickupcontroller.text = addresshome;

          if (!_isDisposed && mounted) {
            setState(() {}); // Update UI with detailed address
          }
        }

        if (kDebugMode) print("Detailed address loaded: $addresshome");
      }
    } catch (e) {
      if (kDebugMode) print("Geocoding failed, keeping fallback: $e");

      addresshome = fallbackAddress; // Keep the coordinate-based fallback
    }
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _onAddMarkerButtonPressed(double? lat, long) async {
    final Uint8List markIcon = await getImages("assets/pickup_marker.png", 80);
    // markers.add(Marker(
    //   markerId: const MarkerId("1"),
    //   position: LatLng(double.parse(lat.toString()),double.parse(long.toString())),
    //   onTap: () {
    //     showDialog(
    //       barrierColor: Colors.transparent,
    //       context: context,
    //       builder: (context) {
    //         return StatefulBuilder(builder: (context, setState) {
    //           return Dialog(
    //             alignment: const Alignment(0,-0.22),
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(15),
    //             ),
    //             elevation: 0,
    //             child: Container(
    //               padding: const EdgeInsets.all(10),
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(15),
    //                 color: Colors.white,
    //               ),
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   Text(
    //                     "$addresshome",
    //                     maxLines: 1,
    //                     style: const TextStyle(
    //                       color: Colors.black,
    //                       fontSize: 14,
    //                       overflow: TextOverflow.ellipsis,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           );
    //         },);
    //       },
    //     );
    //   },
    //   // icon: BitmapDescriptor.defaultMarker,
    //   icon: BitmapDescriptor.fromBytes(markIcon),
    // ));

    Marker marker = Marker(
      markerId: const MarkerId("my_1"),
      icon: BitmapDescriptor.fromBytes(markIcon),
      position:
          LatLng(double.parse(lat.toString()), double.parse(long.toString())),
      onTap: () {
        showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  alignment: const Alignment(0, -0.22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$addresshome",
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
    markers[const MarkerId("my_1")] = marker;

    setState(() {});
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  void _navigateAndRefresh() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PickupDropPoint(
                  pagestate: false,
                  bidding: homeApiController
                      .homeapimodel!.categoryList![select1].bidding
                      .toString(),
                )));
    if (result != null && result.shouldRefresh) {
      _refreshPage();
    }
  }

  void _refreshPage() {
    setState(() {});
  }

  socateempt() {
    print("SOCATE SCOCATDFJH");
    socket.emit('vehiclerequest', {
      // 'requestid': addVihicalCalculateController.addVihicalCalculateModel!.id,
      'requestid': request_id,
      'driverid': calculateController.calCulateModel!.driverId,
      'c_id': useridgloable
    });
    print("datadatatdatadtad:- ${socket}");
  }

  socatloadbidinfdata() {
    socket.emit('load_bidding_data', {
      'uid': useridgloable,
      'request_id': request_id,
      'd_id': calculateController.calCulateModel!.driverId
    });
  }

  void refreshAnimation() {
    controller!.reset();
    controller!.repeat(reverse: false);
  }

  bool offerpluse = false;

  bool cancelloader = false;

  List drowertitle = [
    "Home".tr,
    "My Ride".tr,
    "Wallet".tr,
    "Profile".tr,
    "Language".tr,
    "Refer and earn".tr,
    "Faq".tr,
    "Notifications".tr,
    "Dark Mode".tr,
    // "Invite friends",
  ];

  List drowerimage = [
    "assets/svgpicture/myride.svg",
    "assets/svgpicture/routing-2.svg",
    "assets/svgpicture/wallet.svg",
    "assets/svgpicture/profile.svg",
    "assets/svgpicture/languge.svg",
    "assets/svgpicture/share.svg",
    "assets/svgpicture/faq.svg",
    "assets/svgpicture/notification.svg",
    "assets/svgpicture/moon_regulare.svg",
  ];

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      key: _key,
      drawer: draweropen(context),
      body: GetBuilder<HomeApiController>(
        builder: (homeApiController) {
          return homeApiController.isLoading
              ? Center(child: CustomLoadingWidget())
              : Stack(
                  children: [
                    // pickupcontroller.text.isEmpty || dropcontroller.text.isEmpty ? lathome == null ? Center(child: CustomLoadingWidget()) :
                    lathome == null
                        ? Center(child: CustomLoadingWidget())
                        : GoogleMap(
                            gestureRecognizers: {
                              Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer())
                            },
                            initialCameraPosition: pickupcontroller
                                        .text.isEmpty ||
                                    dropcontroller.text.isEmpty
                                ? CameraPosition(
                                    target: LatLng(lathome, longhome), zoom: 13)
                                : CameraPosition(
                                    target: LatLng(latitudepick, longitudepick),
                                    zoom: 13),
                            // initialCameraPosition:  CameraPosition(target: LatLng(21.2408,72.8806), zoom: 13),
                            mapType: MapType.normal,
                            // markers: markers.,
                            markers: pickupcontroller.text.isEmpty ||
                                    dropcontroller.text.isEmpty
                                ? Set<Marker>.of(markers.values)
                                : Set<Marker>.of(markers11.values),
                            // markers: Set<Marker>.of(markers.values),
                            onTap: (argument) {
                              setState(() {
                                _onAddMarkerButtonPressed(
                                    argument.latitude, argument.longitude);
                                lathome = argument.latitude;
                                longhome = argument.longitude;
                                getCurrentLatAndLong(
                                  lathome,
                                  longhome,
                                );
                                homeMapController
                                    .homemapApi(
                                        mid: mid,
                                        lat: lathome.toString(),
                                        lon: longhome.toString())
                                    .then((value) {
                                  setState(() {});
                                  print("///:---  ${value["Result"]}");

                                  if (value["Result"] == false) {
                                    setState(() {
                                      vihicallocations.clear();
                                      markers.clear();
                                      _addMarkers();
                                      print(
                                          "***if condition+++:---  $vihicallocations");
                                    });
                                  } else {
                                    setState(() {});
                                    vihicallocations.clear();
                                    for (int i = 0;
                                        i <
                                            homeMapController
                                                .homeMapApiModel!.list!.length;
                                        i++) {
                                      vihicallocations.add(LatLng(
                                          double.parse(homeMapController
                                              .homeMapApiModel!
                                              .list![i]
                                              .latitude
                                              .toString()),
                                          double.parse(homeMapController
                                              .homeMapApiModel!
                                              .list![i]
                                              .longitude
                                              .toString())));
                                      _iconPaths.add(
                                          "${Config.imageurl}${homeMapController.homeMapApiModel!.list![i].image}");
                                    }
                                    _addMarkers();
                                  }

                                  print(
                                      "******-**:::::------ in Build$vihicallocations");
                                });
                              });

                              // print("***lato****:--- $lathome");
                              // print("+++longo+++:--- $longhome");
                              // print("--------------------------------------");
                              // print("hfgjhvhjwfvhjuyfvf:-=---  $addresshome");
                            },
                            myLocationEnabled: false,
                            zoomGesturesEnabled: true,
                            tiltGesturesEnabled: true,
                            zoomControlsEnabled: true,
                            onMapCreated: (controller) {
                              setState(() {
                                controller.setMapStyle(themeForMap);
                                mapController1 = controller;
                              });
                            },
                            polylines: Set<Polyline>.of(polylines11.values),
                          ),
                    //   : GoogleMap(
                    //   initialCameraPosition: CameraPosition(
                    //     target: LatLng(latitudepick, longitudepick),
                    //     zoom: 15,
                    //   ),
                    //   myLocationEnabled: true,
                    //   tiltGesturesEnabled: true,
                    //   compassEnabled: true,
                    //   scrollGesturesEnabled: true,
                    //   zoomGesturesEnabled: true,
                    //   onMapCreated: _onMapCreated11,
                    //   markers: Set<Marker>.of(markers11.values),
                    //   polylines: Set<Polyline>.of(polylines11.values),
                    // ),

                    Padding(
                      padding:
                          const EdgeInsets.only(top: 60, left: 10, right: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _key.currentState!.openDrawer();
                                });
                              },
                              child: Container(
                                height: 50,
                                // width: 50,
                                decoration: BoxDecoration(
                                    color: notifier.containercolore,
                                    shape: BoxShape.circle),
                                child: Center(
                                    child: Image(
                                  image: const AssetImage("assets/menu.png"),
                                  height: 20,
                                  color: notifier.textColor,
                                )),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: notifier.containercolore,
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextField(
                                onTap: () {
                                  _addMarkers();
                                  fun().then((value) {
                                    setState(() {});
                                    getCurrentLatAndLong(lathome, longhome)
                                        .then(
                                      (value) {
                                        mapController1.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              target: LatLng(lathome, longhome),
                                              zoom: 14.0,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    // socketConnect();
                                  });
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const PickupDropPoint(),));
                                },
                                // controller: controller,
                                readOnly: true,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        borderSide: BorderSide(
                                            color: notifier.background)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        borderSide: BorderSide(
                                            color: notifier.background)),
                                    hintText: "Your Current Location".tr,
                                    hintStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontFamily: "SofiaProBold",
                                        fontSize: 14),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        borderSide: BorderSide(
                                            color: notifier.containercolore)),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.green, width: 6),
                                        ),
                                      ),
                                    ),
                                    suffixIcon: InkWell(
                                        onTap: () {
                                          // fun().then((value) {
                                          //   setState(() {
                                          //   });
                                          //   getCurrentLatAndLong(lathome, longhome);
                                          //   mapController1.animateCamera(
                                          //     CameraUpdate.newCameraPosition(
                                          //       CameraPosition(
                                          //         target: LatLng(lathome, longhome),
                                          //         zoom: 14.0,
                                          //       ),
                                          //     ),
                                          //   );
                                          // });

                                          _addMarkers();
                                          fun().then((value) {
                                            setState(() {});
                                            getCurrentLatAndLong(
                                                    lathome, longhome)
                                                .then(
                                              (value) {
                                                mapController1.animateCamera(
                                                  CameraUpdate
                                                      .newCameraPosition(
                                                    CameraPosition(
                                                      target: LatLng(
                                                          lathome, longhome),
                                                      zoom: 14.0,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                            // socketConnect();
                                          });
                                        },
                                        child: SvgPicture.asset(
                                          "assets/svgpicture/gpsicon.svg",
                                        ))),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    DraggableScrollableSheet(
                      // initialChildSize:  homeApiController.homeapimodel!.categoryList![select1].bidding == "1" ? 0.37 : 0.30, // Set the default height to 50% of the screen
                      initialChildSize:
                          0.45, // Set the default height to 50% of the screen
                      minChildSize: 0.2, // Minimum height
                      maxChildSize: 1.0,
                      controller: sheetController,
                      builder: (BuildContext context, scrollController) {
                        return Container(
                          // height: 100,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            // color: Colors.white,
                            color: notifier.containercolore,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: CustomScrollView(
                            controller: scrollController,
                            slivers: [
                              SliverToBoxAdapter(
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: notifier.textColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    height: 4,
                                    width: 40,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                ),
                              ),
                              SliverList.list(children: [
                                const SizedBox(height: 10),

                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: SizedBox(
                                    height:
                                        101, // THIS FIXED HEIGHT IS CAUSING OVERFLOW
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      clipBehavior: Clip.none,
                                      itemCount: homeApiController
                                          .homeapimodel!.categoryList!.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              select1 = index;
                                              // dropcontroller.clear();
                                              mid = homeApiController
                                                  .homeapimodel!
                                                  .categoryList![index]
                                                  .id
                                                  .toString();
                                              mroal = homeApiController
                                                  .homeapimodel!
                                                  .categoryList![index]
                                                  .role
                                                  .toString();
                                              print(
                                                  "*****mid*-**:::::------$mid");
                                              _iconPaths.clear();
                                              vihicallocations.clear();
                                              _iconPathsbiddingon.clear();
                                              vihicallocationsbiddingon.clear();

                                              pickupcontroller.text.isEmpty ||
                                                      dropcontroller
                                                          .text.isEmpty
                                                  ? markers.clear()
                                                  : "";
                                              pickupcontroller.text.isEmpty ||
                                                      dropcontroller
                                                          .text.isEmpty
                                                  ? fun().then((value) {
                                                      setState(() {});
                                                      getCurrentLatAndLong(
                                                          lathome, longhome);
                                                      // _loadMapStyles();
                                                      // socketConnect();
                                                    })
                                                  : "";

                                              // vihicallocations.clear();
                                              // markers.clear();
                                              // _addMarkers();

                                              pickupcontroller.text.isEmpty ||
                                                      dropcontroller
                                                          .text.isEmpty
                                                  ? homeMapController
                                                      .homemapApi(
                                                          mid: mid,
                                                          lat: lathome
                                                              .toString(),
                                                          lon: longhome
                                                              .toString())
                                                      .then(
                                                      (value) {
                                                        setState(() {});
                                                        print(
                                                            "///:---  ${value["Result"]}");

                                                        if (value["Result"] ==
                                                            false) {
                                                          setState(() {
                                                            vihicallocations
                                                                .clear();
                                                            markers.clear();
                                                            _addMarkers();
                                                            fun().then((value) {
                                                              setState(() {});
                                                              getCurrentLatAndLong(
                                                                  lathome,
                                                                  longhome);
                                                              // socketConnect();
                                                            });
                                                            print(
                                                                "***if condition+++:---  $vihicallocations");
                                                          });
                                                        } else {
                                                          setState(() {});
                                                          for (int i = 0;
                                                              i <
                                                                  homeMapController
                                                                      .homeMapApiModel!
                                                                      .list!
                                                                      .length;
                                                              i++) {
                                                            vihicallocations.add(LatLng(
                                                                double.parse(homeMapController
                                                                    .homeMapApiModel!
                                                                    .list![i]
                                                                    .latitude
                                                                    .toString()),
                                                                double.parse(homeMapController
                                                                    .homeMapApiModel!
                                                                    .list![i]
                                                                    .longitude
                                                                    .toString())));
                                                            _iconPaths.add(
                                                                "${Config.imageurl}${homeMapController.homeMapApiModel!.list![i].image}");
                                                          }
                                                          _addMarkers();
                                                        }

                                                        print(
                                                            "******-**:::::------ Build 2$vihicallocations");
                                                      },
                                                    )
                                                  : homeMapController
                                                      .homemapApi(
                                                          mid: mid,
                                                          lat: lathome
                                                              .toString(),
                                                          lon: longhome
                                                              .toString())
                                                      .then(
                                                      (value) {
                                                        setState(() {});
                                                        print(
                                                            "///:---  ${value["Result"]}");

                                                        if (value["Result"] ==
                                                            false) {
                                                          setState(() {
                                                            vihicallocationsbiddingon
                                                                .clear();
                                                            markers.clear();
                                                            _addMarkers2();
                                                            print(
                                                                "***if condition+++:---  $vihicallocationsbiddingon");
                                                          });
                                                        } else {
                                                          setState(() {});
                                                          for (int i = 0;
                                                              i <
                                                                  homeMapController
                                                                      .homeMapApiModel!
                                                                      .list!
                                                                      .length;
                                                              i++) {
                                                            vihicallocationsbiddingon.add(LatLng(
                                                                double.parse(homeMapController
                                                                    .homeMapApiModel!
                                                                    .list![i]
                                                                    .latitude
                                                                    .toString()),
                                                                double.parse(homeMapController
                                                                    .homeMapApiModel!
                                                                    .list![i]
                                                                    .longitude
                                                                    .toString())));
                                                            _iconPathsbiddingon.add(
                                                                "${Config.imageurl}${homeMapController.homeMapApiModel!.list![i].image}");
                                                          }
                                                          _addMarkers2();
                                                        }

                                                        print(
                                                            "******-**:::::------ Build 3$vihicallocationsbiddingon");
                                                      },
                                                    );

                                              calculateController
                                                  .calculateApi(
                                                      context: context,
                                                      uid: userid.toString(),
                                                      mid: mid,
                                                      mrole: mroal,
                                                      pickup_lat_lon:
                                                          "$latitudepick,$longitudepick",
                                                      drop_lat_lon:
                                                          "$latitudedrop,$longitudedrop",
                                                      drop_lat_lon_list:
                                                          onlypass)
                                                  .then(
                                                (value) {
                                                  dropprice = 0;
                                                  minimumfare = 0;
                                                  maximumfare = 0;

                                                  if (value["Result"] == true) {
                                                    amountresponse = "true";
                                                    dropprice =
                                                        value["drop_price"];
                                                    minimumfare =
                                                        value["vehicle"]
                                                            ["minimum_fare"];
                                                    maximumfare =
                                                        value["vehicle"]
                                                            ["maximum_fare"];
                                                    responsemessage =
                                                        value["message"];

                                                    tot_hour = value["tot_hour"]
                                                        .toString();
                                                    tot_time =
                                                        value["tot_minute"]
                                                            .toString();
                                                    vehicle_id =
                                                        value["vehicle"]["id"]
                                                            .toString();
                                                    vihicalrice = double.parse(
                                                        value["drop_price"]
                                                            .toString());
                                                    totalkm = double.parse(
                                                        value["tot_km"]
                                                            .toString());
                                                    tot_secound = "0";

                                                    vihicalimage =
                                                        value["vehicle"]
                                                                ["map_img"]
                                                            .toString();
                                                    vihicalname =
                                                        value["vehicle"]["name"]
                                                            .toString();

                                                    setState(() {});
                                                  } else {
                                                    amountresponse = "false";
                                                    print(
                                                        "jojojojojojojojojojojojojojojojojojojojojojojojo");
                                                    setState(() {});
                                                  }

                                                  print(
                                                      "********** dropprice **********:----- $dropprice");
                                                  print(
                                                      "********** minimumfare **********:----- $minimumfare");
                                                  print(
                                                      "********** maximumfare **********:----- $maximumfare");
                                                },
                                              );
                                              // Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailsScreen()));
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Container(
                                              height: 50,
                                              // width: 100,
                                              decoration: BoxDecoration(
                                                color: select1 == index
                                                    ? theamcolore
                                                        .withOpacity(0.08)
                                                    : notifier.containercolore,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: select1 ==
                                                          index
                                                      ? CrossAxisAlignment.start
                                                      : CrossAxisAlignment
                                                          .center,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height: 40,
                                                          width: 40,
                                                          child: Image(
                                                            image: NetworkImage(
                                                                "${Config.imageurl}${homeApiController.homeapimodel!.categoryList![index].image}"),
                                                            height: 40,
                                                          ),
                                                        ),
                                                        select1 == index
                                                            ? const SizedBox(
                                                                width: 5,
                                                              )
                                                            : const SizedBox(),
                                                        select1 == index
                                                            ? InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    vihicalInformationApiController
                                                                        .vihicalinformationApi(
                                                                            vehicle_id:
                                                                                homeApiController.homeapimodel!.categoryList![index].id.toString())
                                                                        .then(
                                                                      (value) {
                                                                        Get.bottomSheet(
                                                                          // isScrollControlled: true,
                                                                          // isDismissible: false,
                                                                          // enableDrag: false,
                                                                          StatefulBuilder(
                                                                            builder:
                                                                                (context, setState) {
                                                                              return Container(
                                                                                clipBehavior: Clip.hardEdge,
                                                                                // height: 260,
                                                                                width: Get.width,
                                                                                // padding: const EdgeInsets.all(12),
                                                                                decoration: BoxDecoration(
                                                                                  color: notifier.containercolore,
                                                                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                                                                ),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(15),
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      Image.network(
                                                                                        "${Config.imageurl}${vihicalInformationApiController.vihicalInFormationApiModel!.vehicle!.image}",
                                                                                        height: 60,
                                                                                      ),
                                                                                      Text(
                                                                                        "${vihicalInformationApiController.vihicalInFormationApiModel!.vehicle!.name}",
                                                                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: notifier.textColor),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 10,
                                                                                      ),
                                                                                      Text(
                                                                                        "${vihicalInformationApiController.vihicalInFormationApiModel!.vehicle!.description}",
                                                                                        style: TextStyle(fontSize: 16, color: notifier.textColor),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 20,
                                                                                      ),
                                                                                      CommonOutLineButton(
                                                                                          bordercolore: theamcolore,
                                                                                          onPressed1: () {
                                                                                            Get.back();
                                                                                          },
                                                                                          txt1: "Close".tr,
                                                                                          context: context)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  });
                                                                },
                                                                child: Image(
                                                                  image: const AssetImage(
                                                                      "assets/info-circle.png"),
                                                                  height: 20,
                                                                  color:
                                                                      theamcolore,
                                                                ))
                                                            : const SizedBox(),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "${homeApiController.homeapimodel!.categoryList![index].name}",
                                                      style: TextStyle(
                                                          color: notifier
                                                              .textColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    // _navigateAndRefresh();
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(15),
                                            topLeft: Radius.circular(15)),
                                      ),
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          height: 750,
                                          decoration: const BoxDecoration(
                                              color: Colors.pinkAccent,
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(15),
                                                topLeft: Radius.circular(15),
                                              )),
                                          child: Column(
                                            children: [
                                              // _navigateAndRefresh();
                                              Expanded(
                                                  child: PickupDropPoint(
                                                pagestate: false,
                                                bidding: homeApiController
                                                    .homeapimodel!
                                                    .categoryList![select1]
                                                    .bidding
                                                    .toString(),
                                              )),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.05),
                                        // color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        // contentPadding: EdgeInsets.zero,
                                        contentPadding:
                                            const EdgeInsets.only(left: 10),
                                        leading: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.green, width: 4),
                                          ),
                                        ),
                                        title: pickupcontroller.text.isEmpty
                                            ? Transform.translate(
                                                offset: const Offset(-20, 0),
                                                child: Text(
                                                  "${addresshome ?? "Searching for you on the map...".tr}",
                                                  style: TextStyle(
                                                      color:
                                                          notifier.textColor),
                                                ))
                                            : Transform.translate(
                                                offset: const Offset(-20, 0),
                                                child: Text(
                                                  pickupcontroller.text,
                                                  style: TextStyle(
                                                      color:
                                                          notifier.textColor),
                                                )),
                                        // trailing: InkWell(
                                        //   onTap: () {
                                        //     // Navigator.push(context, MaterialPageRoute(builder: (context) => DriverListScreen(),));
                                        //   },
                                        //   child: Container(
                                        //     padding: const EdgeInsets.all(10),
                                        //     decoration: BoxDecoration(
                                        //       color: theamcolore.withOpacity(0.05),
                                        //       borderRadius: BorderRadius.circular(35),
                                        //     ),
                                        //     child: Text("Entrance",style: TextStyle(color: theamcolore)),
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                  ),
                                ),
                                textfieldlist.length > 0
                                    ? const SizedBox(height: 0)
                                    : const SizedBox(height: 10),
                                textfieldlist.length > 0
                                    ? InkWell(
                                        onTap: () {
                                          // _navigateAndRefresh();
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(15),
                                                  topLeft: Radius.circular(15)),
                                            ),
                                            context: context,
                                            builder: (context) {
                                              return SizedBox(
                                                height: 750,
                                                child: Column(
                                                  children: [
                                                    // _navigateAndRefresh();
                                                    Expanded(
                                                        child: PickupDropPoint(
                                                      pagestate: false,
                                                      bidding: homeApiController
                                                          .homeapimodel!
                                                          .categoryList![
                                                              select1]
                                                          .bidding
                                                          .toString(),
                                                    )),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                          // Navigator.push(context, MaterialPageRoute(builder: (context) => const PickupDropPoint(),));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20, top: 10),
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.05),
                                              // color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 10, right: 10),
                                              leading: Container(
                                                height: 20,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.red,
                                                      width: 4),
                                                ),
                                              ),
                                              title: Transform.translate(
                                                  offset: const Offset(-20, 0),
                                                  child: Text(
                                                    "${textfieldlist.length + 1} route stops",
                                                    style: TextStyle(
                                                        color:
                                                            notifier.textColor),
                                                  )),
                                              trailing: Icon(
                                                Icons.add,
                                                color: notifier.textColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: InkWell(
                                          onTap: () {
                                            // _navigateAndRefresh();
                                            showModalBottomSheet(
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(15),
                                                    topLeft:
                                                        Radius.circular(15)),
                                              ),
                                              context: context,
                                              builder: (context) {
                                                return SizedBox(
                                                  height: 750,
                                                  // color: Colors.red,
                                                  child: Column(
                                                    children: [
                                                      // _navigateAndRefresh();
                                                      Expanded(
                                                          child:
                                                              PickupDropPoint(
                                                        pagestate: false,
                                                        bidding:
                                                            homeApiController
                                                                .homeapimodel!
                                                                .categoryList![
                                                                    select1]
                                                                .bidding
                                                                .toString(),
                                                      )),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                            // Navigator.push(context, MaterialPageRoute(builder: (context) => const PickupDropPoint(),));
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Row(
                                                // crossAxisAlignment: CrossAxisAlignment.start,
                                                // mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Image(
                                                    image: const AssetImage(
                                                        "assets/search.png"),
                                                    height: 20,
                                                    color: notifier.textColor,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Flexible(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 2),
                                                      child: dropcontroller
                                                              .text.isEmpty
                                                          ? Text(
                                                              "To",
                                                              style: TextStyle(
                                                                  color: notifier
                                                                      .textColor,
                                                                  fontSize: 16),
                                                            )
                                                          : Text(
                                                              dropcontroller
                                                                  .text,
                                                              style: TextStyle(
                                                                  color: notifier
                                                                      .textColor,
                                                                  fontSize: 16),
                                                              maxLines: 2,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                homeApiController.homeapimodel!
                                            .categoryList![select1].bidding ==
                                        "1"
                                    ? const SizedBox(
                                        height: 10,
                                      )
                                    : const SizedBox(),
                                homeApiController.homeapimodel!
                                            .categoryList![select1].bidding ==
                                        "1"
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: InkWell(
                                          onTap: () {
                                            // bottomshhetopen = true;
                                            // if(isLoad){
                                            //   return;
                                            // }else{
                                            //   isLoad = true;
                                            // }
                                            // homeApiController.homeApi(uid: userid.toString(),lat: lathome.toString(),lon: longhome.toString()).then((value) {
                                            //   if(value["Result"] == true){
                                            //     setState(() {
                                            //       Buttonpresebottomshhet();
                                            //       isLoad = false;
                                            //     });
                                            //   }else{
                                            //
                                            //   }
                                            // },);
                                            Buttonpresebottomshhet();
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Row(
                                                children: [
                                                  (pickupcontroller
                                                              .text.isEmpty ||
                                                          dropcontroller
                                                              .text.isEmpty)
                                                      ? Text(
                                                          "${currencyy ?? globalcurrency}",
                                                          style: TextStyle(
                                                              color: notifier
                                                                  .textColor,
                                                              fontSize: 16),
                                                        )
                                                      : Text(
                                                          "${currencyy ?? globalcurrency} ${dropprice == null ? "" : dropprice}",
                                                          style: TextStyle(
                                                              color: notifier
                                                                  .textColor,
                                                              fontSize: 16),
                                                        ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Text(
                                                    "Offer your fare".tr,
                                                    style: TextStyle(
                                                        color:
                                                            notifier.textColor,
                                                        fontSize: 16),
                                                  ),
                                                  const Spacer(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                // const SizedBox(height: 20,),
                                pickupcontroller.text.isEmpty ||
                                        dropcontroller.text.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: CommonButton(
                                            containcolore:
                                                theamcolore.withOpacity(0.2),
                                            onPressed1: () {
                                              // rateBottomSheet();
                                              // rateBottomSheet();
                                              // Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailsScreen()));
                                            },
                                            context: context,
                                            txt1: "Find a driver".tr),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: CommonButton(
                                            containcolore: theamcolore,
                                            onPressed1: homeApiController
                                                        .homeapimodel!
                                                        .categoryList![select1]
                                                        .bidding ==
                                                    "1"
                                                ? () {
                                                    // if(isLoad){
                                                    //   return;
                                                    // }else{
                                                    //   isLoad = true;
                                                    // }
                                                    // homeApiController.homeApi(uid: userid.toString(),lat: lathome.toString(),lon: longhome.toString()).then((value) {
                                                    //   if(value["Result"] == true){
                                                    //    setState(() {
                                                    //      Buttonpresebottomshhet();
                                                    //      isLoad = false;
                                                    //    });
                                                    //   }else{
                                                    //
                                                    //   }
                                                    // },);

                                                    Buttonpresebottomshhet();
                                                  }
                                                : () {
                                                    print("222222222222");
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => HomeScreen(
                                                              latpic:
                                                                  latitudepick,
                                                              longpic:
                                                                  longitudepick,
                                                              latdrop:
                                                                  latitudedrop,
                                                              longdrop:
                                                                  longitudedrop,
                                                              destinationlat:
                                                                  destinationlat)),
                                                    );
                                                    modual_calculateController
                                                        .modualcalculateApi(
                                                            context: context,
                                                            uid: userid
                                                                .toString(),
                                                            mid: mid,
                                                            mrole: mroal,
                                                            pickup_lat_lon:
                                                                "$latitudepick,$longitudepick",
                                                            drop_lat_lon:
                                                                "$latitudedrop,$longitudedrop",
                                                            drop_lat_lon_list:
                                                                onlypass)
                                                        .then(
                                                      (value) {
                                                        midseconde =
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![0]
                                                                .id!;
                                                        vihicalrice = double.parse(
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![0]
                                                                .dropPrice!
                                                                .toString());
                                                        totalkm = double.parse(
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![0]
                                                                .dropKm!
                                                                .toString());
                                                        tot_time =
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![0]
                                                                .dropTime!
                                                                .toString();
                                                        tot_hour =
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![0]
                                                                .dropHour!
                                                                .toString();
                                                        vihicalname =
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![0]
                                                                .name!
                                                                .toString();
                                                        vihicalimage =
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![0]
                                                                .image!
                                                                .toString();
                                                        vehicle_id =
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![0]
                                                                .id!
                                                                .toString();

                                                        print(
                                                            "GOGOGOGOGOGOGOGOGOGOGOGOG:- $midseconde");
                                                        print(
                                                            "GOGOGOGOGOGOGOGOGOGOGOGOG:- $vihicalrice");
                                                        // setState((){});
                                                      },
                                                    );
                                                  },
                                            context: context,
                                            txt1: "Find a driver".tr),
                                      ),
                              ])
                            ],
                          ),
                        );
                      },
                    )
                  ],
                );
        },
      ),
    );
  }

  Widget draweropen(context) {
    return Drawer(
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      backgroundColor: notifier.containercolore,
      child: GetBuilder<HomeApiController>(
        builder: (homeApiController) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 60,
                ),
                Row(
                  children: [
                    Spacer(),
                    Text(
                      "V 1.3",
                      style: TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                homeApiController.isLoading
                    ? Center(child: CustomLoadingWidget())
                    : InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ));
                        },
                        child: Stack(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                  color: greaycolore, shape: BoxShape.circle),
                              child: decodeUid["profile_image"] == ""
                                  ? Center(
                                      child: Text("${decodeUid["name"][0]}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 25)))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(65),
                                      child: Image.network(
                                        "${Config.imageurl}${decodeUid["profile_image"]}",
                                        fit: BoxFit.cover,
                                      )),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    color: theamcolore,
                                    border: Border.all(color: Colors.white),
                                    shape: BoxShape.circle),
                                child: const Center(
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Container(
                    height: 25,
                    // width: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theamcolore)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            "${homeApiController.homeapimodel!.cusRating!.avgStar}",
                            style: TextStyle(
                                fontSize: 14, color: notifier.textColor),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset(
                          "assets/svgpicture/star-fill.svg",
                          height: 12,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  username == "" ? "" : username,
                  style: TextStyle(
                      color: notifier.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const SizedBox(
                  height: 5,
                ),
                InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ));
                    },
                    child: Text(
                      "View profile",
                      style: TextStyle(color: theamcolore),
                    )),
                const SizedBox(
                  height: 5,
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.4),
                ),
                // const SizedBox(height: 5,),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: drowertitle.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        switch (index) {
                          case 0:
                            // Get.back();
                            pickupcontroller.text = "";
                            dropcontroller.text = "";
                            latitudepick = 0.00;
                            longitudepick = 0.00;
                            latitudedrop = 0.00;
                            longitudedrop = 0.00;
                            picktitle = "";
                            picksubtitle = "";
                            droptitle = "";
                            dropsubtitle = "";
                            droptitlelist = [];
                            Get.offAll(const MapScreen(
                              selectvihical: false,
                            ));
                          case 1:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const MyRideScreen(),
                            ));
                          case 2:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const TopUpScreen(),
                            ));
                          case 3:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ));
                          case 4:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const LanguageScreen(),
                            ));
                          case 5:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ReferAndEarn(),
                            ));
                          case 6:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const FaqScreen(),
                            ));
                          case 7:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ));
                          case 8:
                            return;
                          case 9:
                            return;
                        }
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "${drowerimage[index]}",
                                  height: 25,
                                  color: notifier.textColor,
                                ),
                                // const Image(image: AssetImage("assets/info-circle.png"),height: 25,),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "${drowertitle[index]}".tr,
                                  style: TextStyle(
                                      fontSize: 16, color: notifier.textColor),
                                ),
                                const Spacer(),
                                index == 8
                                    ? // Replace the existing dark mode switch with this code:

                                    SizedBox(
                                        height: 20,
                                        width: 30,
                                        child: Transform.scale(
                                          scale: 0.8,
                                          child: CupertinoSwitch(
                                            value: notifier.isDark,
                                            activeColor: theamcolore,
                                            onChanged: (bool value) async {
                                              // Check if widget is still mounted before setState

                                              if (!mounted || _isDisposed) {
                                                return;
                                              }

                                              try {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();

                                                await prefs.setBool(
                                                    "isDark", value);

                                                notifier.isAvailable(value);

                                                // Check mounted again before setState

                                                if (!mounted || _isDisposed) {
                                                  return;
                                                }

                                                setState(() {
                                                  darkMode = value;
                                                });

                                                // Navigate after setState completes

                                                Get.offAll(MapScreen(
                                                    selectvihical: false));
                                              } catch (e) {
                                                if (kDebugMode) {
                                                  print(
                                                      "Dark mode switch error: $e");
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                GetBuilder<pagelistApiController>(
                  builder: (pagelistcontroller) {
                    return pagelistcontroller.isLoading
                        ? const SizedBox()
                        : ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            separatorBuilder: (context, index) {
                              return const SizedBox(width: 5);
                            },
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: pagelistcontroller
                                .pageListApiiimodel!.pagesList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Page_List_description(
                                                title:
                                                    pagelistcontroller
                                                        .pageListApiiimodel!
                                                        .pagesList![index]
                                                        .title
                                                        .toString(),
                                                description: pagelistcontroller
                                                    .pageListApiiimodel!
                                                    .pagesList![index]
                                                    .description
                                                    .toString()),
                                      ));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 20),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/svgpicture/pagelist.svg",
                                            height: 25,
                                            color: notifier.textColor,
                                          ),
                                          // const Image(image: AssetImage("assets/svgpicture/pagelist.svg"),height: 25,),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            "${pagelistcontroller.pageListApiiimodel!.pagesList![index].title}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: notifier.textColor),
                                          ),
                                          const Spacer(),
                                          // index == 3 ? Container(
                                          //    height: 8,
                                          //    width: 8,
                                          //    decoration: const BoxDecoration(
                                          //      color: Colors.red,
                                          //      shape: BoxShape.circle
                                          //    ),
                                          //  ) : const SizedBox()
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                  },
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 10,top: 15,right: 10),
                //   child: CommonOutLineButton(bordercolore: theamcolore, onPressed1: () {
                //     loginSharedPreferencesSet(true);
                //     Get.offAll(const OnbordingScreen());
                //   },context: context,txt1: "Log Out"),
                // ),
                InkWell(
                  onTap: () {
                    loginSharedPreferencesSet(true);
                    Get.offAll(const OnbordingScreen());
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/svgpicture/logout.svg",
                              height: 25,
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              "Log Out".tr,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.red),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                    showModalBottomSheet<void>(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15))),
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                              color: notifier.containercolore,
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  topLeft: Radius.circular(15))),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(
                                  height: 25,
                                ),
                                Text('Delete Account'.tr,
                                    style: TextStyle(
                                        color: theamcolore,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                const SizedBox(height: 12.5),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  height: 12.5,
                                ),
                                Text(
                                    'Are you sure you want to delete account?'
                                        .tr,
                                    style: TextStyle(
                                        color: notifier.textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          fixedSize:
                                              const WidgetStatePropertyAll(
                                                  Size(130, 40)),
                                          elevation:
                                              const WidgetStatePropertyAll(0),
                                          shape: WidgetStatePropertyAll(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          backgroundColor:
                                              const WidgetStatePropertyAll(
                                                  Colors.white)),
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'.tr.tr,
                                          style: const TextStyle(
                                              color: Colors.black)),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          fixedSize:
                                              const WidgetStatePropertyAll(
                                                  Size(130, 40)),
                                          elevation:
                                              const WidgetStatePropertyAll(0),
                                          shape: WidgetStatePropertyAll(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  theamcolore)),
                                      onPressed: () => {
                                        // resetNew(),
                                        loginSharedPreferencesSet(true),
                                        deleteAccount
                                            .deleteaccountApi(
                                                id: useridgloable.toString())
                                            .then(
                                          (value) {
                                            Get.offAll(OnbordingScreen());
                                          },
                                        ),
                                        // Delete_Api_Class(uid: userData["id"]).then((value) {
                                        //   ScaffoldMessenger.of(context).showSnackBar(
                                        //     SnackBar(content: Text(value["ResponseMsg"]),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                                        //   );
                                        // }),
                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => const Login_Screen(),))
                                      },
                                      child: Text('Yes,Remove'.tr,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                        child: Text(
                          "Delete account",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  final FocusNode _focusNode = FocusNode();

  int? couponindex;

  Buttonpresebottomshhet() {
    if (pickupcontroller.text.isEmpty || dropcontroller.text.isEmpty) {
      CustomNotification.show(
          message: "Select Pickup and Drop", type: NotificationType.info);
      ;
    } else if (amountresponse == "false") {
      CustomNotification.show(
          message: "Address is not in the zone!", type: NotificationType.info);
      ;
    } else if (dropprice == 0) {
      CustomNotification.show(
          message: responsemessage, type: NotificationType.info);
      ;
    } else {
      toast = 0;
      amountcontroller.text = dropprice.toString();
      // var maxprice =  dropprice + (dropprice * int.parse(maximumfare) / 100);
      // var minprice =  dropprice - (dropprice * int.parse(minimumfare) / 100);
      int maxprice = int.parse(maximumfare);
      int minprice = int.parse(minimumfare);
      print("**maxprice**:-- $maxprice");
      print("**maxprice**:-- $minprice");
      // controller.reset();
      // controller.dispose();

      Get.bottomSheet(
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        StatefulBuilder(
          builder: (context, setState) {
            return Container(
              // height: 460,
              width: Get.width,
              decoration: BoxDecoration(
                color: notifier.containercolore,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Column(
                      children: [
                        isanimation == false
                            ? const SizedBox()
                            : lottie.Lottie.asset("assets/lottie/loading.json",
                                height: 30),

                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            // Spacer(),
                            // homeApiController.homeapimodel!.runnigRide!.isEmpty ? SizedBox() :
                            // InkWell(
                            //   onTap: () {
                            //     setState((){
                            //       socatloadbidinfdata();
                            //     });
                            //   },
                            //   child: Container(
                            //     padding: EdgeInsets.all(10),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.all(Radius.circular(10)),
                            //       border: Border.all(color: theamcolore),
                            //     ),
                            //     child: Center(child: Text("Driver Bid",style: TextStyle(color: theamcolore,fontSize: 12),),),
                            //   ),
                            // ),
                            Spacer(),
                            SizedBox(
                              width: 40,
                            ),
                            Text(
                              "Set your price".tr,
                              style: TextStyle(
                                  color: notifier.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (controller != null &&
                                      controller!.isAnimating) {
                                    CustomNotification.show(
                                        message:
                                            "Your current request is in progress. You can either wait for it to complete or cancel to perform this action."
                                                .tr,
                                        type: NotificationType.info);
                                    ;
                                  } else {
                                    Get.back();
                                  }
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Image(
                                    image: AssetImage("assets/close.png"),
                                    color: notifier.textColor,
                                    height: 20,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text("💡Raise the fare, increase your chances.".tr,
                            style: const TextStyle(color: Colors.grey)),
                        // const SizedBox(height: 2,),
                        // const Text("amount goes to the captain",style: TextStyle(color: Colors.grey)),
                        // SizedBox(height: 30,),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (controller != null &&
                                      controller!.isAnimating) {
                                    CustomNotification.show(
                                        message:
                                            "Your current request is in progress. You can either wait for it to complete or cancel to perform this action."
                                                .tr,
                                        type: NotificationType.info);
                                    ;
                                  } else {
                                    if (double.parse(dropprice.toString()) >
                                        minprice) {
                                      dropprice -= 1;
                                      amountcontroller.text =
                                          dropprice.toString();
                                      mainamount = dropprice.toString();
                                      offerpluse = true;

                                      if (couponindex != null) {
                                        if (couponadd[couponindex!] == true) {
                                          couponadd[couponindex!] = false;
                                        }
                                      }

                                      // couponadd[couponindex!] = false;
                                      couponname = "";
                                      couponId = "";
                                      // if (controller != null && controller.isAnimating) {
                                      //   controller.dispose();
                                      // }
                                      // controller.reset();
                                      // controller.dispose();
                                    }
                                  }
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Image(
                                    image: AssetImage("assets/minus.png"),
                                    color: notifier.textColor,
                                    height: 20,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Center(
                              child: SizedBox(
                                width: 150,
                                child: TextField(
                                  // focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  controller: amountcontroller,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 30, color: notifier.textColor),
                                  readOnly: controller != null &&
                                          controller!.isAnimating
                                      ? true
                                      : false,
                                  onTap: () {
                                    controller != null &&
                                            controller!.isAnimating
                                        ? CustomNotification.show(
                                            message:
                                                "Your current request is in progress. You can either wait for it to complete or cancel to perform this action."
                                                    .tr,
                                            type: NotificationType.info)
                                        : "";
                                  },
                                  onSubmitted: (value) {
                                    setState(() {
                                      if (int.parse(amountcontroller.text) >
                                          maxprice) {
                                        amountcontroller.clear();
                                        toast = 1;
                                        print("fffff");
                                      } else if (int.parse(
                                              amountcontroller.text) <
                                          minprice) {
                                        amountcontroller.clear();
                                        toast = 2;
                                        print("hhhhh");
                                      } else {
                                        toast = 0;
                                        dropprice =
                                            int.parse(amountcontroller.text);
                                        mainamount = amountcontroller.text;
                                        // dropprice = amountcontroller.text;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (controller != null &&
                                      controller!.isAnimating) {
                                    CustomNotification.show(
                                        message:
                                            "Your current request is in progress. You can either wait for it to complete or cancel to perform this action."
                                                .tr,
                                        type: NotificationType.info);
                                    ;
                                  } else {
                                    if (double.parse(dropprice.toString()) <
                                        maxprice) {
                                      // dropprice = amountcontroller.text;
                                      dropprice += 1;
                                      amountcontroller.text =
                                          dropprice.toString();
                                      mainamount = dropprice.toString();
                                      offerpluse = true;
                                      if (couponindex != null) {
                                        if (couponadd[couponindex!] == true) {
                                          couponadd[couponindex!] = false;
                                        }
                                      }

                                      couponname = "";
                                      couponId = "";
                                      // if (controller != null && controller.isAnimating) {
                                      //   controller.dispose();
                                      // }
                                      // controller.reset();
                                      // controller.dispose();
                                    }
                                  }

                                  print("////:--- $dropprice");
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Image(
                                    image: AssetImage("assets/plus.png"),
                                    color: notifier.textColor,
                                    height: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        toast == 1
                            ? Text(
                                "Maximum fare is $currencyy$maxprice",
                                style: const TextStyle(color: Colors.red),
                              )
                            : toast == 2
                                ? Text(
                                    "Minimum fare is $currencyy$minprice",
                                    style: const TextStyle(color: Colors.red),
                                  )
                                : const SizedBox(),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          // leading: const Padding(
                          //   padding: EdgeInsets.only(left: 10),
                          //   child: Icon(Icons.telegram,size: 30,),
                          // ),
                          leading: const Image(
                            image: AssetImage("assets/automatically.png"),
                            height: 30,
                            width: 30,
                          ),
                          title: Text(
                            "Automatically book the nearest driver for (${globalcurrency}${amountcontroller.text})"
                                .tr,
                            style: TextStyle(
                                color: notifier.textColor, fontSize: 16),
                          ),
                          trailing: SizedBox(
                            height: 30,
                            width: 40,
                            child: Transform.scale(
                              scale: 0.9,
                              child: CupertinoSwitch(
                                // This bool value toggles the switch.
                                value: light,
                                activeColor: theamcolore,
                                onChanged: controller != null &&
                                        controller!.isAnimating
                                    ? (bool value) {
                                        CustomNotification.show(
                                            message:
                                                "Your current request is in progress. You can either wait for it to complete or cancel to perform this action."
                                                    .tr,
                                            type: NotificationType.info);
                                        ;
                                      }
                                    : (bool value) {
                                        setState(() {
                                          light = value;
                                          offerpluse = true;
                                          biddautostatus = value.toString();
                                          print(
                                              "****:--BIDSTATUS (${biddautostatus})");
                                        });
                                      },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  // Spacer(),

                  Container(
                    // height: 190,
                    decoration: BoxDecoration(
                        color: notifier.containercolore,
                        // border: Border.all(color: Colors.grey.withOpacity(0.4))
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0, -0.4),
                              blurRadius: 5),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    // for(int i=1; i<paymentGetApiController.paymentgetwayapi!.paymentList!.length; i++){
                                    //   if(int.parse(paymentGetApiController.paymentgetwayapi!.defaultPayment.toString()) == paymentGetApiController.paymentgetwayapi!.paymentList![i].id){
                                    //     setState((){
                                    //       payment = paymentGetApiController.paymentgetwayapi!.paymentList![i].id!;
                                    //       print("+++++$payment");
                                    //       print("+++++$i");
                                    //     });
                                    //   }
                                    // }

                                    showModalBottomSheet(
                                      // isDismissible: false,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15)),
                                      ),
                                      context: context,
                                      builder: (BuildContext context) {
                                        return StatefulBuilder(
                                            builder: (context, setState) {
                                          return ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15)),
                                            child: Scaffold(
                                              backgroundColor:
                                                  notifier.containercolore,
                                              floatingActionButtonLocation:
                                                  FloatingActionButtonLocation
                                                      .centerDocked,
                                              floatingActionButton: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10,
                                                    left: 10,
                                                    right: 10),
                                                child: CommonButton(
                                                    containcolore: theamcolore,
                                                    onPressed1: () {
                                                      Get.back();
                                                      Get.back();
                                                      Buttonpresebottomshhet();
                                                      // Get.back();
                                                    },
                                                    txt1: "CONTINUE".tr,
                                                    context: context),
                                              ),
                                              body: Container(
                                                // height: 450,
                                                decoration: BoxDecoration(
                                                  color:
                                                      notifier.containercolore,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  15),
                                                          topRight:
                                                              Radius.circular(
                                                                  15)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 50),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      const SizedBox(
                                                        height: 13,
                                                      ),
                                                      Text(
                                                          'Payment Getway Method'
                                                              .tr,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "SofiaProBold",
                                                              fontSize: 18,
                                                              color: notifier
                                                                  .textColor)),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      walleteamount == 0
                                                          ? const SizedBox()
                                                          : Row(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  "assets/svgpicture/wallet.svg",
                                                                  height: 30,
                                                                  color:
                                                                      theamcolore,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "My Wallet (${globalcurrency}${walleteamount})",
                                                                  style: TextStyle(
                                                                      color: notifier
                                                                          .textColor),
                                                                ),
                                                                const Spacer(),
                                                                Transform.scale(
                                                                  scale: 0.8,
                                                                  child:
                                                                      CupertinoSwitch(
                                                                    value:
                                                                        switchValue,
                                                                    activeColor:
                                                                        theamcolore,
                                                                    onChanged: (bool
                                                                        value) {
                                                                      setState(
                                                                          () {
                                                                        switchValue =
                                                                            value;
                                                                      });
                                                                    },
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Expanded(
                                                        child:
                                                            ListView.separated(
                                                                separatorBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return const SizedBox(
                                                                      width: 0);
                                                                },
                                                                shrinkWrap:
                                                                    true,
                                                                scrollDirection:
                                                                    Axis
                                                                        .vertical,
                                                                itemCount: paymentGetApiController
                                                                    .paymentgetwayapi!
                                                                    .paymentList!
                                                                    .length,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int index) {
                                                                  return InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        // payment = index;
                                                                        payment = paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![index]
                                                                            .id!;
                                                                        paymentname = paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![index]
                                                                            .name!;
                                                                        // paymentmethodId = paymentGetApiController.paymentgetwayapi!.paymentdata[index].id;
                                                                      });
                                                                    },
                                                                    child: paymentGetApiController.paymentgetwayapi!.paymentList![index].status ==
                                                                            "0"
                                                                        ? const SizedBox()
                                                                        : Container(
                                                                            height:
                                                                                90,
                                                                            margin: const EdgeInsets.only(
                                                                                left: 10,
                                                                                right: 10,
                                                                                top: 6,
                                                                                bottom: 6),
                                                                            padding:
                                                                                const EdgeInsets.all(5),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              // color: Colors.yellowAccent,
                                                                              border: Border.all(color: payment == paymentGetApiController.paymentgetwayapi!.paymentList![index].id! ? theamcolore : Colors.grey.withOpacity(0.4)),
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                            child:
                                                                                Center(
                                                                              child: ListTile(
                                                                                leading: Transform.translate(
                                                                                  offset: const Offset(-5, 0),
                                                                                  child: Container(
                                                                                    height: 100,
                                                                                    width: 60,
                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.4)), image: DecorationImage(image: NetworkImage('${Config.imageurl}${paymentGetApiController.paymentgetwayapi!.paymentList![index].image}'))),
                                                                                  ),
                                                                                ),
                                                                                title: Padding(
                                                                                  padding: const EdgeInsets.only(bottom: 4),
                                                                                  child: Text(
                                                                                    paymentGetApiController.paymentgetwayapi!.paymentList![index].name.toString(),
                                                                                    style: TextStyle(fontSize: 16, fontFamily: "SofiaProBold", color: notifier.textColor),
                                                                                    maxLines: 2,
                                                                                  ),
                                                                                ),
                                                                                subtitle: Padding(
                                                                                  padding: const EdgeInsets.only(bottom: 4),
                                                                                  child: Text(
                                                                                    paymentGetApiController.paymentgetwayapi!.paymentList![index].subTitle.toString(),
                                                                                    style: TextStyle(fontSize: 12, fontFamily: "SofiaProBold", color: notifier.textColor),
                                                                                    maxLines: 2,
                                                                                  ),
                                                                                ),
                                                                                trailing: Radio(
                                                                                  value: payment == paymentGetApiController.paymentgetwayapi!.paymentList![index].id! ? true : false,
                                                                                  fillColor: MaterialStatePropertyAll(theamcolore),
                                                                                  groupValue: true,
                                                                                  onChanged: (value) {
                                                                                    print(value);
                                                                                    setState(() {
                                                                                      selectedOption = value.toString();
                                                                                      selectBoring = paymentGetApiController.paymentgetwayapi!.paymentList![index].image.toString();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                  );
                                                                }),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                      },
                                    );
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    // leading: const Icon(Icons.card_giftcard_sharp),
                                    leading: const Image(
                                      image: AssetImage("assets/payment.png"),
                                      height: 30,
                                      width: 30,
                                    ),
                                    title: Transform.translate(
                                        offset: const Offset(-15, 0),
                                        child: Text(
                                          paymentname,
                                          style: TextStyle(
                                              color: notifier.textColor),
                                        )),
                                    trailing: Image(
                                      image: AssetImage(
                                          "assets/angle-right-small.png"),
                                      height: 30,
                                      color: notifier.textColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    {
                                      setState(() {
                                        mainamount = dropprice.toString();
                                        if (couponadd.isEmpty) {
                                          for (int i = 0;
                                              i <
                                                  paymentGetApiController
                                                      .paymentgetwayapi!
                                                      .couponList!
                                                      .length;
                                              i++) {
                                            couponadd.add(false);
                                          }
                                        }
                                      });

                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        // isDismissible: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15)),
                                        ),
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                            return Scaffold(
                                              backgroundColor:
                                                  notifier.containercolore,
                                              appBar: AppBar(
                                                elevation: 0,
                                                toolbarHeight: 90,
                                                backgroundColor:
                                                    notifier.containercolore,
                                                automaticallyImplyLeading:
                                                    false,
                                                leading: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 40,
                                                          left: 18,
                                                          right: 18),
                                                  child: InkWell(
                                                      onTap: () {
                                                        Get.back();
                                                      },
                                                      child: Image(
                                                        image: AssetImage(
                                                            "assets/arrow-left.png"),
                                                        color:
                                                            notifier.textColor,
                                                      )),
                                                ),
                                                title: Transform.translate(
                                                    offset:
                                                        const Offset(-10, 0),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 40),
                                                      child: Text(
                                                        "All coupons".tr,
                                                        style: TextStyle(
                                                            color: notifier
                                                                .textColor,
                                                            fontSize: 18),
                                                      ),
                                                    )),
                                              ),
                                              body: Padding(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Text(
                                                      "Best Coupon".tr,
                                                      style: TextStyle(
                                                          color: notifier
                                                              .textColor,
                                                          fontSize: 20),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            paymentGetApiController
                                                                .paymentgetwayapi!
                                                                .couponList!
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Container(
                                                            // height: 230,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 10),
                                                            decoration: BoxDecoration(
                                                                color: notifier
                                                                    .containercolore,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            15)),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.4))),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(15),
                                                              child: Row(
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "${paymentGetApiController.paymentgetwayapi!.couponList![index].title}",
                                                                        style: TextStyle(
                                                                            color:
                                                                                notifier.textColor,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 18),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        "${paymentGetApiController.paymentgetwayapi!.couponList![index].subTitle}",
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.grey),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            "Coupon Code: ".tr,
                                                                            style:
                                                                                TextStyle(color: notifier.textColor),
                                                                          ),
                                                                          Text(
                                                                            "${paymentGetApiController.paymentgetwayapi!.couponList![index].code}",
                                                                            style:
                                                                                TextStyle(color: theamcolore, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            "Coupon Amount: ".tr,
                                                                            style:
                                                                                TextStyle(color: notifier.textColor),
                                                                          ),
                                                                          Text(
                                                                            "${globalcurrency}${paymentGetApiController.paymentgetwayapi!.couponList![index].discountAmount}",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, color: notifier.textColor),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            "Minimum Amount: ".tr,
                                                                            style:
                                                                                TextStyle(color: notifier.textColor),
                                                                          ),
                                                                          Text(
                                                                            "${globalcurrency}${paymentGetApiController.paymentgetwayapi!.couponList![index].minAmount}",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, color: notifier.textColor),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            "Ex Date: ".tr,
                                                                            style:
                                                                                TextStyle(color: notifier.textColor),
                                                                          ),
                                                                          Text(
                                                                            paymentGetApiController.paymentgetwayapi!.couponList![index].endDate.toString().split(" ").first,
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, color: notifier.textColor),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              15),
                                                                      couponadd[index] ==
                                                                              true
                                                                          ? InkWell(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  // couponindex = index;
                                                                                  couponadd[index] = false;
                                                                                  dropprice = mainamount;
                                                                                  amountcontroller.text = mainamount;
                                                                                  couponname = "";
                                                                                  couponId = "";
                                                                                  Get.back(result: {
                                                                                    "coupAdded": "",
                                                                                    "couponid": "",
                                                                                  });
                                                                                  Get.back(result: {
                                                                                    "coupAdded": "",
                                                                                    "couponid": "",
                                                                                  });
                                                                                  Buttonpresebottomshhet();
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                  height: 45,
                                                                                  width: 130,
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border.all(color: Colors.red),
                                                                                    borderRadius: BorderRadius.circular(30),
                                                                                  ),
                                                                                  child: const Center(
                                                                                      child: Text(
                                                                                    "Remove",
                                                                                    style: TextStyle(color: Colors.red),
                                                                                  ))))
                                                                          : InkWell(
                                                                              onTap: () {
                                                                                if (double.parse(amountcontroller.text.toString()) >= double.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].minAmount.toString())) {
                                                                                  // cartController.checkCouponDataApi(cid: cartController.cartDataInfo?.couponList[index].id);

                                                                                  setState(() {
                                                                                    couponAmt = int.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].discountAmount.toString());
                                                                                    // couponadd[index] = true;
                                                                                    couponindex = index;
                                                                                    if (couponadd[index] == false) {
                                                                                      for (int i = 0; i < couponadd.length; i++) {
                                                                                        if (couponadd.contains(true)) {
                                                                                          couponadd[i] = false;
                                                                                        }
                                                                                      }
                                                                                      couponadd[index] = true;
                                                                                    } else {
                                                                                      couponadd[index] = false;
                                                                                    }
                                                                                  });

                                                                                  // amountcontroller.text = "${double.parse(amountcontroller.text) - double.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].discountAmount.toString())}";
                                                                                  // amountcontroller.text = "${double.parse(amountcontroller.text) - double.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].discountAmount.toString())}";

                                                                                  print("----------------------------------------${double.parse(amountcontroller.text.toString())}");
                                                                                  couponname = paymentGetApiController.paymentgetwayapi!.couponList![index].title.toString();
                                                                                  couponId = paymentGetApiController.paymentgetwayapi!.couponList![index].id.toString();

                                                                                  print("xjsbchjscvsgchsvcscsc  $couponId");

                                                                                  // Get.back(result: paymentGetApiController.paymentgetwayapi!.couponList![index].code);
                                                                                  Get.back(result: {
                                                                                    "coupAdded": paymentGetApiController.paymentgetwayapi!.couponList![index].title,
                                                                                    "couponid": paymentGetApiController.paymentgetwayapi!.couponList![index].id.toString(),
                                                                                  });
                                                                                  Get.back(result: {
                                                                                    "coupAdded": paymentGetApiController.paymentgetwayapi!.couponList![index].title,
                                                                                    "couponid": paymentGetApiController.paymentgetwayapi!.couponList![index].id.toString(),
                                                                                  });
                                                                                  Buttonpresebottomshhet();
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                  height: 45,
                                                                                  width: 130,
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border.all(color: int.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].minAmount!) < int.parse(mainamount) ? theamcolore : Colors.grey.withOpacity(0.2)),
                                                                                    borderRadius: BorderRadius.circular(30),
                                                                                  ),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    "Apply coupons".tr,
                                                                                    style: TextStyle(color: int.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].minAmount!) < int.parse(mainamount) ? theamcolore : Colors.grey),
                                                                                  ))),
                                                                            ),
                                                                    ],
                                                                  ),
                                                                  const Spacer(),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SvgPicture
                                                                          .asset(
                                                                        "assets/svgpicture/offerIcon.svg",
                                                                        height:
                                                                            50,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                    // Listview
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                      );
                                    }
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    // leading: const Padding(
                                    //   padding: EdgeInsets.only(top: 8),
                                    //   child: Icon(Icons.circle_notifications_sharp),
                                    // ),
                                    leading: const Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Image(
                                        image: AssetImage("assets/coupon.png"),
                                        height: 30,
                                        width: 30,
                                      ),
                                    ),

                                    title: couponname == ""
                                        ? Transform.translate(
                                            offset: const Offset(-15, 10),
                                            child: Text(
                                              "Coupon".tr,
                                              style: TextStyle(
                                                  color: notifier.textColor),
                                            ))
                                        : Transform.translate(
                                            offset: const Offset(-15, 0),
                                            child: Text(
                                              couponname,
                                              style: TextStyle(
                                                  color: notifier.textColor),
                                            )),
                                    subtitle: couponname == ""
                                        ? const Text("")
                                        : Transform.translate(
                                            offset: const Offset(-15, 0),
                                            child: Text(
                                              "Coupon applied".tr,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: notifier.textColor),
                                            )),
                                    trailing: Image(
                                      image: AssetImage(
                                          "assets/angle-right-small.png"),
                                      height: 30,
                                      color: notifier.textColor,
                                    ),

                                    // title: Transform.translate(offset: const Offset(-15, 0),child: const Text("BIKE50")),
                                    // subtitle: Transform.translate(offset: const Offset(-15, 0),child: const Text("Coupon applied",style: TextStyle(fontSize: 12),)),
                                    // trailing: const Image(image: AssetImage("assets/angle-right-small.png"),height: 30,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isanimation == false
                              ? CommonButton(
                                  containcolore: theamcolore,
                                  onPressed1: () {
                                    setState(() {
                                      if (double.parse(amountcontroller.text) >
                                          maxprice) {
                                        amountcontroller.clear();
                                        toast = 1;
                                        print("fffff");
                                      } else if (double.parse(
                                              amountcontroller.text) <
                                          minprice) {
                                        amountcontroller.clear();
                                        toast = 2;
                                        print("hhhhh");
                                      } else {
                                        isanimation = true;
                                        loadertimer = true;
                                        offerpluse = false;
                                        requesttime();
                                        orderfunction();
                                        // dropprice = amountcontroller.text;
                                      }
                                    });
                                  },
                                  context: context,
                                  txt1:
                                      "Book for ${currencyy ?? globalcurrency}${amountcontroller.text}")
                              : AnimatedBuilder(
                                  animation: controller!,
                                  builder: (context, child) {
                                    return SizedBox(
                                      height: 49,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          padding: const WidgetStatePropertyAll(
                                              EdgeInsets.zero),
                                          elevation:
                                              const WidgetStatePropertyAll(0),
                                          overlayColor:
                                              const WidgetStatePropertyAll(
                                                  Colors.transparent),
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  theamcolore.withOpacity(0.4)),
                                          shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            setState(() {
                                              if (double.parse(
                                                      amountcontroller.text) >
                                                  maxprice) {
                                                amountcontroller.clear();
                                                toast = 1;
                                                print("fffff");
                                              } else if (double.parse(
                                                      amountcontroller.text) <
                                                  minprice) {
                                                amountcontroller.clear();
                                                toast = 2;
                                                print("hhhhh");
                                              } else {
                                                if (offerpluse == true) {
                                                  // refreshAnimation();
                                                  if (controller != null &&
                                                      controller!.isAnimating) {
                                                    controller!.dispose();
                                                  }
                                                  print(
                                                      "fgvjgfsvjhsgfvjhbfgvjhafgbvhjkafgv");
                                                  requesttime();
                                                  orderfunction();

                                                  offerpluse = false;
                                                } else {}
                                                // dropprice = amountcontroller.text;
                                              }

                                              // refreshAnimation();

                                              if (double.parse(
                                                      amountcontroller.text) >
                                                  maxprice) {
                                                amountcontroller.clear();
                                                amountcontroller.text =
                                                    maxprice.toString();
                                                toast = 1;
                                                print("fffff");
                                              } else if (double.parse(
                                                      amountcontroller.text) <
                                                  minprice) {
                                                amountcontroller.clear();
                                                amountcontroller.text =
                                                    minprice.toString();
                                                toast = 2;
                                                print("hhhhh");
                                              } else {
                                                toast = 0;
                                                // dropprice =
                                                dropprice = double.parse(
                                                    amountcontroller.text);
                                                mainamount =
                                                    amountcontroller.text;
                                              }
                                            });
                                          });
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          clipBehavior: Clip.none,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: LinearProgressIndicator(
                                                minHeight: 49,
                                                value: 1.0 - controller!.value,
                                                backgroundColor: theamcolore
                                                    .withOpacity(0.1),
                                                color: theamcolore,
                                              ),
                                            ),
                                            offerpluse == true
                                                ? Text(
                                                    "Raise fare to $currencyy${amountcontroller.text}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                      letterSpacing: 0.4,
                                                    ),
                                                  )
                                                : Text(
                                                    "Book for $currencyy${amountcontroller.text}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                      letterSpacing: 0.4,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          homeApiController.homeapimodel!.runnigRide!.isEmpty
                              ? SizedBox()
                              : homeApiController.homeapimodel!.runnigRide![0]
                                          .biddingRunStatus ==
                                      0
                                  ? SizedBox()
                                  : const SizedBox(
                                      height: 10,
                                    ),
                          homeApiController.homeapimodel!.runnigRide!.isEmpty
                              ? SizedBox()
                              : homeApiController.homeapimodel!.runnigRide![0]
                                          .biddingRunStatus ==
                                      0
                                  ? SizedBox()
                                  : CommonOutLineButton(
                                      bordercolore: theamcolore,
                                      onPressed1: () {
                                        setState(() {
                                          // socket.connect();
                                          homeApiController
                                              .homeapimodel!
                                              .runnigRide![0]
                                              .biddingRunStatus = 0;
                                          print(
                                              "+++++ biddingRunStatus +++++ :- ${homeApiController.homeapimodel!.runnigRide![0].biddingRunStatus}");
                                          socatloadbidinfdata();
                                        });
                                      },
                                      context: context,
                                      txt1: "Driver Offers"),
                          const SizedBox(
                            height: 10,
                          ),
                          StatefulBuilder(
                            builder: (context, setState) {
                              return cancelloader
                                  ? Center(
                                      child: CustomLoadingWidget(),
                                    )
                                  : CommonOutLineButton(
                                      bordercolore: theamcolore,
                                      onPressed1: () {
                                        setState(() {
                                          isanimation = false;
                                          cancelloader = true;
                                          print(
                                              "++CANCEL LOADER++:- ${cancelloader}");
                                          removeRequest
                                              .removeApi(
                                                  uid: useridgloable.toString())
                                              .then(
                                            (value) {
                                              socket.emit('AcceRemoveOther', {
                                                'requestid': request_id,
                                                'driverid': calculateController
                                                    .calCulateModel!.driverId!,
                                              });
                                              // socket.emit('Vehicle_Ride_Cancel',{
                                              //   'uid': "$useridgloable",
                                              //   'driverid' : value["driver_list"],
                                              // });
                                              Future.delayed(
                                                  Duration(microseconds: 500),
                                                  () {
                                                setState(() {
                                                  setState(() {});
                                                });
                                              });
                                              Get.back();
                                              cancelloader = false;
                                            },
                                          );
                                          if (controller != null &&
                                              controller!.isAnimating) {
                                            print("vgvgvgvgvgvgvgvgvgvgv");
                                            controller!.dispose();
                                          }
                                          cancelTimer();
                                        });
                                      },
                                      context: context,
                                      txt1: "Cancel Request".tr);
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // CommonButton(containcolore: theamcolore, onPressed1: () {
                  //   Get.back();
                  // },txt1: "Book Auto for \$45",context: context),
                  // const SizedBox(height: 10,),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  orderfunction() {
    print("DRIVER ID:- ${calculateController.calCulateModel!.driverId!}");
    print("PICK LOCATION:- ${pickupcontroller.text}");
    print("DROP LOCATION:- ${dropcontroller.text}");
    socket.connect();

    homeWalletApiController
        .homwwalleteApi(uid: userid.toString(), context: context)
        .then(
      (value) {
        print("{{{{{[wallete}}}}}]:-- ${value["wallet_amount"]}");
        walleteamount = double.parse(value["wallet_amount"]);
        print("[[[[[[[[[[[[[walleteamount]]]]]]]]]]]]]:-- ($walleteamount)");
      },
    );
    // refreshAnimation();

    // print("111111111dd111111111 ${calculateController.calCulateModel!.driverId}");
    print("111111111 amountcontroller.text 111111111 ${amountcontroller.text}");

    percentValue.clear();
    percentValue = [];
    for (int i = 0; i < 4; i++) {
      percentValue.add(0);
    }
    setState(() {
      currentStoryIndex = 0;
      // loadertimer = false;
    });

    priceyourfare = double.parse(amountcontroller.text);
    print("***price***::-(${priceyourfare})");

    addVihicalCalculateController.addvihicalcalculateApi(
      pickupadd: {
        "title": "${picktitle == "" ? addresspickup : picktitle}",
        "subt": picksubtitle
      },
      dropadd: {"title": droptitle, "subt": dropsubtitle},
      droplistadd: droptitlelist,
      context: context,
      uid: useridgloable.toString(),
      tot_km: "$totalkm",
      vehicle_id: vehicle_id,
      tot_minute: tot_time,
      tot_hour: tot_hour,
      m_role: mroal,
      coupon_id: couponId,
      payment_id: "$payment",
      driverid: calculateController.calCulateModel!.driverId!,
      // driverid: [29,14],
      price: amountcontroller.text,
      pickup: "$latitudepick,$longitudepick",
      drop: "$latitudedrop,$longitudedrop",
      droplist: onlypass,
      bidd_auto_status: biddautostatus,
    ).then(
      (value) {
        print("+++++${value["id"]}");
        setState(() {});
        request_id = value["id"].toString();
        socateempt();
      },
    );

    calculateController
        .calculateApi(
            context: context,
            uid: userid.toString(),
            mid: mid,
            mrole: mroal,
            pickup_lat_lon: "$latitudepick,$longitudepick",
            drop_lat_lon: "$latitudedrop,$longitudedrop",
            drop_lat_lon_list: onlypass)
        .then(
      (value) {
        // print("********** value **********:----- ${value}");
        // print("********** value **********:----- ${value["drop_price"]}");
        // print("********** value **********:----- ${value["vehicle"]["minimum_fare"]}");
        // print("********** value **********:----- ${value["vehicle"]["maximum_fare"]}");

        dropprice = 0;
        minimumfare = 0;
        maximumfare = 0;

        if (value["Result"] == true) {
          amountresponse = "true";
          dropprice = value["drop_price"];
          minimumfare = value["vehicle"]["minimum_fare"];
          maximumfare = value["vehicle"]["maximum_fare"];
          responsemessage = value["message"];
        } else {
          amountresponse = "false";
          print("jojojojojojojojojojojojojojojojojojojojojojojojo");
        }

        print("********** dropprice **********:----- $dropprice");
        print("********** minimumfare **********:----- $minimumfare");
        print("********** maximumfare **********:----- $maximumfare");
      },
    );
  }
}

class RefreshData {
  final bool shouldRefresh;
  RefreshData(this.shouldRefresh);
}
