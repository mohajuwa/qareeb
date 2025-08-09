// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';

import '../api_code/add_vehical_api_controller.dart';
import '../api_code/remove_request.dart';
import '../api_code/resend_request_api_controller.dart';
import '../api_code/timeout_request_api_controller.dart';
import '../api_code/vihical_calculate_api_controller.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';
import '../common_code/common_flow_screen.dart';
import '../common_code/config.dart';
import 'home_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

List<double> percentValue = [];
int currentStoryIndex = 0;
// int durationn = 5;
int durationn = 180;
// int durationn = 313;

class CounterBottomSheet extends StatefulWidget {
  const CounterBottomSheet({
    super.key,
  });

  @override
  State<CounterBottomSheet> createState() => _CounterBottomSheetState();
}

class _CounterBottomSheetState extends State<CounterBottomSheet> {
  @override
  void initState() {
    // TODO: implement initState
    getdata();
    socketConnect();
    // socket.connect();
    for (int i = 0; i < 4; i++) {
      percentValue.add(0);
    }
    _watchStories();
    super.initState();
  }

  var decodeUid;
  var userid;
  var currencyy;

  TimeoutRequestApiController timeoutRequestApiController =
      Get.put(TimeoutRequestApiController());
  ResendRequestApiController resendRequestApiController =
      Get.put(ResendRequestApiController());
  VihicalCalculateController vihicalCalculateController =
      Get.put(VihicalCalculateController());
  AddVihicalCalculateController addVihicalCalculateController =
      Get.put(AddVihicalCalculateController());
  RemoveRequest removeRequest = Get.put(RemoveRequest());

  getdata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("userLogin");
    var currency = preferences.getString("currenci");

    decodeUid = jsonDecode(uid!);
    currencyy = jsonDecode(currency!);

    userid = decodeUid['id'];
    print("****CounterBottomSheet*****:--- ($userid)");
    print("****CounterBottomSheet*****:--- ($currencyy)");
  }

  late IO.Socket socket;

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

    socket.onConnect((_) {
      print('Connected');

      socket.emit('message', 'Hello from Flutter');
    });

    _connectSocket();
  }

  _connectSocket() async {
    setState(() {
      // midseconde = modual_calculateController.modualCalculateApiModel!.caldriver![0].id!;
    });

    socket.onConnect((data) => print('Connection established Connected'));
    socket.onConnectError((data) => print('Connect Error: $data'));
    socket.onDisconnect((data) => print('Socket.IO server disconnected'));
  }

  // socateempt() {
  //   socket.emit('vehiclerequest',{
  //     'requestid': addVihicalCalculateController.addVihicalCalculateModel!.id,
  //     'driverid' : vihicalCalculateController.vihicalCalculateModel!.driverId,
  //   });
  // }

  void _watchStories() {
    setState(() {});

    // for(int i=0; i<1; i++){
    Timer.periodic(Duration(milliseconds: durationn), (timer) {
      setState(() {
        if (percentValue[currentStoryIndex] + 0.1 < 1) {
          percentValue[currentStoryIndex] += 0.01;
        } else {
          percentValue[currentStoryIndex] = 1;

          timer.cancel();

          if (currentStoryIndex < 4 - 1) {
            setState(() {
              currentStoryIndex++;
            });

            setState(() {
              _watchStories();
            });
          } else {
            Get.back();
            percentValue = [];
            for (int i = 0; i < 4; i++) {
              percentValue.add(0);
            }

            setState(() {
              currentStoryIndex = 0;
            });

            // removeRequest.removeApi(uid: userid.toString()).then((value) {
            //   Get.back();
            //   print("+++ removeApi +++:- ${value["driver_list"]}");
            //   socket.emit('Vehicle_Ride_Cancel',{
            //     'uid': "$useridgloable",
            //     'driverid' : value["driver_list"],
            //   });
            // },);

            timeoutRequestApiController
                .timeoutrequestApi(
                    uid: userid.toString(), request_id: request_id.toString())
                .then(
              (value) {
                print("*****value data******:--- $value");
                print("*****value data******:--- ${value["driverid"]}");

                socket.emit('RequestTimeOut', {
                  'requestid': addVihicalCalculateController
                      .addVihicalCalculateModel!.id,
                  'driverid': value["driverid"],
                });

                // socket.emit('Vehicle_Ride_Cancel',{
                //   'uid': "$useridgloable",
                //   'driverid' : value["driver_list"],
                // });

                // socateemptrequesttimeout();
                Get.bottomSheet(StatefulBuilder(
                  builder: (context, setState) {
                    return Container(
                      // height: 400,
                      // width: Get.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/svgpicture/exclamation-circle.svg",
                                  height: 25,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Captains are busy".tr,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
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
                                                  color: Colors.green,
                                                  width: 4),
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
                                                    BorderRadius.circular(10)),
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
                                                    color: Colors.red,
                                                    width: 4)),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Transform.translate(
                                            offset: picktitle == ""
                                                ? const Offset(0, 0)
                                                : const Offset(0, -10),
                                            child: ListTile(
                                              // isThreeLine: true,
                                              contentPadding: EdgeInsets.zero,
                                              title: Text(
                                                  "${picktitle == "" ? addresspickup : picktitle}"),
                                              subtitle: Text(
                                                picksubtitle,
                                                style: const TextStyle(
                                                    color: Colors.grey),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Transform.translate(
                                            offset: const Offset(0, -30),
                                            child: ListTile(
                                              // isThreeLine: true,
                                              contentPadding: EdgeInsets.zero,
                                              title: Text(droptitle),
                                              subtitle: Text(
                                                dropsubtitle,
                                                style: const TextStyle(
                                                    color: Colors.grey),
                                                maxLines: 1,
                                              ),
                                            ),
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
                                : Transform.translate(
                                    offset: const Offset(0, -30),
                                    child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
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
                                                    offset:
                                                        const Offset(-5, -25),
                                                    child: Column(
                                                      children: [
                                                        // const SizedBox(height: 4,),
                                                        Container(
                                                          height: 10,
                                                          width: 3,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.4),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
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
                                                                .withOpacity(
                                                                    0.4),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
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
                                                              color:
                                                                  Colors.white,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .red,
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
                                              flex: 9,
                                              child: Transform.translate(
                                                offset: const Offset(0, -15),
                                                child: Column(
                                                  children: [
                                                    // Transform.translate(
                                                    //   offset: const Offset(0, -7),
                                                    //   child: Text("${droptitlelist[index]["title"]}"),
                                                    // ),
                                                    // const SizedBox(height: 5,),
                                                    ListTile(
                                                      // isThreeLine: true,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                          "${droptitlelist[index]["title"]}"),
                                                      subtitle: Text(
                                                        "${droptitlelist[index]["subt"]}",
                                                        style: const TextStyle(
                                                            color: Colors.grey),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                            // SizedBox(height: 30,),
                            CommonButton(
                                containcolore: theamcolore,
                                onPressed1: () {
                                  resendRequestApiController
                                      .resendrequestApi(
                                          uid: userid.toString(),
                                          driverid: vihicalCalculateController
                                              .vihicalCalculateModel!.driverId!)
                                      .then(
                                    (value) {
                                      print(
                                          "+++ resendrequestApi +++ :- ${value["driver_list"]}");
                                      Get.back();
                                      socket.emit('vehiclerequest', {
                                        'requestid':
                                            addVihicalCalculateController
                                                .addVihicalCalculateModel!.id,
                                        'driverid': value["driver_list"],
                                        'c_id': useridgloable
                                      });
                                      // socateempt();
                                      commonbottomsheetrequestsend(
                                          context: context);
                                    },
                                  );
                                },
                                txt1: "Try Again",
                                context: context),
                            const SizedBox(
                              height: 10,
                            ),
                            CommonOutLineButton(
                                bordercolore: theamcolore,
                                onPressed1: () {
                                  removeRequest
                                      .removeApi(uid: userid.toString())
                                      .then(
                                    (value) {
                                      Get.back();
                                    },
                                  );
                                },
                                txt1: "Cancel",
                                context: context),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ));
              },
            );

            // setState(() {
            //   _watchStories();
            // });
          }
        }
      });
    });

    // }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          for (int i = 0; i < 4; i++)
            StatefulBuilder(
              builder: (context, setState) {
                return Expanded(
                  child: LinearPercentIndicator(
                    lineHeight: 5,
                    // width: 70,
                    padding: const EdgeInsets.only(
                      right: 10,
                    ),
                    alignment: MainAxisAlignment.start,
                    barRadius: const Radius.circular(30),
                    curve: Curves.bounceInOut,
                    percent: percentValue[i],
                    progressColor: theamcolore,
                    backgroundColor: theamcolore.withOpacity(0.4),
                  ),
                );
              },
            )
        ],
      ),
    );
  }
}
