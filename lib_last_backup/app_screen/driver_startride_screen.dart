// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'driver_detail_screen.dart';
import '../common_code/colore_screen.dart';
import '../chat_code/chat_screen.dart';
import '../common_code/common_flow_screen.dart';
import '../common_code/config.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:ui' as ui;
import '../timer_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart';

Future<Uint8List> resizeImage(Uint8List data,
    {required int targetWidth, required int targetHeight}) async {
  // Decode the image
  final ui.Codec codec = await ui.instantiateImageCodec(data);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();

  // Original dimensions
  final int originalWidth = frameInfo.image.width;
  final int originalHeight = frameInfo.image.height;

  // Calculate the aspect ratio
  final double aspectRatio = originalWidth / originalHeight;

  // Determine the dimensions to maintain the aspect ratio
  int resizedWidth, resizedHeight;
  if (originalWidth > originalHeight) {
    resizedWidth = targetWidth;
    resizedHeight = (targetWidth / aspectRatio).round();
  } else {
    resizedHeight = targetHeight;
    resizedWidth = (targetHeight * aspectRatio).round();
  }

  // Resize image
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final Size size = Size(resizedWidth.toDouble(), resizedHeight.toDouble());
  final Rect rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);

  // Paint image
  final Paint paint = Paint()..isAntiAlias = true;
  canvas.drawImageRect(
      frameInfo.image,
      Rect.fromLTWH(
          0.0, 0.0, originalWidth.toDouble(), originalHeight.toDouble()),
      rect,
      paint);

  final ui.Image resizedImage =
      await recorder.endRecording().toImage(resizedWidth, resizedHeight);

  final ByteData? resizedByteData =
      await resizedImage.toByteData(format: ImageByteFormat.png);
  return resizedByteData!.buffer.asUint8List();
}

Future<Uint8List> getNetworkImage(String path,
    {int targetWidth = 50, int targetHeight = 50}) async {
  final completer = Completer<ImageInfo>();
  var image = NetworkImage(path);
  image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info)),
      );
  final ImageInfo imageInfo = await completer.future;

  final ByteData? byteData = await imageInfo.image.toByteData(
    format: ImageByteFormat.png,
  );

  Uint8List resizedImage = await resizeImage(Uint8List.view(byteData!.buffer),
      targetWidth: targetWidth, targetHeight: targetHeight);
  return resizedImage;
}

// List multipledropaddress = [];

class DriverStartrideScreen extends StatefulWidget {
  const DriverStartrideScreen({super.key});

  @override
  State<DriverStartrideScreen> createState() => _DriverStartrideScreenState();
}

class _DriverStartrideScreenState extends State<DriverStartrideScreen> {
  // Start Ride Map And Poliline Code

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();

  void _onMapCreated(GoogleMapController controller) async {}

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
    );
    markers[markerId] = marker;
  }

  _addMarker3(String id) async {
    for (int a = 0; a < droppointstartscreen.length; a++) {
      final Uint8List markIcon = await getImages("assets/drop_marker.png", 80);
      MarkerId markerId = MarkerId(id[a]);

      // Assuming _dropOffPoints[a] is of type PointLatLng, convert it to LatLng
      LatLng position = LatLng(
          droppointstartscreen[a].latitude, droppointstartscreen[a].longitude);

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
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${listdrop[a]["title"]}",
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${listdrop[a]["subtitle"]}",
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

  updatemarker(LatLng position, String id, String imageUrl) async {
    final Uint8List markIcon = await getNetworkImage(imageUrl);
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: BitmapDescriptor.fromBytes(markIcon),
      position: position,
    );
    markers[markerId] = marker;
    if (markers.containsKey(markerId)) {
      final Marker oldMarker = markers[markerId]!;
      // Create a new marker with the updated position, keeping other properties same
      final Marker updatedMarker = oldMarker.copyWith(
        positionParam: position, // Update the marker's position
      );
      markers[markerId] = updatedMarker;
      setState(() {});
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

  socketConnect() async {
    setState(() {});
    socket.connect();
    _connectSocket();
  }

  _connectSocket() async {
    setState(() {});

    socket.on('V_Driver_Location$useridgloable', (V_Driver_Location) {
      print("++++++ /V_Driver_Location111/ ++++ :---  $V_Driver_Location");
      print(
          "V_Driver_Location111 is of type: ${V_Driver_Location.runtimeType}");
      print("V_Driver_Location111 keys: ${V_Driver_Location.keys}");
      print("+++++V_Driver_Location111 userid+++++: $useridgloable");
      print("++++driver_id hhhh111 +++++: $driver_id");
      print(
          "++++ooooooooooooooooooooooooo111 +++++: ${V_Driver_Location["driver_location"]["image"]}");
      print(
          "++++oooooooooooooooooooooooooimagenetwork111 +++++: $imagenetwork");

      if (driver_id == V_Driver_Location["d_id"].toString()) {
        print("SuccessFully111");

        if (droppointstartscreen.isEmpty) {
          print("ififififi");
          socket.emit('drop_location_list', {
            'c_id': useridgloable,
            'd_id': driver_id,
            'r_id': request_id,
          });
        } else {
          livelat =
              double.parse(V_Driver_Location["driver_location"]["latitude"]);
          livelong =
              double.parse(V_Driver_Location["driver_location"]["longitude"]);
          imagenetwork =
              "${Config.imageurl}${V_Driver_Location["driver_location"]["image"]}";

          print("****livelat****:-- ${livelat}");
          print("****livelong****:-- ${livelong}");

          print("elselese11");
          print("....::-- ${livelat}--${livelong}");
          print("*****:-- ${droppointstartscreen}");
          updatemarker(LatLng(livelat, livelong), "origin", imagenetwork);
          for (int a = 0; a < droppointstartscreen.length; a++) {
            _addMarker3("destination");
          }
          getDirections(
              lat1: PointLatLng(livelat, livelong),
              dropOffPoints: droppointstartscreen);
          print("==========:--- ${droppointstartscreen}");
          print("=====length=====:--- ${droppointstartscreen.length}");
        }
      } else {
        print("UnSuccessFully111");
      }
    });

    socket.on('drop_location$useridgloable', (drop_location) {
      print("++++++ /drop_location_list/ ++++ :---  $drop_location");

      livelat = double.parse(drop_location["driver_location"]["latitude"]);
      livelong = double.parse(drop_location["driver_location"]["longitude"]);
      imagenetwork =
          "${Config.imageurl}${drop_location["driver_location"]["image"]}";

      listdrop = [];
      listdrop = drop_location["drop_list"];

      for (int i = 0; i < listdrop.length; i++) {
        droppointstartscreen.add(PointLatLng(
            double.parse(drop_location["drop_list"][i]["latitude"]),
            double.parse(drop_location["drop_list"][i]["longitude"])));
      }

      updatemarker(LatLng(livelat, livelong), "origin", imagenetwork);

      for (int a = 0; a < droppointstartscreen.length; a++) {
        _addMarker3("destination");
      }

      getDirections(
          lat1: PointLatLng(livelat, livelong),
          dropOffPoints: droppointstartscreen);
      print("==========:--- ${droppointstartscreen}");
      print("=====length=====:--- ${droppointstartscreen.length}");
    });
  }

  String themeForMap = "";

  mapThemeStyle({required BuildContext context}) {
    final stylePath = darkMode == true
        ? "assets/map_styles/dark_style.json"
        : "assets/map_styles/light_style.json";

    DefaultAssetBundle.of(context).loadString(stylePath).then((value) {
      setState(() {
        themeForMap = value;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    socketConnect();

    print("================(${imagenetwork})");
    print("================1(${livelat})");
    print("================2(${livelong})");
    mapThemeStyle(context: context);
    updatemarker(LatLng(livelat, livelong), "origin", imagenetwork);
    for (int a = 0; a < droppointstartscreen.length; a++) {
      _addMarker3("destination");
    }
    getDirections(
        lat1: PointLatLng(livelat, livelong),
        dropOffPoints: droppointstartscreen);

    Timer(const Duration(seconds: 3), () {
      print("TIMER TIMER TIMER");
      setState(() {
        updatemarker(LatLng(livelat, livelong), "origin", imagenetwork);
        for (int a = 0; a < droppointstartscreen.length; a++) {
          _addMarker3("destination");
        }
        getDirections(
            lat1: PointLatLng(livelat, livelong),
            dropOffPoints: droppointstartscreen);
      });
    });

    print("================(${imagenetwork})");
    print("================1(${livelat})");
    print("================2(${livelong})");
    super.initState();
  }

  Future<void> _makingPhoneCall({required String number}) async {
    await Permission.phone.request();
    var status = await Permission.phone.status;

    if (!status.isGranted) {
      status = await Permission.phone.request();
    }

    if (status.isGranted) {
      var url = Uri.parse('tel:$number');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } else if (status.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: "Please allow calls Permission");
      await openAppSettings();
    } else {
      Fluttertoast.showToast(msg: "Please allow calls Permission");
      await openAppSettings();
    }
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        extendBody: true,
        // backgroundColor: Colors.black,
        // backgroundColor: Colors.transparent,
        bottomNavigationBar: Container(
          height: 380,
          decoration: BoxDecoration(
            color: notifier.containercolore,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Heading to the destination".tr,
                      style: TextStyle(fontSize: 16, color: notifier.textColor),
                    ),
                    const Spacer(),
                    // Container(
                    //   height: 40,
                    //   width: 80,
                    //   decoration: BoxDecoration(
                    //     color: theamcolore,
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Center(child: Text("$totaldropmint min",style: const TextStyle(color: Colors.white),),),
                    // ),
                    // Text("${totaldrophour},${totaldropmint}"),
                    // SizedBox(width: 5,),
                    timervarable == false
                        ? SizedBox()
                        : TimerScreen(
                            hours: int.parse(totaldrophour),
                            minutes: int.parse(totaldropmint),
                            secound: int.parse(totaldropsecound),
                          ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.black.withOpacity(0.2),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "Drop to".tr,
                    style: TextStyle(color: notifier.textColor),
                  ),
                  // subtitle: Text("${droptitle}"),
                  subtitle: listdrop.isEmpty
                      ? SizedBox()
                      : Text(
                          "${listdrop[0]["title"]}",
                          style: TextStyle(color: notifier.textColor),
                        ),

                  // subtitle: const Text("Ambika Pinnacle"),
                  trailing: InkWell(
                    onTap: () {
                      commonbottomsheetcancelflow(context: context);
                    },
                    child: Container(
                      height: 35,
                      width: 110,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: Text(
                          "Trip Details".tr,
                          style: TextStyle(color: notifier.textColor),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(drivername,
                                    style: TextStyle(
                                        color: notifier.textColor,
                                        fontSize: 18)),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  drivervihicalnumber,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                            subtitle: Text(
                              driverlanguage,
                              style: TextStyle(color: notifier.textColor),
                            ),
                            trailing: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                InkWell(
                                  onTap: () {
                                    driverdetailbottomsheet();
                                  },
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      image: DecorationImage(
                                          image: NetworkImage(driverimage),
                                          fit: BoxFit.cover),
                                    ),
                                    // child: Image(image: NetworkImage("https://i.pinimg.com/originals/a3/fc/98/a3fc98cd46931905114589e2e8abdc49.jpg"))
                                  ),
                                ),
                                Positioned(
                                  bottom: -15,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 25,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color:
                                                Colors.grey.withOpacity(0.2)),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Text("${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.rating}"),
                                          Text("${driverrating}"),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          SvgPicture.asset(
                                            "assets/svgpicture/star-fill.svg",
                                            height: 15,
                                          ),
                                          // const Icon(Icons.star,color: Colors.yellow,size: 15,)
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _makingPhoneCall(
                                        number:
                                            "${drivercountrycode}${driverphonenumber}");
                                  });
                                },
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey)),
                                  child: const Center(
                                    child: Icon(
                                      Icons.call,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ChatScreen(),
                                        ));
                                  },
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.grey,
                                        )),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Icon(
                                          Icons.message,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Message ${drivername}",
                                          style: TextStyle(
                                              color: notifier.textColor),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          // const SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        // body: GoogleMap(
        //   initialCameraPosition: CameraPosition(target: LatLng(livelat, livelong),zoom: 15),
        //   myLocationEnabled: true,
        //   tiltGesturesEnabled: true,
        //   compassEnabled: true,
        //   scrollGesturesEnabled: true,
        //   zoomGesturesEnabled: true,
        //   onMapCreated: _onMapCreated,
        //   markers: Set<Marker>.of(markers.values),
        //   polylines: Set<Polyline>.of(polylines.values),
        // ),
        body:
            // droppointstartscreen.isEmpty ? SizedBox() :
            Stack(
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: LatLng(livelat, livelong), zoom: 15),
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
                  Get.offAll(const MapScreen(
                    selectvihical: false,
                  ));
                },
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                      child: Image(
                    image: AssetImage("assets/arrow-left.png"),
                    height: 20,
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
