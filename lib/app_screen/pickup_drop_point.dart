import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/daynamic_widget.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/controllers/app_controller.dart'; // ✅ ADD: AppController import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/api_code/map_api_get.dart';
import 'package:qareeb/app_screen/custom_location_select_screen.dart';
import 'package:qareeb/app_screen/home_screen.dart';
import '../api_code/calculate_api_controller.dart';
import '../api_code/modual_calculate_api_controller.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';

bool picanddrop = true;
// bool multilistselection = false;
var addresspickup;
List onlypass = [];

var dropprice;
var minimumfare;
var maximumfare;

class PickupDropPoint extends StatefulWidget {
  final bool pagestate;
  final String bidding;
  const PickupDropPoint(
      {super.key, required this.pagestate, required this.bidding});

  @override
  State<PickupDropPoint> createState() => _PickupDropPointState();
}

class _PickupDropPointState extends State<PickupDropPoint> {
  // ✅ ADD: AppController instance
  final appController = AppController.instance;

  MapSuggestGetApiController mapSuggestGetApiController =
      Get.put(MapSuggestGetApiController());
  CalculateController calculateController = Get.put(CalculateController());

  Modual_CalculateController modualCalculateController =
      Get.put(Modual_CalculateController());

  ColorNotifier notifier = ColorNotifier();

  Future<void> calculateDistance() async {
    // ✅ REPLACE: Global variables with AppController
    double distanceInMeters = Geolocator.distanceBetween(
      appController.pickupLat.value,
      appController.pickupLng.value,
      appController.dropLat.value,
      appController.dropLng.value,
    );

    double distanceInKilometers = distanceInMeters / 1000;
    if (kDebugMode) {
      print("Distance: $distanceInKilometers km");
    }
  }

  @override
  void initState() {
    super.initState();

    datagetfunction();
    if (kDebugMode) {
      print("******:----suryo:---- ${widget.bidding}");
    }
    fun().then((value) {
      setState(() {});
      getCurrentLatAndLong(
          appController.pickupLat.value, appController.pickupLng.value);
    });
    if (kDebugMode) {
      print("********** bidding **********:--- (${widget.bidding})");
    }
  }

  Future fun() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {}
    var currentLocation = await locateUser();
    if (kDebugMode) {
      debugPrint('location: ${currentLocation.latitude}');
    }
    getCurrentLatAndLong(
      currentLocation.latitude,
      currentLocation.longitude,
    );

    if (kDebugMode) {
      print("????????????${currentLocation.longitude}");
      print("SECOND USER hhhhhhhhhhhhhh CURRENT LOCATION : --  $addresspickup");
    }
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getCurrentLatAndLong(double latitude, double longitude) async {
    // ✅ REPLACE: Global variables with AppController
    appController.pickupLat.value = latitude;
    appController.pickupLng.value = longitude;

    await placemarkFromCoordinates(latitude, longitude)
        .then((List<Placemark> placemarks) {
      addresspickup =
          '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.country}';
    });
  }

  bool destination = false;
  List destinationname = [];

  submitDataName() {
    destinationname = [];

    for (int a = 0; a < textfieldlist.length; a++) {
      if (textfieldlist[a].destinationcontroller.text.isNotEmpty) {
        destinationname.add(textfieldlist[a].destinationcontroller.text);
        textFieldindex = a;
      }
    }

    setState(() {});
  }

  int textFieldindex = 0;
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  int selectedIndex = 0;
  var decodeUid;
  var userid;

  datagetfunction() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("userLogin");

    decodeUid = jsonDecode(uid!);
    userid = decodeUid['id'];

    // ✅ REPLACE: useridgloable with AppController
    appController.globalUserId.value = userid.toString();
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    return Scaffold(
      backgroundColor: notifier.background,
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Container(
          width: Get.width,
          height: 60,
          color: notifier.background,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: notifier.textColor,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 15),
                picanddrop
                    ? Text("Pickup".tr,
                        style:
                            TextStyle(fontSize: 20, color: notifier.textColor))
                    : Text("Drop".tr,
                        style:
                            TextStyle(fontSize: 20, color: notifier.textColor)),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        height: Get.height,
        width: Get.width,
        color: notifier.background,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 16, bottom: 20, left: 0),
                      child: Column(
                        children: [
                          Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green, width: 4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 10,
                            width: 3,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 10,
                            width: 3,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 10,
                            width: 3,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          const SizedBox(height: 4),
                          textfieldlist.isNotEmpty
                              ? const SizedBox()
                              : Container(
                                  height: 10,
                                  width: 3,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                          const SizedBox(height: 4),
                          Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.red, width: 4)),
                          ),
                          const SizedBox(height: 4),
                          textfieldlist.isEmpty
                              ? const SizedBox()
                              : Column(
                                  children: List.generate(
                                    textfieldlist.length,
                                    (index) => Column(
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 3,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 10,
                                          width: 3,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.red, width: 4)),
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Column(
                      children: [
                        // Pickup Field
                        Container(
                          margin: const EdgeInsets.only(left: 15, right: 15),
                          decoration: BoxDecoration(
                            color: notifier.textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            // ✅ REPLACE: pickupcontroller with AppController
                            controller: appController.pickupController,
                            decoration: InputDecoration(
                              hintText: 'Where from ?'.tr,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            style: TextStyle(color: notifier.textColor),
                            onTap: () {
                              Get.to(() => CustomLocationSelectScreen(
                                    bidding: widget.bidding,
                                    pagestate: true,
                                  ));
                            },
                            readOnly: true,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Drop Field
                        Container(
                          margin: const EdgeInsets.only(left: 15, right: 15),
                          decoration: BoxDecoration(
                            color: notifier.textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            // ✅ REPLACE: dropcontroller with AppController
                            controller: appController.dropController,
                            decoration: InputDecoration(
                              hintText: 'Where to ?'.tr,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            style: TextStyle(color: notifier.textColor),
                            onTap: () {
                              Get.to(() => CustomLocationSelectScreen(
                                    bidding: widget.bidding,
                                    pagestate: false,
                                  ));
                            },
                            readOnly: true,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Additional Destinations List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: textfieldlist.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 8,
                                    child: Transform.translate(
                                      offset: const Offset(0, -7),
                                      child: textfieldlist[index],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                      });

                                      setState(() {
                                        textfieldlist.removeAt(index);
                                        destinationlat.removeAt(index);
                                        onlypass.removeAt(index);
                                        // ✅ REPLACE: droptitlelist with AppController
                                        appController.dropTitleList
                                            .removeAt(index);

                                        if (kDebugMode) {
                                          print(
                                              ">>>>>>>>>>>>>>>>textfieldlist<<<<<<<<<<<<<<<< ${textfieldlist}");
                                          print(
                                              ">>>>>>>>>>>>>>>>onlypass<<<<<<<<<<<<<<<< ${onlypass}");
                                          print(
                                              ">>>>>>>>>>>>>>>>destinationlat<<<<<<<<<<<<<<<< ${destinationlat}");
                                          print(
                                              ">>>>>>>>>>>>>>>>droptitlelist<<<<<<<<<<<<<<<< ${appController.dropTitleList}");
                                        }
                                      });
                                    },
                                    child: Transform.translate(
                                      offset: const Offset(0, -9),
                                      child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              shape: BoxShape.circle),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Image(
                                              image: const AssetImage(
                                                  "assets/close.png"),
                                              height: 15,
                                              color: notifier.textColor,
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Add destination button
            Row(
              children: [
                InkWell(
                  onTap: () {
                    textfieldlist.add(DynamicWidget());
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add destination'.tr,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(15),
              child: CommonButton(
                txt1: "Continue".tr,
                // ✅ FIX: Added missing required arguments
                containcolore: theamcolore,
                onPressed1: () {
                  // Validate inputs
                  if (appController.pickupController.text.isEmpty) {
                    Get.snackbar('Error', 'Please select pickup location');
                    return;
                  }

                  if (appController.dropController.text.isEmpty) {
                    Get.snackbar('Error', 'Please select drop location');
                    return;
                  }

                  // Calculate fare based on bidding type
                  if (widget.bidding == "1") {
                    calculateController
                        .calculateApi(
                      context: context,
                      uid: userid.toString(),
                      mid: mid, // Assuming 'mid' is a global variable
                      mrole: mroal, // Assuming 'mroal' is a global variable
                      pickup_lat_lon:
                          "${appController.pickupLat.value},${appController.pickupLng.value}",
                      drop_lat_lon:
                          "${appController.dropLat.value},${appController.dropLng.value}",
                      drop_lat_lon_list: onlypass,
                    )
                        .then((value) {
                      dropprice = 0.0;
                      minimumfare = 0.0;
                      maximumfare = 0.0;

                      if (value != null &&
                          value.isNotEmpty &&
                          calculateController.calCulateModel != null) {
                        final model = calculateController.calCulateModel!;

                        dropprice = model.dropPrice ?? 0.0;
                        minimumfare = double.tryParse(
                                model.vehicle?.minimumFare ?? '0') ??
                            0.0;
                        maximumfare = double.tryParse(
                                model.vehicle?.maximumFare ?? '0') ??
                            0.0;
                        appController.totalKm.value = model.totKm ?? 0.0;

                        final hours = model.totHour ?? 0;
                        final minutes = model.totMinute ?? 0;
                        appController.totalTime.value = "${hours}h ${minutes}m";

                        Get.to(() => HomeScreen(
                              latpic: appController.pickupLat.value,
                              longpic: appController.pickupLng.value,
                              latdrop: appController.dropLat.value,
                              longdrop: appController.dropLng.value,
                              destinationlat: destinationlat,
                            ));
                      }
                    });
                  } else {
                    modualCalculateController
                        .modualcalculateApi(
                      context: context,
                      uid: userid.toString(),
                      mid: mid,
                      mrole: mroal,
                      pickup_lat_lon:
                          "${appController.pickupLat.value},${appController.pickupLng.value}",
                      drop_lat_lon:
                          "${appController.dropLat.value},${appController.dropLng.value}",
                      drop_lat_lon_list: onlypass,
                    )
                        .then((value) {
                      if (value != null &&
                          value.modualCalculateApiModel?.caldriver
                                  ?.isNotEmpty ==
                              true) {
                        final driverData =
                            value.modualCalculateApiModel!.caldriver![0];
                        appController.totalKm.value = (driverData.dropKm is num)
                            ? driverData.dropKm!.toDouble()
                            : double.tryParse(driverData.dropKm.toString()) ??
                                0.0;
                        appController.totalTime.value =
                            driverData.dropTime?.toString() ?? '';
                        appController.totalHour.value =
                            driverData.dropHour?.toString() ?? '';
                        appController.midSecond.value = driverData.id!;

                        Get.to(() => HomeScreen(
                              latpic: appController.pickupLat.value,
                              longpic: appController.pickupLng.value,
                              latdrop: appController.dropLat.value,
                              longdrop: appController.dropLng.value,
                              destinationlat: destinationlat,
                            ));
                      }
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    focusNode1.dispose();
    focusNode2.dispose();
    // Don't dispose controllers here as they're managed by AppController
    super.dispose();
  }
}
