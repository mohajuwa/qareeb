// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/common_code/modern_loading_widget.dart';
import 'package:qareeb/common_code/socket_service.dart';
import 'package:qareeb/common_code/type_utils.dart';
import 'package:qareeb/providers/dynamic_fields_state.dart';
import 'package:qareeb/providers/location_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/api_code/map_api_get.dart';
import 'package:qareeb/app_screen/custom_location_select_screen.dart'
    hide RefreshData;
import 'package:qareeb/app_screen/home_screen.dart';
import '../api_code/calculate_api_controller.dart';
import '../api_code/modual_calculate_api_controller.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';
import 'map_screen.dart';
import 'my_ride_screen.dart';

class PickupDropPoint extends StatefulWidget {
  final bool pagestate;
  final String bidding;
  const PickupDropPoint(
      {super.key, required this.pagestate, required this.bidding});

  @override
  State<PickupDropPoint> createState() => _PickupDropPointState();
}

class _PickupDropPointState extends State<PickupDropPoint> {
  MapSuggestGetApiController mapSuggestGetApiController =
      Get.put(MapSuggestGetApiController());

  CalculateController calculateController = Get.put(CalculateController());

  Modual_CalculateController modual_calculateController =
      Get.put(Modual_CalculateController());

  // KEEP THESE:

  bool destination = false;

  List destinationname = [];

  int textFieldindex = 0;

  FocusNode focusNode1 = FocusNode();

  FocusNode focusNode2 = FocusNode();

  int selectedIndex = 0;

  var decodeUid;

  var userid;

  ColorNotifier notifier = ColorNotifier();
  Future<void> calculateDistance() async {
    final locationState = context.read<LocationState>();

    double distanceInMeters = Geolocator.distanceBetween(
      locationState.latitudePick,
      locationState.longitudePick,
      locationState.latitudeDrop,
      locationState.longitudeDrop,
    );

    double distanceInKilometers = distanceInMeters / 1000;

    print("Distance: $distanceInKilometers km");
  }

  @override
  void initState() {
    super.initState();

    datagetfunction();

    print("******:----suryo:---- ${widget.bidding}");

    fun().then((value) {
      setState(() {});

      final locationState = context.read<LocationState>();

      getCurrentLatAndLong(
          locationState.latitudePick, locationState.longitudePick);
    });

    print("********** bidding **********:--- (${widget.bidding})");
  }

  Future fun() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {}

    var currentLocation = await locateUser();

    debugPrint('location: ${currentLocation.latitude}');

    getCurrentLatAndLong(
        currentLocation.latitude, currentLocation.longitude); // ✅ CORRECT

    print("????????????${currentLocation.longitude}");

    final locationState = context.read<LocationState>();

    print(
        "SECOND USER hhhhhhhhhhhhhh CURRENT LOCATION : --  ${locationState.addressPickup}"); // ✅ PROVIDER
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getCurrentLatAndLong(double latitude, double longitude) async {
    if (mounted) {
      context
          .read<LocationState>()
          .setPickupLocation(latitude, longitude, "Current Location", "");
    }
    await placemarkFromCoordinates(latitude, longitude)
        .then((List<Placemark> placemarks) {
      String address =
          '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.country}';

      // Update address in provider too
      if (mounted) {
        context.read<LocationState>().setAddressPickup(address);
      }
    });
  }

  submitDataName() {
    destinationname = [];

    final dynamicFields = context.read<DynamicFieldsState>();

    for (int a = 0; a < dynamicFields.textFieldList.length; a++) {
      if (dynamicFields
          .textFieldList[a].destinationcontroller.text.isNotEmpty) {
        destinationname
            .add(dynamicFields.textFieldList[a].destinationcontroller.text);

        textFieldindex = a;
      }
    }

    setState(() {});
  }

  datagetfunction() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("userLogin");

    decodeUid = jsonDecode(uid!);
    userid = decodeUid['id'];
    print("++Pickup_and_drop++:---  ${userid}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    return Consumer2<LocationState, DynamicFieldsState>(
        builder: (context, locationState, dynamicFields, child) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(15),
          topLeft: Radius.circular(15),
        ),
        child: WillPopScope(
          onWillPop: () async {
            Get.offAll(const ModernMapScreen(
              selectVehicle: false,
            ));
            return false;
          },
          child: Scaffold(
            backgroundColor: notifier.background,
            body: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15),
                topLeft: Radius.circular(15),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.offAll(const ModernMapScreen(
                                    selectVehicle: false,
                                  ));
                                  print(
                                      "++++locationState.dropController++++:--- ${locationState.dropController.text}");
                                },
                                child: Image(
                                  image: AssetImage("assets/arrow-left.png"),
                                  height: 25,
                                  color: notifier.textColor,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Consumer<LocationState>(
                                builder: (context, locationState, child) {
                                  return !locationState.picAndDrop
                                      ? Text("Pickup".tr,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: notifier.textColor))
                                      : Text("Drop".tr,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: notifier.textColor));
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
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
                                        dynamicFields.textFieldList.isNotEmpty
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
                                        dynamicFields.textFieldList.isEmpty
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
                                        Consumer<LocationState>(builder:
                                            (context, locationState, child) {
                                          return TextField(
                                            style: TextStyle(
                                                color: notifier.textColor),
                                            controller:
                                                locationState.pickupController,
                                            onTap: () {
                                              setState(() {
                                                locationState
                                                    .setPicAndDrop(false);

                                                uthertextfilde = false;
                                              });
                                            },
                                            onChanged: (value) {
                                              setState(() {
                                                mapSuggestGetApiController
                                                    .mapApi(
                                                        context: context,
                                                        suggestkey: locationState
                                                            .pickupController
                                                            .text);
                                              });
                                            },
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 10),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                      color: Colors.pink),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                  borderSide: BorderSide(
                                                      color: theamcolore),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey
                                                          .withOpacity(0.4)),
                                                ),
                                                hintText:
                                                    "Searching for you on the map..."
                                                        .tr,
                                                hintStyle: TextStyle(
                                                    color: notifier.textColor),
                                                suffixIcon: locationState
                                                        .pickupController
                                                        .text
                                                        .isEmpty
                                                    ? const SizedBox()
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(13),
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              locationState
                                                                  .pickupController
                                                                  .clear();
                                                            });
                                                          },
                                                          child: Container(
                                                            height: 20,
                                                            width: 20,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.2),
                                                                shape: BoxShape
                                                                    .circle),
                                                            child: Center(
                                                              child: Image(
                                                                image: AssetImage(
                                                                    "assets/close.png"),
                                                                height: 15,
                                                                color: notifier
                                                                    .textColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                labelStyle: const TextStyle(
                                                    color: Color(0xFF424242))),
                                          );
                                        }),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        TextField(
                                          controller:
                                              locationState.dropController,
                                          onTap: () {
                                            setState(() {
                                              locationState.setPicAndDrop(true);

                                              uthertextfilde = false;
                                            });
                                          },
                                          style: TextStyle(
                                              color: notifier.textColor),
                                          onChanged: (value) {
                                            setState(() {
                                              mapSuggestGetApiController.mapApi(
                                                  context: context,
                                                  suggestkey: locationState
                                                      .dropController.text);
                                              print(
                                                  "++++locationState.dropController++++:--- ${locationState.dropController.text}");
                                            });
                                          },
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 10),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                    color: Colors.pink),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                borderSide: BorderSide(
                                                    color: theamcolore),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                    color: Colors.grey
                                                        .withOpacity(0.4)),
                                              ),
                                              hintText: "Drop location".tr,
                                              hintStyle: TextStyle(
                                                  color: notifier.textColor),
                                              suffixIcon: locationState
                                                      .dropController
                                                      .text
                                                      .isEmpty
                                                  ? const SizedBox()
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              13),
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            locationState
                                                                .dropController
                                                                .clear();
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 20,
                                                          width: 20,
                                                          decoration: BoxDecoration(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.2),
                                                              shape: BoxShape
                                                                  .circle),
                                                          child: Center(
                                                            child: Image(
                                                              image: AssetImage(
                                                                  "assets/close.png"),
                                                              height: 15,
                                                              color: notifier
                                                                  .textColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                              labelStyle: const TextStyle(
                                                color: Color(0xFF424242),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          dynamicFields.textFieldList.isEmpty
                              ? const SizedBox()
                              : Consumer<DynamicFieldsState>(
                                  builder: (context, dynamicFields, child) {
                                  return ListView.builder(
                                    itemCount:
                                        dynamicFields.textFieldList.length,
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
                                                  offset: const Offset(-5, -15),
                                                  child: Column(
                                                    children: [
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
                                            flex: 8,
                                            child: Transform.translate(
                                              offset: const Offset(0, -7),
                                              child: dynamicFields
                                                  .textFieldList[index],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedIndex = index;
                                              });

                                              setState(() {
                                                dynamicFields
                                                    .removeTextField(index);

                                                // Remove corresponding location data

                                                if (index <
                                                    locationState
                                                        .dropTitleList.length) {
                                                  locationState.dropTitleList
                                                      .removeAt(index);
                                                }

                                                if (index <
                                                    locationState.destinationLat
                                                        .length) {
                                                  final newDestinationLat =
                                                      List<PointLatLng>.from(
                                                          locationState
                                                              .destinationLat);

                                                  newDestinationLat
                                                      .removeAt(index);

                                                  locationState
                                                      .updateDestinationLat(
                                                          newDestinationLat);
                                                }

                                                if (index <
                                                    locationState
                                                        .onlyPass.length) {
                                                  locationState.onlyPass
                                                      .removeAt(index);
                                                }

                                                print(
                                                    ">>>>>>>>>>>>>>>>textFieldList<<<<<<<<<<<<<<<< ${dynamicFields.textFieldList}");

                                                print(
                                                    ">>>>>>>>>>>>>>>>onlypass<<<<<<<<<<<<<<<< ${locationState.onlyPass}");

                                                print(
                                                    ">>>>>>>>>>>>>>>>destinationlat<<<<<<<<<<<<<<<< ${locationState.destinationLat}");

                                                print(
                                                    ">>>>>>>>>>>>>>>>dropTitleList<<<<<<<<<<<<<<<< ${locationState.dropTitleList}");
                                              });
                                            },
                                            child: Transform.translate(
                                              offset: const Offset(0, -9),
                                              child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      shape: BoxShape.circle),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Image(
                                                      image: AssetImage(
                                                          "assets/close.png"),
                                                      height: 15,
                                                      color: notifier.textColor,
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CustomLocationSelectScreen(
                                          bidding: widget.bidding,
                                          pagestate: widget.pagestate,
                                        ),
                                      ));
                                },
                                child: Container(
                                  height: 40,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.4)),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.pin_drop_outlined,
                                          color: notifier.textColor,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Select on map".tr,
                                          style: TextStyle(
                                              color: notifier.textColor),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              widget.pagestate == true
                                  ? const SizedBox()
                                  : InkWell(
                                      onTap: () {
                                        context
                                            .read<DynamicFieldsState>()
                                            .addTextField();
                                        setState(() {
                                          uthertextfilde = true;
                                        });
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  Colors.grey.withOpacity(0.4)),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              height: 20,
                                              width: 20,
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(
                                                color: Colors.deepOrangeAccent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Add a destination".tr,
                                              style: TextStyle(
                                                  color: notifier.textColor),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                            ],
                          ),
                          const SizedBox(height: 10),
                          uthertextfilde == true
                              ? const SizedBox()
                              : locationState.picAndDrop == true
                                  ? const SizedBox()
                                  : locationState.pickupController.text.isEmpty
                                      ? const SizedBox()
                                      : GetBuilder<MapSuggestGetApiController>(
                                          builder:
                                              (mapSuggestGetApiController) {
                                          return mapSuggestGetApiController
                                                  .isLoading
                                              ? const ModernLoadingWidget(
                                                  size: 60,
                                                  message: "جاري التحميل...",
                                                )
                                              : ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      mapSuggestGetApiController
                                                          .mapApiModel!
                                                          .results
                                                          ?.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        print(
                                                            "****:--- ${mapSuggestGetApiController.mapApiModel!.results?[index].name}");
                                                        setState(() {
                                                          final lat =
                                                              mapSuggestGetApiController
                                                                  .mapApiModel!
                                                                  .results![
                                                                      index]
                                                                  .geometry!
                                                                  .location!
                                                                  .lat!;

                                                          final lng =
                                                              mapSuggestGetApiController
                                                                  .mapApiModel!
                                                                  .results![
                                                                      index]
                                                                  .geometry!
                                                                  .location!
                                                                  .lng!;

                                                          final title =
                                                              mapSuggestGetApiController
                                                                  .mapApiModel!
                                                                  .results![
                                                                      index]
                                                                  .name!;

                                                          final subtitle =
                                                              mapSuggestGetApiController
                                                                  .mapApiModel!
                                                                  .results![
                                                                      index]
                                                                  .formattedAddress!;
                                                          context
                                                              .read<
                                                                  LocationState>()
                                                              .setPickupLocation(
                                                                  lat,
                                                                  lng,
                                                                  title,
                                                                  subtitle);

                                                          print(
                                                              " {{{{{PICK LAT}}}}} :- (${locationState.latitudePick})");

                                                          print(
                                                              " {{{{{PICK LONG}}}}} :- (${locationState.longitudePick})");

                                                          mapSuggestGetApiController
                                                              .mapApiModel
                                                              ?.results
                                                              ?.clear();
                                                          focusNode1.unfocus();
                                                          if (locationState
                                                                  .pickupController
                                                                  .text
                                                                  .isNotEmpty &&
                                                              locationState
                                                                  .dropController
                                                                  .text
                                                                  .isNotEmpty) {
                                                            print(
                                                                "++++++++++++++++done++++++++++++++++");

                                                            // Show loading before navigation

                                                            LoadingService
                                                                .showLoadingDialog(
                                                              context: context,
                                                              message:
                                                                  "جاري تحضير الخريطة...",
                                                              customAnimation:
                                                                  'assets/lottie/loading.json',
                                                              dismissible:
                                                                  false,
                                                            );

                                                            LoadingService.hide(
                                                                context);

                                                            // Add small delay to ensure loading shows

                                                            Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        500));

                                                            SocketService
                                                                .instance
                                                                .disconnect();

                                                            if (widget
                                                                    .bidding ==
                                                                "1") {
                                                              // Hide loading before navigation

                                                              LoadingService
                                                                  .hide(
                                                                      context);

                                                              Get.offAll(
                                                                  const ModernMapScreen(
                                                                      selectVehicle:
                                                                          false));
                                                            } else if (widget
                                                                    .pagestate ==
                                                                true) {
                                                              // Hide loading before navigation

                                                              LoadingService
                                                                  .hide(
                                                                      context);

                                                              // Handle other navigation logic
                                                            }
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        width: Get.width,
                                                        margin: EdgeInsets.only(
                                                            top: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: notifier
                                                              .containercolore,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.4)),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10,
                                                                      right: 10,
                                                                      top: 10,
                                                                      bottom:
                                                                          10),
                                                              child: ListTile(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                leading: Image(
                                                                  image: AssetImage(
                                                                      "assets/location-pin.png"),
                                                                  height: 25,
                                                                  color: notifier
                                                                      .textColor,
                                                                ),
                                                                title: Transform
                                                                    .translate(
                                                                        offset: const Offset(
                                                                            -10,
                                                                            0),
                                                                        child:
                                                                            Text(
                                                                          "${mapSuggestGetApiController.mapApiModel!.results?[index].name}",
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              color: notifier.textColor),
                                                                        )),
                                                                subtitle: Transform
                                                                    .translate(
                                                                        offset: const Offset(
                                                                            -10,
                                                                            5),
                                                                        child:
                                                                            Text(
                                                                          "${mapSuggestGetApiController.mapApiModel!.results?[index].formattedAddress}",
                                                                          style: const TextStyle(
                                                                              color: Colors.grey,
                                                                              fontSize: 12),
                                                                          maxLines:
                                                                              2,
                                                                        )),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                        }),
                          uthertextfilde == true
                              ? const SizedBox()
                              : locationState.picAndDrop == false
                                  ? const SizedBox()
                                  : locationState.dropController.text.isEmpty
                                      ? const SizedBox()
                                      : GetBuilder<MapSuggestGetApiController>(
                                          builder:
                                              (mapSuggestGetApiController) {
                                          return mapSuggestGetApiController
                                                  .isLoading
                                              ? const ModernLoadingWidget(
                                                  size: 60,
                                                  message: "جاري التحميل...",
                                                )
                                              : ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      mapSuggestGetApiController
                                                          .mapApiModel!
                                                          .results
                                                          ?.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          // ✅ USE PROVIDERS for location data

                                                          final lat =
                                                              mapSuggestGetApiController
                                                                  .mapApiModel!
                                                                  .results![
                                                                      index]
                                                                  .geometry!
                                                                  .location!
                                                                  .lat!;

                                                          final lng =
                                                              mapSuggestGetApiController
                                                                  .mapApiModel!
                                                                  .results![
                                                                      index]
                                                                  .geometry!
                                                                  .location!
                                                                  .lng!;

                                                          final title =
                                                              mapSuggestGetApiController
                                                                  .mapApiModel!
                                                                  .results![
                                                                      index]
                                                                  .name!;

                                                          final subtitle =
                                                              mapSuggestGetApiController
                                                                  .mapApiModel!
                                                                  .results![
                                                                      index]
                                                                  .formattedAddress!;

                                                          context
                                                              .read<
                                                                  LocationState>()
                                                              .setDropLocation(
                                                                  lat,
                                                                  lng,
                                                                  title,
                                                                  subtitle);

                                                          // ✅ USE GLOBALS for pricing/vehicle data (no providers yet)

                                                          if (locationState
                                                                  .pickupController
                                                                  .text
                                                                  .isNotEmpty &&
                                                              locationState
                                                                  .dropController
                                                                  .text
                                                                  .isNotEmpty) {
                                                            SocketService
                                                                .instance
                                                                .disconnect();

                                                            widget.bidding ==
                                                                    "1"
                                                                ? calculateController
                                                                    .calculateApi(
                                                                        context:
                                                                            context,
                                                                        uid: userid
                                                                            .toString(),
                                                                        mid:
                                                                            mid, // ✅ GLOBAL - no provider yet

                                                                        mrole:
                                                                            mroal, // ✅ GLOBAL - no provider yet

                                                                        pickup_lat_lon:
                                                                            "${locationState.latitudePick},${locationState.longitudePick}", // ✅ PROVIDER

                                                                        drop_lat_lon:
                                                                            "${locationState.latitudeDrop},${locationState.longitudeDrop}", // ✅ PROVIDER

                                                                        drop_lat_lon_list:
                                                                            locationState
                                                                                .onlyPass // ✅ PROVIDER

                                                                        )
                                                                    .then(
                                                                        (value) {
                                                                    if (value !=
                                                                            null &&
                                                                        value["Result"] ==
                                                                            true) {
                                                                      // ✅ KEEP THESE GLOBALS - no providers yet

                                                                      dropprice =
                                                                          value[
                                                                              "drop_price"];

                                                                      minimumfare =
                                                                          value["vehicle"]
                                                                              [
                                                                              "minimum_fare"];

                                                                      maximumfare =
                                                                          value["vehicle"]
                                                                              [
                                                                              "maximum_fare"];

                                                                      responsemessage =
                                                                          value[
                                                                              "message"];

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
                                                                          safeParseDouble(
                                                                              value["drop_price"]);

                                                                      totalkm =
                                                                          safeParseDouble(
                                                                              value["tot_km"]);

                                                                      tot_secound =
                                                                          "0";

                                                                      vihicalimage =
                                                                          value["vehicle"]["map_img"]
                                                                              .toString();

                                                                      vihicalname =
                                                                          value["vehicle"]["name"]
                                                                              .toString();

                                                                      setState(
                                                                          () {
                                                                        amountresponse =
                                                                            "true"; // ✅ GLOBAL - no provider yet
                                                                      });
                                                                    }
                                                                  })
                                                                : modual_calculateController
                                                                    .modualcalculateApi(
                                                                        context:
                                                                            context,
                                                                        uid: userid
                                                                            .toString(),
                                                                        mid:
                                                                            mid,
                                                                        mrole:
                                                                            mroal,
                                                                        pickup_lat_lon:
                                                                            "${locationState.latitudePick},${locationState.longitudePick}",
                                                                        drop_lat_lon:
                                                                            "${locationState.latitudeDrop},${locationState.longitudeDrop}",
                                                                        drop_lat_lon_list:
                                                                            locationState.onlyPass)
                                                                    .then(
                                                                    (value) {
                                                                      totalkm = safeParseDouble(modual_calculateController
                                                                          .modualCalculateApiModel!
                                                                          .caldriver![
                                                                              index]
                                                                          .dropKm); // ✅ Safe
                                                                      tot_time = modual_calculateController
                                                                          .modualCalculateApiModel!
                                                                          .caldriver![
                                                                              0]
                                                                          .dropTime!
                                                                          .toString();
                                                                      tot_hour = modual_calculateController
                                                                          .modualCalculateApiModel!
                                                                          .caldriver![
                                                                              0]
                                                                          .dropHour!
                                                                          .toString();
                                                                      tot_secound =
                                                                          "0";
                                                                      vihicalname = modual_calculateController
                                                                          .modualCalculateApiModel!
                                                                          .caldriver![
                                                                              0]
                                                                          .name!
                                                                          .toString();
                                                                      vihicalimage = modual_calculateController
                                                                          .modualCalculateApiModel!
                                                                          .caldriver![
                                                                              0]
                                                                          .image!
                                                                          .toString();
                                                                      vehicle_id = modual_calculateController
                                                                          .modualCalculateApiModel!
                                                                          .caldriver![
                                                                              0]
                                                                          .id!
                                                                          .toString();

                                                                      print(
                                                                          "GOGOGOGOGOGOGOGOGOGOGOGOG:- ${midseconde}");
                                                                      print(
                                                                          "GOGOGOGOGOGOGOGOGOGOGOGOG:- ${vihicalrice}");
                                                                    },
                                                                  );
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        width: Get.width,
                                                        margin: EdgeInsets.only(
                                                            top: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: notifier
                                                              .containercolore,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.4)),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10,
                                                                      right: 10,
                                                                      top: 10,
                                                                      bottom:
                                                                          10),
                                                              child: ListTile(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                leading: Image(
                                                                  image: AssetImage(
                                                                      "assets/location-pin.png"),
                                                                  height: 25,
                                                                  color: notifier
                                                                      .textColor,
                                                                ),
                                                                title: Transform
                                                                    .translate(
                                                                        offset: const Offset(
                                                                            -10,
                                                                            0),
                                                                        child:
                                                                            Text(
                                                                          "${mapSuggestGetApiController.mapApiModel!.results?[index].name}",
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              color: notifier.textColor),
                                                                        )),
                                                                subtitle: Transform
                                                                    .translate(
                                                                        offset: const Offset(
                                                                            -10,
                                                                            5),
                                                                        child:
                                                                            Text(
                                                                          "${mapSuggestGetApiController.mapApiModel!.results?[index].formattedAddress}",
                                                                          style: const TextStyle(
                                                                              color: Colors.grey,
                                                                              fontSize: 12),
                                                                          maxLines:
                                                                              2,
                                                                        )),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                        }),
                          uthertextfilde == false
                              ? const SizedBox()
                              : GetBuilder<MapSuggestGetApiController>(
                                  builder: (mapSuggestGetApiController) {
                                  return mapSuggestGetApiController.isLoading
                                      ? const SizedBox()
                                      : ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: mapSuggestGetApiController
                                              .mapApiModel!.results?.length,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  submitDataName();
                                                  final dynamicFields =
                                                      context.read<
                                                          DynamicFieldsState>();

                                                  final locationState = context
                                                      .read<LocationState>();

                                                  dynamicFields
                                                          .textFieldList[
                                                              textFieldindex]
                                                          .destinationcontroller
                                                          .text =
                                                      mapSuggestGetApiController
                                                          .mapApiModel!
                                                          .results![index]
                                                          .name!;

                                                  final pointLatLng = PointLatLng(
                                                      mapSuggestGetApiController
                                                          .mapApiModel!
                                                          .results![index]
                                                          .geometry!
                                                          .location!
                                                          .lat!,
                                                      mapSuggestGetApiController
                                                          .mapApiModel!
                                                          .results![index]
                                                          .geometry!
                                                          .location!
                                                          .lng!);

                                                  locationState
                                                      .updateDestinationLat([
                                                    ...locationState
                                                        .destinationLat,
                                                    pointLatLng
                                                  ]);

                                                  locationState.onlyPass.add({
                                                    "lat":
                                                        mapSuggestGetApiController
                                                            .mapApiModel!
                                                            .results![index]
                                                            .geometry!
                                                            .location!
                                                            .lat!,
                                                    "long":
                                                        mapSuggestGetApiController
                                                            .mapApiModel!
                                                            .results![index]
                                                            .geometry!
                                                            .location!
                                                            .lng!
                                                  });

                                                  locationState
                                                      .addDropLocation({
                                                    "title":
                                                        mapSuggestGetApiController
                                                            .mapApiModel!
                                                            .results![index]
                                                            .name,
                                                    "subt":
                                                        mapSuggestGetApiController
                                                            .mapApiModel!
                                                            .results![index]
                                                            .formattedAddress
                                                  });
                                                  mapSuggestGetApiController
                                                      .mapApiModel?.results
                                                      ?.clear();
                                                  if (locationState
                                                          .pickupController
                                                          .text
                                                          .isNotEmpty &&
                                                      locationState
                                                          .dropController
                                                          .text
                                                          .isNotEmpty) {
                                                    SocketService.instance
                                                        .disconnect();
                                                    print(
                                                        "++++++++++++++++latitudepick++++++++++++++++ ${locationState.latitudePick}");
                                                    print(
                                                        "++++++++++++++++longitudepick++++++++++++++++ ${locationState.longitudePick}");
                                                    print(
                                                        "++++++++++++++++latitudedrop++++++++++++++++ ${locationState.latitudeDrop}");
                                                    print(
                                                        "++++++++++++++++longitudedrop++++++++++++++++ ${locationState.longitudeDrop}");

                                                    widget.bidding == "1"
                                                        ? Get.offAll(
                                                            const ModernMapScreen(
                                                            selectVehicle:
                                                                false,
                                                          ))
                                                        : Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    HomeScreen(
                                                                        latpic: locationState
                                                                            .latitudePick, // ✅ PROVIDER
                                                                        longpic:
                                                                            locationState
                                                                                .longitudePick, // ✅ PROVIDER
                                                                        latdrop:
                                                                            locationState
                                                                                .latitudeDrop, // ✅ PROVIDER
                                                                        longdrop:
                                                                            locationState
                                                                                .longitudeDrop, // ✅ PROVIDER
                                                                        destinationlat:
                                                                            locationState.destinationLat // ✅ PROVIDER
                                                                        )),
                                                          );
                                                    widget.bidding == "1"
                                                        ? calculateController
                                                            .calculateApi(
                                                                context:
                                                                    context,
                                                                uid: userid
                                                                    .toString(),
                                                                mid: mid,
                                                                mrole: mroal,
                                                                pickup_lat_lon:
                                                                    "${locationState.latitudePick},${locationState.longitudePick}",
                                                                drop_lat_lon:
                                                                    "${locationState.latitudeDrop},${locationState.longitudeDrop}",
                                                                drop_lat_lon_list:
                                                                    locationState
                                                                        .onlyPass
// This will automatically handle string/object conversion

                                                                )
                                                            .then((value) {
                                                            if (value != null &&
                                                                value["Result"] ==
                                                                    true) {
                                                              // Success - update your variables

                                                              dropprice = value[
                                                                  "drop_price"];

                                                              minimumfare = value[
                                                                      "vehicle"]
                                                                  [
                                                                  "minimum_fare"];

                                                              maximumfare = value[
                                                                      "vehicle"]
                                                                  [
                                                                  "maximum_fare"];

                                                              responsemessage =
                                                                  value[
                                                                      "message"];

                                                              tot_hour = value[
                                                                      "tot_hour"]
                                                                  .toString();

                                                              tot_time = value[
                                                                      "tot_minute"]
                                                                  .toString();

                                                              vehicle_id =
                                                                  value["vehicle"]
                                                                          ["id"]
                                                                      .toString();

                                                              vihicalrice =
                                                                  safeParseDouble(
                                                                      value[
                                                                          "drop_price"]);

                                                              totalkm =
                                                                  safeParseDouble(
                                                                      value[
                                                                          "tot_km"]);
                                                              tot_secound = "0";

                                                              vihicalimage = value[
                                                                          "vehicle"]
                                                                      [
                                                                      "map_img"]
                                                                  .toString();

                                                              vihicalname =
                                                                  value["vehicle"]
                                                                          [
                                                                          "name"]
                                                                      .toString();

                                                              setState(() {
                                                                amountresponse =
                                                                    "true";
                                                              });

                                                              print(
                                                                  "********** Success **********");

                                                              print(
                                                                  "Drop price: $dropprice YER");

                                                              print(
                                                                  "Distance: $totalkm km");

                                                              print(
                                                                  "Time: ${tot_hour}h ${tot_time}m");
                                                            } else {
                                                              // Handle different error types

                                                              setState(() {
                                                                amountresponse =
                                                                    "false";
                                                              });

                                                              if (value !=
                                                                      null &&
                                                                  value["message"] !=
                                                                      null) {
                                                                String message =
                                                                    value[
                                                                        "message"];

                                                                if (message
                                                                    .contains(
                                                                        "zone")) {
                                                                  // Zone error - suggest using test coordinates

                                                                  print(
                                                                      "Zone error - coordinates outside service area");
                                                                } else if (message
                                                                    .contains(
                                                                        "Vehicle Not Found")) {
                                                                  print(
                                                                      "Vehicle error - check vehicle ID");
                                                                }
                                                              }
                                                            }
                                                          })
                                                        : modual_calculateController
                                                            .modualcalculateApi(
                                                                context:
                                                                    context,
                                                                uid: userid
                                                                    .toString(),
                                                                mid: mid,
                                                                mrole: mroal,
                                                                pickup_lat_lon:
                                                                    "${locationState.latitudePick},${locationState.longitudePick}",
                                                                drop_lat_lon:
                                                                    "${locationState.latitudeDrop},${locationState.longitudeDrop}",
                                                                drop_lat_lon_list:
                                                                    locationState
                                                                        .onlyPass)
                                                            .then(
                                                            (value) {
                                                              totalkm = double.parse(
                                                                  modual_calculateController
                                                                      .modualCalculateApiModel!
                                                                      .caldriver![
                                                                          0]
                                                                      .dropKm!
                                                                      .toString());
                                                              tot_time = modual_calculateController
                                                                  .modualCalculateApiModel!
                                                                  .caldriver![0]
                                                                  .dropTime!
                                                                  .toString();
                                                              tot_hour = modual_calculateController
                                                                  .modualCalculateApiModel!
                                                                  .caldriver![0]
                                                                  .dropHour!
                                                                  .toString();
                                                              tot_secound = "0";
                                                              vihicalname =
                                                                  modual_calculateController
                                                                      .modualCalculateApiModel!
                                                                      .caldriver![
                                                                          0]
                                                                      .name!
                                                                      .toString();
                                                              vihicalimage =
                                                                  modual_calculateController
                                                                      .modualCalculateApiModel!
                                                                      .caldriver![
                                                                          0]
                                                                      .image!
                                                                      .toString();
                                                              vehicle_id =
                                                                  modual_calculateController
                                                                      .modualCalculateApiModel!
                                                                      .caldriver![
                                                                          0]
                                                                      .id!
                                                                      .toString();
                                                            },
                                                          );
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: Get.width,
                                                margin:
                                                    EdgeInsets.only(top: 10),
                                                decoration: BoxDecoration(
                                                  color:
                                                      notifier.containercolore,
                                                  border: Border.all(
                                                      color: Colors.grey
                                                          .withOpacity(0.4)),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 10,
                                                              bottom: 10),
                                                      child: ListTile(
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        leading: Image(
                                                          image: AssetImage(
                                                              "assets/location-pin.png"),
                                                          height: 25,
                                                          color: notifier
                                                              .textColor,
                                                        ),
                                                        title:
                                                            Transform.translate(
                                                                offset:
                                                                    const Offset(
                                                                        -10, 0),
                                                                child: Text(
                                                                  "${mapSuggestGetApiController.mapApiModel!.results?[index].name}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: notifier
                                                                          .textColor),
                                                                )),
                                                        subtitle:
                                                            Transform.translate(
                                                                offset:
                                                                    const Offset(
                                                                        -10, 5),
                                                                child: Text(
                                                                  "${mapSuggestGetApiController.mapApiModel!.results?[index].formattedAddress}",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          12),
                                                                  maxLines: 2,
                                                                )),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}

bool uthertextfilde = false;

class DynamicWidget extends StatelessWidget {
  MapSuggestGetApiController mapSuggestGetApiController =
      Get.put(MapSuggestGetApiController());
  final TextEditingController destinationcontroller = TextEditingController();
  ColorNotifier notifier = ColorNotifier();
  DynamicWidget({super.key});

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        style: TextStyle(color: notifier.textColor),
        controller: destinationcontroller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '';
          }
          return null;
        },
        onTap: () {
          uthertextfilde = true;
        },
        onChanged: (value) {
          mapSuggestGetApiController.mapApi(
              context: context, suggestkey: destinationcontroller.text);
        },
        decoration: InputDecoration(
            errorStyle: const TextStyle(fontSize: 0.1),
            counterText: "",
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.pink),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: theamcolore),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
            ),
            hintText: 'Destination'.tr,
            hintStyle: TextStyle(color: notifier.textColor)),
      ),
    );
  }
}
