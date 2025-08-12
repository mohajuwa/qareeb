// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
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
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/controllers/app_controller.dart';
import 'package:qareeb/services/socket_service.dart';
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

  Map<MarkerId, Marker> markers = {};

  bool _isInitializing = true;

  String _initializationStatus = "Loading...";

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
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  // You already have these (keep them):
  late GoogleMapController mapController11;
  Map<MarkerId, Marker> markers11 = {};
  Map<PolylineId, Polyline> polylines11 = {};
  List<LatLng> polylineCoordinates11 = [];
  PolylinePoints polylinePoints11 = PolylinePoints();
  String themeForMap = "";

  mapThemeStyle({required BuildContext context}) {
    final stylePath = darkMode == true
        ? "assets/map_styles/dark_style.json"
        : "assets/map_styles/light_style.json";

    DefaultAssetBundle.of(context).loadString(stylePath).then((value) {
      setState(() {
        themeForMap = value;
      });
    });
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

  Future<void> socketConnect() async {
    try {
      final socketService = SocketService.instance;

      if (!socketService.isConnected) {
        if (kDebugMode) {
          print("Socket not connected, connecting...");
        }
        await socketService.connect();
      } else {
        if (kDebugMode) {
          print("Socket already connected");
        }
      }

      // Set up event listeners
      socketService.on('home', (data) {
        if (kDebugMode) {
          print("Received 'home' event: $data");
        }
        // Handle home event
      });

      socketService.on('acceptvehrequest', (data) {
        if (kDebugMode) {
          print("Received 'acceptvehrequest' event: $data");
        }
        // Handle vehicle request acceptance
      });
    } catch (e) {
      if (kDebugMode) {
        print("Socket connection error: $e");
      }
      // Don't throw - allow app to continue without socket
    }
  }

  void _debugState() {
    if (kDebugMode) {
      print("🔍 DEBUG STATE:");

      print("   _isInitializing: $_isInitializing");

      print("   _initializationStatus: $_initializationStatus");

      print("   lathome: $lathome");

      print("  userid: $userid");
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

  Timer? _vehicleRefreshTimer;

  void startVehicleRefreshTimer() {
    _vehicleRefreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted && mid.isNotEmpty && lathome != null && longhome != null) {
        loadVehiclesForCategory(mid);
      }
    });
  }

  void stopVehicleRefreshTimer() {
    _vehicleRefreshTimer?.cancel();

    _vehicleRefreshTimer = null;
  }

// Add this to your dispose method:
  @override
  void dispose() {
    if (kDebugMode) {
      print("🗑️ MapScreen disposing...");
    }

    _animationController?.dispose();

    _animationController = null;

    stopVehicleRefreshTimer();

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

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.green,
      end: Colors.red,
    ).animate(_animationController!);

    // ✅ CRITICAL: Load user data first, then initialize app
    _initializeAppWithUserData();
  }

  Future<void> _initializeAppWithUserData() async {
    if (kDebugMode) {
      print("🚀 Starting MapScreen initialization with user data...");
    }

    try {
      setState(() {
        _isInitializing = true;

        _initializationStatus = "Loading user data...";
      });

      // Step 1: Load user data from SharedPreferences first
      mapThemeStyle(context: context);
      await loadUserData();

      // Step 2: Get current location if needed

      setState(() {
        _initializationStatus = "Getting location...";
      });

      if (lathome == null || longhome == null) {
        await _getCurrentLocation();
      }

      // Step 3: Load home API data with current location and user ID

      setState(() {
        _initializationStatus = "Loading vehicles...";
      });

      if (userid != null) {
        await homeApiController.homeApi(
          uid: userid.toString(),
          lat: lathome.toString(),
          lon: longhome.toString(),
        );

        // Step 4: Set default vehicle category

        if (homeApiController.homeapimodel?.categoryList?.isNotEmpty == true) {
          final firstCategory =
              homeApiController.homeapimodel!.categoryList![0];

          setState(() {
            select1 = 0;

            vehicle_id = firstCategory.id.toString();

            vihicalname = firstCategory.name.toString();

            vihicalimage = firstCategory.image.toString();

            mid = firstCategory.id.toString();

            mroal = firstCategory.role.toString();
          });

          // Step 5: Load vehicles for default category

          await loadVehiclesForCategory(mid);
        }
      }

      // Initialization complete

      if (mounted) {
        setState(() {
          _isInitializing = false;

          _initializationStatus = "Ready";
        });
      }

      if (kDebugMode) {
        print("✅ MapScreen initialization completed successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error in initializeAppWithUserData: $e");
      }

      if (mounted) {
        setState(() {
          _isInitializing = false;

          _initializationStatus = "Error: $e";
        });
      }
    }
  }

  Future<void> _initializeApp() async {
    if (kDebugMode) {
      print("🚀 Starting MapScreen initialization...");
    }

    try {
      setState(() {
        _isInitializing = true;

        _initializationStatus = "Loading location...";
      });

      // Step 1: Get current location if needed

      if (lathome == null || longhome == null) {
        await _getCurrentLocation();
      }

      setState(() {
        _initializationStatus = "Loading vehicles...";
      });

      // Step 2: Load home API data with current location

      await homeApiController.homeApi(
        uid: userid.toString(),
        lat: lathome.toString(),
        lon: longhome.toString(),
      );

      // Step 3: Set default vehicle category (CRITICAL FIX)

      if (homeApiController.homeapimodel?.categoryList?.isNotEmpty == true) {
        final firstCategory = homeApiController.homeapimodel!.categoryList![0];

        setState(() {
          select1 = 0;

          vehicle_id = firstCategory.id.toString();

          vihicalname = firstCategory.name.toString();

          vihicalimage = firstCategory.image.toString();

          mid = firstCategory.id.toString();

          mroal = firstCategory.role.toString();
        });

        // Step 4: Load vehicles for default category

        await loadVehiclesForCategory(mid);
      }

      // Initialization complete

      if (mounted) {
        setState(() {
          _isInitializing = false;

          _initializationStatus = "Ready";
        });
      }

      if (kDebugMode) {
        print("✅ MapScreen initialization completed successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error in initializeApp: $e");
      }

      if (mounted) {
        setState(() {
          _isInitializing = false;

          _initializationStatus = "Error: $e";
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (kDebugMode) {
      print("🌍 Getting current location...");
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        lathome = position.latitude;

        longhome = position.longitude;
      });

      await getCurrentLatAndLong(position.latitude, position.longitude);

      if (kDebugMode) {
        print("✅ Current location: $lathome, $longhome");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error getting location: $e");
      }

      // Use default location if unable to get current location

      setState(() {
        lathome = 15.3694; // Default to Sana'a, Yemen

        longhome = 44.1910;
      });

      await getCurrentLatAndLong(lathome!, longhome!);
    }
  }

  Future getDirections(
      {required PointLatLng lat1,
      required PointLatLng lat2,
      required List<PointLatLng> dropOffPoints}) async {
    if (kDebugMode) {
      print(
          "🗺️ Getting directions from ${lat1.latitude},${lat1.longitude} to ${lat2.latitude},${lat2.longitude}");
    }

    try {
      polylines.clear(); // ✅ Use polylines NOT polylines11

      List<LatLng> polylineCoordinates = [];

      List<PointLatLng> allPoints = [lat1, lat2, ...dropOffPoints];

      for (int i = 0; i < allPoints.length - 1; i++) {
        PointLatLng point1 = allPoints[i];

        PointLatLng point2 = allPoints[i + 1];

        // ✅ Use polylinePoints NOT polylinePoints11

        PolylineResult result =
            await polylinePoints11.getRouteBetweenCoordinates(
          Config.mapkey,
          point1,
          point2,
          travelMode: TravelMode.driving,
        );

        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }
      }

      if (polylineCoordinates.isNotEmpty) {
        addPolyLine(polylineCoordinates);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error getting directions: $e");
      }
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");

    Polyline polyline = Polyline(
      polylineId: id,
      color: theamcolore,
      points: polylineCoordinates,
      width: 3,
    );

    polylines[id] = polyline; // Use base polylines

    setState(() {});
  }

  Future<void> loadVehiclesForCategory(String categoryId) async {
    if (kDebugMode) {
      print(
          "🔄 Loading vehicles for category: $categoryId at location: $lathome, $longhome");
    }

    try {
      await homeMapController.homemapApi(
        mid: categoryId,
        lat: lathome.toString(),
        lon: longhome.toString(),
      );

      if (kDebugMode) {
        print("📡 API Response received for category $categoryId");

        print(
            "📊 Vehicles found: ${homeMapController.homeMapApiModel?.list?.length ?? 0}");
      }

      if (homeMapController.homeMapApiModel?.list?.isNotEmpty == true) {
        if (mounted) {
          setState(() {
            // Clear old vehicle data

            vihicallocations.clear();

            _iconPaths.clear();

            // Populate new vehicle data

            for (int i = 0;
                i < homeMapController.homeMapApiModel!.list!.length;
                i++) {
              final vehicle = homeMapController.homeMapApiModel!.list![i];

              vihicallocations.add(LatLng(
                  double.parse(vehicle.latitude.toString()),
                  double.parse(vehicle.longitude.toString())));

              _iconPaths.add("${Config.imageurl}${vehicle.image}");

              if (kDebugMode) {
                print(
                    "🚗 Vehicle $i: Lat ${vehicle.latitude}, Lng ${vehicle.longitude}");
              }
            }

            if (kDebugMode) {
              print(
                  "🎯 About to call _addMarkers with ${vihicallocations.length} vehicles");
            }

            // Add markers to map

            _addMarkers();
          });
        }

        if (kDebugMode) {
          print(
              "✅ Successfully loaded ${homeMapController.homeMapApiModel!.list!.length} vehicles for category $categoryId");
        }
      } else {
        if (kDebugMode) {
          print("⚠️ No vehicles found for category: $categoryId");
        }

        // Clear existing vehicle markers if no vehicles found

        if (mounted) {
          setState(() {
            vihicallocations.clear();

            _iconPaths.clear();

            markers.removeWhere((key, value) =>
                key.value.startsWith('vehicle_') ||
                key.value.contains('driver'));
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error loading vehicles for category $categoryId: $e");
      }
    }
  }

  // ✅ ADD: Load initial vehicles when app starts
  Future<void> loadInitialVehicles() async {
    if (kDebugMode) {
      print("🚗 Loading initial vehicles...");
    }

    try {
      // Load home API data first
      await homeApiController.homeApi(
        uid: userid.toString(),
        lat: lathome.toString(),
        lon: longhome.toString(),
      );

      if (homeApiController.homeapimodel?.categoryList?.isNotEmpty == true) {
        // Set default vehicle category (first one)
        final firstCategory = homeApiController.homeapimodel!.categoryList![0];
        select1 = 0;
        vehicle_id = firstCategory.id.toString();
        vihicalname = firstCategory.name.toString();
        vihicalimage = firstCategory.image.toString();
        mid = firstCategory.id.toString();
        mroal = firstCategory.role.toString();

        // Load vehicles for the selected category
        await loadVehiclesForCategory(mid);
      }

      if (kDebugMode) {
        print("✅ Initial vehicles loaded successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error loading initial vehicles: $e");
      }
    }
  }

  void displayVehicleCount() {
    if (kDebugMode && homeMapController.homeMapApiModel?.list != null) {
      print(
          "📍 Displaying ${homeMapController.homeMapApiModel!.list!.length} vehicles on map");

      print("🚗 Vehicle category: $vihicalname");

      print("📡 Vehicles online and available");
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

      // ✅ FIX: Safer JSON parsing
      try {
        decodeUid = jsonDecode(uid);
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing user JSON: $e");
          print("Raw uid data: $uid");
        }
        throw Exception("Invalid user data format");
      }

      // ✅ FIX: Safer currency parsing
      if (currency != null && currency.isNotEmpty) {
        try {
          currencyy = jsonDecode(currency);
          globalcurrency = currencyy['symbol']?.toString() ?? "YER";
        } catch (e) {
          if (kDebugMode) {
            print("Error parsing currency JSON: $e");
          }
          currencyy = {};
          globalcurrency = "YER";
        }
      } else {
        currencyy = {};
        globalcurrency = "YER";
      }

      // ✅ FIX: Safer user ID extraction
      if (decodeUid != null && decodeUid is Map) {
        userid = decodeUid['id'];
        username = decodeUid["name"]?.toString() ?? "User";

        // ✅ FIX: Ensure userid is properly typed
        if (userid != null) {
          userid = userid is String ? int.tryParse(userid) ?? userid : userid;
        }
      } else {
        throw Exception("Invalid user data structure");
      }

      if (kDebugMode) {
        print("✅ User data loaded: userid=$userid, username=$username");
        print("   Currency: $globalcurrency");
        print("   User data type: ${decodeUid.runtimeType}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading user data: $e");
      }
      throw e;
    }
  }

  Future<void> makeInitialAPICalls() async {
    try {
      if (userid == null) {
        throw Exception("User ID not available");
      }

      if (kDebugMode) {
        print("Making initial API calls with userid: $userid");
      }

      // Make API calls concurrently for better performance

      await Future.wait([
        _makePaymentAPICall(),
        _makePageListAPICall(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print("Error in makeInitialAPICalls: $e");
      }

      // Don't throw - allow app to continue with partial data
    }
  }

  Future<void> _makePageListAPICall() async {
    try {
      await pagelistcontroller.pagelistttApi(context);

      if (kDebugMode) {
        print("✅ PageList API call completed");
      }
    } catch (e) {
      if (kDebugMode) {
        print("PageList API error: $e");
      }
    }
  }

  // ✅ ADD: Method to show loading overlay

  Future<void> _makePaymentAPICall() async {
    try {
      final paymentController = Get.find<PaymentGetApiController>();

      await paymentController.paymentlistApi(context);

      if (kDebugMode) {
        print("✅ Payment API call completed");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Payment API error: $e");
      }
    }
  }

  Future<void> setupMapMarkers() async {
    if (kDebugMode) {
      print("🗺️ Setting up map markers...");
    }

    try {
      // ✅ DON'T clear all markers - this removes vehicles!

      // Only clear pickup/drop markers if they exist

      setState(() {
        markers.removeWhere(
            (key, value) => key.value == "pickup" || key.value == "drop");
      });

      // Add user location marker

      if (lathome != null && longhome != null) {
        final userIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(48, 48)),
          'assets/your_location_icon.png',
        ).catchError((_) =>
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));

        setState(() {
          markers[const MarkerId("my_1")] = Marker(
            markerId: const MarkerId("my_1"),
            position: LatLng(lathome!, longhome!),
            icon: userIcon,
          );
        });
      }

      // Add pickup marker if available

      if (latitudepick != 0.0 && longitudepick != 0.0) {
        setState(() {
          markers[const MarkerId("pickup")] = Marker(
            markerId: const MarkerId("pickup"),
            position: LatLng(latitudepick, longitudepick),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: "Pickup Location"),
          );
        });
      }

      // Add drop marker if available

      if (latitudedrop != 0.0 && longitudedrop != 0.0) {
        setState(() {
          markers[const MarkerId("drop")] = Marker(
            markerId: const MarkerId("drop"),
            position: LatLng(latitudedrop, longitudedrop),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: "Drop Location"),
          );
        });

        // ✅ CRITICAL: Draw route when both points exist

        if (latitudepick != 0.0 && longitudepick != 0.0) {
          // Clear existing route first

          setState(() {
            polylines11.clear();
          });

          await getDirections11(
              lat1: PointLatLng(latitudepick, longitudepick),
              lat2: PointLatLng(latitudedrop, longitudedrop),
              dropOffPoints: _dropOffPoints);

          // Calculate price for selected route and vehicle

          await _calculateRoutePrice();
        }
      }

      // ✅ KEEP vehicles visible

      if (mid.isNotEmpty && lathome != null && longhome != null) {
        await loadVehiclesForCategory(mid);
      }

      if (kDebugMode) {
        print("✅ Map markers setup completed");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error setting up map markers: $e");
      }
    }
  }
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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
    if (kDebugMode) {
      print("🔍 _addMarkers called");

      print("   Vehicle locations: ${vihicallocations.length}");

      print("   Icon paths: ${_iconPaths.length}");

      print("   Selected category: $mid");
    }

    if (homeMapController.homeMapApiModel?.list == null ||
        homeMapController.homeMapApiModel!.list!.isEmpty) {
      if (kDebugMode) {
        print("❌ No vehicle data available for markers");
      }

      // Clear only vehicle markers, keep pickup/drop markers

      setState(() {
        markers.removeWhere((key, value) =>
            key.value.startsWith('vehicle_') || key.value.contains('driver'));
      });

      return;
    }

    final vehicleList = homeMapController.homeMapApiModel!.list!;

    // CRITICAL FIX: Clear only vehicle markers, preserve pickup/drop markers

    setState(() {
      markers.removeWhere((key, value) =>
          key.value.startsWith('vehicle_') ||
          key.value.contains('driver') ||
          (key.value != "my_1" && // Keep user location

              key.value != "pickup" && // Keep pickup marker

              key.value != "drop")); // Keep drop marker
    });

    // Helper function to load icons safely

    Future<BitmapDescriptor> loadIcon(String url,
        {int targetWidth = 30, int targetHeight = 50}) async {
      try {
        if (url.isEmpty || url.contains("undefined") || url.contains("null")) {
          if (kDebugMode) {
            print("⚠️ Invalid icon URL: $url - using default");
          }

          return BitmapDescriptor.defaultMarker;
        }

        final http.Response response =
            await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;

          final ui.Codec codec = await ui.instantiateImageCodec(bytes,
              targetWidth: targetWidth, targetHeight: targetHeight);

          final ui.FrameInfo frameInfo = await codec.getNextFrame();

          final ByteData? byteData =
              await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

          return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
        } else {
          if (kDebugMode) {
            print(
                "⚠️ Failed to load image from $url - HTTP ${response.statusCode}");
          }

          return BitmapDescriptor.defaultMarker;
        }
      } catch (e) {
        if (kDebugMode) {
          print("❌ Error loading icon from $url: $e");
        }

        return BitmapDescriptor.defaultMarker;
      }
    }

    try {
      // Load all icons with error handling

      final List<BitmapDescriptor> icons = await Future.wait(
        _iconPaths.map((path) => loadIcon(path)),
      );

      if (kDebugMode) {
        print("✅ Loaded ${icons.length} icons successfully");
      }

      // Check if widget is still mounted before setState

      if (!mounted) return;

      setState(() {
        // Safe iteration using minimum count

        final itemCount = math.min(vihicallocations.length,
            math.min(icons.length, vehicleList.length));

        if (kDebugMode) {
          print("🎯 Adding $itemCount vehicle markers for category: $mid");
        }

        for (int i = 0; i < itemCount; i++) {
          try {
            final vehicleId =
                "vehicle_${vehicleList[i].id}_$mid"; // Include category in ID

            if (kDebugMode) {
              print("   Adding marker $i - Vehicle ID: $vehicleId");
            }

            MarkerId markerId = MarkerId(vehicleId);

            Marker marker = Marker(
              markerId: markerId,
              icon: icons[i],
              position: vihicallocations[i],
              onTap: () {
                if (kDebugMode) {
                  print("🚗 Tapped vehicle: $vehicleId");
                }

                showVehicleInfo(vehicleList[i]);
              },
            );

            markers[markerId] = marker;
          } catch (e) {
            if (kDebugMode) {
              print("❌ Error adding marker $i: $e");
            }

            // Continue with next marker instead of failing completely
          }
        }

        if (kDebugMode) {
          print("✅ Successfully added ${itemCount} vehicle markers to map");

          print("📍 Total markers on map: ${markers.length}");
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error in _addMarkers: $e");
      }
    }
  }

  // ✅ COMPLETE _addMarkers2() METHOD:
  void _addMarkers2() async {
    if (kDebugMode) {
      print("🔍 _addMarkers2 called");
      print(
          "   Vehicle locations bidding: ${vihicallocationsbiddingon.length}");
      print("   Icon paths bidding: ${_iconPathsbiddingon.length}");
    }

    // ✅ SAFETY CHECK: Ensure we have data
    if (homeMapController.homeMapApiModel?.list == null ||
        homeMapController.homeMapApiModel!.list!.isEmpty) {
      if (kDebugMode) {
        print("❌ No vehicle data available for markers2");
      }
      return;
    }

    final vehicleList = homeMapController.homeMapApiModel!.list!;

    // ✅ HELPER: Load icons safely
    Future<BitmapDescriptor> loadIcon(String url,
        {int targetWidth = 30, int targetHeight = 50}) async {
      try {
        if (url.isEmpty || url.contains("undefined") || url.contains("null")) {
          if (kDebugMode) {
            print("⚠️ Invalid icon URL: $url - using default");
          }

          return BitmapDescriptor.defaultMarker;
        }

        final http.Response response =
            await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;

          final ui.Codec codec = await ui.instantiateImageCodec(bytes,
              targetWidth: targetWidth, targetHeight: targetHeight);

          final ui.FrameInfo frameInfo = await codec.getNextFrame();

          final ByteData? byteData =
              await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

          return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
        } else {
          if (kDebugMode) {
            print(
                "⚠️ Failed to load image from $url - HTTP ${response.statusCode}");
          }

          return BitmapDescriptor.defaultMarker;
        }
      } catch (e) {
        if (kDebugMode) {
          print("❌ Error loading icon from $url: $e");
        }

        return BitmapDescriptor.defaultMarker;
      }
    }

    try {
      // Load all icons with error handling

      final List<BitmapDescriptor> icons = await Future.wait(
        _iconPaths.map((path) => loadIcon(path)),
      );

      if (kDebugMode) {
        print("✅ Loaded ${icons.length} icons successfully");
      }

      // ✅ CHECK: Widget still mounted before setState

      if (!mounted) return;

      setState(() {
        // ✅ SAFE ITERATION: Use the actual data length, not assumptions

        final itemCount = math.min(vihicallocations.length,
            math.min(icons.length, vehicleList.length));

        if (kDebugMode) {
          print("🎯 Adding $itemCount vehicle markers for category: $mid");
        }

        for (int i = 0; i < itemCount; i++) {
          try {
            final vehicleId =
                "vehicle_${vehicleList[i].id}_$mid"; // Include category in ID

            if (kDebugMode) {
              print("   Adding marker $i - Vehicle ID: $vehicleId");
            }

            MarkerId markerId = MarkerId(vehicleId);

            Marker marker = Marker(
              markerId: markerId,
              icon: icons[i],
              position: vihicallocations[i],
              onTap: () {
                if (kDebugMode) {
                  print("🚗 Tapped vehicle: $vehicleId");
                }

                // Show vehicle info dialog

                showVehicleInfo(vehicleList[i]);
              },
            );

            markers[markerId] = marker;
          } catch (e) {
            if (kDebugMode) {
              print("❌ Error adding marker $i: $e");
            }

            // Continue with next marker instead of failing completely
          }
        }

        if (kDebugMode) {
          print("✅ Successfully added ${itemCount} vehicle markers to map");

          print("📍 Total markers on map: ${markers.length}");
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error in _addMarkers: $e");
      }

      // Don't crash the app, just log the error
    }

    try {
      // Load all icons with error handling
      final List<BitmapDescriptor> icons = await Future.wait(
        _iconPathsbiddingon.map((path) => loadIcon(path)),
      );

      // ✅ CHECK: Widget still mounted
      if (!mounted) return;

      setState(() {
        markers11.clear();

        // Add pickup/drop markers
        if (latitudepick != 0.0 && longitudepick != 0.0) {
          _addMarker11(LatLng(latitudepick, longitudepick), "origin",
              BitmapDescriptor.defaultMarker);
        }

        if (latitudedrop != 0.0 && longitudedrop != 0.0) {
          _addMarker2(LatLng(latitudedrop, longitudedrop), "destination",
              BitmapDescriptor.defaultMarkerWithHue(90));
        }

        // Add drop-off points
        if (_dropOffPoints.isNotEmpty) {
          for (int a = 0; a < _dropOffPoints.length; a++) {
            _addMarker3("destination");
          }
        }

        // Add directions
        if (latitudepick != 0.0 &&
            longitudepick != 0.0 &&
            latitudedrop != 0.0 &&
            longitudedrop != 0.0) {
          getDirections11(
              lat1: PointLatLng(latitudepick, longitudepick),
              lat2: PointLatLng(latitudedrop, longitudedrop),
              dropOffPoints: _dropOffPoints);
        }

        // ✅ SAFE ITERATION: Use minimum length
        final itemCount = math.min(vihicallocationsbiddingon.length,
            math.min(icons.length, vehicleList.length));

        for (int i = 0; i < itemCount; i++) {
          try {
            final vehicleId =
                vehicleList[i].id?.toString() ?? "vehicle_bidding_$i";
            final markerId = MarkerId(vehicleId);
            final marker = Marker(
              markerId: markerId,
              position: vihicallocationsbiddingon[i],
              icon: icons[i], // Safe because of itemCount calculation
            );
            markers11[markerId] = marker;
          } catch (e) {
            if (kDebugMode) {
              print("❌ Error adding bidding marker $i: $e");
            }
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error in _addMarkers2: $e");
      }
    }
  }

  late GoogleMapController mapController1;
  void showVehicleInfo(dynamic vehicle) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Driver Information",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text("Driver ID: ${vehicle.id}"),
              Text("Distance: ${vehicle.distance ?? 'N/A'} km"),
              Text("Rating: ${vehicle.rating ?? 'N/A'} ⭐"),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

      // ✅ CRITICAL: Redraw route after coming back

      if (latitudepick != 0.0 &&
          longitudepick != 0.0 &&
          latitudedrop != 0.0 &&
          longitudedrop != 0.0) {
        await setupMapMarkers(); // This will redraw the route

        if (kDebugMode) {
          print("🔄 Route redrawn after location selection");
        }
      }
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

    // Debug the current state
    _debugState();

    return Scaffold(
      key: _key,
      drawer: draweropen(context),
      body: _isInitializing
          ? _buildLoadingOverlay() // Show loading when initializing
          : _buildMainContent(), // Show main content when ready
    );
  }

  Widget _buildMainContent() {
    if (kDebugMode) {
      print("🎯 _buildMainContent called");
    }

    return GetBuilder<HomeApiController>(
      builder: (homeApiController) {
        if (kDebugMode) {
          print("🏠 HomeApiController state:");
          print("   isLoading: ${homeApiController.isLoading}");
          print(
              "   homeapimodel: ${homeApiController.homeapimodel != null ? 'exists' : 'null'}");
          if (homeApiController.homeapimodel != null) {
            print(
                "   categoryList length: ${homeApiController.homeapimodel!.categoryList?.length ?? 0}");
          }
        }

        // ✅ Check if HomeApiController needs to load data
        if (homeApiController.homeapimodel == null &&
            !homeApiController.isLoading) {
          if (kDebugMode) {
            print(
                "🔄 HomeApiController has no data and not loading - triggering API call");
          }

          // ✅ FORCE load vehicles after map is created

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (lathome != null && longhome != null) {
              if (mid.isEmpty &&
                  homeApiController.homeapimodel?.categoryList?.isNotEmpty ==
                      true) {
                // Set default category if not set

                final firstCategory =
                    homeApiController.homeapimodel!.categoryList![0];

                setState(() {
                  select1 = 0;

                  vehicle_id = firstCategory.id.toString();

                  vihicalname = firstCategory.name.toString();

                  vihicalimage = firstCategory.image.toString();

                  mid = firstCategory.id.toString();

                  mroal = firstCategory.role.toString();
                });
              }

              if (mid.isNotEmpty) {
                loadVehiclesForCategory(mid);
              }
            }
          });
        }

        return homeApiController.isLoading
            ? Container(
                color: notifier.background,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: theamcolore),
                      const SizedBox(height: 20),
                      Text(
                        "Loading vehicles...".tr,
                        style: TextStyle(color: notifier.textColor),
                      ),
                      // Debug info - only show in debug mode
                      if (kDebugMode) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "HOME API DEBUG:",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Loading: ${homeApiController.isLoading}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                              Text(
                                "UserId: $userid",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                              Text(
                                "Lat: $lathome",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                              Text(
                                "Lon: $longhome",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (userid != null &&
                                lathome != null &&
                                longhome != null) {
                              homeApiController.homeApi(
                                uid: userid.toString(),
                                lat: lathome.toString(),
                                lon: longhome.toString(),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: theamcolore),
                          child: Text("Force Load Home API",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : homeApiController.homeapimodel == null
                ? Container(
                    color: notifier.background,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 50, color: Colors.red),
                          const SizedBox(height: 20),
                          Text(
                            "No vehicle data available".tr,
                            style: TextStyle(
                                color: notifier.textColor, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (userid != null &&
                                  lathome != null &&
                                  longhome != null) {
                                homeApiController.homeApi(
                                  uid: userid.toString(),
                                  lat: lathome.toString(),
                                  lon: longhome.toString(),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: theamcolore),
                            child: Text("Retry",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      // ✅ MAIN MAP
                      lathome == null
                          ? Center(
                              child:
                                  CircularProgressIndicator(color: theamcolore))
                          : GoogleMap(
                              gestureRecognizers: {
                                Factory<OneSequenceGestureRecognizer>(
                                    () => EagerGestureRecognizer())
                              },
                              initialCameraPosition: appController
                                          .pickupController.text.isEmpty ||
                                      appController.dropController.text.isEmpty
                                  ? CameraPosition(
                                      target: LatLng(lathome, longhome),
                                      zoom: 13)
                                  : CameraPosition(
                                      target: LatLng(
                                          appController.pickupLat.value,
                                          appController.pickupLng.value),
                                      zoom: 13),
                              mapType: MapType.normal,
                              markers: appController
                                          .pickupController.text.isEmpty ||
                                      appController.dropController.text.isEmpty
                                  ? Set<Marker>.of(markers.values)
                                  : Set<Marker>.of(markers11.values),
                              onTap: (argument) {
                                handleMapTap(argument);
                              },
                              myLocationEnabled: false,
                              zoomGesturesEnabled: true,
                              tiltGesturesEnabled: true,
                              zoomControlsEnabled: true,
                              onMapCreated: (controller) {
                                setState(() {
                                  controller.setMapStyle(themeForMap);
                                  mapController1 = controller;

                                  if (appController
                                          .pickupController.text.isNotEmpty &&
                                      appController
                                          .dropController.text.isNotEmpty) {
                                    setupMapMarkers();
                                  }
                                });
                              },
                              polylines: Set<Polyline>.of(polylines11.values),
                            ),

                      // ✅ TOP UI BAR (Menu + Search)
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
                                          .then((value) {
                                        mapController1.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              target: LatLng(lathome, longhome),
                                              zoom: 14.0,
                                            ),
                                          ),
                                        );
                                      });
                                    });
                                  },
                                  readOnly: true,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                            _addMarkers();
                                            fun().then((value) {
                                              setState(() {});
                                              getCurrentLatAndLong(
                                                      lathome, longhome)
                                                  .then((value) {
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
                                              });
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

                      // ✅ BOTTOM DRAGGABLE SHEET - Complete with all features
                      DraggableScrollableSheet(
                        initialChildSize: 0.45,
                        minChildSize: 0.2,
                        maxChildSize: 1.0,
                        controller: sheetController,
                        builder: (BuildContext context, scrollController) {
                          return Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
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

                                  // Pickup and drop selection - KEEP YOUR EXISTING CODE HERE

                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    child: InkWell(
                                      onTap: () {
                                        _navigateAndRefresh();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: notifier.background,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                  height: 10,
                                                  width: 10,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.green,
                                                        width: 3),
                                                  ),
                                                ),
                                                Container(
                                                    height: 30,
                                                    width: 1,
                                                    color: Colors.grey),
                                                Container(
                                                  height: 10,
                                                  width: 10,
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    appController
                                                            .pickupController
                                                            .text
                                                            .isEmpty
                                                        ? "Select pickup location"
                                                            .tr
                                                        : appController
                                                            .pickupController
                                                            .text,
                                                    style: TextStyle(
                                                      color: notifier.textColor,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    height: 1,
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    appController.dropController
                                                            .text.isEmpty
                                                        ? "Where to go?".tr
                                                        : appController
                                                            .dropController
                                                            .text,
                                                    style: TextStyle(
                                                      color: appController
                                                              .dropController
                                                              .text
                                                              .isEmpty
                                                          ? Colors.grey
                                                          : notifier.textColor,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(Icons.add),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Vehicle selection - KEEP YOUR EXISTING CODE HERE

                                  if (homeApiController.homeapimodel
                                          ?.categoryList?.isNotEmpty ==
                                      true)
                                    buildVehicleSelection(homeApiController)
                                  else
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(
                                        "No vehicles available",
                                        style: TextStyle(
                                            color: notifier.textColor),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                  const SizedBox(height: 20),

                                  // ✅ NEW: Single calculation display

                                  buildConditionalCalculationPanel(),

                                  const SizedBox(height: 20),

                                  // Find driver button - KEEP YOUR EXISTING CODE HERE

                                  buildFindDriverButton(),

                                  const SizedBox(height: 20),
                                ])
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: notifier.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: notifier.containercolore,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.map_outlined,
                size: 50,
                color: theamcolore,
              ),
            ),

            const SizedBox(height: 30),

            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theamcolore),
              strokeWidth: 3,
            ),

            const SizedBox(height: 20),

            // Status text
            Text(
              _initializationStatus,
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Secondary text
            Text(
              "Please wait...".tr,
              style: TextStyle(
                color: notifier.textColor?.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            // Debug info (only in debug mode)
            if (kDebugMode) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      "DEBUG INFO:",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Initializing: $_isInitializing",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Text(
                      "Status: $_initializationStatus",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Text(
                      "UserId: $userid",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Text(
                      "LatHome: $lathome",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],

            // Force refresh button for debugging
            if (kDebugMode) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      _isInitializing = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theamcolore,
                ),
                child: Text(
                  "Force Skip Loading",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
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

// ✅ FIX 1: Type error - API returns strings, need to parse them

  Buttonpresebottomshhet() {
    if (appController.pickupController.text.isEmpty ||
        appController.dropController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Select Pickup and Drop");

      return;
    }

    if (amountresponse == "false") {
      Fluttertoast.showToast(msg: "Address is not in the zone!");

      return;
    }

    // ✅ FIXED: Parse strings to double properly

    double currentPrice =
        calculateController.calCulateModel?.dropPrice ?? dropprice;

    // ✅ API returns strings, need to parse them

    double currentMinFare = calculateController
                .calCulateModel?.vehicle?.minimumFare !=
            null
        ? double.parse(
            calculateController.calCulateModel!.vehicle!.minimumFare.toString())
        : minimumfare;

    double currentMaxFare = calculateController
                .calCulateModel?.vehicle?.maximumFare !=
            null
        ? double.parse(
            calculateController.calCulateModel!.vehicle!.maximumFare.toString())
        : maximumfare;

    if (currentPrice == 0) {
      Fluttertoast.showToast(
          msg: responsemessage.isEmpty
              ? "Price calculation failed"
              : responsemessage);

      return;
    }

    toast = 0;

    amountcontroller.text = currentPrice.toString();

    int maxprice = currentMaxFare.toInt();

    int minprice = currentMinFare.toInt();

    if (kDebugMode) {
      print("**Updated maxprice**: $maxprice");

      print("**Updated minprice**: $minprice");

      print("**Current vehicle price**: $currentPrice");
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
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
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

                      // ✅ UPDATED: Price adjustment controls with current prices

                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (_animationController != null &&
                                    _animationController!.isAnimating) {
                                  Fluttertoast.showToast(
                                    msg:
                                        "Your current request is in progress. You can either wait for it to complete or cancel to perform this action.",
                                  );
                                } else {
                                  if (double.parse(amountcontroller.text) >
                                      minprice) {
                                    // ✅ Update the displayed price AND the global variables

                                    double newPrice =
                                        double.parse(amountcontroller.text) - 1;

                                    amountcontroller.text = newPrice.toString();

                                    dropprice = newPrice; // ✅ Update global

                                    mainamount = newPrice.toString();

                                    offerpluse = true;

                                    if (couponindex != null &&
                                        couponadd[couponindex!] == true) {
                                      couponadd[couponindex!] = false;
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
                                readOnly: _animationController != null &&
                                    _animationController!.isAnimating,
                                onTap: () {
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
                                      amountcontroller.text =
                                          maxprice.toString();

                                      toast = 1;
                                    } else if (int.parse(
                                            amountcontroller.text) <
                                        minprice) {
                                      amountcontroller.text =
                                          minprice.toString();

                                      toast = 2;
                                    } else {
                                      toast = 0;

                                      dropprice = double.parse(amountcontroller
                                          .text); // ✅ Update global

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
                                if (_animationController != null &&
                                    _animationController!.isAnimating) {
                                  Fluttertoast.showToast(
                                    msg:
                                        "Your current request is in progress. You can either wait for it to complete or cancel to perform this action.",
                                  );
                                } else {
                                  if (double.parse(amountcontroller.text) <
                                      maxprice) {
                                    // ✅ Update the displayed price AND the global variables

                                    double newPrice =
                                        double.parse(amountcontroller.text) + 1;

                                    amountcontroller.text = newPrice.toString();

                                    dropprice = newPrice; // ✅ Update global

                                    mainamount = newPrice.toString();

                                    offerpluse = true;

                                    if (couponindex != null &&
                                        couponadd[couponindex!] == true) {
                                      couponadd[couponindex!] = false;
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

                      // Error messages with updated prices

                      toast == 1
                          ? Text(
                              "Maximum fare is $globalcurrency$maxprice",
                              style: const TextStyle(color: Colors.red),
                            )
                          : toast == 2
                              ? Text(
                                  "Minimum fare is $globalcurrency$minprice",
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
                          "Automatically book the nearest driver for (${amountcontroller.text} ${globalcurrency})"
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
                                    "Book for A ${amountcontroller.text} ${globalcurrency}")
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
                                        backgroundColor: WidgetStatePropertyAll(
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
                                                _animationController!.dispose();
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
                                            mainamount = amountcontroller.text;
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
                                              backgroundColor:
                                                  theamcolore.withOpacity(0.1),
                                              color: theamcolore,
                                            ),
                                          ),
                                          offerpluse == true
                                              ? Text(
                                                  "Raise fare to ${globalcurrency}${amountcontroller.text}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    letterSpacing: 0.4,
                                                  ),
                                                )
                                              : Text(
                                                  "Book for  AfterRise${globalcurrency}${amountcontroller.text}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
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
                                            _animationController!.isAnimating) {
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
      droplistadd: droptitlelist,
      context: context,
      uid: appController.globalUserId.value,
      tot_km: "${appController.totalkm}",
      vehicle_id: appController.vehicle_id,
      tot_minute: appController.tot_time,
      tot_hour: appController.tot_hour,
      m_role: mroal,
      coupon_id: appController.couponId.value,
      payment_id: "$payment",
      driverid: calculateController.calCulateModel!.driverId!,
      price: amountcontroller.text,
      pickup:
          "${appController.pickupLat.value},${appController.pickupLng.value}",
      drop: "${appController.dropLat.value},${appController.dropLng.value}",
      droplist: appController.onlypass,
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
            drop_lat_lon_list: appController.onlypass)
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

  // ✅ IMPROVED: Map tap handler with vehicle loading
  void handleMapTap(LatLng tappedPoint) {
    setState(() {
      _onAddMarkerButtonPressed(tappedPoint.latitude, tappedPoint.longitude);

      lathome = tappedPoint.latitude;

      longhome = tappedPoint.longitude;

      getCurrentLatAndLong(lathome, longhome);
    });

    // Load vehicles at new location

    if (mid.isNotEmpty) {
      loadVehiclesForCategory(mid);
    }
  }

  // ✅ IMPROVED: Vehicle selection with immediate map update

  Widget buildVehicleSelection(HomeApiController homeApiController) {
    if (homeApiController.homeapimodel?.categoryList?.isNotEmpty != true) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "No vehicles available",
          style: TextStyle(color: notifier.textColor),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: homeApiController.homeapimodel!.categoryList!.length,
          itemBuilder: (context, index) {
            final category =
                homeApiController.homeapimodel!.categoryList![index];

            return Padding(
              padding: const EdgeInsets.all(4),
              child: InkWell(
                onTap: () async {
                  if (kDebugMode) {
                    print(
                        "🚗 Selected vehicle category: ${category.name} (ID: ${category.id})");
                  }

                  setState(() {
                    select1 = index;

                    vehicle_id = category.id.toString();

                    vihicalname = category.name.toString();

                    vihicalimage = category.image.toString();

                    mid = category.id.toString();

                    mroal = category.role.toString();
                  });

                  // Clear existing vehicle markers before loading new category

                  setState(() {
                    markers.removeWhere((key, value) =>
                        key.value.startsWith('vehicle_') ||
                        key.value.contains('driver'));
                  });

                  // Load vehicles for new category

                  if (lathome != null && longhome != null) {
                    await loadVehiclesForCategory(mid);
                  }

                  // ✅ RECALCULATE price when vehicle changes

                  if (latitudepick != 0.0 &&
                      longitudepick != 0.0 &&
                      latitudedrop != 0.0 &&
                      longitudedrop != 0.0) {
                    try {
                      final result = await calculateController.calculateApi(
                        context: context,
                        uid: userid.toString(),
                        mid: mid,
                        mrole: mroal,
                        pickup_lat_lon: "${latitudepick},${longitudepick}",
                        drop_lat_lon: "${latitudedrop},${longitudedrop}",
                        drop_lat_lon_list: appController.onlypass,
                      );

                      if (result["Result"] == true) {
                        setState(() {
                          // ✅ PARSE API strings to doubles properly

                          dropprice = (result["drop_price"] as num).toDouble();

                          minimumfare = double.parse(
                              result["vehicle"]["minimum_fare"].toString());

                          maximumfare = double.parse(
                              result["vehicle"]["maximum_fare"].toString());

                          responsemessage = result["message"]?.toString() ?? "";

                          amountresponse = "true";

                          // Update other calculation data

                          totalkm =
                              (result["tot_km"] as num?)?.toDouble() ?? 0.0;

                          tot_time = result["tot_minute"]?.toString() ?? "0";

                          tot_hour = result["tot_hour"]?.toString() ?? "0";

                          // Update vehicle info

                          vihicalrice = dropprice;
                        });

                        if (kDebugMode) {
                          print(
                              "✅ Vehicle price updated: $dropprice $globalcurrency");
                        }
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print("❌ Error updating price for vehicle change: $e");
                      }
                    }
                  }
                },
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: select1 == index
                        ? theamcolore.withOpacity(0.08)
                        : notifier.containercolore,
                    borderRadius: BorderRadius.circular(10),
                    border: select1 == index
                        ? Border.all(color: theamcolore, width: 2)
                        : Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            "${Config.imageurl}${category.image}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.directions_car,
                                  color: theamcolore, size: 24);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        category.name ?? "",
                        style: TextStyle(
                          color: select1 == index
                              ? theamcolore
                              : notifier.textColor,
                          fontSize: 12,
                          fontWeight: select1 == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildConditionalTripPanel() {
    // Only show if we have a complete trip calculation
    if (appController.pickupController.text.isEmpty ||
        appController.dropController.text.isEmpty ||
        calculateController.calCulateModel == null ||
        loadertimer) {
      return SizedBox.shrink(); // Don't show panel
    }

    return buildTripCalculationPanel();
  }
// ✅ FIX 1: Corrected _calculateRoutePrice method

  Future<void> _calculateRoutePrice() async {
    if (kDebugMode) {
      print("💰 Calculating price for route with vehicle category: $mid");
    }

    try {
      // Only calculate if we have pickup and drop points

      if (latitudepick == 0.0 ||
          longitudepick == 0.0 ||
          latitudedrop == 0.0 ||
          longitudedrop == 0.0) {
        if (kDebugMode) {
          print("⚠️ Missing pickup or drop coordinates for price calculation");
        }

        return;
      }

      setState(() {
        loadertimer = true;
      });

      await calculateController.calculateApi(
        context: context,
        uid: userid.toString(),
        mid: mid,
        mrole: mroal,
        pickup_lat_lon: "${latitudepick},${longitudepick}",
        drop_lat_lon: "${latitudedrop},${longitudedrop}",
        drop_lat_lon_list: appController.onlypass,
      );

      if (calculateController.calCulateModel?.result == "true") {
        final result = calculateController.calCulateModel!;

        setState(() {
          // ✅ FIXED: Proper type handling for API response

          vihicalrice = result.dropPrice ?? 0.0;

          totalkm = result.totKm ?? 0.0;

          tot_time = result.totMinute?.toString() ?? "0";

          tot_hour = result.totHour?.toString() ?? "0";

          // Update vehicle information from response

          if (result.vehicle != null) {
            vihicalname = result.vehicle!.name ?? vihicalname;

            vehicle_id = result.vehicle!.id?.toString() ?? vehicle_id;
          }

          loadertimer = false;
        });

        if (kDebugMode) {
          print("✅ Price calculated: $vihicalrice ${globalcurrency}");

          print("📏 Distance: $totalkm km");

          print("⏱️ Time: $tot_hour hours $tot_time minutes");
        }
      } else {
        setState(() {
          loadertimer = false;
        });

        if (kDebugMode) {
          print(
              "❌ Price calculation failed: ${calculateController.calCulateModel?.message}");
        }
      }
    } catch (e) {
      setState(() {
        loadertimer = false;
      });

      if (kDebugMode) {
        print("❌ Error calculating price: $e");
      }
    }
  }

// ✅ FIX 2: Corrected buildCalculationDisplay method

  Widget buildCalculationDisplay() {
    if (calculateController.calCulateModel == null) {
      return SizedBox.shrink();
    }

    return GetBuilder<CalculateController>(
      builder: (calculateController) {
        if (calculateController.calCulateModel == null) {
          return SizedBox.shrink();
        }

        final calculation = calculateController.calCulateModel!;

        String currency = globalcurrency.isNotEmpty
            ? globalcurrency
            : (currencyy != null && currencyy['symbol'] != null
                ? currencyy['symbol']
                : 'YER');

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: notifier.containercolore,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theamcolore.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calculate, color: theamcolore, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Trip Calculation",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: notifier.textColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Distance:",
                      style: TextStyle(color: notifier.textColor)),
                  Text(
                    // ✅ FIXED: Direct use of double values

                    "${calculation.totKm ?? totalkm} km",

                    style: TextStyle(
                        color: notifier.textColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Duration:",
                      style: TextStyle(color: notifier.textColor)),
                  Text(
                    // ✅ FIXED: Direct use of int values, convert to string only for display

                    "${calculation.totHour ?? int.tryParse(tot_hour) ?? 0}h ${calculation.totMinute ?? int.tryParse(tot_time) ?? 0}m",

                    style: TextStyle(
                        color: notifier.textColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Estimated Fare:",
                      style: TextStyle(color: notifier.textColor)),
                  Text(
                    // ✅ FIXED: Direct use of double value

                    "${calculation.dropPrice ?? dropprice} $currency",

                    style: TextStyle(
                      color: theamcolore,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (minimumfare > 0 && maximumfare > 0) ...[
                SizedBox(height: 5),
                Text(
                  "Range: ${minimumfare.toInt()} $currency - ${maximumfare.toInt()} $currency",
                  style: TextStyle(
                    color: notifier.textColor?.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

// ✅ FIX 3: Corrected buildFindDriverButton method

  Widget buildFindDriverButton() {
    if (appController.pickupController.text.isEmpty ||
        appController.dropController.text.isEmpty) {
      return SizedBox.shrink();
    }

    String currency = globalcurrency.isNotEmpty
        ? globalcurrency
        : (currencyy != null && currencyy['symbol'] != null
            ? currencyy['symbol']
            : 'YER');

    return Padding(
      padding: const EdgeInsets.all(10),
      child: GetBuilder<CalculateController>(
        builder: (calculateController) {
          return calculateController.isLoading
              ? Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: theamcolore.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Calculating trip...",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: () async {
                    if (calculateController.calCulateModel?.driverId != null) {
                      Buttonpresebottomshhet();
                    } else {
                      if (kDebugMode) {
                        print("🔄 Calculating trip price...");
                      }

                      try {
                        final result = await calculateController.calculateApi(
                          context: context,
                          uid: appController.globalUserId.value,
                          mid: mid,
                          mrole: mroal,
                          pickup_lat_lon:
                              "${appController.pickupLat.value},${appController.pickupLng.value}",
                          drop_lat_lon:
                              "${appController.dropLat.value},${appController.dropLng.value}",
                          drop_lat_lon_list: appController.onlypass,
                        );

                        if (result["Result"] == true) {
                          setState(() {
                            // ✅ FIXED: Proper type casting from API response

                            dropprice =
                                (result["drop_price"] as num).toDouble();

                            minimumfare =
                                (result["vehicle"]["minimum_fare"] as num)
                                    .toDouble();

                            maximumfare =
                                (result["vehicle"]["maximum_fare"] as num)
                                    .toDouble();

                            responsemessage = result["message"]?.toString() ??
                                "Calculation failed";

                            amountresponse = "true";

                            // ✅ FIXED: Proper type handling for numeric values

                            totalkm =
                                (result["tot_km"] as num?)?.toDouble() ?? 0.0;

                            tot_time = result["tot_minute"]?.toString() ?? "0";

                            tot_hour = result["tot_hour"]?.toString() ?? "0";
                          });

                          if (kDebugMode) {
                            print(
                                "✅ Calculation completed: $dropprice $currency");
                          }

                          Buttonpresebottomshhet();
                        } else {
                          setState(() {
                            amountresponse = "false";

                            responsemessage = result["message"]?.toString() ??
                                "Calculation failed";
                          });

                          Fluttertoast.showToast(msg: responsemessage);
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          print("❌ Calculation error: $e");
                        }

                        Fluttertoast.showToast(
                            msg: "Failed to calculate trip price");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theamcolore,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    calculateController.calCulateModel?.driverId != null
                        ? "Set your price - ${(calculateController.calCulateModel?.dropPrice ?? dropprice).toInt()} $currency"
                            .tr
                        : "Calculate price".tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
        },
      ),
    );
  }

// ✅ STEP 1: First, add this method to your _MapScreenState class (anywhere in the class, maybe after buildTripCalculationPanel):

  Widget buildConditionalCalculationPanel() {
    bool hasPickupAndDrop = appController.pickupController.text.isNotEmpty &&
        appController.dropController.text.isNotEmpty;

    if (!hasPickupAndDrop) {
      return SizedBox.shrink();
    }

    // Check if we have calculation data

    bool hasCalculation = calculateController.calCulateModel != null;

    bool isNotLoading = !loadertimer && !calculateController.isLoading;

    if (isNotLoading && hasCalculation) {
      return buildTripCalculationPanel();
    }

    if (!isNotLoading) {
      // Show loading state

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: notifier.containercolore,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theamcolore.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: theamcolore,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 15),
            Text(
              "Calculating trip details...",
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget buildTripCalculationPanel() {
    if (latitudepick == 0.0 || latitudedrop == 0.0 || loadertimer) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.containercolore,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.route, color: theamcolore, size: 20),
              const SizedBox(width: 8),
              Text(
                "Trip Details",
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.straighten, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "Distance: ${totalkm.toStringAsFixed(1)} km",
                      style: TextStyle(color: notifier.textColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "Duration: ${tot_hour}h ${tot_time}m",
                      style: TextStyle(color: notifier.textColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.directions_car, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "Vehicle: $vihicalname",
                      style: TextStyle(color: notifier.textColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.attach_money, color: theamcolore, size: 16),
                  Text(
                    "${vihicalrice.toStringAsFixed(0)} $globalcurrency",
                    style: TextStyle(
                      color: theamcolore,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
