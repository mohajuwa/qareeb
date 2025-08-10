// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/controllers/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/api_code/vihical_calculate_api_controller.dart';
import 'package:qareeb/app_screen/map_screen.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';
import 'package:qareeb/common_code/common_button.dart';
import 'dart:ui' as ui;
import '../api_code/add_vehical_api_controller.dart';
import '../api_code/cancel_rason_request_api_controller.dart';
import '../api_code/coupon_payment_api_contoller.dart';
import '../api_code/home_wallet_api_controller.dart';
import '../api_code/modual_calculate_api_controller.dart';
import '../api_code/vihical_driver_detail_api_controller.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_flow_screen.dart';
import '../common_code/config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'counter_bottom_sheet.dart';
import 'my_ride_screen.dart';

final appController = AppController.instance;

void resetAllRideData() {
  print("--- 🔄 Resetting ALL global ride data by using AppController... ---");

  // Use the centralized controller instead of global variables
  final appController = AppController.instance;
  appController.resetAllRideData();

  // Reset pickup_drop_point.dart variables
  latitudepick = 0.00;
  longitudepick = 0.00;
  latitudedrop = 0.00;
  longitudedrop = 0.00;
  picktitle = "";
  picksubtitle = "";
  droptitle = "";
  dropsubtitle = "";
  droptitlelist.clear();
  destinationlat.clear();
  onlypass.clear();
  destinationlong.clear();
  picanddrop = true;
  amountresponse = "";
  responsemessage = "";

  // Clear controllers
  pickupcontroller.clear();
  dropcontroller.clear();

  print("--- ✅ All ride data reset completed ---");
}

class HomeScreen extends StatefulWidget {
  final double latpic;
  final double longpic;
  final double latdrop;
  final double longdrop;
  final List<PointLatLng> destinationlat;

  const HomeScreen(
      {super.key,
      required this.latpic,
      required this.longpic,
      required this.latdrop,
      required this.longdrop,
      required this.destinationlat});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PointLatLng> _dropOffPoints = [];

  var decodeUid;

  var currencyy;
  socketConnect() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("userLogin");
    var currency = preferences.getString("currenci");
    decodeUid = jsonDecode(uid!);
    currencyy = jsonDecode(currency!);

    useridgloable = decodeUid['id'];
    print("****home screen*****:--- ($useridgloable)");
    print("*********:--- ($currencyy)");

    setState(() {});

    socket.connect();

    _connectSocket();
  }

  @override
  void dispose() {
    socket.dispose(); // or _socket?.close() if it's a socket

    super.dispose();
  }

  _connectSocket() async {
    setState(() {});

    socket.onConnect(
        (data) => print('Connection established Connected home screen'));
    socket.onConnectError((data) => print('Connect Error home screen: $data'));
    socket.onDisconnect(
        (data) => print('Socket.IO server disconnected home screen'));

    print("*********midsecounde*********:--  ($midseconde)");
    print("*********midsecounde*********:--  ($vihicalrice)");
    vihicalCalculateController
        .vihicalcalculateApi(
            uid: useridgloable.toString(),
            mid: "$midseconde",
            pickup_lat_lon: "$latitudepick,$longitudepick",
            drop_lat_lon: "$latitudedrop,$longitudedrop",
            drop_lat_lon_list: onlypass)
        .then(
      (value) {
        print("-----------------:--- $value");

        for (int i = 0;
            i <
                vihicalCalculateController
                    .vihicalCalculateModel!.caldriver!.length;
            i++) {
          vihicallocationsbiddingoff.add(LatLng(
              double.parse(vihicalCalculateController
                  .vihicalCalculateModel!.caldriver![i].latitude!),
              double.parse(vihicalCalculateController
                  .vihicalCalculateModel!.caldriver![i].longitude!)));
          _iconPathsbiddingoff.add(
              "${Config.imageurl}${vihicalCalculateController.vihicalCalculateModel!.caldriver![i].image}");
        }
        _addMarkers();
      },
    );

    socket.on('homemap', (homemap) {
      print("++++++ // ++++ :---  $homemap");
      print("Vehicle is of type: ${homemap.runtimeType}");
      print("Vehicle keys: ${homemap.keys}");
      print("++++stutus+++:-- : ${homemap.keys}");

      vihicallocationsbiddingoff.clear();
      _iconPathsbiddingoff.clear();
      vihicalCalculateController
          .vihicalcalculateApi(
              uid: useridgloable.toString(),
              mid: "$midseconde",
              pickup_lat_lon: "$latitudepick,$longitudepick",
              drop_lat_lon: "$latitudedrop,$longitudedrop",
              drop_lat_lon_list: onlypass)
          .then(
        (value) {
          for (int i = 0;
              i <
                  vihicalCalculateController
                      .vihicalCalculateModel!.caldriver!.length;
              i++) {
            vihicallocationsbiddingoff.add(LatLng(
                double.parse(vihicalCalculateController
                    .vihicalCalculateModel!.caldriver![i].latitude!),
                double.parse(vihicalCalculateController
                    .vihicalCalculateModel!.caldriver![i].longitude!)));
            _iconPathsbiddingoff.add(
                "${Config.imageurl}${vihicalCalculateController.vihicalCalculateModel!.caldriver![i].image}");
          }
          _addMarkers();
        },
      );
    });

    socket.on('acceptvehrequest$useridgloable', (acceptvehrequest) {
      socket.close();

      print("++++++ /acceptvehrequest/ ++++ :---  $acceptvehrequest");
      print("acceptvehrequest is of type: ${acceptvehrequest.runtimeType}");
      print("acceptvehrequest keys: ${acceptvehrequest.keys}");
      print("++++userid+++++: $useridgloable");
      print(
          "++++hjhhhhhhhhhhhhhhhhhh+++++: ${acceptvehrequest["uid"].toString()}");
      print(
          "++++hjhhhhhhhhhhhhhhhhhh+++++: ${acceptvehrequest["uid"].toString()}");
      loadertimer = true;

      appController.requestId.value = acceptvehrequest["request_id"].toString();
      driver_id = acceptvehrequest["uid"].toString();

      if (acceptvehrequest["c_id"]
          .toString()
          .contains(useridgloable.toString())) {
        print("condition done");
        driveridloader == false;
        print("condition done1");
        print("condition done0 ${context}");
        globalDriverAcceptClass.driverdetailfunction(
            context: context,
            lat: widget.latpic,
            long: widget.longpic,
            d_id: acceptvehrequest["uid"].toString(),
            request_id: acceptvehrequest["request_id"].toString());
        print("condition done2");
      } else {
        print("condition not done");
      }
    });
  }

  socateempt() {
    socket.emit('vehiclerequest', {
      'requestid': addVihicalCalculateController.addVihicalCalculateModel!.id,
      'driverid': vihicalCalculateController.vihicalCalculateModel!.driverId,
      'c_id': useridgloable
    });
  }

  String themeForMap = "";

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
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();

    mapThemeStyle(context: context);

    setState(() {});

    socketConnect();

    _dropOffPoints = [];

    _dropOffPoints = widget.destinationlat;
    print("****////***:-----  $_dropOffPoints");

    _addMarker(LatLng(widget.latpic, widget.longpic), "origin",
        BitmapDescriptor.defaultMarker);

    _addMarker2(LatLng(widget.latdrop, widget.longdrop), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));

    for (int a = 0; a < _dropOffPoints.length; a++) {
      _addMarker3("destination");
    }

    getDirections(
        lat1: PointLatLng(widget.latpic, widget.longpic),
        lat2: PointLatLng(widget.latdrop, widget.longdrop),
        dropOffPoints: _dropOffPoints);

    for (int i = 1;
        i < paymentGetApiController.paymentgetwayapi!.paymentList!.length;
        i++) {
      if (int.parse(paymentGetApiController.paymentgetwayapi!.defaultPayment
              .toString()) ==
          paymentGetApiController.paymentgetwayapi!.paymentList![i].id) {
        setState(() {
          payment =
              paymentGetApiController.paymentgetwayapi!.paymentList![i].id!;
          paymentname =
              paymentGetApiController.paymentgetwayapi!.paymentList![i].name!;
          print("+++++$payment");
          print("-----$i");
        });
      }
    }

    print("1111/////1111:---  ${widget.latpic},${widget.longpic}");
    print("2222/////2222:---  ${widget.latdrop},${widget.longdrop}");
    print("3333/////3333:---  $onlypass");
    print("4444/////4444:---  $_dropOffPoints");

    print("()()()()() :---  ${picktitle == "" ? addresspickup : picktitle}");
    print("()()()()() :---  $picksubtitle");
    print("()()()()() :---  $droptitle");
    print("()()()()() :---  $dropsubtitle");
    print("()()()()() :---  $droptitlelist");
    setState(() {});
  }

  late GoogleMapController mapController;

  Map<MarkerId, Marker> markers = {};

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
                        Text(
                          "${picktitle == "" ? "${pickupcontroller.text}" : picktitle}",
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        picksubtitle == ""
                            ? const SizedBox()
                            : Text(
                                picksubtitle,
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
    markers[markerId] = marker;
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
                        Text(
                          "${droptitle}",
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          dropsubtitle,
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
    markers[markerId] = marker;
  }

  _addMarker3(String id) async {
    for (int a = 0; a < _dropOffPoints.length; a++) {
      final Uint8List markIcon = await getImages("assets/drop_marker.png", 80);
      MarkerId markerId = MarkerId(id[a]);

      LatLng position =
          LatLng(_dropOffPoints[a].latitude, _dropOffPoints[a].longitude);

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
                          Text(
                            "${droptitlelist[a]["title"]}",
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${droptitlelist[a]["subt"]}",
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

      markers[markerId] = marker;
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: theamcolore,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  Future getDirections(
      {required PointLatLng lat1,
      required PointLatLng lat2,
      required List<PointLatLng> dropOffPoints}) async {
    List<LatLng> polylineCoordinates = [];
    List<PointLatLng> allPoints = [lat1, lat2, ...dropOffPoints];

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
      } else {}
    }

    addPolyLine(polylineCoordinates);
  }

  String mainAmount = "";
  bool light = true;

  Modual_CalculateController modual_calculateController =
      Get.put(Modual_CalculateController());
  VihicalCalculateController vihicalCalculateController =
      Get.put(VihicalCalculateController());
  AddVihicalCalculateController addVihicalCalculateController =
      Get.put(AddVihicalCalculateController());
  VihicalDriverDetailApiController vihicalDriverDetailApiController =
      Get.put(VihicalDriverDetailApiController());
  PaymentGetApiController paymentGetApiController =
      Get.put(PaymentGetApiController());
  CancelRasonRequestApiController cancelRasonRequestApiController =
      Get.put(CancelRasonRequestApiController());
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());
  HomeWalletApiController homeWalletApiController =
      Get.put(HomeWalletApiController());

  final List<String> _iconPathsbiddingoff = [];

  final List<LatLng> vihicallocationsbiddingoff = [];

  void _addMarkers() async {
    Future<BitmapDescriptor> loadIcon(String url) async {
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

          return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
        } else {
          throw Exception('Failed to load image from $url');
        }
      } catch (e) {
        print("Error loading icon from $url: $e");
        return BitmapDescriptor.defaultMarker;
      }
    }

    final List<BitmapDescriptor> icons = await Future.wait(
      _iconPathsbiddingoff.map((path) => loadIcon(path)),
    );

    setState(() {
      markers.clear();

      _addMarker(LatLng(widget.latpic, widget.longpic), "origin",
          BitmapDescriptor.defaultMarker);

      _addMarker2(LatLng(widget.latdrop, widget.longdrop), "destination",
          BitmapDescriptor.defaultMarkerWithHue(90));

      for (int a = 0; a < _dropOffPoints.length; a++) {
        _addMarker3("destination");
      }

      getDirections(
          lat1: PointLatLng(widget.latpic, widget.longpic),
          lat2: PointLatLng(widget.latdrop, widget.longdrop),
          dropOffPoints: _dropOffPoints);

      for (var i = 0; i < vihicallocationsbiddingoff.length; i++) {
        final markerId = MarkerId('marker_$i');
        final marker = Marker(
          markerId: markerId,
          position: vihicallocationsbiddingoff[i],
          icon: icons[i],
        );
        markers[markerId] = marker; // Add marker to the map
      }
    });
  }

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

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return WillPopScope(
      onWillPop: () async {
        return await Get.offAll(MapScreen(selectvihical: true));
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: notifier.background,
        bottomNavigationBar: GetBuilder<Modual_CalculateController>(
            builder: (modual_calculateController) {
          return modual_calculateController.isLoading
              ? Center(child: CircularProgressIndicator(color: theamcolore))
              : Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 430,
                      width: Get.width,
                      decoration: BoxDecoration(
                        color: notifier.containercolore,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: ListView.separated(
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(height: 15);
                                  },
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: modual_calculateController
                                      .modualCalculateApiModel!
                                      .caldriver!
                                      .length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          select = index;

                                          vihicallocationsbiddingoff.clear();
                                          _iconPathsbiddingoff.clear();
                                          print(
                                              "++++vihicallocationsbiddingoff+++++:-- $vihicallocationsbiddingoff");
                                          print(
                                              "+++++_iconPathsbiddingoff++++++++++:-- $_iconPathsbiddingoff");
                                          setState(() {});

                                          appController.selectedVehicleIndex.value =
                                              modual_calculateController
                                                  .modualCalculateApiModel!
                                                  .caldriver![index]
                                                  .id!;
                                          appController.vehiclePrice.value = double.parse(
                                              modual_calculateController
                                                  .modualCalculateApiModel!
                                                  .caldriver![index]
                                                  .dropPrice!
                                                  .toString());
                                          totalkm = double.parse(
                                              modual_calculateController
                                                  .modualCalculateApiModel!
                                                  .caldriver![index]
                                                  .dropKm!
                                                  .toString());
                                          tot_time = modual_calculateController
                                              .modualCalculateApiModel!
                                              .caldriver![index]
                                              .dropTime!
                                              .toString();
                                          tot_hour = modual_calculateController
                                              .modualCalculateApiModel!
                                              .caldriver![index]
                                              .dropHour!
                                              .toString();
                                          tot_secound = "0";
                                          vihicalname =
                                              modual_calculateController
                                                  .modualCalculateApiModel!
                                                  .caldriver![index]
                                                  .name!
                                                  .toString();
                                          vihicalimage =
                                              modual_calculateController
                                                  .modualCalculateApiModel!
                                                  .caldriver![index]
                                                  .image!
                                                  .toString();
                                          vehicle_id =
                                              modual_calculateController
                                                  .modualCalculateApiModel!
                                                  .caldriver![index]
                                                  .id!
                                                  .toString();

                                          setState(() {});
                                          print(
                                              "+++++dropprice++++++++++:-- $vihicalrice");

                                          vihicalCalculateController
                                              .vihicalcalculateApi(
                                                  uid: useridgloable.toString(),
                                                  mid: midseconde.toString(),
                                                  pickup_lat_lon:
                                                      "$latitudepick,$longitudepick",
                                                  drop_lat_lon:
                                                      "$latitudedrop,$longitudedrop",
                                                  drop_lat_lon_list: onlypass)
                                              .then(
                                            (value) {
                                              setState(() {});

                                              if (value["Result"] == true) {
                                                for (int i = 0;
                                                    i <
                                                        vihicalCalculateController
                                                            .vihicalCalculateModel!
                                                            .caldriver!
                                                            .length;
                                                    i++) {
                                                  vihicallocationsbiddingoff.add(LatLng(
                                                      double.parse(
                                                          vihicalCalculateController
                                                              .vihicalCalculateModel!
                                                              .caldriver![i]
                                                              .latitude!),
                                                      double.parse(
                                                          vihicalCalculateController
                                                              .vihicalCalculateModel!
                                                              .caldriver![i]
                                                              .longitude!)));
                                                  _iconPathsbiddingoff.add(
                                                      "${Config.imageurl}${vihicalCalculateController.vihicalCalculateModel!.caldriver![i].image}");
                                                }
                                                _addMarkers();
                                              } else {
                                                markers.clear();
                                                _addMarker(
                                                    LatLng(widget.latpic,
                                                        widget.longpic),
                                                    "origin",
                                                    BitmapDescriptor
                                                        .defaultMarker);

                                                _addMarker2(
                                                    LatLng(widget.latdrop,
                                                        widget.longdrop),
                                                    "destination",
                                                    BitmapDescriptor
                                                        .defaultMarkerWithHue(
                                                            90));

                                                for (int a = 0;
                                                    a < _dropOffPoints.length;
                                                    a++) {
                                                  _addMarker3("destination");
                                                }

                                                getDirections(
                                                    lat1: PointLatLng(
                                                        widget.latpic,
                                                        widget.longpic),
                                                    lat2: PointLatLng(
                                                        widget.latdrop,
                                                        widget.longdrop),
                                                    dropOffPoints:
                                                        _dropOffPoints);
                                              }
                                            },
                                          );
                                        });
                                      },
                                      child: Container(
                                        height: 80,
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: select == index
                                                  ? theamcolore
                                                  : Colors.grey
                                                      .withOpacity(0.4),
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: ListTile(
                                            leading: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: Image.network(
                                                  "${Config.imageurl}${modual_calculateController.modualCalculateApiModel!.caldriver![index].image}"),
                                            ),
                                            title: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '${modual_calculateController.modualCalculateApiModel!.caldriver![index].name}',
                                                    style: TextStyle(
                                                        color:
                                                            notifier.textColor,
                                                        fontFamily:
                                                            "SofiaProBold",
                                                        fontSize: 16)),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                select == index
                                                    ? SvgPicture.asset(
                                                        "assets/svgpicture/user.svg",
                                                        height: 15,
                                                        color:
                                                            notifier.textColor,
                                                      )
                                                    : const SizedBox(),
                                                select == index
                                                    ? Text(
                                                        "${modual_calculateController.modualCalculateApiModel!.caldriver![index].passengerCapacity}",
                                                        style: TextStyle(
                                                            color: notifier
                                                                .textColor),
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                  '${modual_calculateController.modualCalculateApiModel!.caldriver![index].driPicTime} min away - Drop ${modual_calculateController.modualCalculateApiModel!.caldriver![index].driPicDrop}',
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14)),
                                            ),
                                            trailing: Text(
                                                "$currencyy${modual_calculateController.modualCalculateApiModel!.caldriver![index].dropPrice}",
                                                style: TextStyle(
                                                    color: notifier.textColor,
                                                    fontSize: 16)),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                            const SizedBox(
                              height: 130,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                          color: notifier.containercolore,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0, -0.4),
                                blurRadius: 5),
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15)),
                                        ),
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                            return ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15),
                                                      topRight:
                                                          Radius.circular(15)),
                                              child: Scaffold(
                                                backgroundColor:
                                                    notifier.background,
                                                floatingActionButtonLocation:
                                                    FloatingActionButtonLocation
                                                        .centerDocked,
                                                floatingActionButton: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10,
                                                          left: 10,
                                                          right: 10),
                                                  child: CommonButton(
                                                      containcolore:
                                                          theamcolore,
                                                      onPressed1: () {
                                                        Get.back();
                                                      },
                                                      txt1: "CONTINUE".tr,
                                                      context: context),
                                                ),
                                                body: Container(
                                                  decoration: BoxDecoration(
                                                    color: notifier
                                                        .containercolore,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(15),
                                                            topRight:
                                                                Radius.circular(
                                                                    15)),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            bottom: 50),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        const SizedBox(
                                                          height: 13,
                                                        ),
                                                        Text(
                                                            'Payment Getway Method'
                                                                .tr,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "SofiaProBold",
                                                                fontSize: 18,
                                                                color: notifier
                                                                    .textColor)),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        walleteamount == 0
                                                            ? const SizedBox()
                                                            : Row(
                                                                children: [
                                                                  SvgPicture
                                                                      .asset(
                                                                    "assets/svgpicture/wallet.svg",
                                                                    height: 30,
                                                                    color:
                                                                        theamcolore,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                    "My Wallet ($currencyy$walleteamount)",
                                                                    style: TextStyle(
                                                                        color: notifier
                                                                            .textColor),
                                                                  ),
                                                                  const Spacer(),
                                                                  Transform
                                                                      .scale(
                                                                    scale: 0.8,
                                                                    child:
                                                                        CupertinoSwitch(
                                                                      value:
                                                                          switchValue,
                                                                      activeColor:
                                                                          theamcolore,
                                                                      onChanged:
                                                                          (bool
                                                                              value) {
                                                                        setState(
                                                                            () {
                                                                          switchValue =
                                                                              value;
                                                                        });
                                                                      },
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Expanded(
                                                          child: ListView
                                                              .separated(
                                                                  separatorBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return const SizedBox(
                                                                        width:
                                                                            0);
                                                                  },
                                                                  shrinkWrap:
                                                                      true,
                                                                  scrollDirection:
                                                                      Axis
                                                                          .vertical,
                                                                  itemCount: paymentGetApiController
                                                                      .paymentgetwayapi!
                                                                      .paymentList!
                                                                      .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    return InkWell(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          payment = paymentGetApiController
                                                                              .paymentgetwayapi!
                                                                              .paymentList![index]
                                                                              .id!;
                                                                          paymentname = paymentGetApiController
                                                                              .paymentgetwayapi!
                                                                              .paymentList![index]
                                                                              .name!;
                                                                        });
                                                                      },
                                                                      child: paymentGetApiController.paymentgetwayapi!.paymentList![index].status ==
                                                                              "0"
                                                                          ? const SizedBox()
                                                                          : Container(
                                                                              height: 90,
                                                                              margin: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                                                                              padding: const EdgeInsets.all(5),
                                                                              decoration: BoxDecoration(
                                                                                border: Border.all(color: payment == paymentGetApiController.paymentgetwayapi!.paymentList![index].id! ? theamcolore : Colors.grey.withOpacity(0.4)),
                                                                                borderRadius: BorderRadius.circular(15),
                                                                              ),
                                                                              child: Center(
                                                                                child: ListTile(
                                                                                  leading: Transform.translate(
                                                                                    offset: const Offset(-5, 0),
                                                                                    child: Container(
                                                                                      height: 100,
                                                                                      width: 60,
                                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.4)), image: DecorationImage(image: NetworkImage('${Config.imageurl}${paymentGetApiController.paymentgetwayapi!.paymentList![index].image}'))),
                                                                                    ),
                                                                                  ),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(bottom: 4),
                                                                                    child: Text(
                                                                                      paymentGetApiController.paymentgetwayapi!.paymentList![index].name.toString(),
                                                                                      style: TextStyle(fontSize: 16, fontFamily: "SofiaProBold", color: notifier.textColor),
                                                                                      maxLines: 2,
                                                                                    ),
                                                                                  ),
                                                                                  subtitle: Padding(
                                                                                    padding: const EdgeInsets.only(bottom: 4),
                                                                                    child: Text(
                                                                                      paymentGetApiController.paymentgetwayapi!.paymentList![index].subTitle.toString(),
                                                                                      style: TextStyle(fontSize: 12, fontFamily: "SofiaProBold", color: notifier.textColor),
                                                                                      maxLines: 2,
                                                                                    ),
                                                                                  ),
                                                                                  trailing: Radio(
                                                                                    value: payment == paymentGetApiController.paymentgetwayapi!.paymentList![index].id! ? true : false,
                                                                                    fillColor: MaterialStatePropertyAll(theamcolore),
                                                                                    groupValue: true,
                                                                                    onChanged: (value) {
                                                                                      print(value);
                                                                                      setState(() {
                                                                                        selectedOption = value.toString();
                                                                                        selectBoring = paymentGetApiController.paymentgetwayapi!.paymentList![index].image.toString();
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                    );
                                                                  }),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                      );
                                    },
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Image(
                                        image: AssetImage("assets/payment.png"),
                                        height: 30,
                                        width: 30,
                                      ),
                                      title: Transform.translate(
                                          offset: const Offset(-15, 0),
                                          child: Text(
                                            "${paymentname}",
                                            style: TextStyle(
                                                color: notifier.textColor),
                                          )),
                                      trailing: Image(
                                        image: AssetImage(
                                            "assets/angle-right-small.png"),
                                        height: 30,
                                        color: notifier.textColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            mainamount = vihicalrice.toString();
                                            if (couponadd.isEmpty) {
                                              for (int i = 0;
                                                  i <
                                                      paymentGetApiController
                                                          .paymentgetwayapi!
                                                          .couponList!
                                                          .length;
                                                  i++) {
                                                couponadd.add(false);
                                              }
                                            }
                                          });

                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight:
                                                      Radius.circular(15)),
                                            ),
                                            context: context,
                                            builder: (BuildContext context) {
                                              return StatefulBuilder(
                                                  builder: (context, setState) {
                                                return Scaffold(
                                                  backgroundColor:
                                                      notifier.containercolore,
                                                  appBar: AppBar(
                                                    elevation: 0,
                                                    toolbarHeight: 90,
                                                    backgroundColor: notifier
                                                        .containercolore,
                                                    automaticallyImplyLeading:
                                                        false,
                                                    leading: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 40,
                                                              left: 18,
                                                              right: 18),
                                                      child: InkWell(
                                                          onTap: () {
                                                            Get.back();
                                                          },
                                                          child: Image(
                                                            image: AssetImage(
                                                                "assets/arrow-left.png"),
                                                            color: notifier
                                                                .textColor,
                                                          )),
                                                    ),
                                                    title: Transform.translate(
                                                        offset: const Offset(
                                                            -10, 0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 40),
                                                          child: Text(
                                                            "All coupons".tr,
                                                            style: TextStyle(
                                                                color: notifier
                                                                    .textColor,
                                                                fontSize: 18),
                                                          ),
                                                        )),
                                                  ),
                                                  body: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Text(
                                                          "Best Coupon".tr,
                                                          style: TextStyle(
                                                              color: notifier
                                                                  .textColor,
                                                              fontSize: 20),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount:
                                                                paymentGetApiController
                                                                    .paymentgetwayapi!
                                                                    .couponList!
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            10),
                                                                decoration: BoxDecoration(
                                                                    color: notifier
                                                                        .containercolore,
                                                                    borderRadius:
                                                                        BorderRadius.all(Radius.circular(
                                                                            15)),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.4))),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          15),
                                                                  child: Row(
                                                                    children: [
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            "${paymentGetApiController.paymentgetwayapi!.couponList![index].title}",
                                                                            style: TextStyle(
                                                                                color: notifier.textColor,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 18),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                            "${paymentGetApiController.paymentgetwayapi!.couponList![index].subTitle}",
                                                                            style:
                                                                                const TextStyle(color: Colors.grey),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                "Coupon Code: ".tr,
                                                                                style: TextStyle(color: notifier.textColor),
                                                                              ),
                                                                              Text(
                                                                                "${paymentGetApiController.paymentgetwayapi!.couponList![index].code}",
                                                                                style: TextStyle(color: theamcolore, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                "Coupon Amount: ".tr,
                                                                                style: TextStyle(color: notifier.textColor),
                                                                              ),
                                                                              Text(
                                                                                "${currencyy}${paymentGetApiController.paymentgetwayapi!.couponList![index].discountAmount}",
                                                                                style: TextStyle(fontWeight: FontWeight.bold, color: notifier.textColor),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                "Minimum Amount: ".tr,
                                                                                style: TextStyle(color: notifier.textColor),
                                                                              ),
                                                                              Text(
                                                                                "${currencyy}${paymentGetApiController.paymentgetwayapi!.couponList![index].minAmount}",
                                                                                style: TextStyle(fontWeight: FontWeight.bold, color: notifier.textColor),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                "Ex Date: ".tr,
                                                                                style: TextStyle(color: notifier.textColor),
                                                                              ),
                                                                              Text(
                                                                                "${paymentGetApiController.paymentgetwayapi!.couponList![index].endDate.toString().split(" ").first}",
                                                                                style: TextStyle(fontWeight: FontWeight.bold, color: notifier.textColor),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 15),
                                                                          couponadd[index] == true
                                                                              ? InkWell(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      couponadd[index] = false;
                                                                                      dropprice = mainamount as double;
                                                                                      appController.vehiclePrice.value = double.parse(mainamount);
                                                                                      couponname = "";
                                                                                      couponId = "";

                                                                                      Get.back(result: {
                                                                                        "coupAdded": "",
                                                                                        "couponid": "",
                                                                                      });
                                                                                      setState(() {});
                                                                                    });
                                                                                    setState(() {});
                                                                                  },
                                                                                  child: Container(
                                                                                      height: 45,
                                                                                      width: 130,
                                                                                      decoration: BoxDecoration(
                                                                                        border: Border.all(color: Colors.red),
                                                                                        borderRadius: BorderRadius.circular(30),
                                                                                      ),
                                                                                      child: Center(
                                                                                          child: Text(
                                                                                        "Remove".tr,
                                                                                        style: const TextStyle(color: Colors.red),
                                                                                      ))))
                                                                              : InkWell(
                                                                                  onTap: () {
                                                                                    if (vihicalrice >= double.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].minAmount.toString())) {
                                                                                      setState(() {
                                                                                        couponAmt = int.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].discountAmount.toString());

                                                                                        setState(() {
                                                                                          couponname = paymentGetApiController.paymentgetwayapi!.couponList![index].title.toString();
                                                                                        });
                                                                                        if (couponadd[index] == false) {
                                                                                          for (int i = 0; i < couponadd.length; i++) {
                                                                                            if (couponadd.contains(true)) {
                                                                                              couponadd[i] = false;
                                                                                            }
                                                                                          }
                                                                                          couponadd[index] = true;
                                                                                        } else {
                                                                                          couponadd[index] = false;
                                                                                        }
                                                                                      });

                                                                                      appController.vehiclePrice.value = vihicalrice - double.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].discountAmount!);

                                                                                      couponId = paymentGetApiController.paymentgetwayapi!.couponList![index].id.toString();

                                                                                      print("xjsbchjscvsgchsvcscsc  $couponId");
                                                                                      Get.back(result: {
                                                                                        "coupAdded": paymentGetApiController.paymentgetwayapi!.couponList![index].title,
                                                                                        "couponid": paymentGetApiController.paymentgetwayapi!.couponList![index].id.toString(),
                                                                                      });
                                                                                      setState(() {});
                                                                                    }
                                                                                    setState(() {});
                                                                                  },
                                                                                  child: Container(
                                                                                      height: 45,
                                                                                      width: 130,
                                                                                      decoration: BoxDecoration(
                                                                                        border: Border.all(color: int.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].minAmount!) < double.parse(mainamount) ? theamcolore : Colors.grey.withOpacity(0.2)),
                                                                                        borderRadius: BorderRadius.circular(30),
                                                                                      ),
                                                                                      child: Center(
                                                                                          child: Text(
                                                                                        "Apply coupons".tr,
                                                                                        style: TextStyle(color: double.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].minAmount!) < double.parse(mainamount) ? theamcolore : Colors.grey),
                                                                                      ))),
                                                                                ),
                                                                        ],
                                                                      ),
                                                                      const Spacer(),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          SvgPicture
                                                                              .asset(
                                                                            "assets/svgpicture/offerIcon.svg",
                                                                            height:
                                                                                50,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                            },
                                          ).then(
                                            (value) {
                                              setState(() {
                                                couponname = value["coupAdded"];
                                                couponId = value["couponid"];
                                              });
                                            },
                                          );
                                        },
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: const Padding(
                                            padding: EdgeInsets.only(top: 6),
                                            child: Image(
                                              image: AssetImage(
                                                  "assets/coupon.png"),
                                              height: 30,
                                              width: 30,
                                            ),
                                          ),
                                          title: couponname == ""
                                              ? Transform.translate(
                                                  offset: Offset(-15, 10),
                                                  child: Text(
                                                    "Coupon".tr,
                                                    style: TextStyle(
                                                        color:
                                                            notifier.textColor),
                                                  ))
                                              : Transform.translate(
                                                  offset: const Offset(-15, 0),
                                                  child: Text(
                                                    "$couponname",
                                                    style: TextStyle(
                                                        color:
                                                            notifier.textColor),
                                                  )),
                                          subtitle: couponname == ""
                                              ? const Text("")
                                              : Transform.translate(
                                                  offset: const Offset(-15, 0),
                                                  child: Text(
                                                    "Coupon applied".tr,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            notifier.textColor),
                                                  )),
                                          trailing: Image(
                                            image: AssetImage(
                                                "assets/angle-right-small.png"),
                                            height: 30,
                                            color: notifier.textColor,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            select == -1
                                ? CommonButton(
                                    containcolore: theamcolore.withOpacity(0.1),
                                    onPressed1: () {},
                                    context: context,
                                    txt1: "Book $vihicalname")
                                : CommonButton(
                                    containcolore: theamcolore,
                                    onPressed1: () {
                                      homeWalletApiController
                                          .homwwalleteApi(
                                              uid: useridgloable.toString(),
                                              context: context)
                                          .then(
                                        (value) {
                                          print(
                                              "{{{{{[wallete}}}}}]:-- ${value["wallet_amount"]}");
                                          walleteamount = double.parse(
                                              value["wallet_amount"]);
                                          print(
                                              "[[[[[[[[[[[[[walleteamount]]]]]]]]]]]]]:-- ($walleteamount)");
                                        },
                                      );

                                      print(
                                          "pickupadd title:- ${picktitle == "" ? addresspickup : picktitle}");
                                      print("pickupadd sub :- $picksubtitle");
                                      print("dropadd title :- $droptitle");
                                      print("dropadd sub :- $dropsubtitle");
                                      print("list sub :- $droptitlelist");
                                      print(
                                          "99999999999999999999999999 :- ${vihicalCalculateController.vihicalCalculateModel!.driverId}");
                                      print("22222222222222 :- $payment");
                                      print("222222mroal22222222 :- $mroal");

                                      percentValue.clear();
                                      percentValue = [];
                                      for (int i = 0; i < 4; i++) {
                                        percentValue.add(0);
                                      }
                                      setState(() {
                                        currentStoryIndex = 0;
                                        loadertimer = false;
                                      });

                                      addVihicalCalculateController
                                          .addvihicalcalculateApi(
                                              bidd_auto_status: "false",
                                              pickupadd: {
                                                "title":
                                                    "${picktitle == "" ? addresspickup : picktitle}",
                                                "subt": picksubtitle
                                              },
                                              dropadd: {
                                                "title": droptitle,
                                                "subt": dropsubtitle
                                              },
                                              droplistadd: droptitlelist,
                                              context: context,
                                              uid: useridgloable.toString(),
                                              tot_km: "$totalkm",
                                              vehicle_id: vehicle_id,
                                              tot_minute: tot_time,
                                              tot_hour: tot_hour,
                                              m_role: mroal,
                                              coupon_id: couponId,
                                              payment_id: "$payment",
                                              driverid:
                                                  vihicalCalculateController
                                                      .vihicalCalculateModel!
                                                      .driverId!,
                                              price: "$vihicalrice",
                                              pickup:
                                                  "$latitudepick,$longitudepick",
                                              drop:
                                                  "$latitudedrop,$longitudedrop",
                                              droplist: onlypass)
                                          .then(
                                        (value) {
                                          print("+++++${value["id"]}");
                                          setState(() {});
                                          appController.requestId.value = value["id"].toString();
                                          socateempt();
                                        },
                                      );
                                      commonbottomsheetrequestsend(
                                          context: context);
                                    },
                                    context: context,
                                    txt1: "Book $vihicalname")
                          ],
                        ),
                      ),
                    ),
                  ],
                );
        }),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(widget.latpic, widget.longpic), zoom: 15),
              myLocationEnabled: true,
              tiltGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              onMapCreated: (controller) {
                controller.setMapStyle(themeForMap);
                _onMapCreated(controller);
              },
              markers: Set<Marker>.of(markers.values),
              polylines: Set<Polyline>.of(polylines.values),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 60),
              child: InkWell(
                onTap: () {
                  Get.offAll(MapScreen(
                    selectvihical: true,
                  ));
                },
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: notifier.containercolore,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                      child: Image(
                    image: AssetImage("assets/arrow-left.png"),
                    height: 20,
                    color: notifier.textColor,
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
