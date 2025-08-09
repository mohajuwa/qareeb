// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/common_code/modern_loading_widget.dart';
import 'package:qareeb/common_code/socket_service.dart';
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/map_state.dart';
import 'package:qareeb/providers/pricing_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/api_code/my_ride_detail_api.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:qareeb/common_code/common_button.dart';
import 'dart:ui' as ui;
import '../common_code/common_flow_screen.dart';
import '../common_code/config.dart';
import '../pdf/pdfpreview_screen.dart';

class MyRideDetailScreen extends StatefulWidget {
  final String request_id;
  final String status;

  const MyRideDetailScreen({
    super.key,
    required this.request_id,
    required this.status,
  });

  @override
  State<MyRideDetailScreen> createState() => _MyRideDetailScreenState();
}

class _MyRideDetailScreenState extends State<MyRideDetailScreen> {
  // ✅ MIGRATED - API Controllers
  MyRideDetailApiController myRideDetailApiController =
      Get.put(MyRideDetailApiController());

  // ✅ MIGRATED - Map functionality now uses provider
  PolylinePoints polylinePoints = PolylinePoints();
  GoogleMapController? mapController;

  // ✅ KEEP - UI state variables
  ColorNotifier notifier = ColorNotifier();
  var decodeUid;
  var userid;
  var currencyy;

  // ✅ KEEP - Drop off points for route calculation
  List<PointLatLng> _dropOffPoints = [];

  @override
  void initState() {
    super.initState();
    getdata();
    _initializeSocket();
  }

  @override
  void dispose() {
    SocketService.instance.disconnect();
    super.dispose();
  }

  // ✅ MIGRATED - Socket initialization for real-time updates
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

    // Listen for ride detail updates
    socketService.on('ride_detail_update${widget.request_id}', (data) {
      _handleRideDetailUpdate(data);
    });

    if (kDebugMode) print("✅ Socket listeners setup for MyRideDetailScreen");
  }

  // ✅ NEW - Socket event handlers
  void _handleRideStatusUpdate(dynamic data) {
    if (!mounted) return;

    try {
      if (kDebugMode) print("🔄 Ride status update received: $data");

      if (data["request_id"].toString() == widget.request_id) {
        // Refresh ride detail data
        _refreshRideDetail();
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling ride status update: $e");
    }
  }

  void _handleRideDetailUpdate(dynamic data) {
    if (!mounted) return;

    try {
      if (kDebugMode) print("📊 Ride detail update received: $data");

      // Update ride information in real-time
      _refreshRideDetail();
    } catch (e) {
      if (kDebugMode) print("❌ Error handling ride detail update: $e");
    }
  }

  // ✅ NEW - Refresh ride detail method
  void _refreshRideDetail() {
    if (userid != null) {
      myRideDetailApiController
          .mydetailApi(
        context: context,
        uid: userid.toString(),
        request_id: widget.request_id,
        status: widget.status,
      )
          .then((_) {
        if (mounted) {
          setState(() {});
          _updateMapWithRideData();
        }
      });
    }
  }

  // ✅ ENHANCED - Data loading with better error handling
  getdata() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var uid = preferences.getString("userLogin");
      var currency = preferences.getString("currenci");

      if (uid == null) {
        if (kDebugMode) print("❌ No user login data found");
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
        print("✅ Loading ride detail for: ${widget.request_id}");
      }

      setState(() {});

      // Load ride detail data
      await myRideDetailApiController.mydetailApi(
        context: context,
        uid: userid.toString(),
        request_id: widget.request_id,
        status: widget.status,
      );

      if (mounted) {
        setState(() {});
        _updateMapWithRideData();
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error loading ride detail data: $e");
    }
  }

  // ✅ NEW - Update map with ride data
  void _updateMapWithRideData() {
    if (myRideDetailApiController.myRideDetailApiModel?.reuqestList == null) {
      return;
    }

    final rideData =
        myRideDetailApiController.myRideDetailApiModel!.reuqestList!;

    // Clear existing map data
    context.read<MapState>().clearMapData();

    // Add pickup marker
    if (rideData.pickup != null) {
      _addPickupMarker(
        LatLng(
          double.parse(rideData.pickup!.latitude.toString()),
          double.parse(rideData.pickup!.longitude.toString()),
        ),
        rideData.pickup!.title.toString(),
      );
    }

    // Add drop markers - drop is a List<Pickup>
    if (rideData.drop != null && rideData.drop!.isNotEmpty) {
      _dropOffPoints.clear();

      // Add first drop as main drop
      final firstDrop = rideData.drop!.first;
      _addDropMarker(
        LatLng(
          double.parse(firstDrop.latitude.toString()),
          double.parse(firstDrop.longitude.toString()),
        ),
        firstDrop.title.toString(),
      );

      // Add all drops to _dropOffPoints for route calculation
      for (int i = 0; i < rideData.drop!.length; i++) {
        final dropItem = rideData.drop![i];
        _dropOffPoints.add(
          PointLatLng(
            double.parse(dropItem.latitude.toString()),
            double.parse(dropItem.longitude.toString()),
          ),
        );
      }

      // Add additional drop markers if more than one
      if (rideData.drop!.length > 1) {
        _addMultipleDropMarkers(rideData.drop!);
      }
    }

    // Generate route if we have pickup and drop
    if (rideData.pickup != null &&
        rideData.drop != null &&
        rideData.drop!.isNotEmpty) {
      _generateRoute(
        PointLatLng(
          double.parse(rideData.pickup!.latitude.toString()),
          double.parse(rideData.pickup!.longitude.toString()),
        ),
        _dropOffPoints,
      );
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

  // ✅ MIGRATED - Use MapState provider for pickup marker
  void _addPickupMarker(LatLng position, String title) async {
    final Uint8List markIcon = await getImages("assets/pickup_marker.png", 80);
    MarkerId markerId = const MarkerId("pickup");
    Marker marker = Marker(
      markerId: markerId,
      icon: BitmapDescriptor.fromBytes(markIcon),
      position: position,
      infoWindow: InfoWindow(
        title: "Pickup".tr,
        snippet: title,
      ),
      onTap: () {
        _showLocationDialog("Pickup Location".tr, title);
      },
    );

    // ✅ MIGRATED - Use MapState provider
    context.read<MapState>().addMarker(markerId, marker);
  }

  // ✅ MIGRATED - Use MapState provider for drop marker
  void _addDropMarker(LatLng position, String title) async {
    final Uint8List markIcon = await getImages("assets/drop_marker.png", 80);
    MarkerId markerId = const MarkerId("drop");
    Marker marker = Marker(
      markerId: markerId,
      icon: BitmapDescriptor.fromBytes(markIcon),
      position: position,
      infoWindow: InfoWindow(
        title: "Drop Location".tr,
        snippet: title,
      ),
      onTap: () {
        _showLocationDialog("Drop Location".tr, title);
      },
    );

    // ✅ MIGRATED - Use MapState provider
    context.read<MapState>().addMarker(markerId, marker);
  }

  // ✅ MIGRATED - Use MapState provider for multiple drop markers
  void _addMultipleDropMarkers([List<dynamic>? dropList]) async {
    final drops = dropList ?? _dropOffPoints;

    if (dropList != null) {
      // Working with drop list from API (List<Pickup>)
      for (int i = 1; i < dropList.length; i++) {
        // Start from 1 since first is main drop
        final dropItem = dropList[i];
        final Uint8List markIcon =
            await getImages("assets/drop_marker.png", 80);
        MarkerId markerId = MarkerId("additional_drop_$i");

        Marker marker = Marker(
          markerId: markerId,
          icon: BitmapDescriptor.fromBytes(markIcon),
          position: LatLng(
            double.parse(dropItem.latitude.toString()),
            double.parse(dropItem.longitude.toString()),
          ),
          infoWindow: InfoWindow(
            title: "Drop ${i + 1}",
            snippet: dropItem.title.toString(),
          ),
          onTap: () {
            _showLocationDialog(
                "Drop Location ${i + 1}", dropItem.title.toString());
          },
        );

        // ✅ MIGRATED - Use MapState provider
        context.read<MapState>().addMarker(markerId, marker);
      }
    } else {
      // Working with _dropOffPoints (List<PointLatLng>)
      for (int i = 0; i < _dropOffPoints.length; i++) {
        final dropPoint = _dropOffPoints[i];
        final Uint8List markIcon =
            await getImages("assets/drop_marker.png", 80);
        MarkerId markerId = MarkerId("drop_$i");

        Marker marker = Marker(
          markerId: markerId,
          icon: BitmapDescriptor.fromBytes(markIcon),
          position: LatLng(dropPoint.latitude, dropPoint.longitude),
          infoWindow: InfoWindow(
            title: "Drop ${i + 1}",
            snippet: "Additional drop location",
          ),
          onTap: () {
            _showLocationDialog(
                "Drop Location ${i + 1}", "Drop point ${i + 1}");
          },
        );

        // ✅ MIGRATED - Use MapState provider
        context.read<MapState>().addMarker(markerId, marker);
      }
    }
  }

  // ✅ MIGRATED - Use MapState provider for polylines
  void addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("ride_route");
    Polyline polyline = Polyline(
      polylineId: id,
      color: theamcolore,
      points: polylineCoordinates,
      width: 4,
    );

    // ✅ MIGRATED - Use MapState provider
    context.read<MapState>().addPolyline(id, polyline);
  }

  // ✅ ENHANCED - Route generation with multiple drop points
  Future _generateRoute(
      PointLatLng start, List<PointLatLng> dropOffPoints) async {
    List<LatLng> polylineCoordinates = [];
    List<PointLatLng> allPoints = [start, ...dropOffPoints];

    for (int i = 0; i < allPoints.length - 1; i++) {
      PointLatLng point1 = allPoints[i];
      PointLatLng point2 = allPoints[i + 1];

      try {
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
      } catch (e) {
        if (kDebugMode) print("❌ Error generating route segment: $e");
      }
    }

    if (polylineCoordinates.isNotEmpty) {
      addPolyLine(polylineCoordinates);
    }
  }

  // ✅ NEW - Show location dialog
  void _showLocationDialog(String title, String address) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(address),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK".tr),
            ),
          ],
        );
      },
    );
  }

  // ✅ NEW - Map controller callback
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    // ✅ MIGRATED - Wrap with Consumer for provider data
    return Consumer3<LocationState, MapState, PricingState>(
      builder: (context, locationState, mapState, pricingState, child) {
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
                "Ride Details".tr,
                style: TextStyle(color: notifier.textColor, fontSize: 18),
              ),
            ),
            actions: [
              // ✅ NEW - PDF download button for completed rides
              if (widget.status == "complete" || widget.status == "completed")
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfPreviewPage(
                          requestId: widget.request_id,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.picture_as_pdf,
                    color: notifier.textColor,
                  ),
                ),
            ],
          ),
          body: GetBuilder<MyRideDetailApiController>(
            builder: (myRideDetailApiController) {
              if (myRideDetailApiController.isLoading) {
                return const Center(
                  child: ModernLoadingWidget(
                    size: 60,
                    message:
                        "جاري تحميل تفاصيل الرحلة...", // Loading ride details...
                  ),
                );
              }

              if (myRideDetailApiController.myRideDetailApiModel?.reuqestList ==
                  null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Ride details not found".tr,
                        style: TextStyle(
                          fontSize: 18,
                          color: notifier.textColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final rideData =
                  myRideDetailApiController.myRideDetailApiModel!.reuqestList!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ ENHANCED - Ride status card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notifier.containercolore,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              _getStatusColor(widget.status).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Ride #${widget.request_id}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: notifier.textColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(widget.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(widget.status),
                                  ),
                                ),
                                child: Text(
                                  widget.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(widget.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ✅ Ride timing information
                          if (rideData.startTime != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: notifier.textColor.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Start Time: ${rideData.startTime}",
                                  style: TextStyle(
                                    color: notifier.textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],

                          // ✅ Ride duration
                          if (rideData.totHour != null &&
                              rideData.totMinute != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 16,
                                  color: notifier.textColor.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Duration: ${rideData.totHour} hours ${rideData.totMinute} minutes",
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

                    const SizedBox(height: 16),

                    // ✅ ENHANCED - Map container with ride route
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: rideData.pickup != null
                                ? LatLng(
                                    double.parse(
                                        rideData.pickup!.latitude.toString()),
                                    double.parse(
                                        rideData.pickup!.longitude.toString()),
                                  )
                                : const LatLng(
                                    24.7136, 46.6753), // Default to Riyadh
                            zoom: 12.0,
                          ),
                          markers: Set<Marker>.from(mapState.markers.values),
                          polylines:
                              Set<Polyline>.from(mapState.polylines.values),
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          buildingsEnabled: false,
                          indoorViewEnabled: false,
                          compassEnabled: false,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ✅ ENHANCED - Location details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notifier.containercolore,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Route Details".tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: notifier.textColor,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ✅ Pickup location
                          if (rideData.pickup != null) ...[
                            _buildLocationItem(
                              icon: Icons.radio_button_checked,
                              iconColor: Colors.green,
                              title: "Pickup Location".tr,
                              address: rideData.pickup!.title.toString(),
                              subtitle: rideData.pickup!.subtitle?.toString(),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // ✅ Drop location
                          if (rideData.drop != null &&
                              rideData.drop!.isNotEmpty) ...[
                            _buildLocationItem(
                              icon: Icons.location_on,
                              iconColor: Colors.red,
                              title: "Drop Location".tr,
                              address: rideData.drop!.first.title.toString(),
                              subtitle:
                                  rideData.drop!.first.subtitle?.toString(),
                            ),
                          ],

                          // ✅ Additional drop locations
                          if (rideData.drop != null &&
                              rideData.drop!.length > 1) ...[
                            const SizedBox(height: 12),
                            for (int i = 1; i < rideData.drop!.length; i++) ...[
                              _buildLocationItem(
                                icon: Icons.location_on_outlined,
                                iconColor: Colors.orange,
                                title: "Additional Drop ${i}",
                                address: rideData.drop![i].title.toString(),
                                subtitle:
                                    rideData.drop![i].subtitle?.toString(),
                              ),
                              if (i < rideData.drop!.length - 1)
                                const SizedBox(height: 8),
                            ],
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ✅ ENHANCED - Payment details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notifier.containercolore,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Payment Details".tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: notifier.textColor,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ✅ Total amount
                          if (rideData.finalPrice != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Amount".tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: notifier.textColor,
                                  ),
                                ),
                                Text(
                                  "${rideData.finalPrice} ${currencyy ?? 'SAR'}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theamcolore,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // ✅ Original price if different from final price
                          if (rideData.price != null &&
                              rideData.price != rideData.finalPrice) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Original Price".tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: notifier.textColor.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  "${rideData.price} ${currencyy ?? 'SAR'}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: notifier.textColor.withOpacity(0.7),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ✅ NEW - Build location item widget
  Widget _buildLocationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: notifier.textColor.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                  color: notifier.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: notifier.textColor.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ✅ NEW - Get status color helper
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.orange;
      case 'complete':
      case 'completed':
        return Colors.green;
      case 'cancel':
      case 'cancelled':
        return Colors.red;
      case 'ongoing':
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
