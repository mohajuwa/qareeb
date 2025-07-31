// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:qareeb/app_screen/driver_detail_screen.dart';
import 'package:qareeb/app_screen/home_screen.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';
import 'package:qareeb/common_code/common_button.dart';
import 'package:qareeb/common_code/config.dart';
import '../api_code/add_vehical_api_controller.dart';
import '../api_code/calculate_api_controller.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_flow_screen.dart';
import 'map_screen.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen>
    with TickerProviderStateMixin {
  AddVihicalCalculateController addVihicalCalculateController =
      Get.put(AddVihicalCalculateController());
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());
  CalculateController calculateController = Get.put(CalculateController());
  // late AnimationController controller;
  List<double> progressList = [];

  List<AnimationController> controllers = [];

  socketConnect() async {
    socket.connect();
    _connectSocket();
  }

  _connectSocket() async {
    print("DATADATADATADATADATADATDATADTADLOADLOAD");

    // socket.on("removecustomerdata${useridgloable}", (removecustomerdata) async {
    //   print("++++++ removecustomerdata ++++++ :---  $removecustomerdata");
    //   print("++++++ request_id running ride ++++++ :---  $request_id");
    //
    //   if(removecustomerdata["requestid"] == request_id){
    //     print("REQUEST ID MATCH");
    //     Get.back();
    //   }
    //   else{
    //     print("REQUEST ID NOT MATCH");
    //   }
    //
    // });
  }

  acceptsocate() {
    socket.emit('Accept_Bidding', {
      'uid': useridgloable,
      'd_id': d_id,
      // 'request_id' : addVihicalCalculateController.addVihicalCalculateModel!.id,
      'request_id': request_id,
      'price': price,
      // 'driverid' : [29,14],
    });
  }

  int d_id = 0;

  num price = 0;

  // Timer code

  Timer? countdownTimer;

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          for (int i = 0; i < vehicle_bidding_secounde.length; i++) {
            if (vehicle_bidding_secounde[i] > 0) {
              vehicle_bidding_secounde[i]--;
              // print("secounde:- ${vehicle_bidding_secounde}");
              // print("++++++:----- vfghsv  ${timeout}");
            }
          }
        });
      } else {
        // Cancel the timer if the widget is not mounted to avoid memory leaks
        countdownTimer?.cancel();
      }

      // if(timeoutsecound == 0){
      //   print("fffffffffssvdsgdf ${timeoutsecound}");
      //   Get.back();
      // }
    });
  }

  String formatTime(int seconds) {
    // Convert seconds to mm:ss format
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // print("ghjkbgjkhbfkb  ${timeoutsecound}");
  //   socketConnect();
  //   startTimer();
  //   print("aaaaaaaadfssf (${durationInSeconds})");
  //
  //   controller = AnimationController(
  //     vsync: this,
  //     duration: Duration(
  //       seconds: durationInSeconds,
  //     ),
  //   );
  //
  //   controller.addStatusListener((status) {
  //     print("Timer finished! ddddddd");
  //     if (status == AnimationStatus.completed) {
  //       print("Timer finished! dgdg");
  //
  //       // Use post-frame callback to safely access the context
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (mounted) {
  //           // Open bottom sheet when animation is completed
  //           Get.back();
  //         }
  //       });
  //     }
  //   });
  //
  //   controller.forward();
  //
  // }

  @override
  void initState() {
    super.initState();
    socketConnect();
    startTimer();
    print("Initializing with duration (${durationInSeconds})");
    buttontimer = true;
    print("========= BOTTONTIMER :- ${buttontimer}");

    if (controller == null || !controller!.isAnimating) {
      controller = AnimationController(
        vsync: this,
        duration: Duration(
          seconds: durationInSeconds,
        ),
      );

      controller!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          print("Timer finished!");

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Get.back();
            }
          });
        }
      });

      controller!.forward();
    }
  }

  @override
  void dispose() {
    // for (var controller in controllers) {
    //   controller.dispose();
    // }
    // controller.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  // bool acceptloader = false;

//   onWillPop:  () async {
//   // Navigator.pop(context, RefreshData(true));
//   Get.offAll(const MapScreen());
//   return false;
// },
  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.driverlistcolore,
      // backgroundColor: notifier.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Column(
          children: [
            AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: InkWell(
                onTap: () {
                  setState(() {
                    Get.back();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SvgPicture.asset("assets/svgpicture/BackIcon.svg"),
                ),
              ),
              // iconTheme: IconThemeData(
              //   color: notifier.textColor,
              // ),
              backgroundColor: notifier.containercolore,
              centerTitle: true,
              title: Text(
                "Choose a driver".tr,
                style: TextStyle(color: notifier.textColor),
              ),
            ),
            Container(
              height: 50,
              width: Get.width,
              color: theamcolore.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Text(
                      "👋",
                      style: TextStyle(fontSize: 22),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        "Driver can offer their fare and time".tr,
                        style:
                            TextStyle(color: notifier.textColor, fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body:
          // acceptloader == true ? Center(child: CircularProgressIndicator(color: theamcolore,),) :
          Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 12,
                  );
                },
                clipBehavior: Clip.none,
                itemCount: vehicle_bidding_driver.length,
                itemBuilder: (context, index) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        width: Get.width,
                        decoration: BoxDecoration(
                          color: notifier.containercolore,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              priceyourfare ==
                                      vehicle_bidding_driver[index]["price"]
                                  ? Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: theamcolore,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Center(
                                            child: Text(
                                              "Your fare",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    driver_id = vehicle_bidding_driver[index]
                                            ["id"]
                                        .toString();
                                    driverdetailbottomsheet();
                                  });
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                "${Config.imageurl}${vehicle_bidding_driver[index]["profile_image"]}"),
                                            fit: BoxFit.cover)),
                                  ),
                                  title: Text(
                                    "${vehicle_bidding_driver[index]["car_name"]}",
                                    style: TextStyle(color: notifier.textColor),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${vehicle_bidding_driver[index]["first_name"]} ${vehicle_bidding_driver[index]["last_name"]}",
                                        style: TextStyle(
                                            color: notifier.textColor),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          // const Icon(Icons.star,color: Colors.amber,),
                                          SvgPicture.asset(
                                            "assets/svgpicture/star-fill.svg",
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 6),
                                            child: Text(
                                              "${vehicle_bidding_driver[index]["avg_star"]}",
                                              style: TextStyle(
                                                  color: notifier.textColor),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$globalcurrency${vehicle_bidding_driver[index]["price"]}",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: notifier.textColor),
                                      ),
                                      // const SizedBox(height: 3,),
                                      // Text("${vehicle_bidding_driver[index]["tot_min"]}",style: const TextStyle(fontSize: 12),),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "${vehicle_bidding_driver[index]["tot_km"]} km",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: notifier.textColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: CommonOutLineButton(
                                          bordercolore: Colors.red,
                                          onPressed1: () {
                                            print("www:-- ${useridgloable}");
                                            print(
                                                "www:-- ${vehicle_bidding_driver[index]["id"]}");
                                            // print("www:-- ${addVihicalCalculateController.addVihicalCalculateModel!.id}");
                                            socket.emit('Bidding_decline', {
                                              'uid': useridgloable,
                                              'id':
                                                  vehicle_bidding_driver[index]
                                                      ["id"],
                                              // 'request_id' : addVihicalCalculateController.addVihicalCalculateModel!.id,
                                              'request_id': request_id,
                                            });
                                          },
                                          context: context,
                                          txt2: "Decline".tr,
                                          clore: Colors.red)),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: CommonButton(
                                          containcolore: Colors.green,
                                          onPressed1: () {
                                            setState(() {
                                              // acceptloader = true;
                                              buttontimer = false;
                                              isanimation = false;
                                              isControllerDisposed = true;
                                              if (controller != null &&
                                                  controller!.isAnimating) {
                                                print("vgvgvgvgvgvgvgvgvgvgv");
                                                controller!.dispose();
                                              }
                                              d_id =
                                                  vehicle_bidding_driver[index]
                                                      ["id"];
                                              driver_id =
                                                  vehicle_bidding_driver[index]
                                                          ["id"]
                                                      .toString();
                                              price =
                                                  vehicle_bidding_driver[index]
                                                      ["price"];
                                              vihicalrice = double.parse(
                                                  vehicle_bidding_driver[index]
                                                          ["price"]
                                                      .toString());
                                              print("****:-- ${d_id}");
                                              print("****:-- ${price}");
                                              print(
                                                  "**driver_id**:-- ${driver_id}");
                                              acceptsocate();

                                              globalDriverAcceptClass
                                                  .driverdetailfunction(
                                                      context: context,
                                                      lat: latitudepick,
                                                      long: longitudepick,
                                                      d_id: d_id.toString(),
                                                      request_id: "");
                                              // acceptloader = false;
                                            });
                                          },
                                          context: context,
                                          txt1: "Accept".tr))
                                ],
                              ),
                              // const SizedBox(height: 10,),
                              // Row(
                              //   children: [
                              //     Spacer(),
                              //     Text("${formatTime(vehicle_bidding_secounde[index])}",style: TextStyle(fontSize: 16),),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 7,right: 7),
                      //   child: LinearProgressIndicator(
                      //     minHeight: 4,
                      //     backgroundColor: Colors.white,
                      //     color: Colors.green,
                      //     value: 1.0 - controller.value,
                      //     semanticsLabel: 'Linear progress indicator',
                      //   ),
                      // ),

                      // Padding(
                      //   padding: const EdgeInsets.only(left: 7,right: 7),
                      //   child: LinearProgressIndicator(
                      //     value: progressList[index],
                      //     minHeight: 4,
                      //     backgroundColor: Colors.white,
                      //     color: Colors.green,
                      //     // valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      //     semanticsLabel: 'Linear progress indicator',
                      //   ),
                      // ),

                      Positioned(
                        right: 0,
                        top: -15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theamcolore),
                            color: Colors.white,
                          ),
                          child: Text(
                            formatTime(vehicle_bidding_secounde[index]),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theamcolore,
                            ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 7,right: 7),
                      //   child: LinearProgressIndicator(
                      //     value: index < progressList.length ? progressList[index] : 0.0,
                      //     minHeight: 4,
                      //     backgroundColor: Colors.white,
                      //     color: Colors.green,
                      //     semanticsLabel: 'Linear progress indicator',
                      //   ),
                      // ),
                    ],
                  );
                },
              ),
            ),

            // Expanded(
            //   child: ListView.builder(
            //     itemCount: 20,
            //     itemBuilder: (context, index) {
            //       return Padding(
            //         padding: const EdgeInsets.all(10),
            //         child: Container(
            //           height: 100,
            //           color: Colors.red,
            //         ),
            //       );
            //     },
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
