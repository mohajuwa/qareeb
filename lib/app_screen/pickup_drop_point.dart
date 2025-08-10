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
import 'package:qareeb/common_code/refrish_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/api_code/map_api_get.dart';
import 'package:qareeb/app_screen/custom_location_select_screen.dart';
import 'package:qareeb/app_screen/home_screen.dart';
import '../api_code/calculate_api_controller.dart';
import '../api_code/modual_calculate_api_controller.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';
import 'map_screen.dart';
import 'my_ride_screen.dart';

double latitudepick = 0.00;
double longitudepick = 0.00;
double latitudedrop = 0.00;
double longitudedrop = 0.00;

String picktitle = "";
String picksubtitle = "";

String droptitle = "";
String dropsubtitle = "";

List droptitlelist = [];

List<DynamicWidget> textfieldlist = [];

List<PointLatLng> destinationlat = [];
List onlypass = [];
List<LatLng> destinationlong = [];

bool picanddrop = true;
// bool multilistselection = false;
var addresspickup;

var dropprice;
var minimumfare;
var maximumfare;
String amountresponse = "";
String responsemessage = "";

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

  Future<void> calculateDistance() async {
    double distanceInMeters = Geolocator.distanceBetween(
      latitudepick,
      longitudepick,
      latitudedrop,
      longitudedrop,
    );

    double distanceInKilometers = distanceInMeters / 1000;

    print("Distance: $distanceInKilometers km");
  }

  @override
  void initState() {
    super.initState();

    datagetfunction();
    print("******:----suryo:---- ${widget.bidding}");
    fun().then(
      (value) {
        setState(() {});
        getCurrentLatAndLong(latitudepick, longitudepick);
      },
    );
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
      currentLocation.latitude,
      currentLocation.longitude,
    );

    print("????????????${currentLocation.longitude}");
    print("SECOND USER hhhhhhhhhhhhhh CURRENT LOCATION : --  $addresspickup");
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getCurrentLatAndLong(double latitude, double longitude) async {
    latitudepick = latitude;
    longitudepick = longitude;

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
    print("++Pickup_and_drop++:---  ${userid}");
    setState(() {});
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(15),
        topLeft: Radius.circular(15),
      ),
      child: WillPopScope(
        onWillPop: () async {
          Get.offAll(const MapScreen(
            selectvihical: false,
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
                                Get.offAll(const MapScreen(
                                  selectvihical: false,
                                ));
                                print(
                                    "++++appController.dropController++++:--- ${appController.dropController.text}");
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
                            picanddrop == false
                                ? Text("Pickup".tr,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: notifier.textColor))
                                : Text("Drop".tr,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: notifier.textColor)),
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
                                            color: Colors.grey.withOpacity(0.4),
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
                                            color: Colors.grey.withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      textfieldlist.isNotEmpty
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
                                      textfieldlist.isEmpty
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        style: TextStyle(
                                            color: notifier.textColor),
                                        controller:
                                            appController.pickupController,
                                        focusNode: focusNode1,
                                        onTap: () {
                                          setState(() {
                                            picanddrop = false;
                                            uthertextfilde = false;
                                          });
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            mapSuggestGetApiController.mapApi(
                                                context: context,
                                                suggestkey: appController
                                                    .pickupController.text);
                                          });
                                        },
                                        decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.only(left: 10),
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
                                            hintText:
                                                "Searching for you on the map..."
                                                    .tr,
                                            hintStyle: TextStyle(
                                                color: notifier.textColor),
                                            suffixIcon: appController
                                                    .pickupController
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
                                                          appController
                                                              .pickupController
                                                              .clear();
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        decoration:
                                                            BoxDecoration(
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
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextField(
                                        controller:
                                            appController.dropController,
                                        focusNode: focusNode2,
                                        onTap: () {
                                          setState(() {
                                            picanddrop = true;
                                            uthertextfilde = false;
                                          });
                                        },
                                        style: TextStyle(
                                            color: notifier.textColor),
                                        onChanged: (value) {
                                          setState(() {
                                            mapSuggestGetApiController.mapApi(
                                                context: context,
                                                suggestkey: appController
                                                    .dropController.text);
                                            print(
                                                "---:-  ${appController.dropController.text}");
                                          });
                                        },
                                        decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.only(left: 10),
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
                                            suffixIcon: appController
                                                    .dropController.text.isEmpty
                                                ? const SizedBox()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            13),
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          appController
                                                              .dropController
                                                              .clear();
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        decoration:
                                                            BoxDecoration(
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
                        textfieldlist.isEmpty
                            ? const SizedBox()
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: textfieldlist.length,
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
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey
                                                          .withOpacity(0.4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  Container(
                                                    height: 10,
                                                    width: 3,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey
                                                          .withOpacity(0.4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
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
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: Colors.red,
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
                                                            .withOpacity(0.4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
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
                                            droptitlelist.removeAt(index);

                                            print(
                                                ">>>>>>>>>>>>>>>>textfieldlist<<<<<<<<<<<<<<<< ${textfieldlist}");
                                            print(
                                                ">>>>>>>>>>>>>>>>onlypass<<<<<<<<<<<<<<<< ${onlypass}");
                                            print(
                                                ">>>>>>>>>>>>>>>>destinationlat<<<<<<<<<<<<<<<< ${destinationlat}");
                                            print(
                                                ">>>>>>>>>>>>>>>>droptitlelist<<<<<<<<<<<<<<<< ${droptitlelist}");
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
                                                padding: EdgeInsets.all(4.0),
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
                              ),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      setState(() {
                                        textfieldlist.add(DynamicWidget());
                                        uthertextfilde = true;
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Colors.grey.withOpacity(0.4)),
                                        borderRadius: BorderRadius.circular(30),
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
                            : picanddrop == true
                                ? const SizedBox()
                                : appController.pickupController.text.isEmpty
                                    ? const SizedBox()
                                    : GetBuilder<MapSuggestGetApiController>(
                                        builder: (mapSuggestGetApiController) {
                                        return mapSuggestGetApiController
                                                .isLoading
                                            ? CircularProgressIndicator(
                                                color: theamcolore,
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
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      print(
                                                          "****:--- ${mapSuggestGetApiController.mapApiModel!.results?[index].name}");
                                                      setState(() {
                                                        appController
                                                                .pickupController
                                                                .text =
                                                            mapSuggestGetApiController
                                                                .mapApiModel!
                                                                .results![index]
                                                                .name!;
                                                        latitudepick =
                                                            mapSuggestGetApiController
                                                                .mapApiModel!
                                                                .results![index]
                                                                .geometry!
                                                                .location!
                                                                .lat!;
                                                        longitudepick =
                                                            mapSuggestGetApiController
                                                                .mapApiModel!
                                                                .results![index]
                                                                .geometry!
                                                                .location!
                                                                .lng!;

                                                        print(
                                                            " {{{{{PICK LAT}}}}} :- (${latitudepick})");
                                                        print(
                                                            " {{{{{PICK LONG}}}}} :- (${longitudepick})");

                                                        picktitle =
                                                            mapSuggestGetApiController
                                                                .mapApiModel!
                                                                .results![index]
                                                                .name!;
                                                        picksubtitle =
                                                            mapSuggestGetApiController
                                                                .mapApiModel!
                                                                .results![index]
                                                                .formattedAddress!;

                                                        mapSuggestGetApiController
                                                            .mapApiModel
                                                            ?.results
                                                            ?.clear();
                                                        focusNode1.unfocus();
                                                        if (appController
                                                                .pickupController
                                                                .text
                                                                .isNotEmpty &&
                                                            appController
                                                                .dropController
                                                                .text
                                                                .isNotEmpty) {
                                                          driveridloader =
                                                              false;
                                                          socket.close();
                                                          print(
                                                              "++++++++++++++++done++++++++++++++++");
                                                          widget.bidding == "1"
                                                              ? Get.offAll(
                                                                  const MapScreen(
                                                                  selectvihical:
                                                                      false,
                                                                ))
                                                              : widget.pagestate ==
                                                                      true
                                                                  ? Navigator.pop(
                                                                      context,
                                                                      RefreshData(
                                                                          true))
                                                                  : Navigator
                                                                      .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              HomeScreen(
                                                                                latpic: latitudepick,
                                                                                longpic: longitudepick,
                                                                                latdrop: latitudedrop,
                                                                                longdrop: longitudedrop,
                                                                                destinationlat: destinationlat,
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
                                                                      mrole:
                                                                          mroal,
                                                                      pickup_lat_lon:
                                                                          "${latitudepick},${longitudepick}",
                                                                      drop_lat_lon:
                                                                          "${latitudedrop},${longitudedrop}",
                                                                      drop_lat_lon_list:
                                                                          onlypass)
                                                                  .then(
                                                                  (value) {
                                                                    dropprice =
                                                                        0;
                                                                    minimumfare =
                                                                        0;
                                                                    maximumfare =
                                                                        0;

                                                                    if (value[
                                                                            "Result"] ==
                                                                        true) {
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
                                                                          double.parse(
                                                                              value["drop_price"].toString());
                                                                      totalkm =
                                                                          double.parse(
                                                                              value["tot_km"].toString());
                                                                      tot_secound =
                                                                          "0";

                                                                      vihicalimage =
                                                                          value["vehicle"]["map_img"]
                                                                              .toString();
                                                                      vihicalname =
                                                                          value["vehicle"]["name"]
                                                                              .toString();
                                                                    } else {
                                                                      print(
                                                                          "jojojojojojojojojojojojojojojojojojojojojojojojo");
                                                                    }

                                                                    print(
                                                                        "********** dropprice **********:----- ${dropprice}");
                                                                    print(
                                                                        "********** minimumfare **********:----- ${minimumfare}");
                                                                    print(
                                                                        "********** maximumfare **********:----- ${maximumfare}");
                                                                  },
                                                                )
                                                              : modual_calculateController
                                                                  .modualcalculateApi(
                                                                      context:
                                                                          context,
                                                                      uid: userid
                                                                          .toString(),
                                                                      mid: mid,
                                                                      mrole:
                                                                          mroal,
                                                                      pickup_lat_lon:
                                                                          "${latitudepick},${longitudepick}",
                                                                      drop_lat_lon:
                                                                          "${latitudedrop},${longitudedrop}",
                                                                      drop_lat_lon_list:
                                                                          onlypass)
                                                                  .then(
                                                                  (value) {
                                                                    totalkm = (modual_calculateController.modualCalculateApiModel!.caldriver![0].dropKm
                                                                            is num)
                                                                        ? modual_calculateController
                                                                            .modualCalculateApiModel!
                                                                            .caldriver![
                                                                                0]
                                                                            .dropKm!
                                                                            .toDouble()
                                                                        : double.tryParse(modual_calculateController.modualCalculateApiModel!.caldriver![0].dropKm.toString()) ??
                                                                            0.0;

                                                                    tot_time = (modual_calculateController.modualCalculateApiModel!.caldriver![0].dropTime
                                                                            is num)
                                                                        ? modual_calculateController
                                                                            .modualCalculateApiModel!
                                                                            .caldriver![
                                                                                0]
                                                                            .dropTime!
                                                                            .toDouble()
                                                                            .toString()
                                                                        : modual_calculateController
                                                                            .modualCalculateApiModel!
                                                                            .caldriver![0]
                                                                            .dropTime
                                                                            .toString();

                                                                    tot_hour = (modual_calculateController.modualCalculateApiModel!.caldriver![0].dropHour
                                                                            is num)
                                                                        ? modual_calculateController
                                                                            .modualCalculateApiModel!
                                                                            .caldriver![
                                                                                0]
                                                                            .dropHour!
                                                                            .toDouble()
                                                                            .toString()
                                                                        : modual_calculateController
                                                                            .modualCalculateApiModel!
                                                                            .caldriver![0]
                                                                            .dropHour
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
                                                                  },
                                                                );
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      width: Get.width,
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      decoration: BoxDecoration(
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
                                                                    bottom: 10),
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
                                                                      offset:
                                                                          const Offset(
                                                                              -10,
                                                                              0),
                                                                      child:
                                                                          Text(
                                                                        "${mapSuggestGetApiController.mapApiModel!.results?[index].name}",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            color:
                                                                                notifier.textColor),
                                                                      )),
                                                              subtitle: Transform
                                                                  .translate(
                                                                      offset:
                                                                          const Offset(
                                                                              -10,
                                                                              5),
                                                                      child:
                                                                          Text(
                                                                        "${mapSuggestGetApiController.mapApiModel!.results?[index].formattedAddress}",
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.grey,
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
                            : picanddrop == false
                                ? const SizedBox()
                                : appController.dropController.text.isEmpty
                                    ? const SizedBox()
                                    : GetBuilder<MapSuggestGetApiController>(
                                        builder: (mapSuggestGetApiController) {
                                        return mapSuggestGetApiController
                                                .isLoading
                                            ? CircularProgressIndicator(
                                                color: theamcolore,
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
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      print(
                                                          "****:--- ${mapSuggestGetApiController.mapApiModel!.results?[index].name}");
                                                      setState(() {
                                                        print(
                                                            "++++++++++++++++lat++++++++++++++++ ${mapSuggestGetApiController.mapApiModel!.results![index].geometry!.location!.lat!}");
                                                        print(
                                                            "++++++++++++++++lng++++++++++++++++ ${mapSuggestGetApiController.mapApiModel!.results![index].geometry!.location!.lng!}");
                                                        appController
                                                                .dropController
                                                                .text =
                                                            mapSuggestGetApiController
                                                                .mapApiModel!
                                                                .results![index]
                                                                .name!;
                                                        latitudedrop =
                                                            mapSuggestGetApiController
                                                                .mapApiModel!
                                                                .results![index]
                                                                .geometry!
                                                                .location!
                                                                .lat!;
                                                        longitudedrop =
                                                            mapSuggestGetApiController
                                                                .mapApiModel!
                                                                .results![index]
                                                                .geometry!
                                                                .location!
                                                                .lng!;

                                                        print(
                                                            " {{{{{DROP LAT}}}}} :- (${latitudedrop})");
                                                        print(
                                                            " {{{{{DROP LONG}}}}} :- (${longitudedrop})");

                                                        droptitle =
                                                            mapSuggestGetApiController
                                                                .mapApiModel!
                                                                .results![index]
                                                                .name!;
                                                        dropsubtitle =
                                                            mapSuggestGetApiController
                                                                .mapApiModel!
                                                                .results![index]
                                                                .formattedAddress!;

                                                        mapSuggestGetApiController
                                                            .mapApiModel
                                                            ?.results
                                                            ?.clear();
                                                        focusNode2.unfocus();
                                                        if (appController
                                                                .pickupController
                                                                .text
                                                                .isNotEmpty &&
                                                            appController
                                                                .dropController
                                                                .text
                                                                .isNotEmpty) {
                                                          driveridloader =
                                                              false;
                                                          print(
                                                              "++++++++++++++++done++++++++++++++++");

                                                          socket.close();
                                                          widget.bidding == "1"
                                                              ? Get.offAll(
                                                                  const MapScreen(
                                                                  selectvihical:
                                                                      false,
                                                                ))
                                                              : widget.pagestate ==
                                                                      true
                                                                  ? Navigator.pop(
                                                                      context,
                                                                      RefreshData(
                                                                          true))
                                                                  : Navigator
                                                                      .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => HomeScreen(
                                                                              latpic: latitudepick,
                                                                              longpic: longitudepick,
                                                                              latdrop: latitudedrop,
                                                                              longdrop: longitudedrop,
                                                                              destinationlat: destinationlat)),
                                                                    );
                                                          widget.bidding == "1"
                                                              ? calculateController
                                                                  .calculateApi(
                                                                      context:
                                                                          context,
                                                                      uid: userid
                                                                          .toString(),
                                                                      mid: mid,
                                                                      mrole:
                                                                          mroal,
                                                                      pickup_lat_lon:
                                                                          "${latitudepick},${longitudepick}",
                                                                      drop_lat_lon:
                                                                          "${latitudedrop},${longitudedrop}",
                                                                      drop_lat_lon_list:
                                                                          onlypass)
                                                                  .then(
                                                                  (value) {
                                                                    dropprice =
                                                                        0;
                                                                    minimumfare =
                                                                        0;
                                                                    maximumfare =
                                                                        0;

                                                                    if (value[
                                                                            "Result"] ==
                                                                        true) {
                                                                      amountresponse =
                                                                          "true";
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
                                                                          double.parse(
                                                                              value["drop_price"].toString());
                                                                      totalkm =
                                                                          double.parse(
                                                                              value["tot_km"].toString());
                                                                      tot_secound =
                                                                          "0";

                                                                      vihicalimage =
                                                                          value["vehicle"]["map_img"]
                                                                              .toString();
                                                                      vihicalname =
                                                                          value["vehicle"]["name"]
                                                                              .toString();

                                                                      print(
                                                                          ".......>>>>>> ${tot_hour}");
                                                                      print(
                                                                          ".......>>>>>> ${tot_time}");
                                                                      print(
                                                                          ".......>>>>>> ${vehicle_id}");
                                                                      print(
                                                                          ".......>>>>>> ${vihicalrice}");
                                                                      print(
                                                                          ".......>>>>>> ${totalkm}");
                                                                      print(
                                                                          ".......>>>>>> ${totalkm}");
                                                                      print(
                                                                          ".......>>>>>> ${totalkm}");
                                                                    } else {
                                                                      amountresponse =
                                                                          "false";
                                                                      print(
                                                                          "jojojojojojojojojojojojojojojojojojojojojojojojo");
                                                                    }

                                                                    print(
                                                                        "********** dropprice **********:----- ${dropprice}");
                                                                    print(
                                                                        "********** minimumfare **********:----- ${minimumfare}");
                                                                    print(
                                                                        "********** maximumfare **********:----- ${maximumfare}");
                                                                  },
                                                                )
                                                              : modual_calculateController
                                                                  .modualcalculateApi(
                                                                      context:
                                                                          context,
                                                                      uid: userid
                                                                          .toString(),
                                                                      mid: mid,
                                                                      mrole:
                                                                          mroal,
                                                                      pickup_lat_lon:
                                                                          "${latitudepick},${longitudepick}",
                                                                      drop_lat_lon:
                                                                          "${latitudedrop},${longitudedrop}",
                                                                      drop_lat_lon_list:
                                                                          onlypass)
                                                                  .then(
                                                                  (value) {
                                                                    totalkm = (modual_calculateController.modualCalculateApiModel!.caldriver![0].dropKm
                                                                            is num)
                                                                        ? modual_calculateController
                                                                            .modualCalculateApiModel!
                                                                            .caldriver![
                                                                                0]
                                                                            .dropKm!
                                                                            .toDouble()
                                                                        : double.tryParse(modual_calculateController.modualCalculateApiModel!.caldriver![0].dropKm.toString()) ??
                                                                            0.0;

                                                                    tot_time = (modual_calculateController.modualCalculateApiModel!.caldriver![0].dropTime
                                                                            is num)
                                                                        ? modual_calculateController
                                                                            .modualCalculateApiModel!
                                                                            .caldriver![
                                                                                0]
                                                                            .dropTime!
                                                                            .toDouble()
                                                                            .toString()
                                                                        : modual_calculateController
                                                                            .modualCalculateApiModel!
                                                                            .caldriver![0]
                                                                            .dropTime
                                                                            .toString();

                                                                    tot_hour = (modual_calculateController.modualCalculateApiModel!.caldriver![0].dropHour
                                                                            is num)
                                                                        ? modual_calculateController
                                                                            .modualCalculateApiModel!
                                                                            .caldriver![
                                                                                0]
                                                                            .dropHour!
                                                                            .toDouble()
                                                                            .toString()
                                                                        : modual_calculateController
                                                                            .modualCalculateApiModel!
                                                                            .caldriver![0]
                                                                            .dropHour
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
                                                      decoration: BoxDecoration(
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
                                                                    bottom: 10),
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
                                                                      offset:
                                                                          const Offset(
                                                                              -10,
                                                                              0),
                                                                      child:
                                                                          Text(
                                                                        "${mapSuggestGetApiController.mapApiModel!.results?[index].name}",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            color:
                                                                                notifier.textColor),
                                                                      )),
                                                              subtitle: Transform
                                                                  .translate(
                                                                      offset:
                                                                          const Offset(
                                                                              -10,
                                                                              5),
                                                                      child:
                                                                          Text(
                                                                        "${mapSuggestGetApiController.mapApiModel!.results?[index].formattedAddress}",
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.grey,
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
                                                textfieldlist[textFieldindex]
                                                        .destinationcontroller
                                                        .text =
                                                    mapSuggestGetApiController
                                                        .mapApiModel!
                                                        .results![index]
                                                        .name!;
                                                destinationlat.add(PointLatLng(
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
                                                        .lng!));
                                                onlypass.add({
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

                                                droptitlelist.add({
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
                                                if (appController
                                                        .pickupController
                                                        .text
                                                        .isNotEmpty &&
                                                    appController.dropController
                                                        .text.isNotEmpty) {
                                                  driveridloader = false;
                                                  socket.close();
                                                  print(
                                                      "++++++++++++++++latitudepick++++++++++++++++ $latitudepick");
                                                  print(
                                                      "++++++++++++++++longitudepick++++++++++++++++ $longitudepick");
                                                  print(
                                                      "++++++++++++++++latitudedrop++++++++++++++++ $latitudedrop");
                                                  print(
                                                      "++++++++++++++++longitudedrop++++++++++++++++ $longitudedrop");
                                                  widget.bidding == "1"
                                                      ? Get.offAll(
                                                          const MapScreen(
                                                          selectvihical: false,
                                                        ))
                                                      : Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => HomeScreen(
                                                                  latpic:
                                                                      latitudepick,
                                                                  longpic:
                                                                      longitudepick,
                                                                  latdrop:
                                                                      latitudedrop,
                                                                  longdrop:
                                                                      longitudedrop,
                                                                  destinationlat:
                                                                      destinationlat)),
                                                        );
                                                  widget.bidding == "1"
                                                      ? calculateController
                                                          .calculateApi(
                                                              context: context,
                                                              uid: userid
                                                                  .toString(),
                                                              mid: mid,
                                                              mrole: mroal,
                                                              pickup_lat_lon:
                                                                  "${latitudepick},${longitudepick}",
                                                              drop_lat_lon:
                                                                  "${latitudedrop},${longitudedrop}",
                                                              drop_lat_lon_list:
                                                                  onlypass)
                                                          .then(
                                                          (value) {
                                                            dropprice = 0;
                                                            minimumfare = 0;
                                                            maximumfare = 0;

                                                            if (value[
                                                                    "Result"] ==
                                                                true) {
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
                                                              vihicalrice = double
                                                                  .parse(value[
                                                                          "drop_price"]
                                                                      .toString());
                                                              totalkm = double
                                                                  .parse(value[
                                                                          "tot_km"]
                                                                      .toString());
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
                                                            } else {
                                                              print(
                                                                  "jojojojojojojojojojojojojojojojojojojojojojojojo");
                                                            }

                                                            print(
                                                                "********** dropprice **********:----- ${dropprice}");
                                                            print(
                                                                "********** minimumfare **********:----- ${minimumfare}");
                                                            print(
                                                                "********** maximumfare **********:----- ${maximumfare}");
                                                          },
                                                        )
                                                      : modual_calculateController
                                                          .modualcalculateApi(
                                                              context: context,
                                                              uid: userid
                                                                  .toString(),
                                                              mid: mid,
                                                              mrole: mroal,
                                                              pickup_lat_lon:
                                                                  "${latitudepick},${longitudepick}",
                                                              drop_lat_lon:
                                                                  "${latitudedrop},${longitudedrop}",
                                                              drop_lat_lon_list:
                                                                  onlypass)
                                                          .then(
                                                          (value) {
                                                            totalkm = (modual_calculateController
                                                                        .modualCalculateApiModel!
                                                                        .caldriver![
                                                                            0]
                                                                        .dropKm
                                                                    is num)
                                                                ? modual_calculateController
                                                                    .modualCalculateApiModel!
                                                                    .caldriver![
                                                                        0]
                                                                    .dropKm!
                                                                    .toDouble()
                                                                : double.tryParse(modual_calculateController
                                                                        .modualCalculateApiModel!
                                                                        .caldriver![
                                                                            0]
                                                                        .dropKm
                                                                        .toString()) ??
                                                                    0.0;

                                                            tot_time = (modual_calculateController
                                                                        .modualCalculateApiModel!
                                                                        .caldriver![
                                                                            0]
                                                                        .dropTime
                                                                    is num)
                                                                ? modual_calculateController
                                                                    .modualCalculateApiModel!
                                                                    .caldriver![
                                                                        0]
                                                                    .dropTime!
                                                                    .toDouble()
                                                                    .toString()
                                                                : modual_calculateController
                                                                    .modualCalculateApiModel!
                                                                    .caldriver![
                                                                        0]
                                                                    .dropTime
                                                                    .toString();

                                                            tot_hour = (modual_calculateController
                                                                        .modualCalculateApiModel!
                                                                        .caldriver![
                                                                            0]
                                                                        .dropHour
                                                                    is num)
                                                                ? modual_calculateController
                                                                    .modualCalculateApiModel!
                                                                    .caldriver![
                                                                        0]
                                                                    .dropHour!
                                                                    .toDouble()
                                                                    .toString()
                                                                : modual_calculateController
                                                                    .modualCalculateApiModel!
                                                                    .caldriver![
                                                                        0]
                                                                    .dropHour
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
                                              margin: EdgeInsets.only(top: 10),
                                              decoration: BoxDecoration(
                                                color: notifier.containercolore,
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
                                                        color:
                                                            notifier.textColor,
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
