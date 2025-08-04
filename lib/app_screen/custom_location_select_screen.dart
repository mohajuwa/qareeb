// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import 'package:qareeb/common_code/common_button.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/common_code/type_utils.dart';
import 'dart:ui' as ui;
import '../api_code/calculate_api_controller.dart';
import '../api_code/modual_calculate_api_controller.dart';
import 'home_screen.dart';
import 'map_screen.dart';

var lat;
var long;
var address;

class CustomLocationSelectScreen extends StatefulWidget {
  final String bidding;
  final bool pagestate;
  const CustomLocationSelectScreen(
      {super.key, required this.bidding, required this.pagestate});

  @override
  State<CustomLocationSelectScreen> createState() =>
      _CustomLocationSelectScreenState();
}

class _CustomLocationSelectScreenState
    extends State<CustomLocationSelectScreen> {
  String themeForMap = "";
  GoogleMapController? mapController;
  bool isMapReady = false;
  Set<Marker> markers = {};

  // Add timeout and error handling
  static const Duration _apiTimeout = Duration(seconds: 15);
  static const Duration _mapTimeout = Duration(seconds: 10);

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
        ).catchError((error) {
          if (kDebugMode) {
            print("❌ Dark style loading error: $error");
          }
          // Use default dark theme or leave empty
          themeForMap = "";
        });
      });
    } else {
      setState(() {
        DefaultAssetBundle.of(context)
            .loadString("assets/map_styles/light_style.json")
            .then(
          (value) {
            setState(() {
              themeForMap = value;
            });
          },
        ).catchError((error) {
          if (kDebugMode) {
            print("❌ Light style loading error: $error");
          }
          // Use default light theme or leave empty
          themeForMap = "";
        });
      });
    }
    setState(() {});
  }

  CalculateController calculateController = Get.put(CalculateController());
  Modual_CalculateController modual_calculateController =
      Get.put(Modual_CalculateController());

  @override
  void initState() {
    super.initState();
    mapThemeStyle(context: context);
    _initializeLocation();
  }

  // Initialize location with error handling
  Future<void> _initializeLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      lat = position.latitude;
      long = position.longitude;

      // Get address with timeout
      await _getAddressFromCoordinates(lat, long);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Location initialization error: $e");
      }
      // Set default location (Ibb, Yemen)
      lat = 13.9667;
      long = 44.1833;
      address = "الموقع الافتراضي، إب، اليمن";

      if (mounted) {
        setState(() {});
      }
    }
  }

  // Get address with proper error handling
  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude)
              .timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        address =
            "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
      } else {
        address = "$latitude, $longitude";
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Geocoding error: $e");
      }
      address = "$latitude, $longitude";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: CommonButton(
            containcolore: theamcolore,
            onPressed1: () async {
              await _handleLocationSelection();
            },
            txt1: picanddrop == false
                ? "تأكيد نقطة الانطلاق"
                : "تأكيد نقطة الوصول"),
      ),
      appBar: AppBar(
        backgroundColor: theamcolore,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          picanddrop == false ? "اختيار نقطة الانطلاق" : "اختيار نقطة الوصول",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: lat == null || long == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                // Google Map with error handling
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) async {
                    try {
                      mapController = controller;
                      // Apply theme only if it loaded successfully
                      if (themeForMap.isNotEmpty) {
                        await controller.setMapStyle(themeForMap);
                      }
                      isMapReady = true;
                      if (mounted) {
                        setState(() {});
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print("❌ Map initialization error: $e");
                      }
                      // Map will use default style if theme fails to load
                      isMapReady = true;
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  },
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      double.tryParse(lat.toString()) ?? 13.9667,
                      double.tryParse(long.toString()) ?? 44.1833,
                    ),
                    zoom: 16.0,
                  ),
                  onCameraMove: (CameraPosition position) {
                    lat = position.target.latitude;
                    long = position.target.longitude;
                  },
                  onCameraIdle: () async {
                    await _getAddressFromCoordinates(lat, long);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  markers: markers,
                ),

                // Center marker
                Center(
                  child: Icon(
                    Icons.location_pin,
                    size: 40,
                    color: theamcolore,
                  ),
                ),

                // Address display
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      address ?? "جاري تحديد الموقع...",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Handle location selection with proper error handling and type safety
  Future<void> _handleLocationSelection() async {
    try {
      if (picanddrop == false) {
        // Pickup location selection
        if (kDebugMode) {
          print("++++++pickup run+++++++");
        }

        pickupcontroller.text = address ?? "";
        picktitle = address ?? "";
        picksubtitle = address ?? "";
        latitudepick = lat;
        longitudepick = long;

        if (pickupcontroller.text.isNotEmpty &&
            dropcontroller.text.isNotEmpty) {
          await _processCompleteRoute();
        } else {
          Navigator.pop(context);
        }
      } else {
        // Drop location selection
        if (kDebugMode) {
          print("++++++drop run+++++++");
        }

        dropcontroller.text = address ?? "";
        droptitle = address ?? "";
        dropsubtitle = address ?? "";
        latitudedrop = lat;
        longitudedrop = long;

        if (pickupcontroller.text.isNotEmpty &&
            dropcontroller.text.isNotEmpty) {
          await _processCompleteRoute();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Location selection error: $e");
      }
      _showErrorMessage("حدث خطأ أثناء تحديد الموقع");
    }
  }

  // Process complete route with enhanced error handling
  Future<void> _processCompleteRoute() async {
    try {
      if (kDebugMode) {
        print("++++++++++++++++done++++++++++++++++");
      }

      if (widget.bidding == "1") {
        Get.offAll(const ModernMapScreen(selectVehicle: false));
        await _performCalculation();
      } else if (widget.pagestate == true) {
        Navigator.pop(context, RefreshData(true));
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              latpic: latitudepick,
              longpic: longitudepick,
              latdrop: latitudedrop,
              longdrop: longitudedrop,
              destinationlat: destinationlat,
            ),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Route processing error: $e");
      }
      _showErrorMessage("حدث خطأ أثناء معالجة المسار");
    }
  }

  // Enhanced calculation with proper error handling and type safety
// Enhanced calculation with proper error handling and type safety
  Future<void> _performCalculation() async {
    try {
      // Show loading indicator (store reference for cleanup)
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      var value = await calculateController
          .calculateApi(
            context: context,
            uid: useridgloable.toString(),
            mid: mid,
            mrole: mroal,
            pickup_lat_lon: "${latitudepick},${longitudepick}",
            drop_lat_lon: "${latitudedrop},${longitudedrop}",
            drop_lat_lon_list: onlypass,
          )
          .timeout(_apiTimeout);

      // ALWAYS hide loading indicator first
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Reset values with type safety
      dropprice = 0.0;
      minimumfare = 0.0;
      maximumfare = 0.0;

      if (value != null && value["Result"] == true) {
        amountresponse = "true";

        // ✅ FIXED: Use safeParseDouble for all numeric values
        dropprice = safeParseDouble(value["drop_price"]);
        minimumfare = safeParseDouble(value["vehicle"]["minimum_fare"]);
        maximumfare = safeParseDouble(value["vehicle"]["maximum_fare"]);

        responsemessage = value["message"]?.toString() ?? "";
        tot_hour = value["tot_hour"]?.toString() ?? "0";
        tot_time = value["tot_minute"]?.toString() ?? "0";
        vehicle_id = value["vehicle"]?["id"]?.toString() ?? "";

        // Use safeParseDouble for double variables
        vihicalrice = safeParseDouble(value["drop_price"]);
        totalkm = safeParseDouble(value["tot_km"]);
        tot_secound = "0";

        vihicalimage = value["vehicle"]?["map_img"]?.toString() ?? "";
        vihicalname = value["vehicle"]?["name"]?.toString() ?? "";

        if (kDebugMode) {
          print(".......>>>>>> tot_hour: ${tot_hour}");
          print(".......>>>>>> tot_time: ${tot_time}");
          print(".......>>>>>> vehicle_id: ${vehicle_id}");
          print(".......>>>>>> vihicalrice: ${vihicalrice}");
          print(".......>>>>>> totalkm: ${totalkm}");
        }
      } else {
        amountresponse = "false";
        String errorMsg = value?["message"]?.toString() ?? "فشل في حساب الأجرة";
        _showErrorMessage(errorMsg);

        if (kDebugMode) {
          print("❌ Calculate API failed: $errorMsg");
        }
      }
    } catch (e) {
      // CRITICAL: Always hide loading indicator in catch block
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (kDebugMode) {
        print("❌ Calculation error: $e");
      }

      String errorMessage = "حدث خطأ أثناء حساب الأجرة";
      if (e.toString().contains('TimeoutException')) {
        errorMessage = "انتهت مهلة الطلب. حاول مرة أخرى.";
      } else if (e.toString().contains('SocketException')) {
        errorMessage = "تحقق من اتصال الإنترنت";
      }

      _showErrorMessage(errorMessage);
    }
  }

  // Show error message
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}

// Helper class for refresh data
class RefreshData {
  final bool refresh;
  RefreshData(this.refresh);
}
