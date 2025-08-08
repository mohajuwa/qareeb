// CORRECTED IMPORTS - REPLACE THE IMPORT SECTION IN YOUR map_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/api_code/calculate_api_controller.dart';
import 'package:qareeb/api_code/global_driver_access_api_controller.dart';
import 'package:qareeb/app_screen/driver_detail_screen.dart';
import 'package:qareeb/common_code/common_flow_screen.dart';
import 'package:qareeb/common_code/modern_loading_widget.dart';
import 'package:qareeb/common_code/toastification.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ PROVIDER IMPORTS - ADDED
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/map_state.dart';
import 'package:qareeb/providers/pricing_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';
import 'package:qareeb/providers/socket_service.dart';
import 'package:qareeb/providers/timer_state.dart';

import '../api_code/add_vehical_api_controller.dart';
import '../api_code/coupon_payment_api_contoller.dart';
// REMOVED: import '../api_code/global_driver_accept_class_controller.dart';
import '../api_code/home_controller.dart'; // FIXED: Changed from home_api_controller.dart
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

import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';
import '../common_code/config.dart';
import '../common_code/global_variables.dart';
import '../common_code/push_notification.dart';
import 'counter_bottom_sheet.dart';
import 'driver_list_screen.dart';
import 'driver_startride_screen.dart';
import 'faq_screen.dart';
import 'home_screen.dart';
import 'language_screen.dart';
import 'my_ride_screen.dart';
import 'notification_screen.dart';
import 'pickup_drop_point.dart';
import 'profile_screen.dart';

class ModernMapScreen extends StatefulWidget {
  final bool selectVehicle;
  const ModernMapScreen({super.key, required this.selectVehicle});

  @override
  State<ModernMapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<ModernMapScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ✅ SCAFFOLD KEY FOR DRAWER
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  // Local state variables (non-provider managed)
  final List<LatLng> vihicallocations = [];
  final List<String> _iconPaths = [];
  final List<String> _iconPathsbiddingon = [];
  final List<LatLng> vihicallocationsbiddingon = [];
  List<PointLatLng> _dropOffPoints = [];
  List<bool> couponadd = [];

  // Socket management variables
  bool socketInitialized = false;
  bool _disposed = false;
  Timer? _socketReconnectTimer;
  Timer? _requestTimer;
  StreamSubscription? _appStateSubscription;

  // UI state
  String themeForMap = "";
  bool isLoad = false;
  bool light = false;
  String biddautostatus = "false";
  bool switchValue = false;
  int toast = 0;
  int payment = 0;
  String paymentname = "";
  String selectedOption = "";
  String selectBoring = "";
  int couponAmt = 0;
  String couponId = "";
  String couponname = "";
  String mainamount = "";

  // Location variables (still global for compatibility)
  var lathome;
  var longhome;
  var addresshome;
  var decodeUid;
  var userid;
  var username;
  var currencyy;

  // ✅ DRAWER MENU ITEMS
  List<String> drowertitle = [
    "My Ride",
    "Wallet",
    "Notifications",
    "Language",
    "FAQ",
    "Settings",
    "Logout"
  ];

  List<String> drowerimage = [
    "assets/drower/car.png",
    "assets/drower/wallet.png",
    "assets/drower/notification.png",
    "assets/drower/language.png",
    "assets/drower/faq.png",
    "assets/drower/setting.png",
    "assets/drower/logout.png"
  ];

  // Controllers and focus nodes
  late AnimationController controller;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController amountcontroller = TextEditingController();

  // API Controllers
  HomeApiController homeApiController = Get.put(HomeApiController());
  HomeMapController homeMapController = Get.put(HomeMapController());
  AddVihicalCalculateController addVihicalCalculateController =
      Get.put(AddVihicalCalculateController());
  CalculateController calculateController = Get.put(CalculateController());
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());
  RemoveRequest removeRequest = Get.put(RemoveRequest());
  HomeWalletApiController homeWalletApiController =
      Get.put(HomeWalletApiController());
  PagelistApiController pagelistApiController =
      Get.put(PagelistApiController()); // FIXED

  // Color notifier
  ColorNotifier notifier = ColorNotifier();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _initializeApp();
    mapThemeStyle(context: context);
  }

  // Theme setup
  mapThemeStyle({required context}) {
    if (darkMode == true) {
      setState(() {
        DefaultAssetBundle.of(context)
            .loadString("assets/map_styles/dark_style.json")
            .then((value) {
          setState(() {
            themeForMap = value;
          });
        });
      });
    } else {
      setState(() {
        DefaultAssetBundle.of(context)
            .loadString("assets/map_styles/light_style.json")
            .then((value) {
          setState(() {
            themeForMap = value;
          });
        });
      });
    }
  }

  // ✅ COMPLETE BUILD METHOD WITH ALL UI COMPONENTS
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    return Consumer4<LocationState, MapState, PricingState, RideRequestState>(
      builder:
          (context, locationState, mapState, pricingState, rideState, child) {
        return WillPopScope(
          onWillPop: () async {
            _clearGlobalState();
            Get.offAll(const OnboardingScreen());
            return false;
          },
          child: Scaffold(
            key: _key,
            backgroundColor: notifier.background,

            // ✅ COMPLETE DRAWER
            drawer: Drawer(
              backgroundColor: notifier.containercolore,
              child: Column(
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: theamcolore,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: theamcolore,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GetBuilder<HomeApiController>(
                          builder: (homeApiController) {
                            return homeApiController
                                        .homeapimodel?.cusRating?.avgStar !=
                                    null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.white),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "${homeApiController.homeapimodel!.cusRating!.avgStar}",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(width: 5),
                                        SvgPicture.asset(
                                          "assets/svgpicture/star-fill.svg",
                                          height: 12,
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                        )
                                      ],
                                    ),
                                  )
                                : const SizedBox();
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          username ?? "User",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ));
                          },
                          child: const Text(
                            "View profile",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: drowertitle.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context); // Close drawer first
                            _handleDrawerNavigation(index, locationState);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  drowerimage[index],
                                  height: 20,
                                  width: 20,
                                  color: notifier.textColor,
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  drowertitle[index].tr,
                                  style: TextStyle(
                                    color: notifier.textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            body: Stack(
              children: [
                // ✅ GOOGLE MAP WITH PROVIDER DATA
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) async {
                    context.read<MapState>().setMapController(controller);
                    if (themeForMap.isNotEmpty) {
                      await controller.setMapStyle(themeForMap);
                    }
                    mapReady();
                  },
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      locationState.latitudePick != 0.0
                          ? locationState.latitudePick
                          : lathome ?? 13.9667,
                      locationState.longitudePick != 0.0
                          ? locationState.longitudePick
                          : longhome ?? 77.5667,
                    ),
                    zoom: 14.0,
                  ),
                  markers:
                      homeMapController.homeMapApiModel?.list?.isNotEmpty ==
                              true
                          ? Set<Marker>.from(mapState.markers11.values)
                          : Set<Marker>.from(mapState.markers.values),
                  polylines: Set<Polyline>.from(mapState.polylines11.values),
                  onTap: (argument) {
                    setState(() {
                      _onAddMarkerButtonPressed(
                          argument.latitude, argument.longitude);
                      lathome = argument.latitude;
                      longhome = argument.longitude;
                      getCurrentLatAndLong(lathome, longhome);

                      homeMapController
                          .homemapApi(
                              mid: mid,
                              lat: lathome.toString(),
                              lon: longhome.toString())
                          .then((value) {
                        setState(() {});
                        if (value["Result"] == false) {
                          setState(() {
                            vihicallocations.clear();
                            context.read<MapState>().clearMapData();
                            _addMarkers();
                          });
                        } else {
                          _updateVehicleMarkers();
                        }
                      });
                    });
                  },
                ),

                // ✅ TOP SEARCH BAR WITH MENU BUTTON
                Positioned(
                  top: 50,
                  left: 15,
                  right: 15,
                  child: Row(
                    children: [
                      // Menu button
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
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image(
                                image: const AssetImage("assets/menu.png"),
                                height: 20,
                                color: notifier.textColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      // Search bar
                      Expanded(
                        flex: 5,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: notifier.containercolore,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: TextField(
                            onTap: () {
                              _showPickupDropSheet();
                            },
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "Where to?".tr,
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon:
                                  Icon(Icons.search, color: theamcolore),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ LOCATION SELECTION PANEL (SHOWN WHEN LOCATIONS ARE SET)
                Consumer<LocationState>(
                  builder: (context, locationState, child) {
                    return locationState.pickupController.text.isNotEmpty ||
                            locationState.dropController.text.isNotEmpty
                        ? Positioned(
                            top: 120,
                            left: 15,
                            right: 15,
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: notifier.containercolore,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Pickup location row
                                  Row(
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
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            context
                                                .read<LocationState>()
                                                .setPicAndDrop(false);
                                            _showPickupDropSheet();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              locationState.pickupController
                                                      .text.isNotEmpty
                                                  ? locationState
                                                      .pickupController.text
                                                  : "اختر نقطة الانطلاق",
                                              style: TextStyle(
                                                color: notifier.textColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // Drop location row
                                  Row(
                                    children: [
                                      Container(
                                        height: 15,
                                        width: 15,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.red, width: 4),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            context
                                                .read<LocationState>()
                                                .setPicAndDrop(true);
                                            _showPickupDropSheet();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              locationState.dropController.text
                                                      .isNotEmpty
                                                  ? locationState
                                                      .dropController.text
                                                  : "اختر نقطة الوصول",
                                              style: TextStyle(
                                                color: notifier.textColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Show additional drop locations
                                  if (locationState.dropTitleList.isNotEmpty)
                                    ...locationState.dropTitleList
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      var dropItem = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 15,
                                              width: 15,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.orange,
                                                    width: 4),
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  dropItem["title"] ?? "",
                                                  style: TextStyle(
                                                    color: notifier.textColor,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.close,
                                                  size: 20, color: Colors.red),
                                              onPressed: () {
                                                locationState
                                                    .removeDropLocation(index);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox();
                  },
                ),

                // ✅ CURRENT LOCATION BUTTON
                Positioned(
                  bottom: 150,
                  right: 15,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: notifier.containercolore,
                    onPressed: () {
                      _getCurrentLocation();
                    },
                    child: Icon(
                      Icons.my_location,
                      color: theamcolore,
                    ),
                  ),
                ),

                // ✅ BOOKING BUTTON
                Consumer2<LocationState, PricingState>(
                  builder: (context, locationState, pricingState, child) {
                    return locationState.pickupController.text.isNotEmpty &&
                            locationState.dropController.text.isNotEmpty
                        ? Positioned(
                            bottom: 20,
                            left: 15,
                            right: 15,
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: notifier.containercolore,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Show pricing if available
                                  if (pricingState.dropPrice > 0)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Estimated Fare:",
                                            style: TextStyle(
                                              color: notifier.textColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            "$globalcurrency${pricingState.dropPrice.toStringAsFixed(2)}",
                                            style: TextStyle(
                                              color: theamcolore,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  CommonButton(
                                    containcolore: theamcolore,
                                    onPressed1: () {
                                      _showPickupDropSheet(bidding: "1");
                                    },
                                    txt1: "احجز الرحلة",
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ HANDLE DRAWER NAVIGATION
  void _handleDrawerNavigation(int index, LocationState locationState) {
    switch (index) {
      case 0: // My Ride
        locationState.clearLocationData();
        context.read<MapState>().clearMapData();
        Get.to(() => const MyRideScreen());
        break;
      case 1: // Wallet
        homeWalletApiController.homwwalleteApi(
            uid: useridgloable.toString(), context: context);
        // Navigate to wallet screen
        break;
      case 2: // Notifications
        Get.to(() => const NotificationScreen());
        break;
      case 3: // Language
        Get.to(() => const LanguageScreen());
        break;
      case 4: // FAQ
        pagelistApiController.pagelistttApi(context).then((value) {
          Get.to(() => const FaqScreen());
        });
        break;
      case 5: // Settings
        // Navigate to settings
        break;
      case 6: // Logout
        _showLogoutDialog();
        break;
    }
  }

  // ✅ LOGOUT DIALOG
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: notifier.containercolore,
          title: Text(
            "Logout".tr,
            style: TextStyle(color: notifier.textColor),
          ),
          content: Text(
            "Are you sure you want to logout?".tr,
            style: TextStyle(color: notifier.textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel".tr),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Get.offAll(() => const OnboardingScreen());
              },
              child: Text("Logout".tr, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ✅ SHOW PICKUP DROP SHEET
  void _showPickupDropSheet({String bidding = "0"}) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: PickupDropPoint(
            pagestate: false, // FIXED: Added required parameter

            bidding: bidding,
          ),
        );
      },
    );
  }

  // ✅ GET CURRENT LOCATION
  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      lathome = position.latitude;
      longhome = position.longitude;

      final mapController = context.read<MapState>().mapController;
      if (mapController != null) {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 16.0,
            ),
          ),
        );
      }

      getCurrentLatAndLong(position.latitude, position.longitude);
      _onAddMarkerButtonPressed(position.latitude, position.longitude);
    } catch (e) {
      if (kDebugMode) print("❌ Error getting current location: $e");
      showToastForDuration("Unable to get current location", 2);
    }
  }

  // ✅ MIGRATED MARKER FUNCTIONS
  Future<void> _onAddMarkerButtonPressed(double? lat, long) async {
    final Uint8List markIcon = await getImages("assets/pickup_marker.png", 80);

    MarkerId markerId = const MarkerId("my_1");
    Marker marker = Marker(
      markerId: markerId,
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
                        Consumer<LocationState>(
                          builder: (context, locationState, child) {
                            return Text(
                              locationState.pickupController.text.isNotEmpty
                                  ? locationState.pickupController.text
                                  : locationState.pickTitle.isNotEmpty
                                      ? locationState.pickTitle
                                      : addresshome ?? "Current Location",
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                        Consumer<LocationState>(
                          builder: (context, locationState, child) {
                            return locationState.pickSubtitle == ""
                                ? const SizedBox()
                                : Text(
                                    locationState.pickSubtitle,
                                    maxLines: 3,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                          },
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

    if (mounted) {
      context.read<MapState>().addMarker11(markerId, marker);
    }
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
                        Consumer<LocationState>(
                          builder: (context, locationState, child) {
                            return Text(
                              locationState.dropTitle.isNotEmpty
                                  ? locationState.dropTitle
                                  : "Destination",
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                        Consumer<LocationState>(
                          builder: (context, locationState, child) {
                            return locationState.dropSubtitle == ""
                                ? const SizedBox()
                                : Text(
                                    locationState.dropSubtitle,
                                    maxLines: 3,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                          },
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

    if (mounted) {
      context.read<MapState>().addMarker(markerId, marker);
    }
  }

  Future _addMarker3(String id) async {
    final Uint8List markIcon = await getImages("assets/drop_marker.png", 80);

    final locationState = context.read<LocationState>();
    for (int a = 0; a < locationState.destinationLat.length; a++) {
      MarkerId markerId = MarkerId("drop_$a");
      final marker = Marker(
        markerId: markerId,
        position: LatLng(
          locationState.destinationLat[a].latitude,
          locationState.destinationLat[a].longitude,
        ),
        icon: BitmapDescriptor.fromBytes(markIcon),
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
                            "${locationState.dropTitleList[a]["title"]}",
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${locationState.dropTitleList[a]["subt"]}",
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

      if (mounted) {
        context.read<MapState>().addMarker(markerId, marker);
      }
    }
  }

  Future _addMarker11(
      LatLng position, String id, BitmapDescriptor descriptor) async {
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
                        Consumer<LocationState>(
                          builder: (context, locationState, child) {
                            return Text(
                              locationState.pickupController.text.isNotEmpty
                                  ? locationState.pickupController.text
                                  : locationState.pickTitle,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                        Consumer<LocationState>(
                          builder: (context, locationState, child) {
                            return locationState.pickSubtitle == ""
                                ? const SizedBox()
                                : Text(
                                    locationState.pickSubtitle,
                                    maxLines: 3,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                          },
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

    if (mounted) {
      context.read<MapState>().addMarker11(markerId, marker);
    }
  }

  // ✅ MIGRATED POLYLINE FUNCTIONS
  Future getDirections11(
      {required PointLatLng lat1,
      required PointLatLng lat2,
      required List<PointLatLng> dropOffPoints}) async {
    final mapState = context.read<MapState>();

    mapState.clearPolylines11();

    List<LatLng> polylineCoordinates = [];
    List<PointLatLng> allPoints = [lat1, lat2, ...dropOffPoints];

    for (int i = 0; i < allPoints.length - 1; i++) {
      PointLatLng point1 = allPoints[i];
      PointLatLng point2 = allPoints[i + 1];

      PolylineResult result =
          await mapState.polylinePoints11.getRouteBetweenCoordinates(
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

    addPolyLine11(polylineCoordinates);
  }

  addPolyLine11(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: theamcolore,
      points: polylineCoordinates,
      width: 3,
    );

    if (mounted) {
      context.read<MapState>().addPolyline11(id, polyline);
      setState(() {});
    }
  }

  // ✅ MIGRATED SOCKET FUNCTIONS
  socketConnect() async {
    try {
      SocketService.instance.connect();
      _connectSocket();
    } catch (e) {
      if (kDebugMode) print("❌ Socket connection error: $e");
    }
  }

  _connectSocket() async {
    final socketService = SocketService.instance;

    socketService.on('Vehicle_Bidding$useridgloable', (Vehicle_Bidding) {
      _handleVehicleBidding(Vehicle_Bidding);
    });

    socketService.on('V_Driver_Location$useridgloable', (V_Driver_Location) {
      _handleDriverLocation(V_Driver_Location);
    });

    socketService.on('Calculate_Result$useridgloable', (Calculate_Result) {
      _handleCalculateResult(Calculate_Result);
    });

    socketService.on('RequestTimeOut$useridgloable', (RequestTimeOut) {
      _handleRequestTimeout(RequestTimeOut);
    });

    socketService.on('Accept_Driver$useridgloable', (Accept_Driver) {
      _handleAcceptDriver(Accept_Driver);
    });
  }

  // ✅ NEW EVENT HANDLERS
  void _handleVehicleBidding(dynamic Vehicle_Bidding) {
    if (!mounted) return;

    try {
      if (Vehicle_Bidding != null) {
        context
            .read<RideRequestState>()
            .updateFromVehicleBidding(Vehicle_Bidding);
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) print("❌ Vehicle bidding handler error: $e");
    }
  }

  void _handleDriverLocation(dynamic V_Driver_Location) {
    if (!mounted) return;

    try {
      if (V_Driver_Location != null &&
          V_Driver_Location['latitude'] != null &&
          V_Driver_Location['longitude'] != null) {
        double lat = double.parse(V_Driver_Location['latitude'].toString());
        double lng = double.parse(V_Driver_Location['longitude'].toString());
        String driverId = V_Driver_Location['driver_id'].toString();

        _updateDriverMarker(LatLng(lat, lng), driverId);
      }
    } catch (e) {
      if (kDebugMode) print("❌ Driver location handler error: $e");
    }
  }

  void _handleCalculateResult(dynamic Calculate_Result) {
    if (!mounted) return;

    try {
      if (Calculate_Result != null && Calculate_Result['Result'] == true) {
        context
            .read<PricingState>()
            .updateFromCalculateResult(Calculate_Result);
      }
    } catch (e) {
      if (kDebugMode) print("❌ Calculate result handler error: $e");
    }
  }

  void _handleRequestTimeout(dynamic RequestTimeOut) {
    if (!mounted) return;

    try {
      if (RequestTimeOut != null) {
        context.read<RideRequestState>().handleTimeout(RequestTimeOut);
        _clearGlobalState();
      }
    } catch (e) {
      if (kDebugMode) print("❌ Request timeout handler error: $e");
    }
  }

  void _handleAcceptDriver(dynamic Accept_Driver) {
    if (!mounted) return;

    try {
      if (Accept_Driver != null) {
        context.read<RideRequestState>().updateAcceptedDriver(Accept_Driver);

        // Navigate to driver detail screen
        Get.to(() => DriverDetailScreen(
              // Pass required parameters using provider data
              lat: context.read<LocationState>().latitudePick,
              long: context.read<LocationState>().longitudePick,
            ));
      }
    } catch (e) {
      if (kDebugMode) print("❌ Accept driver handler error: $e");
    }
  }

  void _updateDriverMarker(LatLng position, String driverId) {
    MarkerId markerId = MarkerId("driver_$driverId");

    if (context.read<MapState>().markers.containsKey(markerId)) {
      context.read<MapState>().updateMarkerPosition(markerId, position);
    } else {
      // Add new driver marker
      Marker marker = Marker(
        markerId: markerId,
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      context.read<MapState>().addMarker(markerId, marker);
    }
  }

  // ✅ MIGRATED SOCKET EMIT FUNCTIONS
  void socateempt() {
    SocketService.instance.emit('vehiclerequest', {
      'requestid': addVihicalCalculateController.addVihicalCalculateModel!.id,
      'driverid': calculateController.calCulateModel!.driverId!,
    });
  }

  void socateemptrequesttimeout() {
    SocketService.instance.emit('Vehicle_Ride_Cancel', {
      'uid': "$useridgloable",
      'driverid': calculateController.calCulateModel!.driverId!,
    });
  }

  // ✅ ADDITIONAL SOCKET EMIT METHODS
  void emitVehicleRideCancel(String uid, List driverid) {
    SocketService.instance.emit('Vehicle_Ride_Cancel', {
      'uid': uid,
      'driverid': driverid,
    });
  }

  void emitVehiclePaymentChange(
      String useridgloable, String dId, int paymentId) {
    SocketService.instance.emit('Vehicle_P_Change', {
      'useridgloable': useridgloable,
      'd_id': dId,
      'payment_id': paymentId,
    });
  }

  void emitAcceptBidding(
      String uid, String dId, String requestId, String price) {
    SocketService.instance.emit('Accept_Bidding', {
      'uid': uid,
      'd_id': dId,
      'request_id': requestId,
      'price': price,
    });
  }

  // ✅ MIGRATED CLEAR STATE FUNCTION
  void _clearGlobalState() {
    if (mounted) {
      try {
        context.read<LocationState>().clearLocationData();
        context.read<PricingState>().clearPricingData();
        context.read<RideRequestState>().clearRideRequest();
        context.read<MapState>().clearMapData();

        // Clear local variables
        vihicallocations.clear();
        _iconPaths.clear();
        _iconPathsbiddingon.clear();
        vihicallocationsbiddingon.clear();
        _dropOffPoints.clear();
        couponadd.clear();

        // Reset UI state
        isLoad = false;
        toast = 0;
        payment = 0;
        paymentname = "";
        selectedOption = "";
        selectBoring = "";
        couponAmt = 0;
        couponId = "";
        couponname = "";
        mainamount = "";

        setState(() {});
      } catch (e) {
        if (kDebugMode) print("❌ Clear state error: $e");
      }
    }
  }

  // ✅ BOTTOM SHEET FOR BOOKING
  void Buttonpresebottomshhet() {
    final locationState = context.read<LocationState>();
    final pricingState = context.read<PricingState>();

    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 450,
              decoration: BoxDecoration(
                color: notifier.containercolore,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Vehicle selection would go here
                    GetBuilder<HomeApiController>(
                      builder: (homeApiController) {
                        return homeApiController
                                    .homeapimodel?.categoryList?.isNotEmpty ==
                                true
                            ? Column(
                                children: [
                                  Text(
                                    "Select Vehicle",
                                    style: TextStyle(
                                      color: notifier.textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  // Vehicle list would be built here
                                  Container(
                                    height: 200,
                                    child: ListView.builder(
                                      itemCount: homeApiController
                                          .homeapimodel!.categoryList!.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          color: notifier.containercolore,
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                "${Config.imageurl}${homeApiController.homeapimodel!.categoryList![index].image}",
                                              ),
                                            ),
                                            title: Text(
                                              homeApiController
                                                      .homeapimodel!
                                                      .categoryList![index]
                                                      .name ??
                                                  "",
                                              style: TextStyle(
                                                  color: notifier.textColor),
                                            ),
                                            subtitle: pricingState.dropPrice > 0
                                                ? Text(
                                                    "$globalcurrency${pricingState.dropPrice}",
                                                    style: TextStyle(
                                                        color: theamcolore),
                                                  )
                                                : null,
                                            onTap: () {
                                              // Handle vehicle selection
                                              setState(() {
                                                select1 = index;
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  CommonButton(
                                    containcolore: theamcolore,
                                    onPressed1: () {
                                      Get.back();
                                      _showPickupDropSheet(bidding: "1");
                                    },
                                    txt1: "CONTINUE".tr,
                                  ),
                                ],
                              )
                            : const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper functions (keep existing implementations)
  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future fun() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      if (kDebugMode) print("Location permission denied");
      return;
    }
    var currentLocation = await locateUser();
    debugPrint('location: ${currentLocation.latitude}');
    lathome = currentLocation.latitude;
    longhome = currentLocation.longitude;
    _onAddMarkerButtonPressed(
        currentLocation.latitude, currentLocation.longitude);
    getCurrentLatAndLong(currentLocation.latitude, currentLocation.longitude);
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void getCurrentLatAndLong(lat, long) async {
    try {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, long);
      if (placemark.isNotEmpty) {
        addresshome = "${placemark[0].street}, ${placemark[0].locality}";
      }
    } catch (e) {
      if (kDebugMode) print("❌ Geocoding error: $e");
      addresshome = "$lat, $long";
    }
  }

  void mapReady() {
    setState(() {});
  }

  void _addMarkers() async {
    final mapState = context.read<MapState>();
    final locationState = context.read<LocationState>();

    // Clear existing markers
    mapState.clearMapData();

    // Add pickup marker
    if (locationState.latitudePick != 0.0 &&
        locationState.longitudePick != 0.0) {
      _addMarker11(
        LatLng(locationState.latitudePick, locationState.longitudePick),
        "origin",
        BitmapDescriptor.defaultMarker,
      );
    }

    // Add drop marker
    if (locationState.latitudeDrop != 0.0 &&
        locationState.longitudeDrop != 0.0) {
      _addMarker2(
        LatLng(locationState.latitudeDrop, locationState.longitudeDrop),
        "destination",
        BitmapDescriptor.defaultMarkerWithHue(90),
      );
    }

    // Add multiple drop markers
    if (locationState.destinationLat.isNotEmpty) {
      _addMarker3("destination");
    }

    // Generate route if both pickup and drop exist
    if (locationState.latitudePick != 0.0 &&
        locationState.longitudePick != 0.0 &&
        locationState.latitudeDrop != 0.0 &&
        locationState.longitudeDrop != 0.0) {
      getDirections11(
        lat1: PointLatLng(
            locationState.latitudePick, locationState.longitudePick),
        lat2: PointLatLng(
            locationState.latitudeDrop, locationState.longitudeDrop),
        dropOffPoints: locationState.destinationLat,
      );
    }
  }

  void _updateVehicleMarkers() {
    setState(() {});
    vihicallocations.clear();
    _iconPaths.clear();

    if (homeMapController.homeMapApiModel?.list?.isNotEmpty == true) {
      for (int i = 0;
          i < homeMapController.homeMapApiModel!.list!.length;
          i++) {
        vihicallocations.add(LatLng(
            double.parse(homeMapController.homeMapApiModel!.list![i].latitude
                .toString()),
            double.parse(homeMapController.homeMapApiModel!.list![i].longitude
                .toString())));

        _iconPaths.add(
            "${Config.imageurl}${homeMapController.homeMapApiModel!.list![i].image}");
      }
      _loadMarkerIcons();
    }
  }

  void _loadMarkerIcons() async {
    List<BitmapDescriptor> icons = [];
    for (String path in _iconPaths) {
      BitmapDescriptor icon = await _loadIcon(path);
      icons.add(icon);
    }

    setState(() {
      for (int i = 0; i < vihicallocations.length; i++) {
        MarkerId markerId = MarkerId(
            'vehicle_${homeMapController.homeMapApiModel!.list![i].id}');
        final marker = Marker(
          markerId: markerId,
          position: vihicallocations[i],
          icon: icons[i],
        );
        context.read<MapState>().addMarker11(markerId, marker);
      }
    });
  }

  Future<BitmapDescriptor> _loadIcon(String url) async {
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
        final Uint8List resizedBytes = byteData!.buffer.asUint8List();
        return BitmapDescriptor.fromBytes(resizedBytes);
      } else {
        return BitmapDescriptor.defaultMarker;
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error loading marker icon: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  // Initialize app
  Future<void> _initializeApp() async {
    _clearGlobalState();

    try {
      await _loadUserData();

      if (useridgloable == null) {
        Get.offAll(() => const OnboardingScreen());
        return;
      }

      await _initializeLocation();
      await _initializeSocket();
      makeInitialAPICalls();
    } catch (e) {
      if (kDebugMode) print("❌ App initialization error: $e");
      if (e.toString().contains('userLogin')) {
        Get.offAll(() => const OnboardingScreen());
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var uid = preferences.getString("userLogin");
      var currencyy = preferences.getString("currenci");

      if (uid == null) throw Exception("No user data");

      decodeUid = jsonDecode(uid);
      if (currencyy != null) {
        currencyy = jsonDecode(currencyy);
      }

      useridgloable = decodeUid['id'];
      username = decodeUid["name"] ?? "";

      if (kDebugMode) print("✅ User data loaded: $useridgloable");
    } catch (e) {
      if (kDebugMode) print("❌ User data loading failed: $e");
      rethrow;
    }
  }

  Future<void> _initializeLocation() async {
    try {
      await fun();
      if (mounted) setState(() {});
      getCurrentLatAndLong(lathome, longhome);
    } catch (e) {
      if (kDebugMode) print("❌ Location initialization failed: $e");
    }
  }

  Future<void> _initializeSocket() async {
    if (_disposed) return;

    try {
      final socketService = SocketService.instance;
      socketService.initSocket();

      if (!socketService.isConnected) {
        socketService.connect();
      }

      await Future.delayed(const Duration(milliseconds: 500));
      _connectSocket();
      if (kDebugMode) print("✅ Socket connected from MapScreen");
    } catch (e) {
      if (kDebugMode) print("❌ Socket initialization failed: $e");
    }
  }

  void makeInitialAPICalls() {
    // Make necessary API calls
    homeApiController.homeApi(
      uid: useridgloable.toString(),
      lat: lathome?.toString() ?? "0", // FIXED: Added required lat parameter
      lon: longhome?.toString() ?? "0", // FIXED: Added required lon parameter
    );
    // Load map data
    if (lathome != null && longhome != null) {
      homeMapController
          .homemapApi(
              mid: mid, lat: lathome.toString(), lon: longhome.toString())
          .then((value) {
        if (value["Result"] != false) {
          _updateVehicleMarkers();
        }
      });
    }
  }

  // ✅ APP LIFECYCLE MANAGEMENT
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        if (kDebugMode) print("🔄 App resumed - reinitializing");
        if (!_disposed) {
          _initializeApp();
        }
        break;

      case AppLifecycleState.paused:
        if (kDebugMode) print("⏸️ App paused - cleaning up");
        _fullCleanup();
        break;

      case AppLifecycleState.detached:
        if (kDebugMode) print("🔄 App detached - full cleanup");
        _fullCleanup();
        break;
      default:
        break;
    }
  }

  void _fullCleanup() {
    try {
      if (SocketService.instance.isConnected) {
        if (kDebugMode)
          print("🔌 Disconnecting socket, but keeping instance alive.");
        SocketService.instance.disconnect();
      }

      _socketReconnectTimer?.cancel();
      _requestTimer?.cancel();
    } catch (e) {
      if (kDebugMode) print("❌ Cleanup error: $e");
    }
  }

  // Navigation helper with provider data
  void _navigateToHomeScreen() {
    final locationState = context.read<LocationState>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          latpic: locationState.latitudePick,
          longpic: locationState.longitudePick,
          latdrop: locationState.latitudeDrop,
          longdrop: locationState.longitudeDrop,
          destinationlat: locationState.destinationLat,
        ),
      ),
    );
  }

  // ✅ ADDITIONAL HELPER METHODS
  void socatloadbidinfdata() {
    if (homeApiController.homeapimodel?.runnigRide?.isNotEmpty == true) {
      setState(() {
        isLoad = true;
      });

      // Navigate to driver list or counter bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context) => CounterBottomSheet(),
      );
    }
  }

  // Handle vehicle selection and pricing
  void handleVehicleSelection(int index) {
    setState(() {
      select1 = index;
    });

    final locationState = context.read<LocationState>();

    if (locationState.pickupController.text.isNotEmpty &&
        locationState.dropController.text.isNotEmpty) {
      // Call pricing API
      calculateController
          .calculateApi(
        context: context,
        uid: useridgloable.toString(),
        mid: mid,
        mrole: mroal,
        pickup_lat_lon:
            "${locationState.latitudePick},${locationState.longitudePick}",
        drop_lat_lon:
            "${locationState.latitudeDrop},${locationState.longitudeDrop}",
        drop_lat_lon_list: locationState.onlyPass,
      )
          .then((value) {
        if (value != null && value["Result"] == true) {
          context.read<PricingState>().updatePricing(
                dropPrice:
                    double.tryParse(value["drop_price"].toString()) ?? 0.0,
                minimumFare:
                    double.tryParse(value["minimum_fare"].toString()) ?? 0.0,
                maximumFare:
                    double.tryParse(value["maximum_fare"].toString()) ?? 0.0,
                amountResponse: value["amount_response"]?.toString() ?? "",
                responseMessage: value["response_message"]?.toString() ?? "",
              );
        }
      });
    }
  }

  // Handle payment method selection
  void handlePaymentSelection(int paymentId, String paymentName) {
    setState(() {
      payment = paymentId;
      paymentname = paymentName;
    });
  }

  // Handle coupon application
  void applyCoupon(String couponCode) {
    setState(() {
      couponname = couponCode;
    });
  }

  // ✅ FLOATING ACTION BUTTONS (if needed)
  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          mini: true,
          backgroundColor: notifier.containercolore,
          heroTag: "current_location",
          onPressed: _getCurrentLocation,
          child: Icon(Icons.my_location, color: theamcolore),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // ✅ HANDLE BACK BUTTON
  Future<bool> _onWillPop() async {
    final locationState = context.read<LocationState>();

    if (locationState.pickupController.text.isNotEmpty ||
        locationState.dropController.text.isNotEmpty) {
      bool? shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: notifier.containercolore,
          title:
              Text("Clear Route?", style: TextStyle(color: notifier.textColor)),
          content: Text(
            "Are you sure you want to clear the current route?",
            style: TextStyle(color: notifier.textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _clearGlobalState();
                Navigator.pop(context, true);
              },
              child: Text("Clear", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      return shouldPop ?? false;
    }

    _clearGlobalState();
    Get.offAll(const OnboardingScreen());
    return false;
  }

  // ✅ ERROR HANDLING METHODS
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: notifier.containercolore,
        title: Text("Error", style: TextStyle(color: notifier.textColor)),
        content: Text(message, style: TextStyle(color: notifier.textColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _handleApiError(String error) {
    if (kDebugMode) print("❌ API Error: $error");
    showToastForDuration("Something went wrong. Please try again.", 3);
  }

  // ✅ ADDITIONAL BOTTOM SHEET METHODS
  void _showCouponBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 500,
              decoration: BoxDecoration(
                color: notifier.containercolore,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Apply Coupon",
                    style: TextStyle(
                      color: notifier.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Coupon input field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter coupon code",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          couponname = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CommonButton(
                      containcolore: theamcolore,
                      onPressed1: () {
                        if (couponname.isNotEmpty) {
                          applyCoupon(couponname);
                          Navigator.pop(context);
                        }
                      },
                      txt1: "Apply Coupon",
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentMethodBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          decoration: BoxDecoration(
            color: notifier.containercolore,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Select Payment Method",
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Payment methods list would go here
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.money, color: theamcolore),
                      title: Text("Cash",
                          style: TextStyle(color: notifier.textColor)),
                      trailing: payment == 1
                          ? Icon(Icons.check, color: theamcolore)
                          : null,
                      onTap: () {
                        handlePaymentSelection(1, "Cash");
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.credit_card, color: theamcolore),
                      title: Text("Card",
                          style: TextStyle(color: notifier.textColor)),
                      trailing: payment == 2
                          ? Icon(Icons.check, color: theamcolore)
                          : null,
                      onTap: () {
                        handlePaymentSelection(2, "Card");
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.account_balance_wallet,
                          color: theamcolore),
                      title: Text("Wallet",
                          style: TextStyle(color: notifier.textColor)),
                      trailing: payment == 3
                          ? Icon(Icons.check, color: theamcolore)
                          : null,
                      onTap: () {
                        handlePaymentSelection(3, "Wallet");
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ SEARCH FUNCTIONALITY
  void _performSearch(String query) {
    // Implement search functionality here
    if (query.isNotEmpty) {
      // Call places API or search API
      print("Searching for: $query");
    }
  }

  // ✅ CAMERA ANIMATION HELPERS
  void _animateToLocation(LatLng location) {
    final mapController = context.read<MapState>().mapController;
    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  void _fitToRoute() {
    final locationState = context.read<LocationState>();
    final mapController = context.read<MapState>().mapController;

    if (mapController != null &&
        locationState.latitudePick != 0.0 &&
        locationState.latitudeDrop != 0.0) {
      List<LatLng> points = [
        LatLng(locationState.latitudePick, locationState.longitudePick),
        LatLng(locationState.latitudeDrop, locationState.longitudeDrop),
      ];

      // Add additional drop points
      for (var point in locationState.destinationLat) {
        points.add(LatLng(point.latitude, point.longitude));
      }

      // Calculate bounds
      double minLat =
          points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
      double maxLat =
          points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
      double minLng =
          points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
      double maxLng =
          points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          100.0, // padding
        ),
      );
    }
  }

  // ✅ LOADING STATES
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: notifier.containercolore,
        content: Row(
          children: [
            CircularProgressIndicator(color: theamcolore),
            const SizedBox(width: 20),
            Text(message, style: TextStyle(color: notifier.textColor)),
          ],
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // ✅ ADDITIONAL VEHICLE FUNCTIONS
  void _handleVehicleMarkerTap(String vehicleId) {
    // Handle vehicle marker tap
    print("Vehicle tapped: $vehicleId");

    // Show vehicle info bottom sheet or navigate to details
    _showVehicleDetailsBottomSheet(vehicleId);
  }

  void _showVehicleDetailsBottomSheet(String vehicleId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: notifier.containercolore,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Vehicle Details",
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Vehicle details would be displayed here
          ],
        ),
      ),
    );
  }

  // ✅ FINAL DISPOSE METHOD
  @override
  void dispose() {
    if (kDebugMode) print("🧹 Starting map screen disposal");
    _disposed = true;

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Cancel all timers
    _requestTimer?.cancel();
    _socketReconnectTimer?.cancel();

    // Dispose controllers
    controller.dispose();
    amountcontroller.dispose();
    _focusNode.dispose();

    // Cancel subscription
    _appStateSubscription?.cancel();

    // Clean up socket listeners
    try {
      SocketService.instance.off('Vehicle_Bidding$useridgloable');
      SocketService.instance.off('V_Driver_Location$useridgloable');
      SocketService.instance.off('Calculate_Result$useridgloable');
      SocketService.instance.off('RequestTimeOut$useridgloable');
      SocketService.instance.off('Accept_Driver$useridgloable');
    } catch (e) {
      if (kDebugMode) print("❌ Socket cleanup error: $e");
    }

    // Full cleanup
    _fullCleanup();

    super.dispose();
    if (kDebugMode) print("✅ Map screen disposal complete");
  }
}
