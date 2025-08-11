// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
import 'package:qareeb/common_code/global_variables.dart' hide destinationlat;
import 'package:qareeb/controllers/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:qareeb/api_code/coupon_payment_api_contoller.dart';
import 'package:qareeb/api_code/home_controller.dart';
import 'package:qareeb/app_screen/home_screen.dart';
import 'package:qareeb/app_screen/pagelist_description.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';
import 'package:qareeb/app_screen/profile_screen.dart';
import 'package:qareeb/app_screen/refer_and_earn.dart';
import 'package:qareeb/app_screen/top_up_screen.dart';
import 'dart:ui' as ui;
import 'package:qareeb/common_code/colore_screen.dart';
import 'package:qareeb/common_code/common_button.dart';
import 'package:qareeb/common_code/common_flow_screen.dart';
import 'package:qareeb/common_code/config.dart';
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

import '../common_code/push_notification.dart';
import 'counter_bottom_sheet.dart';
import 'driver_list_screen.dart';
import 'driver_startride_screen.dart';
import 'faq_screen.dart';
import 'language_screen.dart';
import 'my_ride_screen.dart';
import 'notification_screen.dart';

class MapScreen extends StatefulWidget {
  final bool selectvihical;
  const MapScreen({super.key, required this.selectvihical});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final appController = AppController.instance;

  int get _durationInSeconds => appController.durationInSeconds.value;

  set _durationInSeconds(int value) =>
      appController.durationInSeconds.value = value;

  String get tot_hour => appController.totalHour.value;

  set tot_hour(String value) => appController.totalHour.value = value;

  String get tot_time => appController.totalTime.value;

  set tot_time(String value) => appController.totalTime.value = value;

  String get vehicle_id => appController.vehicleId.value;

  set vehicle_id(String value) => appController.vehicleId.value = value;

  double get vihicalrice => appController.vehiclePrice.value;

  set vihicalrice(double value) => appController.vehiclePrice.value = value;

  double get totalkm => appController.totalKm.value;

  set totalkm(double value) => appController.totalKm.value = value;

  String get tot_secound => appController.totalSecond.value;

  set tot_secound(String value) => appController.totalSecond.value = value;

  String get vihicalimage => appController.vehicleImage.value;

  set vihicalimage(String value) => appController.vehicleImage.value = value;

  String get vihicalname => appController.vehicleName.value;

  set vihicalname(String value) => appController.vehicleName.value = value;

  bool get loadertimer => appController.loadingTimer.value;

  set loadertimer(bool value) => appController.loadingTimer.value = value;

  String get globalcurrency => appController.globalCurrency.value;

  set globalcurrency(String value) =>
      appController.globalCurrency.value = value;

  num get priceyourfare => appController.priceYourFare.value;

  set priceyourfare(num value) =>
      appController.priceYourFare.value = value.toDouble();

  String get extratime => appController.extraTime.value;

  set extratime(String value) => appController.extraTime.value = value;

  String get timeincressstatus => appController.timeIncreaseStatus.value;

  set timeincressstatus(String value) =>
      appController.timeIncreaseStatus.value = value;

  String get request_id => appController.requestId.value;

  set request_id(String value) => appController.requestId.value = value;

  String get driver_id => appController.driverId.value;

  set driver_id(String value) => appController.driverId.value = value;

  bool get otpstatus => appController.otpStatus.value;

  set otpstatus(bool value) => appController.otpStatus.value = value;

  int get select => appController.selectedVehicleIndex.value;

  set select(int value) => appController.selectedVehicleIndex.value = value;

  int get midseconde => appController.midSecond.value;

  set midseconde(int value) => appController.midSecond.value = value;

  final List<LatLng> vihicallocations = [];

  final List<String> _iconPaths = [];
  final List<String> _iconPathsbiddingon = [];
  final List<LatLng> vihicallocationsbiddingon = [];
  List<PointLatLng> _dropOffPoints = [];
  List<bool> couponadd = [];
  AnimationController? _animationController;
  Animation<Color?>? _colorAnimation;
  bool _isAnimationRunning = false;
  // bool timeout = false;

  String themeForMap = "";

  mapThemeStyle({required context}) {
    if (darkMode == true) {
      setState(() {
        DefaultAssetBundle.of(context)
            .loadString("assets/map_styles/dark_style.json")
            .then(
          (value) {
            setState(() {
              themeForMap = value;
            });
          },
        );
      });
    }
  }

  bool isLoad = false;

  bool light = false;
  String biddautostatus = "false";
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
  bool socketInitialized = false;

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

  socketConnect() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      var uid = preferences.getString("userLogin");

      var currency = preferences.getString("currenci");

      if (uid == null) {
        Get.offAll(() => const OnboardingScreen());

        return;
      }

      decodeUid = jsonDecode(uid);

      if (currency != null) {
        currencyy = jsonDecode(currency);

        globalcurrency = currencyy['symbol'] ?? "\$"; // ✅ Direct assignment
      } else {
        currencyy = {};

        globalcurrency = "\$";
      }

      userid = decodeUid['id'];

      username = decodeUid["name"] ?? "";

      appController.globalUserId.value = userid.toString();

      appController.userName.value = username;

      appController.socketService.connect();

      _setupSocketListeners();

      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print("Error in socketConnect: $e");
      }

      Get.offAll(() => const OnboardingScreen());
    }
  }

  void _setupSocketListeners() {
    final socketService = appController.socketService;

    // Home event listener
    socketService.on('home', (data) {
      if (kDebugMode) {
        print("🏠 Home event: $data");
      }
      // Handle home event
    });

    // Vehicle request acceptance
    socketService.on('acceptvehrequest${appController.userId.value}', (data) {
      if (kDebugMode) {
        print("🚗 Accept vehicle request: $data");
      }
      // Handle acceptance
    });
  }

  _connectSocket() async {
    final appController = AppController.instance;

    // ✅ REPLACE: useridgloable with appController

    if (appController.globalUserId.value.isEmpty) {
      if (kDebugMode) {
        print("Error: userid is null in _connectSocket");
      }

      return;
    }

    // ✅ REPLACE: All global variables with AppController

    homeWalletApiController
        .homwwalleteApi(uid: appController.globalUserId.value, context: context)
        .then((value) {
      try {
        if (value != null && value["wallet_amount"] != null) {
          walleteamount = double.parse(value["wallet_amount"].toString());
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing wallet amount: $e");
        }
      }
    });

    // Continue with other API calls using appController.globalUserId.value...
  }

  requesttime() {
    _durationInSeconds = int.parse(
        calculateController.calCulateModel!.offerExpireTime.toString());

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _durationInSeconds),
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.green,
    ).animate(_animationController!);

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_animationController == null || !mounted) return;

        _isAnimationRunning = false;

        setState(() {});

        Get.back();

        timeoutRequestApiController
            .timeoutrequestApi(
                uid: appController.globalUserId.value,
                request_id: request_id) // ✅ Uses getter automatically

            .then((value) {
          // Handle timeout...
        });
      }
    });

    _animationController!.forward();
  }

// Helper methods for socket management and other files:
  bool isSocketInitialized() {
    return socketInitialized;
  }

// Safe socket emit method for other files to use
  void emitSocketEvent(String event, dynamic data) {
    if (!isSocketInitialized()) {
      if (kDebugMode) {
        print("Socket not initialized, cannot emit: $event");
      }
      return;
    }

    if (socket.connected) {
      socket.emit(event, data);
    } else {
      if (kDebugMode) {
        print("Socket not connected, cannot emit: $event");
      }
    }
  }

// Methods that other files are using - keep them working:
  void socateempt() {
    appController.socketService.emit('vehiclerequest', {
      'requestid': addVihicalCalculateController.addVihicalCalculateModel!.id,
      'driverid': calculateController.calCulateModel!.driverId!,
    });
  }

// STEP 5: Replace globals in socateemptrequesttimeout() method

  void socateemptrequesttimeout() {
    appController.socketService.emitVehicleRideCancel(
      appController.globalUserId.value,
      calculateController.calCulateModel!.driverId!,
    );
  }

// Add this to your dispose method:
  @override
  void dispose() {
    if (kDebugMode) {
      print("🗑️ MapScreen disposing...");
    }
    _animationController?.dispose();

    _animationController = null;

    super.dispose();
  }

// For other files that need to emit socket events, create helper methods:
// These methods can be called from other files safely

  void emitVehicleRideCancel(String uid, dynamic driverid) {
    final appController = AppController.instance;
    appController.socketService.emitVehicleRideCancel(uid, driverid);
  }

  void emitVehiclePaymentChange(String userid, String dId, int paymentId) {
    final appController = AppController.instance;
    appController.socketService.emit('Vehicle_P_Change', {
      'userid': userid,
      'd_id': dId,
      'payment_id': paymentId,
    });
  }

  void emitVehicleRideComplete(String dId, String requestId) {
    final appController = AppController.instance;
    appController.socketService.emit('Vehicle_Ride_Complete', {
      'd_id': dId,
      'request_id': requestId,
    });
  }

  void emitSendChat(
      String senderId, String receiverId, String message, String status) {
    final appController = AppController.instance;
    appController.socketService.emit('Send_Chat', {
      'sender_id': senderId,
      'recevier_id': receiverId,
      'message': message,
      'status': status,
    });
  }

  void emitAcceptBidding(
      String uid, String dId, String requestId, String price) {
    final appController = AppController.instance;
    appController.socketService.emitAcceptBidding(uid, dId, requestId, price);
  }

  void emitVehicleRequest(String requestId, List driverId, String cId) {
    final appController = AppController.instance;
    appController.socketService.emitVehicleRequest(requestId, driverId, cId);
  }

  void emitVehicleTimeRequest(String uid, String dId) {
    final appController = AppController.instance;
    appController.socketService.emit('Vehicle_Time_Request', {
      'uid': uid,
      'd_id': dId,
    });
  }

  bool isTimerRunning = false;

  pagelistApiController pagelistcontroller = Get.put(pagelistApiController());

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      print("DURATION SECONDS: $_durationInSeconds");
    }

    // ✅ KEEP: Map theme
    mapThemeStyle(context: context);

    // ✅ KEEP: Initialize drop off points
    _dropOffPoints = [];
    _dropOffPoints = destinationlat;
    if (kDebugMode) {
      print("****////***:-----  $_dropOffPoints");
    }

    // ✅ KEEP: Load user data FIRST, then call APIs
    initializeApp();
  }

// New method to handle proper initialization order:
  Future<void> initializeApp() async {
    try {
      // Step 1: Load user data first
      await loadUserData();

      if (userid == null) {
        if (kDebugMode) {
          print("User not logged in, redirecting to login");
        }
        Get.offAll(() => const OnboardingScreen());
        return;
      }

      // Step 2: Initialize location and socket
      await fun();
      setState(() {});
      getCurrentLatAndLong(lathome, longhome);

      // Step 3: Initialize socket with user data
      await socketConnect();

      // Step 4: Now make API calls that need user data
      makeInitialAPICalls();
    } catch (e) {
      if (kDebugMode) {
        print("Error in initializeApp: $e");
      }
      // Don't force logout for initialization errors
    }
  }

  Future<void> loadUserData() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      var uid = preferences.getString("userLogin");

      var currency = preferences.getString("currenci");

      if (uid == null) {
        throw Exception("No user data");
      }

      decodeUid = jsonDecode(uid);

      if (currency != null) {
        currencyy = jsonDecode(currency);

        globalcurrency = currencyy['symbol'] ?? "\$"; // ✅ Direct assignment
      } else {
        currencyy = {};

        globalcurrency = "\$";
      }

      userid = decodeUid['id'];

      username = decodeUid["name"] ?? "";

      appController.globalUserId.value = userid.toString();

      appController.userName.value = username;

      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print("Error loading user data: $e");
      }

      throw e;
    }
  }

// Make API calls that need user data - ONLY after user data is loaded
  void makeInitialAPICalls() {
    if (userid == null) {
      if (kDebugMode) {
        print("Cannot make API calls - userid is null");
      }
      return;
    }

    if (kDebugMode) {
      print("Making initial API calls with userid: $userid");
    }

    // Payment API call
    paymentGetApiController.paymentlistApi(context).then((value) {
      try {
        if (paymentGetApiController.paymentgetwayapi?.paymentList != null) {
          for (int i = 1;
              i < paymentGetApiController.paymentgetwayapi!.paymentList!.length;
              i++) {
            if (int.parse(paymentGetApiController
                    .paymentgetwayapi!.defaultPayment
                    .toString()) ==
                paymentGetApiController.paymentgetwayapi!.paymentList![i].id) {
              setState(() {
                payment = paymentGetApiController
                    .paymentgetwayapi!.paymentList![i].id!;
                paymentname = paymentGetApiController
                    .paymentgetwayapi!.paymentList![i].name!;
                if (kDebugMode) {
                  print("+++++payment: $payment");
                  print("+++++index: $i");
                }
              });
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error processing payment data: $e");
        }
      }
    }).catchError((error) {
      if (kDebugMode) {
        print("Error in payment API: $error");
      }
    });

    // Page list API call
    pagelistcontroller.pagelistttApi(context);

    // Handle widget.selectvihical case
    if (widget.selectvihical == true) {
      if (kDebugMode) {
        print("selectvihical is true - calling homeApi and calculateApi");
      }
      select1 = 0;

      homeApiController
          .homeApi(
              uid: userid.toString(),
              lat: lathome.toString(),
              lon: longhome.toString())
          .then((value) {
        try {
          if (homeApiController.homeapimodel?.categoryList?.isNotEmpty ==
              true) {
            mid =
                homeApiController.homeapimodel!.categoryList![0].id.toString();
            mroal = homeApiController.homeapimodel!.categoryList![0].role
                .toString();

            // Now call calculateApi with proper user data
            calculateController
                .calculateApi(
                    context: context,
                    uid: appController.globalUserId.value,
                    mid: mid,
                    mrole: mroal,
                    pickup_lat_lon:
                        "${appController.pickupLat.value},${appController.pickupLng.value}",
                    drop_lat_lon:
                        "${appController.dropLat.value},${appController.dropLng.value}",
                    drop_lat_lon_list: onlypass)
                .then((value) {
              try {
                dropprice = 0;
                minimumfare = 0;
                maximumfare = 0;

                if (value?["Result"] == true) {
                  amountresponse = "true";
                  // ✅ FIX: Safely parse all incoming values to the correct double type.
                  dropprice = (value["drop_price"] as num?)?.toDouble() ?? 0.0;
                  minimumfare = double.tryParse(
                          value["vehicle"]["minimum_fare"]?.toString() ??
                              '0') ??
                      0.0;
                  maximumfare = double.tryParse(
                          value["vehicle"]["maximum_fare"]?.toString() ??
                              '0') ??
                      0.0;
                  responsemessage = value["message"];

                  tot_hour = value["tot_hour"]?.toString() ?? "0";
                  tot_time = value["tot_minute"]?.toString() ?? "0";
                  vehicle_id = value["vehicle"]["id"]?.toString() ?? "";
                  vihicalrice =
                      double.parse(value["drop_price"]?.toString() ?? "0");
                  totalkm = double.parse(value["tot_km"]?.toString() ?? "0");
                  tot_secound = "0";

                  vihicalimage = value["vehicle"]["map_img"]?.toString() ?? "";
                  vihicalname = value["vehicle"]["name"]?.toString() ?? "";

                  setState(() {});
                } else {
                  amountresponse = "false";
                  if (kDebugMode) {
                    print("Calculate API returned false result");
                  }
                  setState(() {});
                }

                if (kDebugMode) {
                  print("********** dropprice **********:----- $dropprice");
                  print("********** minimumfare **********:----- $minimumfare");
                  print("********** maximumfare **********:----- $maximumfare");
                }
              } catch (e) {
                if (kDebugMode) {
                  print("Error processing calculate API response: $e");
                }
              }
            }).catchError((error) {
              if (kDebugMode) {
                print("Error in calculate API call: $error");
              }
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error processing home API response: $e");
          }
        }
      }).catchError((error) {
        if (kDebugMode) {
          print("Error in home API call: $error");
        }
      });
    }

    // Setup map markers after location is loaded
    setupMapMarkers();
  }

// Setup map markers
  void setupMapMarkers() {
    try {
      // Add markers only if coordinates are valid
      if (appController.pickupLat.value != 0.0 &&
          appController.pickupLng.value != 0.0) {
        _addMarker11(
            LatLng(
                appController.pickupLat.value, appController.pickupLng.value),
            "origin",
            BitmapDescriptor.defaultMarker);
      }

      if (appController.dropLat != 0.0 && appController.dropLng != 0.0) {
        /// destination marker
        _addMarker2(
            LatLng(appController.dropLat.value, appController.dropLng.value),
            "destination",
            BitmapDescriptor.defaultMarkerWithHue(90));
      }

      // Add drop-off point markers
      for (int a = 0; a < _dropOffPoints.length; a++) {
        _addMarker3("destination");
      }

      // Get directions if we have valid coordinates
      if (latitudepick != 0.0 &&
          longitudepick != 0.0 &&
          latitudedrop != 0.0 &&
          longitudedrop != 0.0) {
        getDirections11(
            lat1: PointLatLng(latitudepick, longitudepick),
            lat2: PointLatLng(latitudedrop, longitudedrop),
            dropOffPoints: _dropOffPoints);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error setting up map markers: $e");
      }
    }
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
                          appController.pickupTitle.value.isEmpty
                              ? appController.pickupController.text
                              : appController.pickupTitle.value,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        appController.pickupSubtitle.value == ""
                            ? const SizedBox()
                            : Text(
                                appController.pickupSubtitle.value,
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
                          appController.dropTitle.value,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          appController.dropSubtitle.value,
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
                            "${appController.dropTitleList[a]["title"]}",
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${appController.dropTitleList[a]["subt"]}",
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
    // The loadIcon helper function is fine.
    Future<BitmapDescriptor> loadIcon(String url,
        {int targetWidth = 30, int targetHeight = 50}) async {
      try {
        if (url.isEmpty || url.contains("undefined")) {
          return BitmapDescriptor.defaultMarker;
        }
        final http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;
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
        print("Error loading icon from $url: $e");
        return BitmapDescriptor.defaultMarker;
      }
    }

    // Load all icons asynchronously
    final List<BitmapDescriptor> icons = await Future.wait(
      _iconPaths.map((path) => loadIcon(path)),
    );

    // ✅ FIX 1: Check if the widget is still mounted before calling setState.
    if (!mounted) return;

    // ✅ FIX 2: Refactored to a single, efficient setState call.
    setState(() {
      if (pickupcontroller.text.isEmpty || dropcontroller.text.isEmpty) {
        polylines11.clear();
      }

      for (var i = 0; i < vihicallocations.length; i++) {
        print("qqqqqqqqq:-- ${homeMapController.homeMapApiModel!.list![i].id}");
        print("aaaaaaaaa:-- ${vihicallocations.length}");
        MarkerId markerId =
            MarkerId("${homeMapController.homeMapApiModel!.list![i].id}");
        Marker marker = Marker(
          markerId: markerId,
          icon: icons[i],
          position: LatLng(
              double.parse(homeMapController.homeMapApiModel!.list![i].latitude
                  .toString()),
              double.parse(homeMapController.homeMapApiModel!.list![i].longitude
                  .toString())),
        );
        markers[markerId] = marker;
      }
    });
  }

  void _addMarkers2() async {
    // The loadIcon helper function is fine.
    Future<BitmapDescriptor> loadIcon(String url) async {
      try {
        if (url.isEmpty || url.contains("undefined")) {
          return BitmapDescriptor.defaultMarker;
        }
        final http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;
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
        print("Error loading icon from $url: $e");
        return BitmapDescriptor.defaultMarker;
      }
    }

    // Load all icons asynchronously
    final List<BitmapDescriptor> icons = await Future.wait(
      _iconPathsbiddingon.map((path) => loadIcon(path)),
    );

    // ✅ FIX 1: Check if the widget is still mounted before calling setState.
    if (!mounted) return;

    // ✅ FIX 2: Refactored to a single, efficient setState call.
    setState(() {
      markers11.clear();

      _addMarker11(LatLng(latitudepick, longitudepick), "origin",
          BitmapDescriptor.defaultMarker);

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
        final markerId =
            MarkerId('${homeMapController.homeMapApiModel!.list![i].id}');
        final marker = Marker(
          markerId: markerId,
          position: LatLng(
              double.parse(homeMapController.homeMapApiModel!.list![i].latitude
                  .toString()),
              double.parse(homeMapController.homeMapApiModel!.list![i].longitude
                  .toString())),
          icon: icons[i],
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

  Future getCurrentLatAndLong(double latitude, double longitude) async {
    lathome = latitude;

    longhome = longitude;

    lathomecurrent = latitude;

    longhomecurrent = longitude;

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(lathome, longhome)
              .timeout(const Duration(seconds: 10));

      addresshome =
          '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.country}';

      // ✅ FIX: Use AppController instead of global pickupcontroller

      if (appController.pickupController.text.isEmpty) {
        appController.pickupController.text = addresshome.toString();
      }

      if (kDebugMode) {
        print("FIRST USER CURRENT LOCATION :-- $addresshome");

        print("FIRST USER CURRENT LOCATION :-- $lathome");

        print("FIRST USER CURRENT LOCATION :-- $longhome");
      }
    } catch (e) {
      addresshome = 'Location: $latitude, $longitude';

      // ✅ FIX: Use AppController instead of global pickupcontroller

      if (appController.pickupController.text.isEmpty) {
        appController.pickupController.text = addresshome;
      }

      if (kDebugMode) print("Geocoding error: $e");
    }

    setState(() {});
  }

// Simple network check without external plugin
  Future<bool> _hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
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

  socatloadbidinfdata() {
    appController.socketService.emit('load_bidding_data', {
      'uid': appController.globalUserId.value,
      'request_id': appController.requestId.value,
      'd_id': calculateController.calCulateModel!.driverId
    });
  }

// ✅ FIX: refreshAnimation() method

  void refreshAnimation() {
    _animationController?.reset();

    _animationController?.repeat(reverse: false);
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
              ? Center(
                  child: CircularProgressIndicator(
                  color: theamcolore,
                ))
              : Stack(
                  children: [
                    // pickupcontroller.text.isEmpty || dropcontroller.text.isEmpty ? lathome == null ? Center(child: CircularProgressIndicator(color: theamcolore,)) :
                    lathome == null
                        ? Center(
                            child: CircularProgressIndicator(
                            color: theamcolore,
                          ))
                        : GoogleMap(
                            gestureRecognizers: {
                              Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer())
                            },
                            initialCameraPosition: appController
                                        .pickupController.text.isEmpty ||
                                    appController.dropController.text.isEmpty
                                ? CameraPosition(
                                    target: LatLng(lathome, longhome), zoom: 13)
                                : CameraPosition(
                                    target: LatLng(
                                        appController.pickupLat.value,
                                        appController.pickupLng.value),
                                    zoom: 13),

                            mapType: MapType.normal,
                            // markers: markers.,
                            markers: appController
                                        .pickupController.text.isEmpty ||
                                    appController.dropController.text.isEmpty
                                ? Set<Marker>.of(markers.values)
                                : Set<Marker>.of(markers11.values),
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
                                      "******-**:::::------$vihicallocations");
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
                                    height: 90,
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
                                                vihicallocationsbiddingon
                                                    .clear();

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
                                                              fun().then(
                                                                  (value) {
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
                                                              "******-**:::::------$vihicallocations");
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
                                                              _iconPathsbiddingon
                                                                  .add(
                                                                      "${Config.imageurl}${homeMapController.homeMapApiModel!.list![i].image}");
                                                            }
                                                            _addMarkers2();
                                                          }

                                                          print(
                                                              "******-**:::::------$vihicallocationsbiddingon");
                                                        },
                                                      );

                                                calculateController
                                                    .calculateApi(
                                                        context: context,
                                                        uid: appController
                                                            .globalUserId.value,
                                                        mid: mid,
                                                        mrole: mroal,
                                                        pickup_lat_lon:
                                                            "${appController.pickupLat.value},${appController.pickupLng.value}",
                                                        drop_lat_lon:
                                                            "${appController.dropLat.value},${appController.dropLng.value}",
                                                        drop_lat_lon_list:
                                                            onlypass)
                                                    .then(
                                                  (value) {
                                                    dropprice = 0;
                                                    minimumfare = 0;
                                                    maximumfare = 0;

                                                    if (value["Result"] ==
                                                        true) {
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

                                                      tot_hour =
                                                          value["tot_hour"]
                                                              .toString();
                                                      tot_time =
                                                          value["tot_minute"]
                                                              .toString();
                                                      vehicle_id =
                                                          value["vehicle"]["id"]
                                                              .toString();
                                                      vihicalrice =
                                                          double.parse(value[
                                                                  "drop_price"]
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
                                                          value["vehicle"]
                                                                  ["name"]
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
                                                constraints: BoxConstraints(
                                                  minWidth: 80,
                                                  maxWidth: 120,
                                                  minHeight: 80,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: select1 == index
                                                      ? theamcolore
                                                          .withOpacity(0.08)
                                                      : notifier
                                                          .containercolore,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize
                                                        .min, // Important: prevents overflow
                                                    crossAxisAlignment:
                                                        select1 == index
                                                            ? CrossAxisAlignment
                                                                .start
                                                            : CrossAxisAlignment
                                                                .center,
                                                    children: [
                                                      Flexible(
                                                        // Wrap the Row with Flexible
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize
                                                              .min, // Important: prevents overflow
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Flexible(
                                                              // Make image flexible
                                                              child: SizedBox(
                                                                height:
                                                                    30, // Reduced from 40
                                                                width:
                                                                    30, // Reduced from 40
                                                                child: Image(
                                                                  image: NetworkImage(
                                                                      "${Config.imageurl}${homeApiController.homeapimodel!.categoryList![index].image}"),
                                                                  height: 30,
                                                                  fit: BoxFit
                                                                      .contain, // Ensure proper scaling
                                                                ),
                                                              ),
                                                            ),
                                                            if (select1 ==
                                                                index) ...[
                                                              const SizedBox(
                                                                  width: 5),
                                                              Flexible(
                                                                // Make info icon flexible
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    // Vehicle info logic here
                                                                  },
                                                                  child: Image(
                                                                    image: const AssetImage(
                                                                        "assets/info-circle.png"),
                                                                    height:
                                                                        16, // Reduced from 20
                                                                    color:
                                                                        theamcolore,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height:
                                                              8), // Reduced spacing
                                                      Flexible(
                                                        // Make text flexible
                                                        child: Text(
                                                          "${homeApiController.homeapimodel!.categoryList![index].name}",
                                                          style: TextStyle(
                                                            color: notifier
                                                                .textColor,
                                                            fontSize:
                                                                12, // Smaller font
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ));
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
                                        title: appController
                                                .pickupController.text.isEmpty
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
                                                  appController
                                                      .pickupController.text,
                                                  style: TextStyle(
                                                      color:
                                                          notifier.textColor),
                                                )),
                                      ),
                                    ),
                                  ),
                                ),
                                textfieldlist.isNotEmpty
                                    ? const SizedBox(height: 0)
                                    : const SizedBox(height: 10),
                                textfieldlist.isNotEmpty
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
                                                      child: appController
                                                              .dropController
                                                              .text
                                                              .isEmpty
                                                          ? Text(
                                                              "To",
                                                              style: TextStyle(
                                                                  color: notifier
                                                                      .textColor,
                                                                  fontSize: 16),
                                                            )
                                                          : Text(
                                                              appController
                                                                  .dropController
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
                                (homeApiController.homeapimodel?.categoryList
                                                ?.isNotEmpty ==
                                            true &&
                                        select1 <
                                            homeApiController.homeapimodel!
                                                .categoryList!.length &&
                                        homeApiController
                                                .homeapimodel!
                                                .categoryList![select1]
                                                .bidding ==
                                            "1")
                                    ? const SizedBox(height: 10)
                                    : const SizedBox(),
                                (homeApiController.homeapimodel?.categoryList
                                                ?.isNotEmpty ==
                                            true &&
                                        select1 <
                                            homeApiController.homeapimodel!
                                                .categoryList!.length &&
                                        homeApiController
                                                .homeapimodel!
                                                .categoryList![select1]
                                                .bidding ==
                                            "1")
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
                                                          "${currencyy ?? globalcurrency} ${dropprice ?? ""}",
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
                                appController.pickupController.text.isEmpty ||
                                        appController
                                            .dropController.text.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: CommonButton(
                                            containcolore:
                                                theamcolore.withOpacity(0.2),
                                            onPressed1: () {},
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
                                                    Buttonpresebottomshhet();
                                                  }
                                                : () {
                                                    print("222222222222");

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => HomeScreen(
                                                              latpic: appController
                                                                  .pickupLat
                                                                  .value,
                                                              longpic:
                                                                  appController
                                                                      .pickupLng
                                                                      .value,
                                                              latdrop:
                                                                  appController
                                                                      .dropLat
                                                                      .value,
                                                              longdrop:
                                                                  appController
                                                                      .dropLng
                                                                      .value,
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
                    ? Center(
                        child: CircularProgressIndicator(
                        color: theamcolore,
                      ))
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
                          case 0: // Home

                            // ✅ FIX: Use AppController reset instead of individual globals

                            appController.resetAllRideData();

                            Get.offAll(const MapScreen(selectvihical: false));

                            break;

                          case 1: // My Ride

                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const MyRideScreen(),
                            ));

                            break;

                          case 2: // Wallet

                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const TopUpScreen(),
                            ));

                            break;

                          case 3: // Profile

                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ));

                            break;

                          case 4: // Language

                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const LanguageScreen(),
                            ));

                            break;

                          case 5: // Refer and earn

                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ReferAndEarn(),
                            ));

                            break;

                          case 6: // FAQ

                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const FaqScreen(),
                            ));

                            break;

                          case 7: // Notifications

                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ));

                            break;

                          case 8: // Dark Mode - no action needed, handled by switch

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
                                const SizedBox(width: 15),
                                Text(
                                  "${drowertitle[index]}".tr,
                                  style: TextStyle(
                                      fontSize: 16, color: notifier.textColor),
                                ),
                                const Spacer(),
                                index == 8
                                    ? SizedBox(
                                        height: 20,
                                        width: 30,
                                        child: Transform.scale(
                                          scale: 0.8,
                                          child: CupertinoSwitch(
                                            value: notifier.isDark,
                                            activeColor: theamcolore,
                                            onChanged: (bool value) async {
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();

                                              await prefs.setBool(
                                                  "isDark", value);

                                              if (mounted) {
                                                setState(() {
                                                  notifier.isAvailable(value);

                                                  darkMode = value;
                                                });
                                              }

                                              Get.offAll(const MapScreen(
                                                  selectvihical: false));
                                            },
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                const SizedBox(width: 10),
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
                //     Get.offAll(const OnboardingScreen());
                //   },context: context,txt1: "Log Out"),
                // ),
                InkWell(
                  onTap: () {
                    loginSharedPreferencesSet(true);
                    Get.offAll(const OnboardingScreen());
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
                                      child: Text('Cancel'.tr,
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
                                        loginSharedPreferencesSet(true),
                                        deleteAccount
                                            .deleteaccountApi(
                                                id: appController.globalUserId
                                                    .value) // ✅ FIX: Use AppController

                                            .then((value) {
                                          Get.offAll(OnboardingScreen());
                                        }),
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

// STEP 7: Replace your Buttonpresebottomshhet() method with this COMPLETE function

  Buttonpresebottomshhet() {
    // ✅ FIX: Use AppController instead of global controllers
    if (appController.pickupController.text.isEmpty ||
        appController.dropController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Select Pickup and Drop",
      );
    } else if (amountresponse == "false") {
      Fluttertoast.showToast(
        msg: "Address is not in the zone!",
      );
    } else if (dropprice == 0) {
      Fluttertoast.showToast(
        msg: responsemessage,
      );
    } else {
      toast = 0;
      amountcontroller.text = dropprice.toString();

      int maxprice = maximumfare.toInt();
      int minprice = minimumfare.toInt();
      if (kDebugMode) {
        print("**maxprice**:-- $maxprice");
        print("**minprice**:-- $minprice");
      }

      Get.bottomSheet(
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        StatefulBuilder(
          builder: (context, setState) {
            return Container(
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
                        // ✅ FIX: Use local animation state instead of global isanimation
                        _isAnimationRunning == false
                            ? const SizedBox()
                            : lottie.Lottie.asset("assets/lottie/loading.json",
                                height: 30),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Spacer(),
                            SizedBox(width: 40),
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
                                  // ✅ FIX: Use local animation controller
                                  if (_animationController != null &&
                                      _animationController!.isAnimating) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Your current request is in progress. You can either wait for it to complete or cancel to perform this action.",
                                    );
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
                        const SizedBox(height: 10),

                        // Price adjustment controls...
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  // ✅ FIX: Use local animation controller
                                  if (_animationController != null &&
                                      _animationController!.isAnimating) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Your current request is in progress. You can either wait for it to complete or cancel to perform this action.",
                                    );
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

                                      couponname = "";
                                      couponId = "";
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
                                  keyboardType: TextInputType.number,
                                  controller: amountcontroller,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 30, color: notifier.textColor),
                                  // ✅ FIX: Use local animation controller
                                  readOnly: _animationController != null &&
                                          _animationController!.isAnimating
                                      ? true
                                      : false,
                                  onTap: () {
                                    // ✅ FIX: Use local animation controller
                                    _animationController != null &&
                                            _animationController!.isAnimating
                                        ? Fluttertoast.showToast(
                                            msg:
                                                "Your current request is in progress. You can either wait for it to complete or cancel to perform this action.",
                                          )
                                        : "";
                                  },
                                  onSubmitted: (value) {
                                    setState(() {
                                      if (int.parse(amountcontroller.text) >
                                          maxprice) {
                                        amountcontroller.clear();
                                        toast = 1;
                                      } else if (int.parse(
                                              amountcontroller.text) <
                                          minprice) {
                                        amountcontroller.clear();
                                        toast = 2;
                                      } else {
                                        toast = 0;
                                        dropprice =
                                            int.parse(amountcontroller.text)
                                                as double;
                                        mainamount = amountcontroller.text;
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
                                  // ✅ FIX: Use local animation controller
                                  if (_animationController != null &&
                                      _animationController!.isAnimating) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Your current request is in progress. You can either wait for it to complete or cancel to perform this action.",
                                    );
                                  } else {
                                    if (double.parse(dropprice.toString()) <
                                        maxprice) {
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
                                    image: AssetImage("assets/plus.png"),
                                    color: notifier.textColor,
                                    height: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Error messages
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
                        const SizedBox(height: 10),

                        // Auto booking switch
                        ListTile(
                          contentPadding: EdgeInsets.zero,
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
                                value: light,
                                activeColor: theamcolore,
                                // ✅ FIX: Use local animation controller
                                onChanged: _animationController != null &&
                                        _animationController!.isAnimating
                                    ? (bool value) {
                                        Fluttertoast.showToast(
                                          msg:
                                              "Your current request is in progress. You can either wait for it to complete or cancel to perform this action.",
                                        );
                                      }
                                    : (bool value) {
                                        setState(() {
                                          light = value;
                                          offerpluse = true;
                                          biddautostatus = value.toString();
                                        });
                                      },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // Bottom section with payment/coupon and buttons
                  Container(
                    decoration: BoxDecoration(
                        color: notifier.containercolore,
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
                          // Payment and coupon row here...

                          // ✅ FIX: Main booking button
                          _isAnimationRunning == false
                              ? CommonButton(
                                  containcolore: theamcolore,
                                  onPressed1: () {
                                    setState(() {
                                      if (double.parse(amountcontroller.text) >
                                          maxprice) {
                                        amountcontroller.clear();
                                        toast = 1;
                                      } else if (double.parse(
                                              amountcontroller.text) <
                                          minprice) {
                                        amountcontroller.clear();
                                        toast = 2;
                                      } else {
                                        _isAnimationRunning = true;
                                        loadertimer = true;
                                        offerpluse = false;
                                        requesttime();
                                        orderfunction();
                                      }
                                    });
                                  },
                                  context: context,
                                  txt1:
                                      "Book for ${currencyy ?? globalcurrency}${amountcontroller.text}")
                              : AnimatedBuilder(
                                  // ✅ FIX: Use local animation controller
                                  animation: _animationController!,
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
                                            if (double.parse(
                                                    amountcontroller.text) >
                                                maxprice) {
                                              amountcontroller.clear();
                                              toast = 1;
                                            } else if (double.parse(
                                                    amountcontroller.text) <
                                                minprice) {
                                              amountcontroller.clear();
                                              toast = 2;
                                            } else {
                                              if (offerpluse == true) {
                                                // ✅ FIX: Use local animation controller
                                                if (_animationController !=
                                                        null &&
                                                    _animationController!
                                                        .isAnimating) {
                                                  _animationController!
                                                      .dispose();
                                                }
                                                requesttime();
                                                orderfunction();
                                                offerpluse = false;
                                              }
                                            }

                                            if (double.parse(
                                                    amountcontroller.text) >
                                                maxprice) {
                                              amountcontroller.clear();
                                              amountcontroller.text =
                                                  maxprice.toString();
                                              toast = 1;
                                            } else if (double.parse(
                                                    amountcontroller.text) <
                                                minprice) {
                                              amountcontroller.clear();
                                              amountcontroller.text =
                                                  minprice.toString();
                                              toast = 2;
                                            } else {
                                              toast = 0;
                                              dropprice = double.parse(
                                                  amountcontroller.text);
                                              mainamount =
                                                  amountcontroller.text;
                                            }
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
                                                // ✅ FIX: Use local animation controller
                                                value: 1.0 -
                                                    _animationController!.value,
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
                          const SizedBox(height: 10),

                          // Cancel button
                          StatefulBuilder(
                            builder: (context, setState) {
                              return cancelloader
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: theamcolore,
                                      ),
                                    )
                                  : CommonOutLineButton(
                                      bordercolore: theamcolore,
                                      onPressed1: () {
                                        setState(() {
                                          _isAnimationRunning = false;
                                          cancelloader = true;

                                          removeRequest
                                              .removeApi(
                                                  uid: appController
                                                      .globalUserId.value)
                                              .then((value) {
                                            appController.socketService
                                                .emit('AcceRemoveOther', {
                                              'requestid':
                                                  appController.requestId.value,
                                              'driverid': calculateController
                                                  .calCulateModel!.driverId!,
                                            });

                                            Get.back();
                                            cancelloader = false;
                                          });

                                          // ✅ FIX: Use local animation controller
                                          if (_animationController != null &&
                                              _animationController!
                                                  .isAnimating) {
                                            if (kDebugMode) {
                                              print(
                                                  "🔄 Stopping controller and resetting data");
                                            }
                                            _animationController!.stop();
                                            _animationController!.reset();
                                            appController.resetAllRideData();
                                          }
                                        });
                                      },
                                      context: context,
                                      txt1: "Cancel Request".tr);
                            },
                          ),
                          const SizedBox(height: 10),
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
    }
  }

// STEP 8: Replace your orderfunction() method with this COMPLETE function

  orderfunction() {
    if (kDebugMode) {
      print("DRIVER ID:- ${calculateController.calCulateModel!.driverId!}");
      print("PICK LOCATION:- ${appController.pickupController.text}");
      print("DROP LOCATION:- ${appController.dropController.text}");
    }

    // ✅ FIX: Use AppController socket service
    appController.socketService.connect();

    // ✅ FIX: Use AppController for wallet API
    homeWalletApiController
        .homwwalleteApi(uid: appController.globalUserId.value, context: context)
        .then((value) {
      if (kDebugMode) {
        print("{{{{{[wallet}}}}}]:-- ${value["wallet_amount"]}");
      }
      walleteamount = double.parse(value["wallet_amount"]);
      if (kDebugMode) {
        print("[[[[[[[[[[[[[walleteamount]]]]]]]]]]]]]:-- ($walleteamount)");
      }
    });

    if (kDebugMode) {
      print(
          "111111111 amountcontroller.text 111111111 ${amountcontroller.text}");
    }

    percentValue.clear();
    percentValue = [];
    for (int i = 0; i < 4; i++) {
      percentValue.add(0);
    }
    setState(() {
      currentStoryIndex = 0;
    });

    priceyourfare = double.parse(amountcontroller.text);
    if (kDebugMode) {
      print("***price***::-(${priceyourfare})");
    }

    // ✅ FIX: Use AppController for all location and user data
    addVihicalCalculateController.addvihicalcalculateApi(
      pickupadd: {
        "title":
            "${appController.pickupTitle.value.isEmpty ? addresspickup : appController.pickupTitle.value}",
        "subt": appController.pickupSubtitle.value
      },
      dropadd: {
        "title": appController.dropTitle.value,
        "subt": appController.dropSubtitle.value
      },
      droplistadd: appController.dropTitleList,
      context: context,
      uid: appController.globalUserId.value,
      tot_km: "$totalkm",
      vehicle_id: vehicle_id,
      tot_minute: tot_time,
      tot_hour: tot_hour,
      m_role: mroal,
      coupon_id: couponId,
      payment_id: "$payment",
      driverid: calculateController.calCulateModel!.driverId!,
      price: amountcontroller.text,
      pickup:
          "${appController.pickupLat.value},${appController.pickupLng.value}",
      drop: "${appController.dropLat.value},${appController.dropLng.value}",
      droplist: onlypass,
      bidd_auto_status: biddautostatus,
    ).then((value) {
      if (kDebugMode) {
        print("+++++Request ID: ${value["id"]}");
      }
      setState(() {});

      // ✅ FIX: Use AppController for request ID
      appController.requestId.value = value["id"].toString();
      socateempt();
    });

    // ✅ FIX: Use AppController for calculate API
    calculateController
        .calculateApi(
            context: context,
            uid: appController.globalUserId.value,
            mid: mid,
            mrole: mroal,
            pickup_lat_lon:
                "${appController.pickupLat.value},${appController.pickupLng.value}",
            drop_lat_lon:
                "${appController.dropLat.value},${appController.dropLng.value}",
            drop_lat_lon_list: onlypass)
        .then((value) {
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
        if (kDebugMode) {
          print("Calculate API returned false result");
        }
      }

      if (kDebugMode) {
        print("********** dropprice **********:----- $dropprice");
        print("********** minimumfare **********:----- $minimumfare");
        print("********** maximumfare **********:----- $maximumfare");
      }
    });
  }
}
