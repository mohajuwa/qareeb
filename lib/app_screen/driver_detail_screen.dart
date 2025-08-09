// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qareeb/api_code/global_driver_access_api_controller.dart';
import 'package:qareeb/common_code/toastification.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/common_code/socket_service.dart';
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/map_state.dart';
import 'package:qareeb/providers/pricing_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';
import 'package:qareeb/chat_code/chat_screen.dart';
import 'package:qareeb/common_code/common_button.dart';
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

class DriverDetailScreen extends StatefulWidget {
  final double lat;
  final double long;

  const DriverDetailScreen({super.key, required this.lat, required this.long});

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
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
  var prefrence = [];
  var language = [];
  bool isLoad = false;
  String imagenetwork = "";
  String picktitle = "";
  String pickSubTitle = "";
  double livelat = 0.0;
  double livelong = 0.0;
  var tot_time = "";
  var extratime = "";
  var tot_secound = "";

  @override
  void initState() {
    super.initState();
    getdatafromserver();
    socketConnect();
  }

  @override
  void dispose() {
    SocketService.instance.disconnect();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
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
    // Implementation for network image loading
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
                        Text(
                          "${picktitle == "" ? "تسجيل الموقع بنجاح" : picktitle}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${pickSubTitle}",
                          maxLines: 3,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
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

    // ✅ MIGRATED - Use MapState provider
    context.read<MapState>().addMarker(markerId, marker);
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

  Future getDirections(
      {required PointLatLng lat1, required PointLatLng lat2}) async {
    List<LatLng> polylineCoordinates = [];
    List<PointLatLng> allPoints = [lat1, lat2];

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
        if (kDebugMode) print("❌ No route found between points");
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

  // ✅ FIXED - Removed incorrect connection handlers
  if (kDebugMode) print('✅ Setting up socket connection - DriverDetail');

  _addMarker(LatLng(widget.lat, widget.long), "origin",
      BitmapDescriptor.defaultMarker);

  if (kDebugMode) print("🔍 Listening for driver updates: ${useridgloable}");

  // ✅ MIGRATED - Use SocketService.instance.on instead of socket.on
  socketService.on('V_Driver_Location$useridgloable', (V_Driver_Location) {
    _handleDriverLocation(V_Driver_Location);
  });

  socketService.on('Vehicle_D_IAmHere', (Vehicle_D_IAmHere) {
    _handleDriverArrival(Vehicle_D_IAmHere);
  });

  socketService.on('Vehicle_D_Drop_request', (Vehicle_D_Drop_request) {
    _handleDropRequest(Vehicle_D_Drop_request);
  });

  socketService.on('Vehicle_D_Payment_request', (Vehicle_D_Payment_request) {
    _handlePaymentRequest(Vehicle_D_Payment_request);
  });

  socketService.on('V_Driver_Drop_order', (V_Driver_Drop_order) {
    _handleDropOrder(V_Driver_Drop_order);
  });
}
  // ✅ NEW - Organized event handlers
  void _handleDriverLocation(dynamic V_Driver_Location) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        print("++++++ /V_Driver_Location/ ++++ :---  $V_Driver_Location");
        print("V_Driver_Location is of type: ${V_Driver_Location.runtimeType}");
        print("V_Driver_Location keys: ${V_Driver_Location.keys}");
        print("+++++V_Driver_Location userid+++++: $useridgloable");
        print("++++driver_id hhhh +++++: $driver_id");
      }

      if (V_Driver_Location["driver_location"] != null &&
          V_Driver_Location["driver_location"]["image"] != null) {
        imagenetwork =
            "${Config.imageurl}${V_Driver_Location["driver_location"]["image"]}";
        if (kDebugMode) print("++++imagenetwork +++++: $imagenetwork");
      }

      if (driver_id == V_Driver_Location["d_id"].toString()) {
        if (kDebugMode) print("✅ Driver location match - updating");

        livelat =
            double.parse(V_Driver_Location["driver_location"]["latitude"]);
        livelong =
            double.parse(V_Driver_Location["driver_location"]["longitude"]);

        if (kDebugMode) {
          print("****livelat****:-- ${livelat}");
          print("****livelong****:-- ${livelong}");
        }

        _addMarker(LatLng(widget.lat, widget.long), "origin",
            BitmapDescriptor.defaultMarker);
        updatemarker(LatLng(livelat, livelong), "destination", imagenetwork);
        getDirections(
            lat1: PointLatLng(livelat, livelong),
            lat2: PointLatLng(widget.lat, widget.long));
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

  void _handleDriverArrival(dynamic Vehicle_D_IAmHere) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        print("++++++ /Vehicle_D_IAmHere/ ++++ :---  $Vehicle_D_IAmHere");
        print("Vehicle_D_IAmHere is of type: ${Vehicle_D_IAmHere.runtimeType}");
        print("Vehicle_D_IAmHere keys: ${Vehicle_D_IAmHere.keys}");
        print("Vehicle_D_IAmHere id: ${Vehicle_D_IAmHere["c_id"]}");
        print("userid: $useridgloable");
      }

      tot_time = Vehicle_D_IAmHere["pickuptime"].toString();
      extratime = Vehicle_D_IAmHere["pickuptime"].toString();
      tot_secound = "0";

      if (kDebugMode) {
        print(
            "Vehicle_D_IAmHere_pickuptime: ${Vehicle_D_IAmHere["pickuptime"]}");
        print("Vehicle_D_IAmHere_pickuptime tot_time: ${tot_time}");
        print("Vehicle_D_IAmHere_pickuptime tot_time: ${extratime}");
      }

      if (Vehicle_D_IAmHere["c_id"] == useridgloable.toString()) {
        if (kDebugMode) print("✅ Driver arrival confirmed");

        // Navigate to driver start ride screen
        globalDriverAcceptClass.driverdetailfunction(
          context: context,
          lat: widget.lat,
          long: widget.long,
          d_id: driver_id,
          request_id: request_id,
        );
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling driver arrival: $e");
    }
  }

  void _handleDropRequest(dynamic Vehicle_D_Drop_request) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        print(
            "++++++ /Vehicle_D_Drop_request/ ++++ :---  $Vehicle_D_Drop_request");
      }

      if (Vehicle_D_Drop_request["c_id"] == useridgloable.toString()) {
        if (kDebugMode) print("✅ Drop request received");

        // Handle drop request logic
        // This would typically navigate to a drop confirmation screen
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling drop request: $e");
    }
  }

  void _handlePaymentRequest(dynamic Vehicle_D_Payment_request) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        print(
            "++++++ /Vehicle_D_Payment_request/ ++++ :---  $Vehicle_D_Payment_request");
      }

      if (Vehicle_D_Payment_request["c_id"] == useridgloable.toString()) {
        if (kDebugMode) print("✅ Payment request received");

        // Handle payment request logic
        // This would typically navigate to payment screen
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling payment request: $e");
    }
  }

  void _handleDropOrder(dynamic V_Driver_Drop_order) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        print("++++++ /V_Driver_Drop_order/ ++++ :---  $V_Driver_Drop_order");
      }

      if (V_Driver_Drop_order["c_id"] == useridgloable.toString()) {
        if (kDebugMode) print("✅ Drop order received");

        // Handle drop order completion
        // This would typically show order completion UI
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling drop order: $e");
    }
  }

  getdatafromserver() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = jsonDecode(prefs.getString("UserLogin")!);
    });
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

                // ✅ KEEP - Bottom sheet UI remains the same
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 200,
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
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Driver is on the way".tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: notifier.textColor,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // Show driver details bottom sheet
                                  showDriverDetails();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theamcolore.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Details".tr,
                                    style: TextStyle(
                                      color: theamcolore,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          Row(
                            children: [
                              // Call button
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    // ✅ KEEP - Keep global driver data access
                                    if (globalDriverAcceptClass
                                        .driver_phone.isNotEmpty) {
                                      _makePhoneCall(
                                          globalDriverAcceptClass.driver_phone);
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.call,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Call".tr,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 15),

                              // Message button
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    // Navigate to chat screen
                                    Get.to(() => const ChatScreen());
                                  },
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: theamcolore,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.message,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Message".tr,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // Cancel ride button
                          InkWell(
                            onTap: () {
                              _showCancelDialog();
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
                                  "Cancel Ride".tr,
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

  // ✅ KEEP - Helper methods remain the same
  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cancel Ride".tr),
          content: Text("Are you sure you want to cancel this ride?".tr),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No".tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelRide();
              },
              child: Text("Yes".tr),
            ),
          ],
        );
      },
    );
  }

  void _cancelRide() {
    // ✅ MIGRATED - Use SocketService.instance.emit
    SocketService.instance.emit('cancel_ride', {
      'request_id': request_id,
      'user_id': useridgloable,
      'driver_id': driver_id,
    });

    // Navigate back to home
    Get.offAll(() => HomeScreen(
          latpic: context.read<LocationState>().latitudePick,
          longpic: context.read<LocationState>().longitudePick,
          latdrop: context.read<LocationState>().latitudeDrop,
          longdrop: context.read<LocationState>().longitudeDrop,
          destinationlat: context.read<LocationState>().destinationLat,
        ));
  }

  void showDriverDetails() {
    if (kDebugMode)
      print("++++++:-------Driver Details+++++:---- ${driver_id.toString()}");

    driverDetailApiController
        .driverdetailApi(d_id: driver_id.toString())
        .then((value) {
      prefrence = [];
      language = [];

      if (driverDetailApiController
              .driverDetailApiModel?.dDetail?.prefrenceName !=
          null) {
        prefrence = driverDetailApiController
            .driverDetailApiModel!.dDetail!.prefrenceName
            .toString()
            .split(",");
      }

      if (driverDetailApiController.driverDetailApiModel?.dDetail?.language !=
          null) {
        language = driverDetailApiController
            .driverDetailApiModel!.dDetail!.language
            .toString()
            .split(",");
      }

      return Get.bottomSheet(
        isScrollControlled: true,
        StatefulBuilder(
          builder: (context, setState) {
            return GetBuilder<DriverDetailApiController>(
              builder: (driverDetailApiController) {
                return Container(
                  height: 600,
                  decoration: BoxDecoration(
                    color: notifier.containercolore,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 150,
                              width: Get.width,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15)),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "${Config.imageurl}${driverDetailApiController.driverDetailApiModel!.dDetail!.profileImage}"),
                                      fit: BoxFit.cover)),
                            ),
                            Positioned(
                              top: -25,
                              left: Get.width / 2 - 50,
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        "${Config.imageurl}${driverDetailApiController.driverDetailApiModel!.dDetail!.vehicleImage}"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Driver name and rating
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${driverDetailApiController.driverDetailApiModel!.dDetail!.firstName}",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: notifier.textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "${driverDetailApiController.driverDetailApiModel!.dDetail!.rating}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: notifier.textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Call and message buttons
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _makePhoneCall(
                                              driverDetailApiController
                                                  .driverDetailApiModel!
                                                  .dDetail!
                                                  .primaryPhoneNo!);
                                        },
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.call,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        onTap: () {
                                          Get.to(() => const ChatScreen());
                                        },
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                            color: theamcolore,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.message,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),

                              // Vehicle details
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: notifier.backgroundgrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Vehicle Details".tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: notifier.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildDetailItem(
                                            "Vehicle Type".tr,
                                            "${driverDetailApiController.driverDetailApiModel!.dDetail!.carName}",
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildDetailItem(
                                            "Plate Number".tr,
                                            "${driverDetailApiController.driverDetailApiModel!.dDetail!.vehicleNumber}",
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildDetailItem(
                                      "Vehicle Color".tr,
                                      "${driverDetailApiController.driverDetailApiModel!.dDetail!.carColor}",
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Driver preferences
                              if (prefrence.isNotEmpty) ...[
                                Text(
                                  "Preferences".tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: notifier.textColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: prefrence.map((pref) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: theamcolore.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: theamcolore.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        pref.toString().trim(),
                                        style: TextStyle(
                                          color: theamcolore,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Driver languages
                              if (language.isNotEmpty) ...[
                                Text(
                                  "Languages".tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: notifier.textColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: language.map((lang) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        lang.toString().trim(),
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: notifier.textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: notifier.textColor,
          ),
        ),
      ],
    );
  }
}
