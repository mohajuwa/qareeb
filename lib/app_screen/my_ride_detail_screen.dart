// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
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
  const MyRideDetailScreen(
      {super.key, required this.request_id, required this.status});

  @override
  State<MyRideDetailScreen> createState() => _MyRideDetailScreenState();
}

class _MyRideDetailScreenState extends State<MyRideDetailScreen> {
  @override
  void initState() {
    getdata();
    // TODO: implement initState
    super.initState();
  }

  var decodeUid;
  var userid;
  var currencyy;

  MyRideDetailApiController myRideDetailApiController =
      Get.put(MyRideDetailApiController());

  getdata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("userLogin");
    var currency = preferences.getString("currenci");
    decodeUid = jsonDecode(uid!);
    currencyy = jsonDecode(currency!);
    userid = decodeUid['id'];

    print("++ MyRideDetailScreen ++:---  $userid");
    print("++ MyRideDetailScreen ++:---  $currencyy");
    print("++ request_id ++:---  ${widget.request_id}");
    print("++ widget.status ++:---  ${widget.status}");
    myRideDetailApiController
        .mydetailApi(
            uid: userid.toString(),
            request_id: widget.request_id,
            status: widget.status)
        .then(
      (value) {
        for (int i = 0;
            i <
                myRideDetailApiController
                    .myRideDetailApiModel!.reuqestList!.drop!.length;
            i++) {
          _dropOffPoints.add(PointLatLng(
              double.parse(myRideDetailApiController
                  .myRideDetailApiModel!.reuqestList!.drop![i].latitude
                  .toString()),
              double.parse(myRideDetailApiController
                  .myRideDetailApiModel!.reuqestList!.drop![i].longitude
                  .toString())));
          print("+++++:---- $_dropOffPoints");
        }

        _addMarker(
            LatLng(double.parse(value["Reuqest_list"]["pickup"]["latitude"]),
                double.parse(value["Reuqest_list"]["pickup"]["longitude"])),
            "origin",
            BitmapDescriptor.defaultMarker);

        /// destination marker
        // _addMarker2(LatLng(widget.latdrop, widget.longdrop), "destination", BitmapDescriptor.defaultMarkerWithHue(90));

        for (int a = 0; a < _dropOffPoints.length; a++) {
          _addMarker3("destination");
        }

        getDirections(
            lat1: PointLatLng(
                double.parse(
                  value["Reuqest_list"]["pickup"]["latitude"],
                ),
                double.parse(value["Reuqest_list"]["pickup"]["longitude"])),
            dropOffPoints: _dropOffPoints);
      },
    );
    setState(() {});
  }

  List<PointLatLng> _dropOffPoints = [];

  // Map Code

  late GoogleMapController mapController;

  Map<MarkerId, Marker> markers = {};
  // Set<Marker> markers = {};
  // Set<Marker> markers = Set();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

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

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) async {
    final Uint8List markIcon = await getImages("assets/pickup_marker.png", 80);
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: BitmapDescriptor.fromBytes(markIcon),
      position: position,
      onTap: () {},
    );
    markers[markerId] = marker;
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
        onTap: () {},
      );

      markers[markerId] = marker;
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: theamcolore,
      // points: [...polylineCoordinates,..._dropOffPoints],
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  Future getDirections(
      {required PointLatLng lat1,
      required List<PointLatLng> dropOffPoints}) async {
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
        // Handle the case where no route is found
      }
    }

    addPolyLine(polylineCoordinates);
  }

  // GlobalKey _globalKey = GlobalKey();
  // Uint8List? imageInMemory;
  // String? imagePath;
  // File? capturedFile;

  // Future _capturePng() async {
  //   try {
  //     await [Permission.storage].request();
  //     print('+++++++++++++++++++  inside');
  //     RenderRepaintBoundary boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
  //     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  //     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //     Uint8List pngBytes = byteData!.buffer.asUint8List();
  //
  //     // create file
  //
  //     final String dir = (await getApplicationDocumentsDirectory()).path;
  //     imagePath = '$dir/file_name${DateTime.now()}.png';
  //     capturedFile = File(imagePath!);
  //     await capturedFile!.writeAsBytes(pngBytes);
  //     print(capturedFile!.path);
  //     final result = await ImageGallerySaver.saveImage(pngBytes, quality: 60, name: "file_name${DateTime.now()}");
  //     print(result);
  //     print('png done');
  //     // showToastMessage("Image saved in gallery");
  //     ToastService.showToast(
  //       msg: "Image saved in gallery",
  //     );
  //     return pngBytes;
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return GetBuilder<MyRideDetailApiController>(
      builder: (myRideDetailApiController) {
        return myRideDetailApiController.isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: theamcolore,
              ))
            : Scaffold(
                backgroundColor: notifier.languagecontainercolore,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: notifier.background,
                  automaticallyImplyLeading: false,
                  title: GetBuilder<MyRideDetailApiController>(
                    builder: (myRideDetailApiController) {
                      return Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Image(
                              image: AssetImage("assets/arrow-left.png"),
                              height: 25,
                              color: notifier.textColor,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.id}",
                            style: TextStyle(
                                fontSize: 18, color: notifier.textColor),
                          ),
                          const Spacer(),
                          widget.status == "cancel"
                              ? Container(
                                  height: 30,
                                  width: 100,
                                  decoration: const BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  child: Center(
                                    child: Text(
                                      "cancel".tr,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 30,
                                  width: 100,
                                  decoration: const BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  child: Center(
                                    child: Text(
                                      "Completed".tr,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                        ],
                      );
                    },
                  ),
                ),
                bottomNavigationBar: widget.status == "cancel"
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: CommonButton(
                                        containcolore: theamcolore,
                                        onPressed1: () {
                                          // Get.back();
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                            builder: (context) {
                                              return PdfPreviewPage();
                                            },
                                          ));
                                        },
                                        context: context,
                                        txt1: "Invoice".tr)),
                                const SizedBox(
                                  width: 5,
                                ),
                                myRideDetailApiController.myRideDetailApiModel!
                                            .reuqestList!.reviewCheck ==
                                        0
                                    ? Expanded(
                                        child: CommonButton(
                                            containcolore: Colors.orange,
                                            onPressed1: () {
                                              rateBottomSheet();
                                            },
                                            context: context,
                                            txt1: "Rate your ride".tr))
                                    : SizedBox(),
                              ],
                            )
                          ],
                        ),
                      ),
                body: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      width: Get.width,
                      child: GoogleMap(
                        // mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(
                                double.parse(myRideDetailApiController
                                    .myRideDetailApiModel!
                                    .reuqestList!
                                    .pickup!
                                    .latitude
                                    .toString()),
                                double.parse(myRideDetailApiController
                                    .myRideDetailApiModel!
                                    .reuqestList!
                                    .pickup!
                                    .longitude
                                    .toString())),
                            zoom: 15),
                        myLocationEnabled: true,
                        tiltGesturesEnabled: true,
                        compassEnabled: true,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        onMapCreated: _onMapCreated,
                        markers: Set<Marker>.of(markers.values),
                        polylines: Set<Polyline>.of(polylines.values),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              color: notifier.containercolore,
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  shape: BoxShape.circle),
                                              child: Center(
                                                  child: Container(
                                                height: 10,
                                                width: 10,
                                                decoration: const BoxDecoration(
                                                    color: Colors.green,
                                                    shape: BoxShape.circle),
                                              )),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Pickup".tr,
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                  "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.pickup!.title}",
                                                  style: TextStyle(
                                                      color: notifier.textColor,
                                                      fontSize: 18),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      // scrollDirection: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      clipBehavior: Clip.none,
                                      itemCount: myRideDetailApiController
                                          .myRideDetailApiModel!
                                          .reuqestList!
                                          .drop!
                                          .length,
                                      itemBuilder: (context, index) {
                                        return Row(
                                          children: [
                                            Transform.translate(
                                              offset: const Offset(0, -5),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 8,
                                                    width: 2,
                                                    decoration: const BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                  ),
                                                  const SizedBox(
                                                    height: 2,
                                                  ),
                                                  Container(
                                                    height: 8,
                                                    width: 2,
                                                    decoration: const BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                  ),
                                                  const SizedBox(
                                                    height: 2,
                                                  ),
                                                  Container(
                                                    height: 8,
                                                    width: 2,
                                                    decoration: const BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                  ),
                                                  const SizedBox(
                                                    height: 2,
                                                  ),
                                                  Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .withOpacity(0.2),
                                                        shape: BoxShape.circle),
                                                    child: Center(
                                                        child: Container(
                                                      height: 10,
                                                      width: 10,
                                                      decoration:
                                                          const BoxDecoration(
                                                              color: Colors.red,
                                                              shape: BoxShape
                                                                  .circle),
                                                    )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Destination".tr,
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.drop![index].title}",
                                                      style: TextStyle(
                                                          color: notifier
                                                              .textColor,
                                                          fontSize: 18),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              color: notifier.containercolore,
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "RIDE DETAIL".tr,
                                      style: TextStyle(
                                          color: notifier.textColor,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Ride Type :".tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.mRole}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Car Type :".tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.vehicleName}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "hours / minit :".tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.totHour} hours ${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.totMinute} minit",
                                          style: TextStyle(
                                              color: notifier.textColor,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Date & Time :".tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.startTime}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              color: notifier.containercolore,
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "PAYMENT".tr,
                                      style: TextStyle(
                                          color: notifier.textColor,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Ride Fair :".tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "$currencyy${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.price}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Promo :".tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "$currencyy${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.couponAmount}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "PlatformFee :".tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "$currencyy${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.platformFee}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Weather Price :".tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "$currencyy${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.weatherPrice}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Additional Time Charge (${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.addiTime} mint) :",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "$currencyy${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.addiTimePrice}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Wallet".tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "$currencyy${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.walletPrice}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        myRideDetailApiController
                                                    .myRideDetailApiModel!
                                                    .reuqestList!
                                                    .paidAmount ==
                                                0
                                            ? Text(
                                                "Payment pay (${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.pName})",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: notifier.textColor),
                                              )
                                            : Text(
                                                "Payment pay (${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.pName})",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: notifier.textColor),
                                              ),
                                        const Spacer(),
                                        Text(
                                          "$currencyy${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.paidAmount}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Total :".tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "$currencyy${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.finalPrice}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}






//{
//     "ResponseCode": 200,
//     "Result": true,
//     "message": "Data Load Successful",
//     "Reuqest_list": {
//         "id": 128,
//         "c_id": "20",
//         "d_id": "29",
//         "price": 73.5,
//         "final_price": 117,
//         "coupon_amount": 0,
//         "addi_time_price": 10,
//         "platform_fee": 30,
//         "weather_price": 4,
//         "status": "8",
//         "tot_km": 0.07,
//         "tot_hour": 0,
//         "tot_minute": 2,
//         "m_role": "Vehicle",
//         "vehicle_name": "Auto",
//         "profile_image": "uploads/driver/1725440032362images (1).jpg",
//         "p_image": "uploads/payment_list/1726051224285download.png",
//         "p_name": "Cash",
//         "review_check": 1,
//         "c_title": "",
//         "addi_time": 1,
//         "start_time": "10/04/2024, 06:20 PM",
//         "run_time": {
//             "hour": 0,
//             "minute": 0,
//             "second": 0,
//             "status": 0
//         },
//         "pickup": {
//             "title": "Lajamni Chowk, Surat, India",
//             "subtitle": "",
//             "latitude": "21.2381668",
//             "longitude": "72.8879217"
//         },
//         "drop": [
//             {
//                 "title": "AR Mall and Multiplex",
//                 "subtitle": "opp. panvelpoint, Mota Varachha, Surat, Gujarat 394101, India",
//                 "latitude": "21.2353649",
//                 "longitude": "72.8729176"
//             }
//         ]
//     }
// }













