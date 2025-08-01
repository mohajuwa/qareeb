// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qareeb/common_code/toastification.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
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
  // final String d_id;
  // final String request_id;
  final double lat;
  final double long;
  // const DriverDetailScreen({super.key, required this.d_id, required this.request_id, required this.lat, required this.long});
  const DriverDetailScreen({super.key, required this.lat, required this.long});

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());

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
                          "${picktitle == "" ? addresspickup : picktitle}",
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
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

  updatemarker(LatLng position, String id, String imageUrl) async {
    print("1111111111111111111");
    final Uint8List markIcon = await getNetworkImage(imageUrl);
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: BitmapDescriptor.fromBytes(markIcon),
      position: position,
    );
    print("2222222222222222222");
    markers[markerId] = marker;

    if (markers.containsKey(markerId)) {
      final Marker oldMarker = markers[markerId]!;
      print("3333333333333333333");
      // Create a new marker with the updated position, keeping other properties same
      final Marker updatedMarker = oldMarker.copyWith(
        positionParam: position, // Update the marker's position
      );

      // setState(() {

      markers[markerId] = updatedMarker;
      setState(() {});
      // update();
      print("4444444444444444444");
      // });
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
        // Handle the case where no route is found
      }
    }

    addPolyLine(polylineCoordinates);
  }

  socketConnect() async {
    setState(() {});

    socket = IO.io('https://qareeb.modwir.com', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
      'extraHeaders': {'Accept': '*/*'},
      'timeout': 30000,
      'forceNew': true,
    });

    socket.connect();
    _connectSocket();
  }

  _connectSocket() async {
    setState(() {});
    socket.onConnect(
        (data) => print('Connection established Connected driverdetail'));
    socket.onConnectError((data) => print('Connect Error driverdetail: $data'));
    socket.onDisconnect(
        (data) => print('Socket.IO server disconnected driverdetail'));

    _addMarker(LatLng(widget.lat, widget.long), "origin",
        BitmapDescriptor.defaultMarker);

    print("999999:-- ${useridgloable}");

    // socket.on('test_Driver_Location$useridgloable', (test_Driver_Location) {
    //   print("++++++ /test_Driver_Location/ ++++ :---  $test_Driver_Location");
    // });
    socket.on('V_Driver_Location$useridgloable', (V_Driver_Location) {
      print("++++++ /V_Driver_Location111/ ++++ :---  $V_Driver_Location");
      print(
          "V_Driver_Location111 is of type: ${V_Driver_Location.runtimeType}");
      print("V_Driver_Location111 keys: ${V_Driver_Location.keys}");
      print("+++++V_Driver_Location111 userid+++++: $useridgloable");
      print("++++driver_id hhhh111 +++++: $driver_id");
      print(
          "++++ooooooooooooooooooooooooo111 +++++: ${V_Driver_Location["driver_location"]["image"]}");
      imagenetwork =
          "${Config.imageurl}${V_Driver_Location["driver_location"]["image"]}";
      print(
          "++++oooooooooooooooooooooooooimagenetwork111 +++++: $imagenetwork");

      if (driver_id == V_Driver_Location["d_id"].toString()) {
        print("SuccessFully111");

        livelat =
            double.parse(V_Driver_Location["driver_location"]["latitude"]);
        livelong =
            double.parse(V_Driver_Location["driver_location"]["longitude"]);

        print("****livelat****:-- ${livelat}");
        print("****livelong****:-- ${livelong}");

        _addMarker(LatLng(widget.lat, widget.long), "origin",
            BitmapDescriptor.defaultMarker);

        updatemarker(LatLng(livelat, livelong), "destination", imagenetwork);

        getDirections(
            lat1: PointLatLng(livelat, livelong),
            lat2: PointLatLng(widget.lat, widget.long));
      } else {
        print("111111:- (${driver_id})");
        print("222222:- (${V_Driver_Location["d_id"]})");
        print("UnSuccessFully111");
      }
    });

    socket.on('Vehicle_D_IAmHere', (Vehicle_D_IAmHere) {
      print("++++++ /Vehicle_D_IAmHere/ ++++ :---  $Vehicle_D_IAmHere");
      print("Vehicle_D_IAmHere is of type: ${Vehicle_D_IAmHere.runtimeType}");
      print("Vehicle_D_IAmHere keys: ${Vehicle_D_IAmHere.keys}");
      print("Vehicle_D_IAmHere id: ${Vehicle_D_IAmHere["c_id"]}");
      print("userid: $useridgloable");
      tot_time = Vehicle_D_IAmHere["pickuptime"].toString();
      extratime = Vehicle_D_IAmHere["pickuptime"].toString();
      tot_secound = "0";
      print("Vehicle_D_IAmHere_pickuptime: ${Vehicle_D_IAmHere["pickuptime"]}");
      print("Vehicle_D_IAmHere_pickuptime tot_time: ${tot_time}");
      print("Vehicle_D_IAmHere_pickuptime tot_time: ${extratime}");

      if (Vehicle_D_IAmHere["c_id"] == useridgloable.toString()) {
        print("Done Done");
        driveridloader == false;
        globalDriverAcceptClass.driverdetailfunction(
            lat: widget.lat,
            long: widget.long,
            d_id: Vehicle_D_IAmHere["uid"].toString(),
            request_id: Vehicle_D_IAmHere["request_id"].toString(),
            context: context);
        // Navigator.push(context, MaterialPageRoute(builder: (context) => DriverDetailScreen(d_id: Vehicle_D_IAmHere["uid"].toString(), request_id: Vehicle_D_IAmHere["request_id"].toString(), lat: widget.latpic, long: widget.longpic),));
      } else {
        print("Not Done");
      }
    });

    socket.on('Vehicle_Accept_Cancel${useridgloable}', (Vehicle_Accept_Cancel) {
      print("++++++ /Vehicle_Accept_Cancel/ ++++ :---  $Vehicle_Accept_Cancel");
      print("++++++ /request_id accpt/ ++++ :---  ${request_id.toString()}");
      print(
          "++++++ /request_id new/ ++++ :---  ${Vehicle_Accept_Cancel["request_id"].toString()}");

      // if(request_id.toString() == Vehicle_Accept_Cancel["request_id"].toString()){
      Get.offAll(const ModernMapScreen(
        selectVehicle: false,
      ));
      // }else{
      //   print(">>>>>OOOOOOPPPPPP<<<<<<<:::");
      // }
    });

    // socket.on('Vehicle_Ride_Payment${userid}', (Vehicle_Ride_Payment) {
    //   print("++++++ /Vehicle_Ride_Payment1/ ++++ :---  $Vehicle_Ride_Payment");
    //   print("Vehicle_Ride_Payment1 is of type: ${Vehicle_Ride_Payment.runtimeType}");
    //   print("Vehicle_Ride_Payment1 keys: ${Vehicle_Ride_Payment.keys}");
    // });

    // socket.on('Vehicle_Ride_Start_End$userid', (Vehicle_Ride_Start_End) {
    //
    //   print("++++++ /Vehicle_Ride_Start_End/ ++++ :---  $Vehicle_Ride_Start_End");
    //   print("Vehicle_Ride_Start_End is of type: ${Vehicle_Ride_Start_End.runtimeType}");
    //   print("Vehicle_Ride_Start_End keys: ${Vehicle_Ride_Start_End.keys}");
    //   print("++++Vehicle_Ride_Start_End userid+++++: $userid");
    //   print("++++Vehicle_Ride_Start_End gggg +++++: ${Vehicle_Ride_Start_End["uid"].toString()}");
    //   print("++++driver_id gggg +++++: $driver_id");
    //
    //   statusridestart = "";
    //   totaldropmint = "";
    //
    //   if(driver_id == Vehicle_Ride_Start_End["uid"].toString()){
    //     print("SuccessFully1");
    //     statusridestart = Vehicle_Ride_Start_End["status"];
    //     totaldropmint = Vehicle_Ride_Start_End["tot_min"];
    //     print("+++++++totaldropmint++++:-- $totaldropmint");
    //     print("++++++++ststus++++:-- $statusridestart");
    //
    //     if(statusridestart == "5"){
    //       Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverStartrideScreen(),));
    //     }
    //     else if(statusridestart == "6"){
    //       Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverStartrideScreen(),));
    //     }
    //     else if(statusridestart == "7"){
    //       Navigator.push(context, MaterialPageRoute(builder: (context) => const RideCompletePaymentScreen(),));
    //     }
    //
    //
    //
    //   }else{
    //     statusridestart = "";
    //     print("UnSuccessFully1");
    //   }
    //
    // });
    //
    // socket.on('Vehicle_Ride_OTP', (Vehicle_Ride_OTP) {
    //
    //   print("++++++ /Vehicle_Ride_OTP/ ++++ :---  $Vehicle_Ride_OTP");
    //   print("Vehicle_Ride_OTP is of type: ${Vehicle_Ride_OTP.runtimeType}");
    //   print("Vehicle_Ride_OTP keys: ${Vehicle_Ride_OTP.keys}");
    //   print("++++userid+++++: $userid");
    //   // print("++++hjhhhhhhhhhhhhhhhhhh+++++: ${Vehicle_Ride_OTP["uid"].toString()}");
    //
    //   print("++++otpstatus+++++:- $otpstatus");
    //
    //   if(userid.toString() == Vehicle_Ride_OTP["c_id"].toString()){
    //     otpstatus = Vehicle_Ride_OTP["status"];
    //   }
    //   else{
    //     otpstatus = false;
    //   }
    //
    // });
  }

  VihicalCalculateController vihicalCalculateController =
      Get.put(VihicalCalculateController());
  AddVihicalCalculateController addVihicalCalculateController =
      Get.put(AddVihicalCalculateController());
  VihicalDriverDetailApiController vihicalDriverDetailApiController =
      Get.put(VihicalDriverDetailApiController());

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
    setState(() {});
    // livelat = 21.2420;
    // livelong = 72.8753;
    Timer(const Duration(seconds: 2), () {
      print("22222222222222222222222222 TIMER");
      setState(() {
        mapThemeStyle(context: context);
        _addMarker(LatLng(widget.lat, widget.long), "origin",
                BitmapDescriptor.defaultMarker)
            .then(
          (value) {
            print(
                "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv111222");
          },
        );
        updatemarker(LatLng(livelat, livelong), "destination", imagenetwork);
        getDirections(
            lat1: PointLatLng(livelat, livelong),
            lat2: PointLatLng(widget.lat, widget.long));
      });
    });
    Timer(const Duration(seconds: 3), () {
      print("333333333333333333333333333 TIMER");
      setState(() {
        updatemarker(LatLng(livelat, livelong), "destination", imagenetwork);
        getDirections(
            lat1: PointLatLng(livelat, livelong),
            lat2: PointLatLng(widget.lat, widget.long));
      });
    });

    // mapThemeStyle(context: context);
    // _addMarker(LatLng(widget.lat, widget.long), "origin", BitmapDescriptor.defaultMarker).then((value) {
    //   print("vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv111222");
    // },);

    socketConnect();

    otpstatus = false;
    print("000000000000:-- ${widget.lat}");
    print("000000000000:-- ${widget.long}");
    print("000000livelat000000:-- ${livelat}");
    print("00000072.8753000000:-- ${livelong}");
    print("wwwwww:-- ${tot_secound}");

    // vihicalDriverDetailApiController.vihicaldriverdetailapi(driver_list: vihicalCalculateController.vihicalCalculateModel!.driverId!,uid: userid.toString(), d_id: widget.d_id, request_id: request_id).then((value) {
    //
    //   print("/////////value///:-- $value");
    //
    //   if(value["Result"] == true){
    //     tot_hour = value["accepted_d_detail"]["tot_hour"].toString();
    //     tot_time = value["accepted_d_detail"]["tot_minute"].toString();
    //     timeincressstatus = value["accepted_d_detail"]["status"].toString();
    //     print("-----timeincressstatus---:-- $timeincressstatus");
    //
    //     socket.emit('AcceRemoveOther',{
    //       'requestid': addVihicalCalculateController.addVihicalCalculateModel!.id,
    //       'driverid' : value["driverlist"],
    //     });
    //     // Get.back();
    //
    //     drivername = "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.firstName} ${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.lastName}";
    //     drivervihicalnumber = "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.vehicleNumber}";
    //     driverlanguage = "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.language}";
    //     driverrating = "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.rating}";
    //     driverimage = "${Config.imageurl}${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.profileImage}";
    //
    //     // Get.bottomSheet(
    //     //     isDismissible: false,
    //     //     isScrollControlled: true,
    //     //     enableDrag: false,
    //     //     StatefulBuilder(builder: (context, setState) {
    //     //       return Stack(
    //     //         clipBehavior: Clip.none,
    //     //         children: [
    //     //           GetBuilder<VihicalDriverDetailApiController>(builder: (vihicalDriverDetailApiController) {
    //     //             return Container(
    //     //               height: Get.height,
    //     //               width: Get.width,
    //     //               decoration: const BoxDecoration(
    //     //                 color: Colors.white,
    //     //                 borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
    //     //               ),
    //     //               child: Stack(
    //     //                 children: [
    //     //                   GoogleMap(
    //     //                     initialCameraPosition: CameraPosition(target: LatLng(lat, long),zoom: 15),
    //     //                     myLocationEnabled: true,
    //     //                     tiltGesturesEnabled: true,
    //     //                     compassEnabled: true,
    //     //                     scrollGesturesEnabled: true,
    //     //                     zoomGesturesEnabled: true,
    //     //                     onMapCreated: _onMapCreated,
    //     //                     markers: Set<Marker>.of(markers.values),
    //     //                     polylines: Set<Polyline>.of(polylines.values),
    //     //                   ),
    //     //                   // mapwidget(),
    //     //                   Positioned(
    //     //                     bottom: 0,
    //     //                     child: Container(
    //     //                       height: 360,
    //     //                       width: Get.width,
    //     //                       decoration: const BoxDecoration(
    //     //                         color: Colors.white,
    //     //                         borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
    //     //                       ),
    //     //                       child: Padding(
    //     //                         padding: const EdgeInsets.only(left: 15,right: 15),
    //     //                         child: Column(
    //     //                           mainAxisAlignment: MainAxisAlignment.start,
    //     //                           crossAxisAlignment: CrossAxisAlignment.center,
    //     //                           children: [
    //     //                             const SizedBox(height: 10,),
    //     //                             Row(
    //     //                               crossAxisAlignment: CrossAxisAlignment.center,
    //     //                               mainAxisAlignment: MainAxisAlignment.center,
    //     //                               children: [
    //     //                                 Container(
    //     //                                   height: 5,
    //     //                                   width: 50,
    //     //                                   decoration: BoxDecoration(
    //     //                                     color: Colors.grey.withOpacity(0.4),
    //     //                                     borderRadius: BorderRadius.circular(10),
    //     //                                   ),
    //     //                                 ),
    //     //                               ],
    //     //                             ),
    //     //                             const SizedBox(height: 10,),
    //     //                             Row(
    //     //                               children: [
    //     //
    //     //                                 if(vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.status == "1")
    //     //                                   const Text("Captain on the way",style: TextStyle(color: Colors.black,fontSize: 18),)
    //     //                                 else if(vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.status == "2")
    //     //                                   Column(
    //     //                                     crossAxisAlignment: CrossAxisAlignment.start,
    //     //                                     children: [
    //     //                                       const Text("Captain has arrived",style: TextStyle(color: Colors.black,fontSize: 18),),
    //     //                                       extraststus == "" ?
    //     //                                       Text("Free wait time of $tot_time mins has started.",style: const TextStyle(color: Colors.black,fontSize: 12),):
    //     //                                       Text(extraststus,style: const TextStyle(color: Colors.black,fontSize: 12),),
    //     //
    //     //
    //     //                                       // isloading22  ?
    //     //                                       // Text(extraststus,style: const TextStyle(color: Colors.black,fontSize: 12),)
    //     //                                       //     :
    //     //                                       // Text("Free wait time of $tot_time mins has started.",style: const TextStyle(color: Colors.black,fontSize: 12),)
    //     //
    //     //                                     ],
    //     //                                   )
    //     //                                 else if(vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.status == "3")
    //     //                                     const Text("Heading to the destination",style: TextStyle(color: Colors.black,fontSize: 18),),
    //     //
    //     //
    //     //
    //     //                                 // switch (r) {
    //     //                                 // case 0:
    //     //                                 // // do something
    //     //                                 // break;
    //     //                                 // case myPI:
    //     //                                 // // do something else
    //     //                                 // break;
    //     //                                 // }
    //     //
    //     //                                 const Spacer(),
    //     //                                 // Container(
    //     //                                 //   height: 40,
    //     //                                 //   width: 80,
    //     //                                 //   decoration: BoxDecoration(
    //     //                                 //       color: theamcolore,
    //     //                                 //       borderRadius: BorderRadius.circular(30),
    //     //                                 //   ),
    //     //                                 //   child: Center(child: Text("${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.pickupTime}",style: const TextStyle(color: Colors.white),),),
    //     //                                 // ),
    //     //                                 TimerScreen(hours: int.parse(tot_hour),minutes: int.parse(tot_time)-1),
    //     //                               ],
    //     //                             ),
    //     //                             const Divider(color: Colors.black,),
    //     //                             Row(
    //     //                               children: [
    //     //                                 const Text("Start your order with PIN"),
    //     //                                 // Text("${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.otp}"),
    //     //                                 const Spacer(),
    //     //
    //     //                                 for(int i=0; i<4; i++)
    //     //                                   Padding(
    //     //                                     padding: const EdgeInsets.only(left: 4.0),
    //     //                                     child: Container(
    //     //                                       height: 35,
    //     //                                       width: 30,
    //     //                                       decoration: BoxDecoration(
    //     //                                         border: Border.all(color: Colors.grey),
    //     //                                         borderRadius: BorderRadius.circular(10),
    //     //                                       ),
    //     //                                       child: Center(child: Text(vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.otp![i]),),
    //     //                                     ),
    //     //                                   )
    //     //
    //     //                               ],
    //     //                             ),
    //     //                             const SizedBox(height: 10,),
    //     //                             Container(
    //     //                               decoration: BoxDecoration(
    //     //                                   color: greaycolore,
    //     //                                   borderRadius: BorderRadius.circular(10)
    //     //                               ),
    //     //                               child: Padding(
    //     //                                 padding: const EdgeInsets.all(8.0),
    //     //                                 child: Column(
    //     //                                   children: [
    //     //                                     ListTile(
    //     //                                       isThreeLine: true,
    //     //                                       contentPadding: EdgeInsets.zero,
    //     //                                       title: Column(
    //     //                                         crossAxisAlignment: CrossAxisAlignment.start,
    //     //                                         children: [
    //     //                                           Text("${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.vehicleNumber}",style: const TextStyle(fontSize: 18,color: Colors.black),),
    //     //                                           const SizedBox(height: 5,),
    //     //                                           Text("${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.carName}",style: const TextStyle(fontSize: 15,color: Colors.grey)),
    //     //                                           const SizedBox(height: 8,),
    //     //                                         ],
    //     //                                       ),
    //     //                                       subtitle: Text("${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.firstName} ${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.lastName}",style: const TextStyle(fontSize: 15,color: Colors.grey)),
    //     //                                       trailing: Stack(
    //     //                                         clipBehavior: Clip.none,
    //     //                                         children: [
    //     //                                           Container(
    //     //                                             height: 60,
    //     //                                             width: 60,
    //     //                                             decoration: BoxDecoration(
    //     //                                                 shape: BoxShape.circle,
    //     //                                                 image: DecorationImage(image: NetworkImage("${Config.imageurl}${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.profileImage}"),fit: BoxFit.cover)
    //     //                                             ),
    //     //                                             // child: Image(image: NetworkImage("https://i.pinimg.com/originals/a3/fc/98/a3fc98cd46931905114589e2e8abdc49.jpg"))
    //     //                                           ),
    //     //                                           Positioned(
    //     //                                             bottom: -15,
    //     //                                             left: 0,
    //     //                                             right: 0,
    //     //                                             child: Container(
    //     //                                               height: 25,
    //     //                                               width: 40,
    //     //                                               decoration: BoxDecoration(
    //     //                                                   color: Colors.white,
    //     //                                                   border: Border.all(color: Colors.grey.withOpacity(0.2)),
    //     //                                                   borderRadius: BorderRadius.circular(15)
    //     //                                               ),
    //     //                                               child: Center(child: Row(
    //     //                                                 crossAxisAlignment: CrossAxisAlignment.center,
    //     //                                                 mainAxisAlignment: MainAxisAlignment.center,
    //     //                                                 children: [
    //     //                                                   Text("${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.rating}"),
    //     //                                                   const SizedBox(width: 5,),
    //     //                                                   const Icon(Icons.star,color: Colors.yellow,size: 15,)
    //     //                                                 ],
    //     //                                               ),),
    //     //                                             ),
    //     //                                           )
    //     //                                         ],
    //     //                                       ),
    //     //                                     ),
    //     //                                     const SizedBox(height: 20,),
    //     //                                     Row(
    //     //                                       children: [
    //     //                                         Container(
    //     //                                           height: 45,
    //     //                                           width: 45,
    //     //                                           decoration: BoxDecoration(
    //     //                                               shape: BoxShape.circle,
    //     //                                               border: Border.all(color: Colors.grey)
    //     //                                           ),
    //     //                                           child: const Center(child: Icon(Icons.call,color: Colors.grey,size: 20,),),
    //     //                                         ),
    //     //                                         const SizedBox(width: 10,),
    //     //                                         Expanded(
    //     //                                           child: Container(
    //     //                                             height: 45,
    //     //                                             decoration: BoxDecoration(
    //     //                                                 borderRadius: BorderRadius.circular(30),
    //     //                                                 border: Border.all(
    //     //                                                   color: Colors.grey,
    //     //                                                 )
    //     //                                             ),
    //     //                                             child: Row(
    //     //                                               crossAxisAlignment: CrossAxisAlignment.center,
    //     //                                               children: [
    //     //                                                 const SizedBox(width: 10,),
    //     //                                                 const Icon(Icons.message,color: Colors.grey,size: 20,),
    //     //                                                 const SizedBox(width: 10,),
    //     //                                                 Text("Message ${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.firstName} ${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.lastName}")
    //     //                                               ],
    //     //                                             ),
    //     //                                           ),
    //     //                                         )
    //     //                                       ],
    //     //                                     ),
    //     //                                     const SizedBox(height: 10,),
    //     //
    //     //                                   ],
    //     //                                 ),
    //     //                               ),
    //     //                             ),
    //     //                             const SizedBox(height: 10,),
    //     //                             ListTile(
    //     //                               contentPadding: EdgeInsets.zero,
    //     //                               title: const Text("Pickup From"),
    //     //                               // subtitle: Text("31"),
    //     //                               trailing: InkWell(
    //     //                                 onTap: () {
    //     //                                   commonbottomsheetcancelflow(context: context);
    //     //                                   // commonbottomsheetrequestsend(context: context);
    //     //                                 },
    //     //                                 child: Container(
    //     //                                   height: 40,
    //     //                                   width: 100,
    //     //                                   decoration: BoxDecoration(
    //     //                                     border: Border.all(color: Colors.grey.withOpacity(0.4)),
    //     //                                     borderRadius: BorderRadius.circular(30),
    //     //                                   ),
    //     //                                   child: const Center(child: Text("Trip Details"),),
    //     //                                 ),
    //     //                               ),
    //     //                             )
    //     //                           ],
    //     //                         ),
    //     //                       ),
    //     //                     ),
    //     //                   ),
    //     //
    //     //                 ],
    //     //               ),
    //     //             );
    //     //           },),
    //     //         ],
    //     //       );
    //     //     },)
    //     // );
    //   }
    // });

    // TODO: implement initState
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
      ToastService.showToast("Please allow calls Permission");
      await openAppSettings();
    } else {
      ToastService.showToast("Please allow calls Permission");
      await openAppSettings();
    }
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      body: GetBuilder<VihicalDriverDetailApiController>(
        builder: (vihicalDriverDetailApiController) {
          return Container(
            height: Get.height,
            width: Get.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(widget.lat, widget.long), zoom: 15),
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
                      Get.offAll(const ModernMapScreen(
                        selectVehicle: false,
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
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 370,
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: notifier.containercolore,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 5,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              if (vihicalDriverDetailApiController
                                      .vihicalDriverDetailModel!
                                      .acceptedDDetail!
                                      .status ==
                                  "1")
                                Text(
                                  "Captain on the way".tr,
                                  style: TextStyle(
                                      color: notifier.textColor, fontSize: 18),
                                )
                              else if (vihicalDriverDetailApiController
                                      .vihicalDriverDetailModel!
                                      .acceptedDDetail!
                                      .status ==
                                  "2")
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Captain has arrived".tr,
                                      style: TextStyle(
                                          color: notifier.textColor,
                                          fontSize: 18),
                                    ),
                                    extraststus == ""
                                        ? Text(
                                            "Free wait time of ${extratime} mins has started.",
                                            style: TextStyle(
                                                color: notifier.textColor,
                                                fontSize: 12),
                                          )
                                        : Text(
                                            extraststus,
                                            style: TextStyle(
                                                color: notifier.textColor,
                                                fontSize: 12),
                                          ),

                                    // isloading22  ?
                                    // Text(extraststus,style: const TextStyle(color: Colors.black,fontSize: 12),)
                                    //     :
                                    // Text("Free wait time of $tot_time mins has started.",style: const TextStyle(color: Colors.black,fontSize: 12),)
                                  ],
                                )
                              else if (vihicalDriverDetailApiController
                                      .vihicalDriverDetailModel!
                                      .acceptedDDetail!
                                      .status ==
                                  "3")
                                Text(
                                  "Heading to the destination".tr,
                                  style: TextStyle(
                                      color: notifier.textColor, fontSize: 18),
                                ),

                              // switch (r) {
                              // case 0:
                              // // do something
                              // break;
                              // case myPI:
                              // // do something else
                              // break;
                              // }

                              const Spacer(),

                              // TimerScreen(hours: int.parse(tot_hour),minutes: int.parse(tot_time)-1),
                              TimerScreen(
                                hours: int.parse(tot_hour),
                                minutes: int.parse(tot_time),
                                secound: int.parse(tot_secound),
                              ),
                              // Center(
                              //   child: Container(
                              //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(20),
                              //       border: Border.all(color:  isloading  ? Colors.green : theamcolore), // Dynamic border width
                              //       color: theamcolore.withOpacity(0.1),
                              //     ),
                              //     child: Text(
                              //       _formatTime(_remainingTime),
                              //       style: TextStyle(
                              //         fontSize: 18,
                              //         fontWeight: FontWeight.bold,
                              //         color: isloading  ? Colors.green : theamcolore,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          const Divider(
                            color: Colors.black,
                          ),
                          Row(
                            children: [
                              Text(
                                "Start your order with PIN".tr,
                                style: TextStyle(color: notifier.textColor),
                              ),
                              // Text("${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.otp}"),
                              const Spacer(),

                              for (int i = 0; i < 4; i++)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Container(
                                    height: 35,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                        child: Text(
                                      vihicalDriverDetailApiController
                                          .vihicalDriverDetailModel!
                                          .acceptedDDetail!
                                          .otp![i],
                                      style:
                                          TextStyle(color: notifier.textColor),
                                    )),
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: notifier.languagecontainercolore,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    isThreeLine: true,
                                    contentPadding: EdgeInsets.zero,
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.vehicleNumber}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.textColor),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                            "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.carName}",
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey)),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                        "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.firstName} ${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.lastName}",
                                        style: const TextStyle(
                                            fontSize: 15, color: Colors.grey)),
                                    trailing: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            print(
                                                "jhdgsfhjsvfhjfvhjkafvjahkfvjhkfvjkhfbvjuvaeswj");
                                            print("*****:(:-- ${prefrence}");
                                            print(
                                                "*****:(:-- ${prefrence.length}");
                                            driverdetailbottomsheet();
                                          },
                                          child: Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        "${Config.imageurl}${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.profileImage}"),
                                                    fit: BoxFit.cover)),
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
                                                    color: Colors.grey
                                                        .withOpacity(0.2)),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Center(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 3),
                                                    child: Text(
                                                        "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.rating}"),
                                                  ),
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
                                                    "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.primaryCcode}${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.primaryPhoneNo}");
                                          });
                                        },
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey)),
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
                                                borderRadius:
                                                    BorderRadius.circular(30),
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
                                                  "Message ${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.firstName} ${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.lastName}",
                                                  style: TextStyle(
                                                      color:
                                                          notifier.textColor),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "Pickup From".tr,
                              style: TextStyle(color: notifier.textColor),
                            ),
                            subtitle: Text(
                              picktitle == "" ? addresspickup : picktitle,
                              style: TextStyle(color: notifier.textColor),
                            ),
                            // subtitle: Text("31"),
                            trailing: InkWell(
                              onTap: () {
                                commonbottomsheetcancelflow(context: context);
                                // commonbottomsheetrequestsend(context: context);
                              },
                              child: Container(
                                height: 40,
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.4)),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    "Trip Details".tr,
                                    style: TextStyle(color: notifier.textColor),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// driverdetailbottomsheet(){
// driverdetailbottomsheet(){
//   VihicalDriverDetailApiController vihicalDriverDetailApiController = Get.put(VihicalDriverDetailApiController());
//
//   return GetBuilder<VihicalDriverDetailApiController>(builder: (vihicalDriverDetailApiController) {
//     return Container(
//       height: 500,
//       decoration: const BoxDecoration(
//           color: Colors.red,
//           borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))
//       ),
//     );
//   },);
//
// }

List prefrence = [];
List language = [];

driverdetailbottomsheet() {
  // VihicalDriverDetailApiController vihicalDriverDetailApiController = Get.put(VihicalDriverDetailApiController());
  DriverDetailApiController driverDetailApiController =
      Get.put(DriverDetailApiController());

  print("++++++:-------popopopopo+++++:---- ${driver_id.toString()}");

  driverDetailApiController.driverdetailApi(d_id: driver_id.toString()).then(
    (value) {
      prefrence = [];
      language = [];
      prefrence = driverDetailApiController
          .driverDetailApiModel!.dDetail!.prefrenceName
          .toString()
          .split(",");
      language = driverDetailApiController
          .driverDetailApiModel!.dDetail!.language
          .toString()
          .split(",");

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
                    borderRadius: BorderRadius.only(
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
                                  // color: Colors.red,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15)),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "${Config.imageurl}${driverDetailApiController.driverDetailApiModel!.dDetail!.vehicleImage}"),
                                      fit: BoxFit.cover)),
                            ),
                            Positioned(
                              left: 20,
                              bottom: -35,
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            "${Config.imageurl}${driverDetailApiController.driverDetailApiModel!.dDetail!.profileImage}"),
                                        fit: BoxFit.cover)),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 50,
                              ),
                              Text(
                                "${driverDetailApiController.driverDetailApiModel!.dDetail!.firstName} ${driverDetailApiController.driverDetailApiModel!.dDetail!.lastName}",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: notifier.textColor),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "Rating".tr,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: notifier.textColor),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 1),
                                              child: Text(
                                                "${driverDetailApiController.driverDetailApiModel!.dDetail!.rating}",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: notifier.textColor),
                                              )),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          SvgPicture.asset(
                                            "assets/svgpicture/star-fill.svg",
                                            height: 20,
                                          ),
                                          // Icon(Icons.star,color: Colors.yellow,size: 20,)
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 60,
                                    width: 2,
                                    color: Colors.grey.withOpacity(0.4),
                                  ),
                                  const Spacer(),
                                  Column(
                                    children: [
                                      Text(
                                        "Trips".tr,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: notifier.textColor),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${driverDetailApiController.driverDetailApiModel!.dDetail!.totCompleteOrder}",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: notifier.textColor),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 60,
                                    width: 2,
                                    color: Colors.grey.withOpacity(0.4),
                                  ),
                                  const Spacer(),
                                  Column(
                                    children: [
                                      Text(
                                        "Joined".tr,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: notifier.textColor),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${driverDetailApiController.driverDetailApiModel!.dDetail!.joinDate.toString().split(" ").first}",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: notifier.textColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Language".tr,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: notifier.textColor),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Wrap(
                                // spacing: 13,
                                runSpacing: 13,
                                // alignment: WrapAlignment.start,
                                // clipBehavior: Clip.none,
                                // crossAxisAlignment: WrapCrossAlignment.start,
                                // runAlignment: WrapAlignment.start,
                                spacing: 10,
                                // runSpacing: 5,
                                alignment: WrapAlignment.start,
                                clipBehavior: Clip.none,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                runAlignment: WrapAlignment.start,
                                children: [
                                  for (int a = 0; a < language.length; a++)
                                    Builder(builder: (context) {
                                      return Container(
                                        height: 40,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 8),
                                        // width: 100,
                                        // width: 50,
                                        // width: 10,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "${language[a]}",
                                              style: TextStyle(
                                                  color: notifier.textColor),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Preference".tr,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: notifier.textColor),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Wrap(
                                // spacing: 13,
                                runSpacing: 13,
                                // alignment: WrapAlignment.start,
                                // clipBehavior: Clip.none,
                                // crossAxisAlignment: WrapCrossAlignment.start,
                                // runAlignment: WrapAlignment.start,
                                spacing: 10,
                                // runSpacing: 5,
                                alignment: WrapAlignment.start,
                                clipBehavior: Clip.none,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                runAlignment: WrapAlignment.start,
                                children: [
                                  for (int a = 0; a < prefrence.length; a++)
                                    Builder(builder: (context) {
                                      return Container(
                                        height: 40,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 4),
                                        // width: 100,
                                        // width: 50,
                                        // width: 10,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "${prefrence[a]}",
                                              style: TextStyle(
                                                  color: notifier.textColor),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                ],
                              ),
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
    },
  );

  // prefrence = [];
  // language = [];
  // prefrence = vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.prefrenceName.toString().split(",");
  // language = vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.language.toString().split(",");
}
