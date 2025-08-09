// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/api_code/global_driver_access_api_controller.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/common_code/socket_service.dart';
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/map_state.dart';
import 'package:qareeb/providers/pricing_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/common_code/common_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api_code/add_vehical_api_controller.dart';
import '../api_code/driver_detail_api.dart';
import '../api_code/vihical_calculate_api_controller.dart';
import '../api_code/vihical_driver_detail_api_controller.dart';
import '../common_code/common_flow_screen.dart';
import '../common_code/config.dart';
import '../timer_screen.dart';
import 'home_screen.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import '../common_code/colore_screen.dart';
import 'map_screen.dart';
import 'my_ride_screen.dart';

class DriverStartRideScreen extends StatefulWidget {
  final double lat;
  final double long;
  final String driverId;
  final String requestId;

  const DriverStartRideScreen({
    super.key,
    required this.lat,
    required this.long,
    required this.driverId,
    required this.requestId,
  });

  @override
  State<DriverStartRideScreen> createState() => _DriverStartRideScreenState();
}

class _DriverStartRideScreenState extends State<DriverStartRideScreen> {
  // ✅ MIGRATED - Use GetX controllers as before
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());
  DriverDetailApiController driverDetailApiController =
      Get.put(DriverDetailApiController());
  VihicalDriverDetailApiController vihicalDriverDetailApiController =
      Get.put(VihicalDriverDetailApiController());
  VihicalCalculateController vihicalCalculateApiController =
      Get.put(VihicalCalculateController());
  AddVihicalCalculateController addVihicalCalculateController =
      Get.put(AddVihicalCalculateController());

  // ✅ MIGRATED - Map functionality now uses provider
  PolylinePoints polylinePoints = PolylinePoints();
  GoogleMapController? mapController;

  // ✅ KEEP - UI state variables
  ColorNotifier notifier = ColorNotifier();
  var decodeUid;
  var userid;
  var currencyy; // ✅ ADDED - Missing currency variable
  bool isLoad = false;
  String imagenetwork = "";
  String themeForMap = "";
  double livelat = 0.0;
  double livelong = 0.0;

  // ✅ KEEP - Drop location data
  List<dynamic> listdrop = [];
  List<PointLatLng> droppointstartscreen = [];

  @override
  void initState() {
    super.initState();
    getdatafromserver(); // ✅ ADDED - Load user data including currency
    socketConnect();
    mapThemeStyle(context: context);

    if (kDebugMode) {
      print("================imagenetwork: ${imagenetwork}");
      print("================livelat: ${livelat}");
      print("================livelong: ${livelong}");
    }

    // Initialize with current driver location if available
    if (livelat != 0.0 && livelong != 0.0) {
      updatemarker(LatLng(livelat, livelong), "origin", imagenetwork);
    }
  }

  // ✅ ADDED - Load user data method
  getdatafromserver() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userLoginString = prefs.getString("userLogin");
    var currencyString = prefs.getString("currenci");

    if (userLoginString != null) {
      setState(() {
        userid = jsonDecode(userLoginString);
      });
    }

    if (currencyString != null) {
      currencyy = jsonDecode(currencyString);
    }
  }

  @override
  void dispose() {
    SocketService.instance.disconnect();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    if (themeForMap.isNotEmpty) {
      await mapController?.setMapStyle(themeForMap);
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

  Future<Uint8List> getNetworkImage(String url) async {
    try {
      final response = await NetworkAssetBundle(Uri.parse(url)).load("");
      return response.buffer.asUint8List();
    } catch (e) {
      if (kDebugMode) print("❌ Error loading network image: $e");
      return await getImages("assets/pickup_marker.png", 80);
    }
  }

  // ✅ MIGRATED - Use MapState provider instead of local markers
  void _addMarker(
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
                      children: [
                        // Display drop location details if available
                        if (listdrop.isNotEmpty)
                          for (int a = 0; a < listdrop.length; a++)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${listdrop[a]["title"] ?? "Drop Location"}",
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "${listdrop[a]["subtitle"] ?? ""}",
                                  maxLines: 3,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 5),
                              ],
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

    // ✅ MIGRATED - Use MapState provider
    context.read<MapState>().addMarker(markerId, marker);
  }

  // ✅ MIGRATED - Add destination markers for drop locations
  void _addMarker3(String id) async {
    if (droppointstartscreen.isEmpty) return;

    for (int i = 0; i < droppointstartscreen.length; i++) {
      final dropPoint = droppointstartscreen[i];
      final Uint8List markIcon = await getImages("assets/drop_marker.png", 80);
      MarkerId markerId = MarkerId("${id}_$i");

      Marker marker = Marker(
        markerId: markerId,
        icon: BitmapDescriptor.fromBytes(markIcon),
        position: LatLng(dropPoint.latitude, dropPoint.longitude),
        onTap: () {
          // Show drop location details
          if (i < listdrop.length) {
            showDialog(
              barrierColor: Colors.transparent,
              context: context,
              builder: (context) {
                return Dialog(
                  alignment: const Alignment(0, -0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${listdrop[i]["title"] ?? "Drop Location ${i + 1}"}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${listdrop[i]["subtitle"] ?? "Drop location details"}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      );

      // ✅ MIGRATED - Use MapState provider
      context.read<MapState>().addMarker(markerId, marker);
    }
  }

  // ✅ MIGRATED - Use MapState provider for marker updates
  void updatemarker(LatLng position, String id, String imageUrl) async {
    final Uint8List markIcon = await getNetworkImage(imageUrl);
    MarkerId markerId = MarkerId(id);

    // ✅ MIGRATED - Use MapState provider
    final mapState = context.read<MapState>();

    if (mapState.markers.containsKey(markerId)) {
      // Update existing marker position
      mapState.updateMarkerPosition(markerId, position);
    } else {
      // Create new marker
      Marker marker = Marker(
        markerId: markerId,
        icon: BitmapDescriptor.fromBytes(markIcon),
        position: position,
      );
      mapState.addMarker(markerId, marker);
    }

    setState(() {});
  }

  // ✅ MIGRATED - Use MapState provider for polylines
  void addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: theamcolore,
      points: polylineCoordinates,
      width: 3,
    );

    // ✅ MIGRATED - Use MapState provider
    context.read<MapState>().addPolyline(id, polyline);
  }

  Future getDirections({
    required PointLatLng lat1,
    required List<PointLatLng> dropOffPoints,
  }) async {
    List<LatLng> polylineCoordinates = [];
    List<PointLatLng> allPoints = [lat1, ...dropOffPoints];

    for (int i = 0; i < allPoints.length - 1; i++) {
      PointLatLng point1 = allPoints[i];
      PointLatLng point2 = allPoints[i + 1];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
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
        if (kDebugMode)
          print("❌ No route found between points $i and ${i + 1}");
      }
    }

    addPolyLine(polylineCoordinates);
  }

  // ✅ MIGRATED - Use SocketService.instance instead of direct socket
  socketConnect() async {
    setState(() {});

    try {
      SocketService.instance.connect();
      _connectSocket();
    } catch (e) {
      if (kDebugMode) print("❌ Socket connection error: $e");
    }
  }

  // ✅ MIGRATED - Socket event handlers using SocketService.instance
  _connectSocket() async {
    setState(() {});

    final socketService = SocketService.instance;

    if (kDebugMode) print('✅ Setting up socket connection - DriverStartRide');

    if (kDebugMode) print("🔍 Listening for ride updates: ${useridgloable}");

    // ✅ MIGRATED - Use SocketService.instance.on instead of socket.on
    socketService.on('V_Driver_Location$useridgloable', (V_Driver_Location) {
      _handleDriverLocation(V_Driver_Location);
    });

    socketService.on('drop_location$useridgloable', (drop_location) {
      _handleDropLocation(drop_location);
    });

    socketService.on('ride_started$useridgloable', (ride_started) {
      _handleRideStarted(ride_started);
    });

    socketService.on('ride_completed$useridgloable', (ride_completed) {
      _handleRideCompleted(ride_completed);
    });

    socketService.on('payment_request$useridgloable', (payment_request) {
      _handlePaymentRequest(payment_request);
    });
  }

  // ✅ NEW - Organized event handlers
  void _handleDriverLocation(dynamic V_Driver_Location) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        print("++++++ /V_Driver_Location/ ++++ :---  $V_Driver_Location");
        print("V_Driver_Location is of type: ${V_Driver_Location.runtimeType}");
      }

      if (driver_id == V_Driver_Location["d_id"].toString()) {
        if (kDebugMode) print("✅ Driver location match - updating");

        livelat =
            double.parse(V_Driver_Location["driver_location"]["latitude"]);
        livelong =
            double.parse(V_Driver_Location["driver_location"]["longitude"]);

        if (V_Driver_Location["driver_location"]["image"] != null) {
          imagenetwork =
              "${Config.imageurl}${V_Driver_Location["driver_location"]["image"]}";
        }

        if (kDebugMode) {
          print("****livelat****:-- ${livelat}");
          print("****livelong****:-- ${livelong}");
        }

        updatemarker(LatLng(livelat, livelong), "origin", imagenetwork);

        // Update directions if we have drop points
        if (droppointstartscreen.isNotEmpty) {
          getDirections(
            lat1: PointLatLng(livelat, livelong),
            dropOffPoints: droppointstartscreen,
          );
        }
      } else {
        if (kDebugMode) {
          print("❌ Driver ID mismatch:");
          print("Expected: (${driver_id})");
          print("Received: (${V_Driver_Location["d_id"]})");
        }
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling driver location: $e");
    }
  }

  void _handleDropLocation(dynamic drop_location) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        print("++++++ /drop_location_list/ ++++ :---  $drop_location");
      }

      livelat = double.parse(drop_location["driver_location"]["latitude"]);
      livelong = double.parse(drop_location["driver_location"]["longitude"]);
      imagenetwork =
          "${Config.imageurl}${drop_location["driver_location"]["image"]}";

      listdrop = [];
      listdrop = drop_location["drop_list"];
      droppointstartscreen.clear();

      for (int i = 0; i < listdrop.length; i++) {
        droppointstartscreen.add(PointLatLng(
            double.parse(drop_location["drop_list"][i]["latitude"]),
            double.parse(drop_location["drop_list"][i]["longitude"])));
      }

      updatemarker(LatLng(livelat, livelong), "origin", imagenetwork);

      // Add destination markers for all drop points
      _addMarker3("destination");

      getDirections(
          lat1: PointLatLng(livelat, livelong),
          dropOffPoints: droppointstartscreen);

      if (kDebugMode) {
        print("==========:--- ${droppointstartscreen}");
        print("=====length=====:--- ${droppointstartscreen.length}");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling drop location: $e");
    }
  }

  void _handleRideStarted(dynamic ride_started) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        print("++++++ /ride_started/ ++++ :---  $ride_started");
      }

      if (ride_started["c_id"] == useridgloable.toString()) {
        if (kDebugMode) print("✅ Ride started confirmed");

        // Update ride status
        globalDriverAcceptClass.setRideStarted(true);

        // Show ride started notification
        Get.snackbar(
          "Ride Started".tr,
          "Your ride has started. Enjoy your journey!".tr,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling ride started: $e");
    }
  }

  void _handleRideCompleted(dynamic ride_completed) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        print("++++++ /ride_completed/ ++++ :---  $ride_completed");
      }

      if (ride_completed["c_id"] == useridgloable.toString()) {
        if (kDebugMode) print("✅ Ride completed confirmed");

        // Update ride status
        globalDriverAcceptClass.setRideCompleted(true);

        // Navigate to payment or rating screen
        Get.snackbar(
          "Ride Completed".tr,
          "Your ride has been completed successfully!".tr,
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white,
        );

        // Navigate back to home after delay
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAll(() => HomeScreen(
                latpic: context.read<LocationState>().latitudePick,
                longpic: context.read<LocationState>().longitudePick,
                latdrop: context.read<LocationState>().latitudeDrop,
                longdrop: context.read<LocationState>().longitudeDrop,
                destinationlat: context.read<LocationState>().destinationLat,
              ));
        });
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling ride completed: $e");
    }
  }

  void _handlePaymentRequest(dynamic payment_request) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        print("++++++ /payment_request/ ++++ :---  $payment_request");
      }

      if (payment_request["c_id"] == useridgloable.toString()) {
        if (kDebugMode) print("✅ Payment request received");

        // Show payment dialog or navigate to payment screen
        _showPaymentDialog(payment_request);
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling payment request: $e");
    }
  }

  void _showPaymentDialog(dynamic paymentData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Payment Required".tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Please proceed with payment for your ride.".tr),
              const SizedBox(height: 10),
              if (paymentData["amount"] != null)
                Text(
                  "Amount: ${paymentData["amount"]} ${currencyy ?? "SAR"}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to payment screen
                // Get.to(() => PaymentScreen(paymentData: paymentData));
              },
              child: Text("Pay Now".tr),
            ),
          ],
        );
      },
    );
  }

  mapThemeStyle({required BuildContext context}) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    // ✅ MIGRATED - Wrap with Consumers for provider data
    return Consumer3<LocationState, MapState, RideRequestState>(
      builder: (context, locationState, mapState, rideRequestState, child) {
        return Scaffold(
          backgroundColor: notifier.backgroundgrey,
          body: SizedBox(
            height: Get.height,
            width: Get.width,
            child: Stack(
              children: [
                // ✅ MIGRATED - Use mapState.markers and mapState.polylines
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.lat, widget.long),
                    zoom: 14.0,
                  ),
                  markers: Set<Marker>.from(mapState.markers.values),
                  polylines: Set<Polyline>.from(mapState.polylines.values),
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  buildingsEnabled: false,
                  indoorViewEnabled: false,
                  compassEnabled: false,
                  style: themeForMap.isNotEmpty ? themeForMap : null,
                ),

                // ✅ KEEP - UI Elements remain the same
                Positioned(
                  top: 60,
                  left: 20,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // ✅ KEEP - Bottom sheet UI for ride progress
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: notifier.containercolore,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ride status
                          Row(
                            children: [
                              Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                  color: globalDriverAcceptClass.is_ride_started
                                      ? Colors.green
                                      : Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  globalDriverAcceptClass.is_ride_started
                                      ? "Ride in Progress".tr
                                      : "Driver is arriving".tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: notifier.textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // Driver info section
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: notifier.backgroundgrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Driver image
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: imagenetwork.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(imagenetwork),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: imagenetwork.isEmpty
                                        ? Colors.grey
                                        : null,
                                  ),
                                  child: imagenetwork.isEmpty
                                      ? const Icon(Icons.person,
                                          color: Colors.white)
                                      : null,
                                ),

                                const SizedBox(width: 15),

                                // Driver details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        globalDriverAcceptClass
                                                .driver_name.isNotEmpty
                                            ? globalDriverAcceptClass
                                                .driver_name
                                            : "Driver",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: notifier.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        "${globalDriverAcceptClass.vehicle_type} • ${globalDriverAcceptClass.vehicle_number}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: notifier.textColor
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Call button
                                InkWell(
                                  onTap: () {
                                    if (globalDriverAcceptClass
                                        .driver_phone.isNotEmpty) {
                                      _makePhoneCall(
                                          globalDriverAcceptClass.driver_phone);
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.call,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Drop locations list
                          if (listdrop.isNotEmpty) ...[
                            Text(
                              "Drop Locations".tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: notifier.textColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 150),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: listdrop.length,
                                itemBuilder: (context, index) {
                                  final drop = listdrop[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: notifier.backgroundgrey,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 8,
                                          width: 8,
                                          decoration: BoxDecoration(
                                            color: theamcolore,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${drop["title"] ?? "Drop Location ${index + 1}"}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: notifier.textColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (drop["subtitle"] != null) ...[
                                                const SizedBox(height: 3),
                                                Text(
                                                  "${drop["subtitle"]}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: notifier.textColor
                                                        .withOpacity(0.6),
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],

                          // Emergency button
                          InkWell(
                            onTap: () {
                              _showEmergencyDialog();
                            },
                            child: Container(
                              height: 50,
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  "Emergency".tr,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ KEEP - Helper methods
  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Emergency".tr),
          content: Text("Do you need emergency assistance?".tr),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel".tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _makePhoneCall("911"); // Emergency number
              },
              child: Text("Call Emergency".tr),
            ),
          ],
        );
      },
    );
  }
}
