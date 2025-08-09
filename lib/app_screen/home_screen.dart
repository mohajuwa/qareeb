// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/api_code/global_driver_access_api_controller.dart';
import 'package:qareeb/api_code/vihical_calculate_api_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/common_code/socket_service.dart';
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/map_state.dart';
import 'package:qareeb/providers/pricing_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';
import 'package:qareeb/app_screen/driver_list_screen.dart';
import 'package:qareeb/app_screen/map_screen.dart';
import 'package:qareeb/common_code/common_button.dart';
import 'package:qareeb/common_code/config.dart';
import '../api_code/add_vehical_api_controller.dart';
import '../api_code/calculate_api_controller.dart';
import '../api_code/modual_calculate_api_controller.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_flow_screen.dart';

// Global variables for this screen
int midseconde = 0;
int select = -1;
double vihicalrice = 0.00;
double totalkm = 0.00;
String tot_time = "";
String tot_hour = "";
String tot_secound = "";
String vihicalname = "";
String vihicalimage = "";
String vehicle_id = "";
String extratime = "";
String timeincressstatus = "";
bool loadertimer = false;
bool otpstatus = false;

class HomeScreen extends StatefulWidget {
  final double latpic;
  final double longpic;
  final double latdrop;
  final double longdrop;
  final List<PointLatLng> destinationlat;

  const HomeScreen({
    super.key,
    required this.latpic,
    required this.longpic,
    required this.latdrop,
    required this.longdrop,
    required this.destinationlat,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  GoogleMapController? mapController;
  ColorNotifier notifier = ColorNotifier();

  // API Controllers
  VihicalCalculateController vihicalCalculateController =
      Get.put(VihicalCalculateController());
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());
  Modual_CalculateController modual_calculateController =
      Get.put(Modual_CalculateController());

  // Local state variables
  List<PointLatLng> _dropOffPoints = [];
  List<LatLng> vihicallocationsbiddingoff = [];
  List<String> _iconPathsbiddingoff = [];
  String themeForMap = "";
  bool socketInitialized = false;
  Timer? _locationUpdateTimer;

  // UI state
  bool switchValue = false;
  int payment = 0;
  String paymentname = "";
  String selectedOption = "";
  String selectBoring = "";
  String mainamount = "";
  int couponAmt = 0;
  String couponId = "";
  List<bool> couponadd = [];
  String couponname = "";

  // User data
  var decodeUid;
  var userid;
  var currencyy;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    socketConnect();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  void _initializeScreen() {
    // Set drop off points from widget
    _dropOffPoints = widget.destinationlat;

    // Initialize provider data with passed parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationState = context.read<LocationState>();
      locationState.setPickupLocation(
          widget.latpic, widget.longpic, "Pickup Location", "");
      locationState.setDropLocation(
          widget.latdrop, widget.longdrop, "Drop Location", "");

      _generateRoute();
      _addPickupDropMarkers();
    });

    mapThemeStyle();
  }

  void _cleanupResources() {
    _locationUpdateTimer?.cancel();

    // Cleanup socket listeners
    SocketService.instance.off('Vehicle_Bidding$useridgloable');
    SocketService.instance.off('V_Driver_Location$useridgloable');
    SocketService.instance.off('RequestTimeOut$useridgloable');
  }

  mapThemeStyle() {
    final theme = darkMode == true ? "dark_style.json" : "light_style.json";
    DefaultAssetBundle.of(context)
        .loadString("assets/map_styles/$theme")
        .then((value) {
      if (mounted) {
        setState(() {
          themeForMap = value;
        });
      }
    });
  }

  socketConnect() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var uid = preferences.getString("userLogin");
      var currency = preferences.getString("currenci");

      if (uid != null && currency != null) {
        decodeUid = jsonDecode(uid);
        currencyy = jsonDecode(currency);
        useridgloable = decodeUid['id'];

        if (kDebugMode) {
          print("****home screen*****:--- ($useridgloable)");
          print("*********:--- ($currencyy)");
        }

        if (mounted) setState(() {});

        SocketService.instance.connect();
        _connectSocket();
        _loadVehicleData();
      }
    } catch (e) {
      if (kDebugMode) print("❌ Socket connection error: $e");
    }
  }

  _connectSocket() {
    final socketService = SocketService.instance;

    // Vehicle bidding updates
    socketService.on('Vehicle_Bidding$useridgloable', (vehicleBidding) {
      _handleVehicleBidding(vehicleBidding);
    });

    // Driver location updates
    socketService.on('V_Driver_Location$useridgloable', (driverLocation) {
      _handleDriverLocation(driverLocation);
    });

    // Request timeout
    socketService.on('RequestTimeOut$useridgloable', (requestTimeout) {
      _handleRequestTimeout(requestTimeout);
    });

    if (kDebugMode) print("✅ Socket listeners setup complete for HomeScreen");
  }

  void _handleVehicleBidding(dynamic vehicleBidding) {
    if (!mounted) return;

    try {
      if (vehicleBidding != null) {
        // Update the global driver class instead of provider
        globalDriverAcceptClass.updateFromSocketData(vehicleBidding);

        // Navigate to driver list if we have bidding drivers
        if (globalDriverAcceptClass.vehicleBiddingDriver.isNotEmpty) {
          Get.to(() => const DriverListScreen());
        }
      }
    } catch (e) {
      if (kDebugMode) print("❌ Vehicle bidding handler error: $e");
    }
  }

  void _handleDriverLocation(dynamic driverLocation) {
    if (!mounted) return;

    try {
      if (driverLocation != null &&
          driverLocation['latitude'] != null &&
          driverLocation['longitude'] != null) {
        double lat = double.parse(driverLocation['latitude'].toString());
        double lng = double.parse(driverLocation['longitude'].toString());
        String driverId = driverLocation['driver_id'].toString();

        context.read<MapState>().updateMarkerPosition(
            MarkerId("driver_$driverId"), LatLng(lat, lng));
      }
    } catch (e) {
      if (kDebugMode) print("❌ Driver location handler error: $e");
    }
  }

  void _handleRequestTimeout(dynamic requestTimeout) {
    if (!mounted) return;

    try {
      if (requestTimeout != null) {
        context.read<RideRequestState>().handleTimeout(requestTimeout);
        _showTimeoutDialog();
      }
    } catch (e) {
      if (kDebugMode) print("❌ Request timeout handler error: $e");
    }
  }

  void _showTimeoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text("Request Timeout".tr),
        content:
            Text("No drivers responded to your request. Please try again.".tr),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // Go back to map screen
            },
            child: Text("OK".tr),
          ),
        ],
      ),
    );
  }

  void _loadVehicleData() {
    final locationState = context.read<LocationState>();

    if (kDebugMode) {
      print("*********midsecounde*********:--  ($midseconde)");
      print("*********vihicalrice*********:--  ($vihicalrice)");
    }

    vihicalCalculateController
        .vihicalcalculateApi(
      uid: useridgloable.toString(),
      mid: "$midseconde",
      pickup_lat_lon:
          "${locationState.latitudePick},${locationState.longitudePick}",
      drop_lat_lon:
          "${locationState.latitudeDrop},${locationState.longitudeDrop}",
      drop_lat_lon_list: locationState.onlyPass,
    )
        .then((value) {
      if (value != null) {
        if (kDebugMode) print("-----------------:--- $value");
        _processVehicleData();
      }
    });
  }

  void _processVehicleData() {
    if (vihicalCalculateController.vihicalCalculateModel?.caldriver != null) {
      vihicallocationsbiddingoff.clear();
      _iconPathsbiddingoff.clear();

      for (int i = 0;
          i <
              vihicalCalculateController
                  .vihicalCalculateModel!.caldriver!.length;
          i++) {
        final driver =
            vihicalCalculateController.vihicalCalculateModel!.caldriver![i];

        if (driver.latitude != null && driver.longitude != null) {
          vihicallocationsbiddingoff.add(LatLng(
            double.parse(driver.latitude!),
            double.parse(driver.longitude!),
          ));

          _iconPathsbiddingoff.add(driver.image ?? "assets/default_driver.png");
        }
      }

      _updateVehicleMarkers();
    }
  }

  Future<void> _updateVehicleMarkers() async {
    final mapState = context.read<MapState>();

    // Load custom icons for vehicles
    final List<BitmapDescriptor> icons = await Future.wait(
      _iconPathsbiddingoff.map((path) => _loadIcon(path)),
    );

    // Clear existing markers and add new ones
    mapState.clearMapData();

    // Add pickup and drop markers
    _addPickupDropMarkers();

    // Add vehicle markers
    for (var i = 0; i < vihicallocationsbiddingoff.length; i++) {
      final markerId = MarkerId('vehicle_$i');
      final marker = Marker(
        markerId: markerId,
        position: vihicallocationsbiddingoff[i],
        icon: i < icons.length ? icons[i] : BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: "Available Vehicle".tr,
          snippet: "Tap to request".tr,
        ),
      );
      mapState.addMarker(markerId, marker);
    }

    if (mounted) setState(() {});
  }

  Future<BitmapDescriptor> _loadIcon(String url) async {
    try {
      if (url.startsWith('http')) {
        // Network image
        final imageBytes = await NetworkAssetBundle(Uri.parse(url)).load('');
        final codec = await ui.instantiateImageCodec(
          imageBytes.buffer.asUint8List(),
          targetWidth: 80,
          targetHeight: 80,
        );
        final frameInfo = await codec.getNextFrame();
        final byteData =
            await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
        return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
      } else {
        // Asset image
        final byteData = await rootBundle.load(url);
        final imageBytes = byteData.buffer.asUint8List();
        return BitmapDescriptor.fromBytes(imageBytes);
      }
    } catch (e) {
      if (kDebugMode) print("Error loading icon from $url: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  void _generateRoute() async {
    final locationState = context.read<LocationState>();
    final mapState = context.read<MapState>();

    try {
      PolylinePoints polylinePoints = PolylinePoints();

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Config.mapkey,
        PointLatLng(locationState.latitudePick, locationState.longitudePick),
        PointLatLng(locationState.latitudeDrop, locationState.longitudeDrop),
        wayPoints: _dropOffPoints
            .map((point) => PolylineWayPoint(
                  location: "${point.latitude},${point.longitude}",
                ))
            .toList(),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        Polyline polyline = Polyline(
          polylineId: const PolylineId("route"),
          color: theamcolore,
          points: polylineCoordinates,
          width: 4,
        );

        mapState.addPolyline(const PolylineId("route"), polyline);
      }
    } catch (e) {
      if (kDebugMode) print("❌ Route generation error: $e");
    }
  }

  void _addPickupDropMarkers() {
    final locationState = context.read<LocationState>();
    final mapState = context.read<MapState>();

    // Add pickup marker
    Marker pickupMarker = Marker(
      markerId: const MarkerId("pickup"),
      position: LatLng(locationState.latitudePick, locationState.longitudePick),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: "Pickup".tr,
        snippet: locationState.pickupController.text,
      ),
    );

    // Add drop marker
    Marker dropMarker = Marker(
      markerId: const MarkerId("drop"),
      position: LatLng(locationState.latitudeDrop, locationState.longitudeDrop),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: "Drop".tr,
        snippet: locationState.dropController.text,
      ),
    );

    mapState.addMarker(const MarkerId("pickup"), pickupMarker);
    mapState.addMarker(const MarkerId("drop"), dropMarker);

    // Add waypoint markers if any
    for (int i = 0; i < _dropOffPoints.length; i++) {
      Marker waypointMarker = Marker(
        markerId: MarkerId("waypoint_$i"),
        position:
            LatLng(_dropOffPoints[i].latitude, _dropOffPoints[i].longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
          title: "Waypoint ${i + 1}".tr,
        ),
      );
      mapState.addMarker(MarkerId("waypoint_$i"), waypointMarker);
    }
  }

  void _requestRide() {
    final locationState = context.read<LocationState>();
    final pricingState = context.read<PricingState>();

    if (select == -1) {
      Get.snackbar(
        "Error".tr,
        "Please select a vehicle type".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Emit vehicle request through socket
    SocketService.instance.emit('vehiclerequest', {
      'request_id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user_id': useridgloable,
      'pickup_lat': locationState.latitudePick,
      'pickup_lng': locationState.longitudePick,
      'drop_lat': locationState.latitudeDrop,
      'drop_lng': locationState.longitudeDrop,
      'waypoints': _dropOffPoints
          .map((point) => {
                'lat': point.latitude,
                'lng': point.longitude,
              })
          .toList(),
      'vehicle_type': select,
      'estimated_fare': vihicalrice,
    });

    if (kDebugMode) print("🚗 Vehicle request sent");
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    return Consumer4<LocationState, MapState, PricingState, RideRequestState>(
      builder:
          (context, locationState, mapState, pricingState, rideState, child) {
        return WillPopScope(
          onWillPop: () async {
            return await Get.offAll(const ModernMapScreen(selectVehicle: true));
          },
          child: Scaffold(
            extendBody: true,
            backgroundColor: notifier.background,
            bottomNavigationBar: GetBuilder<Modual_CalculateController>(
              builder: (modual_calculateController) {
                return modual_calculateController.isLoading
                    ? Container(
                        height: 100,
                        color: notifier.containercolore,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: notifier.containercolore,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
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
                            // Vehicle selection list
                            if (modual_calculateController
                                    .modualCalculateApiModel?.caldriver !=
                                null)
                              Container(
                                height: 200,
                                padding: const EdgeInsets.all(15),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: modual_calculateController
                                      .modualCalculateApiModel!
                                      .caldriver!
                                      .length,
                                  itemBuilder: (context, index) {
                                    final vehicle = modual_calculateController
                                        .modualCalculateApiModel!
                                        .caldriver![index];
                                    final isSelected = select == index;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          select = index;
                                          vihicalrice =
                                              vehicle.dropPrice?.toDouble() ??
                                                  0.0;
                                          vihicalname = vehicle.name ?? "";
                                          vehicle_id =
                                              vehicle.id?.toString() ?? "";
                                        });
                                      },
                                      child: Container(
                                        width: 120,
                                        margin:
                                            const EdgeInsets.only(right: 15),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? theamcolore.withOpacity(0.1)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color: isSelected
                                                ? theamcolore
                                                : Colors.grey.withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Vehicle image
                                            Container(
                                              height: 60,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.grey[100],
                                              ),
                                              child: vehicle.mapImg != null
                                                  ? Image.network(
                                                      "${Config.imageurl}${vehicle.mapImg}",
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const Icon(
                                                            Icons
                                                                .directions_car,
                                                            size: 40);
                                                      },
                                                    )
                                                  : const Icon(
                                                      Icons.directions_car,
                                                      size: 40),
                                            ),

                                            const SizedBox(height: 10),

                                            // Vehicle name
                                            Text(
                                              vehicle.name ?? "Vehicle",
                                              style: TextStyle(
                                                color: notifier.textColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                            const SizedBox(height: 5),

                                            // Price
                                            Text(
                                              "$currencyy${vehicle.dropPrice ?? 0}",
                                              style: TextStyle(
                                                color: theamcolore,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            // Capacity
                                            if (vehicle.passengerCapacity !=
                                                null)
                                              Text(
                                                "${vehicle.passengerCapacity} seats"
                                                    .tr,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                            // Action buttons
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CommonOutLineButton(
                                      bordercolore: Colors.grey,
                                      onPressed1: () {
                                        Get.back();
                                      },
                                      context: context,
                                      txt1: "Back".tr,
                                      clore: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: CommonButton(
                                      containcolore: theamcolore,
                                      onPressed1: () {
                                        _requestRide();
                                      },
                                      context: context,
                                      txt1: "Request Ride".tr,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
              },
            ),
            body: Column(
              children: [
                // Header with location info
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: theamcolore,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Select Vehicle".tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Choose your preferred ride".tr,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Map view
                Expanded(
                  child: Consumer<MapState>(
                    builder: (context, mapState, child) {
                      return GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          mapController = controller;
                          if (themeForMap.isNotEmpty) {
                            controller.setMapStyle(themeForMap);
                          }
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(widget.latpic, widget.longpic),
                          zoom: 14.0,
                        ),
                        markers: Set<Marker>.from(mapState.markers.values),
                        polylines:
                            Set<Polyline>.from(mapState.polylines.values),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
