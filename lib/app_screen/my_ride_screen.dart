// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/app_screen/my_ride_detail_screen.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';
import 'package:qareeb/app_screen/ride_complete_payment_screen.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import '../api_code/all_request_data_api_controller.dart';
import '../api_code/vihical_ride_complete_order_api_controller.dart';
import '../common_code/common_flow_screen.dart';
import '../common_code/config.dart';
import '../timer_screen.dart';
import 'driver_startride_screen.dart';
import 'home_screen.dart';

String appstatus = "";
String appstatusid = "";
String runtimestatusid = "";
bool driveridloader = false;

String plusetimer = "";

// String timerstop = "";

class MyRideScreen extends StatefulWidget {
  const MyRideScreen({super.key});

  @override
  State<MyRideScreen> createState() => _MyRideScreenState();
}

class _MyRideScreenState extends State<MyRideScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // socketConnect();
    _tabController = TabController(length: 3, vsync: this);
    datagetfunction();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // socketConnect() async {
  //
  //   setState(() {
  //
  //   });
  //
  //   // socket = IO.io(Config.imageurl,<String,dynamic>{
  //   //   'autoConnect': false,
  //   //   'transports': ['websocket'],
  //   //
  //   // });
  //
  //   socket.connect();
  //
  //   // socket.onConnect((_) {
  //   //   print('Connected');
  //   //   socket.emit('message', 'Hello from Flutter');
  //   // });
  //
  //   _connectSocket();
  //
  // }
  //
  // _connectSocket() async {
  //   setState(() {
  //     // midseconde = modual_calculateController.modualCalculateApiModel!.caldriver![0].id!;
  //   });
  //
  //   socket.onConnect((data) => print('Connection established Connected'));
  //   socket.onConnectError((data) => print('Connect Error: $data'));
  //   socket.onDisconnect((data) => print('Socket.IO server disconnected'));
  // }

  var decodeUid;
  var userid;
  var currencyy;

  AllRequestDataApiController allRequestDataApiController =
      Get.put(AllRequestDataApiController());
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());

  bool loader = true;
  datagetfunction() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("userLogin");
    var currency = preferences.getString("currenci");
    decodeUid = jsonDecode(uid!);
    currencyy = jsonDecode(currency!);
    userid = decodeUid['id'];

    print("++++:---  $userid");
    print("++ currencyy ++:---  $currencyy");
    setState(() {});

    allRequestDataApiController
        .allrequestApi(uid: userid.toString(), status: "upcoming")
        .then(
      (value) {
        setState(() {});
        allRequestDataApiController
            .allrequestApi(uid: userid.toString(), status: "completed")
            .then(
          (value) {
            setState(() {});
            allRequestDataApiController
                .allrequestApi(uid: userid.toString(), status: "cancelled")
                .then(
              (value) {
                setState(() {
                  loader = false;
                  print("88888888888:-- ${loader}");
                });
              },
            );
          },
        );
      },
    );

    // livelat = double.parse(value["accepted_d_detail"]["latitude"]);
    // livelong = double.parse(value["accepted_d_detail"]["longitude"]);
    // imagenetwork = "${Config.imageurl}${value["accepted_d_detail"]["map_img"]}";
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      appBar: AppBar(
        backgroundColor: notifier.background,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Image(
                  image: AssetImage("assets/arrow-left.png"),
                  color: notifier.textColor),
            )),
        title: Transform.translate(
            offset: Offset(-10, 0),
            child: Text("My Rides".tr,
                style: TextStyle(color: notifier.textColor, fontSize: 18))),
      ),
      body: GetBuilder<AllRequestDataApiController>(
        builder: (allRequestDataApiController) {
          return loader
              ? Center(child: CircularProgressIndicator(color: theamcolore))
              : Padding(
                  padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0, right: 0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.4)),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(16)),
                                  ),
                                  child: TabBar(
                                    indicator: BoxDecoration(
                                      color: theamcolore,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    controller: _tabController,
                                    indicatorColor: Colors.red,
                                    labelColor: Colors.white,
                                    unselectedLabelColor: notifier.textColor,
                                    dividerColor: Colors.transparent,
                                    labelStyle: const TextStyle(fontSize: 14),
                                    tabs: <Widget>[
                                      Tab(text: 'Upcoming'.tr),
                                      Tab(text: 'Completed'.tr),
                                      Tab(text: 'Cancelled'.tr),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: <Widget>[
                                    allRequestDataApiController
                                            .allRequestDataModelupcoming!
                                            .reuqestList!
                                            .isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 150,
                                                  width: 150,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          "assets/emptyOrder.png"),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  "No Order Found!".tr,
                                                  style: TextStyle(
                                                    color: notifier.textColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "Currently you don’t have order."
                                                      .tr,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ListView.separated(
                                            separatorBuilder: (context, index) {
                                              return const SizedBox(height: 0);
                                            },
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount:
                                                allRequestDataApiController
                                                    .allRequestDataModelupcoming!
                                                    .reuqestList!
                                                    .length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    appstatus =
                                                        allRequestDataApiController
                                                            .allRequestDataModelupcoming!
                                                            .reuqestList![index]
                                                            .status
                                                            .toString();
                                                    runtimestatusid =
                                                        allRequestDataApiController
                                                            .allRequestDataModelupcoming!
                                                            .reuqestList![index]
                                                            .runTime!
                                                            .status
                                                            .toString();
                                                    appstatusid =
                                                        allRequestDataApiController
                                                            .allRequestDataModelupcoming!
                                                            .reuqestList![index]
                                                            .id
                                                            .toString();

                                                    if (appstatus == "1") {
                                                      print("IF CONDITION");
                                                      driveridloader = true;
                                                      loadertimer = true;

                                                      // driveridloader == true ? drive_id_list = allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].driverIdList! : [];
                                                      // print("Status 1 Status:-- $drive_id_list");
                                                      driver_id =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .dId
                                                              .toString();
                                                      tot_hour =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .hour
                                                              .toString();
                                                      tot_time =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .minute
                                                              .toString();
                                                      tot_secound =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .second
                                                              .toString();
                                                      print(
                                                          "@@@1@@@:--- ${tot_hour}");
                                                      print(
                                                          "@@@1@@@:--- ${tot_time}");
                                                      print(
                                                          "@@@1@@@:--- ${tot_secound}");

                                                      vihicalname =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .vehicleName
                                                              .toString();
                                                      vihicalimage =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .vehicleImage
                                                              .toString();

                                                      picktitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .pickup!
                                                              .title
                                                              .toString();
                                                      picksubtitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .pickup!
                                                              .subtitle
                                                              .toString();
                                                      droptitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .drop!
                                                              .title
                                                              .toString();
                                                      dropsubtitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .drop!
                                                              .subtitle
                                                              .toString();
                                                      request_id =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .id
                                                              .toString();

                                                      vihicalrice = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .price
                                                              .toString());

                                                      // for(int i=0; i<allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].dropList!.length; i++){
                                                      //   droptitlelist.add(
                                                      //       {
                                                      //         "title" : allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].dropList![i].title,
                                                      //         "subt": allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].dropList![i].subtitle
                                                      //       }
                                                      //   );
                                                      //   print(".......111111......:--- ${droptitlelist}");
                                                      // }

                                                      for (int i = 0;
                                                          i <
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .dropList!
                                                                  .length;
                                                          i++) {
                                                        var dropItem =
                                                            allRequestDataApiController
                                                                .allRequestDataModelupcoming!
                                                                .reuqestList![
                                                                    index]
                                                                .dropList![i];

                                                        droptitlelist.add({
                                                          "title": dropItem[
                                                              'title'], // Use the key ['title'] if it's a Map
                                                          "subt": dropItem[
                                                              'subtitle']
                                                        });

                                                        print(
                                                            ".......111111......:--- ${droptitlelist}");
                                                      }

                                                      globalDriverAcceptClass.driverdetailfunction(
                                                          lat: double.parse(
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .pickup!
                                                                  .latitude
                                                                  .toString()),
                                                          long: double.parse(
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .pickup!
                                                                  .longitude
                                                                  .toString()),
                                                          d_id:
                                                              "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].dId}",
                                                          request_id:
                                                              "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].id}",
                                                          context: context);
                                                    } else if (appstatus ==
                                                        "2") {
                                                      driveridloader = true;
                                                      loadertimer = true;

                                                      plusetimer =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .status
                                                              .toString();
                                                      extratime =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .driverWaitTime
                                                              .toString();

                                                      print(
                                                          "plusetimer:222plusetimer:- ${plusetimer}");
                                                      print(
                                                          "extratime:222extratime:- ${extratime}");
                                                      print(
                                                          "appstatus:222appstatus:- ${appstatus}");
                                                      driver_id =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .dId
                                                              .toString();
                                                      tot_hour =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .hour
                                                              .toString();
                                                      tot_time =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .minute
                                                              .toString();
                                                      tot_secound =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .second
                                                              .toString();
                                                      print(
                                                          "@@@2@@@:--- ${tot_hour}");
                                                      print(
                                                          "@@@2@@@:--- ${tot_time}");

                                                      vihicalname =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .vehicleName
                                                              .toString();
                                                      vihicalimage =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .vehicleImage
                                                              .toString();

                                                      picktitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .pickup!
                                                              .title
                                                              .toString();
                                                      picksubtitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .pickup!
                                                              .subtitle
                                                              .toString();
                                                      droptitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .drop!
                                                              .title
                                                              .toString();
                                                      dropsubtitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .drop!
                                                              .subtitle
                                                              .toString();
                                                      vihicalrice = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .price
                                                              .toString());
                                                      request_id =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .id
                                                              .toString();

                                                      for (int i = 0;
                                                          i <
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .dropList!
                                                                  .length;
                                                          i++) {
                                                        var dropItem =
                                                            allRequestDataApiController
                                                                .allRequestDataModelupcoming!
                                                                .reuqestList![
                                                                    index]
                                                                .dropList![i];

                                                        droptitlelist.add({
                                                          "title": dropItem[
                                                              'title'], // Use the key ['title'] if it's a Map
                                                          "subt": dropItem[
                                                              'subtitle']
                                                        });

                                                        print(
                                                            ".......111111......:--- ${droptitlelist}");
                                                      }

                                                      globalDriverAcceptClass.driverdetailfunction(
                                                          lat: double.parse(
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .pickup!
                                                                  .latitude
                                                                  .toString()),
                                                          long: double.parse(
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .pickup!
                                                                  .longitude
                                                                  .toString()),
                                                          d_id:
                                                              "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].dId}",
                                                          request_id:
                                                              "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].id}",
                                                          context: context);
                                                    } else if (appstatus ==
                                                        "3") {
                                                      print(
                                                          "Status 3 Status:--");

                                                      driveridloader = true;
                                                      loadertimer = true;
                                                      otpstatus = true;

                                                      // timerstop = allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].runTime!.status.toString();
                                                      //
                                                      // print("***otpstatus***:---- ${otpstatus}");
                                                      // print("***timerstop***:---- ${timerstop}");

                                                      driver_id =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .dId
                                                              .toString();
                                                      vihicalname =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .vehicleName
                                                              .toString();
                                                      vihicalimage =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .vehicleImage
                                                              .toString();
                                                      // driveridloader == true ? drive_id_list = allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].driverIdList! : [];
                                                      tot_hour =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .hour
                                                              .toString();
                                                      tot_time =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .minute
                                                              .toString();
                                                      tot_secound =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .second
                                                              .toString();

                                                      picktitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .pickup!
                                                              .title
                                                              .toString();
                                                      picksubtitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .pickup!
                                                              .subtitle
                                                              .toString();
                                                      droptitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .drop!
                                                              .title
                                                              .toString();
                                                      dropsubtitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .drop!
                                                              .subtitle
                                                              .toString();
                                                      vihicalrice = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .price
                                                              .toString());
                                                      request_id =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .id
                                                              .toString();

                                                      // for(int i=0; i<allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].dropList!.length; i++){
                                                      //   droptitlelist.add(
                                                      //       {
                                                      //         "title" : allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].dropList![i].title,
                                                      //         "subt": allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].dropList![i].subtitle
                                                      //       }
                                                      //   );
                                                      //   print(".......33333......:--- ${droptitlelist}");
                                                      // }

                                                      for (int i = 0;
                                                          i <
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .dropList!
                                                                  .length;
                                                          i++) {
                                                        var dropItem =
                                                            allRequestDataApiController
                                                                .allRequestDataModelupcoming!
                                                                .reuqestList![
                                                                    index]
                                                                .dropList![i];

                                                        droptitlelist.add({
                                                          "title": dropItem[
                                                              'title'], // Use the key ['title'] if it's a Map
                                                          "subt": dropItem[
                                                              'subtitle']
                                                        });

                                                        print(
                                                            ".......111111......:--- ${droptitlelist}");
                                                      }

                                                      globalDriverAcceptClass.driverdetailfunction(
                                                          lat: double.parse(
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .pickup!
                                                                  .latitude
                                                                  .toString()),
                                                          long: double.parse(
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .pickup!
                                                                  .longitude
                                                                  .toString()),
                                                          d_id:
                                                              "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].dId}",
                                                          request_id:
                                                              "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].id}",
                                                          context: context);
                                                    } else if (appstatus ==
                                                        "5") {
                                                      print(
                                                          "Status 5 Status:--");
                                                      loadertimer = true;
                                                      timervarable = true;
                                                      vihicalname =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .vehicleName
                                                              .toString();
                                                      vihicalimage =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .vehicleImage
                                                              .toString();

                                                      picktitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .pickup!
                                                              .title
                                                              .toString();
                                                      picksubtitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .pickup!
                                                              .subtitle
                                                              .toString();
                                                      droptitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .drop!
                                                              .title
                                                              .toString();
                                                      dropsubtitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .drop!
                                                              .subtitle
                                                              .toString();
                                                      vihicalrice = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .price
                                                              .toString());
                                                      statusridestart =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .status
                                                              .toString();

                                                      totaldrophour =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .hour
                                                              .toString();
                                                      totaldropmint =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .minute
                                                              .toString();
                                                      totaldropsecound =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .runTime!
                                                              .second
                                                              .toString();

                                                      livelat = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .latitude
                                                              .toString());
                                                      livelong = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .longitude
                                                              .toString());
                                                      imagenetwork =
                                                          "${Config.imageurl}${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].mapImg}";
                                                      droppointstartscreen.add(PointLatLng(
                                                          double.parse(
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .drop!
                                                                  .latitude
                                                                  .toString()),
                                                          double.parse(
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .drop!
                                                                  .longitude
                                                                  .toString())));

                                                      print(
                                                          "Status !!totaldrophour!! Status:-- ${livelat}");
                                                      print(
                                                          "Status !!totaldropmint!! Status:-- ${livelong}");
                                                      print(
                                                          "Status !!totaldropsecound!! Status:-- ${imagenetwork}");

                                                      driver_id =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .dId
                                                              .toString();

                                                      drivername =
                                                          "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].firstName} ${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].lastName}";
                                                      drivervihicalnumber =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .vehicleNumber
                                                              .toString();
                                                      driverimage =
                                                          "${Config.imageurl}${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].profileImage.toString()}";
                                                      driverrating =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .avgStar
                                                              .toString();
                                                      driverlanguage =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .language
                                                              .toString();
                                                      request_id =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .id
                                                              .toString();

                                                      for (int i = 0;
                                                          i <
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .dropList!
                                                                  .length;
                                                          i++) {
                                                        var dropItem =
                                                            allRequestDataApiController
                                                                .allRequestDataModelupcoming!
                                                                .reuqestList![
                                                                    index]
                                                                .dropList![i];

                                                        droptitlelist.add({
                                                          "title": dropItem[
                                                              'title'], // Use the key ['title'] if it's a Map
                                                          "subt": dropItem[
                                                              'subtitle']
                                                        });

                                                        // droppointstartscreen.add(PointLatLng(double.parse(dropItem[i]['title']), double.parse(dropItem[i]['subtitle'])));

                                                        print(
                                                            ".......111111......:--- ${droptitlelist}");
                                                        // print(".......droppointstartscreen......:--- ${droppointstartscreen}");
                                                      }

                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const DriverStartrideScreen(),
                                                          ));
                                                    } else if (appstatus ==
                                                        "6") {
                                                      print(
                                                          "Status 6 Status:--");
                                                      loadertimer = true;
                                                      timervarable = false;
                                                      vihicalname =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .vehicleName
                                                              .toString();
                                                      vihicalimage =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .vehicleImage
                                                              .toString();
                                                      driver_id =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .dId
                                                              .toString();
                                                      picktitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .pickup!
                                                              .title
                                                              .toString();
                                                      picksubtitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .pickup!
                                                              .subtitle
                                                              .toString();
                                                      droptitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .drop!
                                                              .title
                                                              .toString();
                                                      dropsubtitle =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .drop!
                                                              .subtitle
                                                              .toString();
                                                      vihicalrice = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .price
                                                              .toString());
                                                      statusridestart =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .status
                                                              .toString();

                                                      drivername =
                                                          "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].firstName} ${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].lastName}";
                                                      drivervihicalnumber =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .vehicleNumber
                                                              .toString();
                                                      driverimage =
                                                          "${Config.imageurl}${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].profileImage.toString()}";
                                                      driverrating =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .avgStar
                                                              .toString();
                                                      driverlanguage =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .language
                                                              .toString();
                                                      request_id =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .id
                                                              .toString();

                                                      // for(int i=0; i<allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].dropList!.length; i++){
                                                      //   droptitlelist.add(
                                                      //       {
                                                      //         "title" : allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].dropList![i].title,
                                                      //         "subt": allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].dropList![i].subtitle
                                                      //       }
                                                      //   );
                                                      //   print(".......33333......:--- ${droptitlelist}");
                                                      // }

                                                      livelat = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .latitude
                                                              .toString());
                                                      livelong = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .longitude
                                                              .toString());
                                                      imagenetwork =
                                                          "${Config.imageurl}${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].mapImg}";
                                                      droppointstartscreen.add(PointLatLng(
                                                          double.parse(
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .drop!
                                                                  .latitude
                                                                  .toString()),
                                                          double.parse(
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .drop!
                                                                  .longitude
                                                                  .toString())));

                                                      for (int i = 0;
                                                          i <
                                                              allRequestDataApiController
                                                                  .allRequestDataModelupcoming!
                                                                  .reuqestList![
                                                                      index]
                                                                  .dropList!
                                                                  .length;
                                                          i++) {
                                                        var dropItem =
                                                            allRequestDataApiController
                                                                .allRequestDataModelupcoming!
                                                                .reuqestList![
                                                                    index]
                                                                .dropList![i];

                                                        droptitlelist.add({
                                                          "title": dropItem[
                                                              'title'], // Use the key ['title'] if it's a Map
                                                          "subt": dropItem[
                                                              'subtitle']
                                                        });

                                                        print(
                                                            ".......111111......:--- ${droptitlelist}");
                                                      }

                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const DriverStartrideScreen(),
                                                          ));
                                                    } else if (appstatus ==
                                                        "7") {
                                                      print(
                                                          "Status 7 Status:--");

                                                      // total = Vehicle_Ride_Payment["price_list"]["tot_price"];
                                                      // finaltotal = Vehicle_Ride_Payment["price_list"]["final_price"];
                                                      // coupontotal = Vehicle_Ride_Payment["price_list"]["coupon_amount"];
                                                      // additionaltotal = Vehicle_Ride_Payment["price_list"]["addi_time_price"];
                                                      // platformfee = Vehicle_Ride_Payment["price_list"]["platform_fee"];
                                                      // additionaltime = Vehicle_Ride_Payment["price_list"]["addi_time"];
                                                      print(
                                                          "//////:-- ${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].finalPrice}");

                                                      total = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .price
                                                              .toString());
                                                      finaltotal = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .finalPrice
                                                              .toString());
                                                      coupontotal = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .couponAmount
                                                              .toString());
                                                      additionaltotal = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .addiTimePrice
                                                              .toString());
                                                      platformfee = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .platformFee
                                                              .toString());
                                                      additionaltime = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .addiTime
                                                              .toString());
                                                      whthercharge = double.parse(
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .weatherPrice
                                                              .toString());

                                                      driver_id =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .dId
                                                              .toString();
                                                      request_id =
                                                          allRequestDataApiController
                                                              .allRequestDataModelupcoming!
                                                              .reuqestList![
                                                                  index]
                                                              .id
                                                              .toString();
                                                      driverimage =
                                                          "${Config.imageurl}${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].profileImage.toString()}";

                                                      print(
                                                          "'''''':--- ${total}");
                                                      print(
                                                          "'''''':--- ${finaltotal}");
                                                      print(
                                                          "'''''':--- ${coupontotal}");
                                                      print(
                                                          "'''''':--- ${additionaltotal}");
                                                      print(
                                                          "'''''':--- ${platformfee}");
                                                      print(
                                                          "'''''':--- ${additionaltime}");

                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const RideCompletePaymentScreen(),
                                                          ));
                                                    } else {
                                                      print("ELSE");
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  // height: 200,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.8,
                                                  margin: const EdgeInsets.only(
                                                      bottom: 10),
                                                  decoration: BoxDecoration(
                                                    // color: Colors.red,
                                                    border: Border.all(
                                                        color: Colors.grey
                                                            .withOpacity(0.4)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].mRole}",
                                                              style: TextStyle(
                                                                  color: notifier
                                                                      .textColor),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Container(
                                                              height: 5,
                                                              width: 5,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color:
                                                                    Colors.grey,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].vehicleName}",
                                                              style: TextStyle(
                                                                  color: notifier
                                                                      .textColor),
                                                            ),
                                                            const Spacer(),
                                                            Text(
                                                              "${currencyy}${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].price}",
                                                              style: TextStyle(
                                                                  color: notifier
                                                                      .textColor,
                                                                  fontSize: 18),
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            allRequestDataApiController
                                                                        .allRequestDataModelupcoming!
                                                                        .reuqestList![
                                                                            index]
                                                                        .startTime ==
                                                                    ""
                                                                ? SizedBox()
                                                                : Text(
                                                                    "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].startTime.toString().split(",").first}, ${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].startTime.toString().split(",").last}",
                                                                    style: TextStyle(
                                                                        color: notifier
                                                                            .textColor),
                                                                  ),
                                                            const Spacer(),
                                                            Text(
                                                              "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].pName}",
                                                              style: TextStyle(
                                                                  color: notifier
                                                                      .textColor),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        ListTile(
                                                          // isThreeLine: true,
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                          leading: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 8.0),
                                                            child: Container(
                                                              height: 22,
                                                              width: 22,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .green
                                                                      .withOpacity(
                                                                          0.2),
                                                                  shape: BoxShape
                                                                      .circle),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(6),
                                                                child:
                                                                    Container(
                                                                  // height: 10,
                                                                  // width: 10,
                                                                  decoration: const BoxDecoration(
                                                                      color: Colors
                                                                          .green,
                                                                      shape: BoxShape
                                                                          .circle),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          title: Transform
                                                              .translate(
                                                                  offset:
                                                                      const Offset(
                                                                          -20,
                                                                          0),
                                                                  child: Text(
                                                                    "Pickup".tr,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green),
                                                                  )),
                                                          subtitle: Transform
                                                              .translate(
                                                                  offset:
                                                                      const Offset(
                                                                          -20,
                                                                          0),
                                                                  child: Text(
                                                                    "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].pickup!.title}",
                                                                    style: TextStyle(
                                                                        color: notifier
                                                                            .textColor,
                                                                        fontSize:
                                                                            16),
                                                                    maxLines: 1,
                                                                  )),
                                                        ),
                                                        ListTile(
                                                          // isThreeLine: true,
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                          leading: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 8.0),
                                                            child: Container(
                                                              height: 22,
                                                              width: 22,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .red
                                                                      .withOpacity(
                                                                          0.2),
                                                                  shape: BoxShape
                                                                      .circle),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(6),
                                                                child:
                                                                    Container(
                                                                  // height: 10,
                                                                  // width: 10,
                                                                  decoration: const BoxDecoration(
                                                                      color: Colors
                                                                          .red,
                                                                      shape: BoxShape
                                                                          .circle),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          title: Transform
                                                              .translate(
                                                                  offset:
                                                                      const Offset(
                                                                          -20,
                                                                          0),
                                                                  child: Text(
                                                                    "Destination"
                                                                        .tr,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red),
                                                                  )),
                                                          subtitle: Transform
                                                              .translate(
                                                                  offset:
                                                                      Offset(
                                                                          -20,
                                                                          0),
                                                                  child: Text(
                                                                    "${allRequestDataApiController.allRequestDataModelupcoming!.reuqestList![index].drop!.title}",
                                                                    style: TextStyle(
                                                                        color: notifier
                                                                            .textColor,
                                                                        fontSize:
                                                                            16),
                                                                    maxLines: 2,
                                                                  )),
                                                        ),
                                                        // const SizedBox(height: 10,),
                                                        // Row(
                                                        //   crossAxisAlignment: CrossAxisAlignment.center,
                                                        //   mainAxisAlignment: MainAxisAlignment.center,
                                                        //   children: [
                                                        //     Icon(Icons.person,color: theamcolore,),
                                                        //     const SizedBox(width: 10,),
                                                        //     const Text("Driver arrived in",style: TextStyle(color: Colors.black,fontSize: 18),),
                                                        //     Text(" 15 mins",style: TextStyle(color: theamcolore,fontSize: 18),),
                                                        //   ],
                                                        // )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                    allRequestDataApiController
                                            .allRequestDataModelcompleted!
                                            .reuqestList!
                                            .isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 150,
                                                  width: 150,
                                                  decoration:
                                                      const BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          "assets/emptyOrder.png"),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  "No Order Found!".tr,
                                                  style: TextStyle(
                                                    color: notifier.textColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "Currently you don’t have order."
                                                      .tr,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ListView.separated(
                                            separatorBuilder: (context, index) {
                                              return const SizedBox(height: 0);
                                            },
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: allRequestDataApiController
                                                .allRequestDataModelcompleted!
                                                .reuqestList!
                                                .length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0),
                                                child: InkWell(
                                                  onTap: () {
                                                    driver_id =
                                                        allRequestDataApiController
                                                            .allRequestDataModelcompleted!
                                                            .reuqestList![index]
                                                            .dId
                                                            .toString();
                                                    ridecompleterequestid =
                                                        allRequestDataApiController
                                                            .allRequestDataModelcompleted!
                                                            .reuqestList![index]
                                                            .id
                                                            .toString();
                                                    driverimage =
                                                        "${Config.imageurl}${allRequestDataApiController.allRequestDataModelcompleted!.reuqestList![index].profileImage.toString()}";
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              MyRideDetailScreen(
                                                            request_id:
                                                                "${allRequestDataApiController.allRequestDataModelcompleted!.reuqestList![index].id}",
                                                            status: "complete",
                                                          ),
                                                        ));
                                                  },
                                                  child: Container(
                                                    // height: 200,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    decoration: BoxDecoration(
                                                      // color: Colors.red,
                                                      border: Border.all(
                                                          color: Colors.grey
                                                              .withOpacity(
                                                                  0.4)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "${allRequestDataApiController.allRequestDataModelcompleted!.reuqestList![index].mRole}",
                                                                style: TextStyle(
                                                                    color: notifier
                                                                        .textColor),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Container(
                                                                height: 5,
                                                                width: 5,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color: Colors
                                                                      .grey,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                "${allRequestDataApiController.allRequestDataModelcompleted!.reuqestList![index].vehicleName}",
                                                                style: TextStyle(
                                                                    color: notifier
                                                                        .textColor),
                                                              ),
                                                              const Spacer(),
                                                              Text(
                                                                "${currencyy}${allRequestDataApiController.allRequestDataModelcompleted!.reuqestList![index].finalPrice}",
                                                                style: TextStyle(
                                                                    color: notifier
                                                                        .textColor,
                                                                    fontSize:
                                                                        18),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "${allRequestDataApiController.allRequestDataModelcompleted!.reuqestList![index].startTime.toString().split(",").first}, ${allRequestDataApiController.allRequestDataModelcompleted!.reuqestList![index].startTime.toString().split(",").last}",
                                                                style: TextStyle(
                                                                    color: notifier
                                                                        .textColor),
                                                              ),
                                                              // const Text("18/11/2024, 10:24 AM"),
                                                              const Spacer(),
                                                              allRequestDataApiController
                                                                          .allRequestDataModelcompleted!
                                                                          .reuqestList![
                                                                              index]
                                                                          .walletPrice ==
                                                                      0
                                                                  ? Text(
                                                                      "${allRequestDataApiController.allRequestDataModelcompleted!.reuqestList![index].pName}",
                                                                      style: TextStyle(
                                                                          color:
                                                                              notifier.textColor),
                                                                    )
                                                                  : allRequestDataApiController
                                                                              .allRequestDataModelcompleted!
                                                                              .reuqestList![index]
                                                                              .paidAmount ==
                                                                          0
                                                                      ? Text(
                                                                          "Wallet"
                                                                              .tr,
                                                                          style:
                                                                              TextStyle(color: notifier.textColor),
                                                                        )
                                                                      : Text(
                                                                          "Wallet + ${allRequestDataApiController.allRequestDataModelcompleted!.reuqestList![index].pName}",
                                                                          style:
                                                                              TextStyle(color: notifier.textColor),
                                                                        )
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          ListTile(
                                                            // isThreeLine: true,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            leading: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 8.0),
                                                              child: Container(
                                                                height: 22,
                                                                width: 22,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .green
                                                                        .withOpacity(
                                                                            0.2),
                                                                    shape: BoxShape
                                                                        .circle),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          6),
                                                                  child:
                                                                      Container(
                                                                    // height: 10,
                                                                    // width: 10,
                                                                    decoration: const BoxDecoration(
                                                                        color: Colors
                                                                            .green,
                                                                        shape: BoxShape
                                                                            .circle),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            title: Transform
                                                                .translate(
                                                                    offset:
                                                                        const Offset(
                                                                            -20,
                                                                            0),
                                                                    child: Text(
                                                                      "Pickup"
                                                                          .tr,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.green),
                                                                    )),
                                                            subtitle: Transform
                                                                .translate(
                                                                    offset:
                                                                        const Offset(
                                                                            -20,
                                                                            0),
                                                                    child: Text(
                                                                      "${allRequestDataApiController.allRequestDataModelcompleted!.reuqestList![index].pickup!.title}",
                                                                      style: TextStyle(
                                                                          color: notifier
                                                                              .textColor,
                                                                          fontSize:
                                                                              16),
                                                                      maxLines:
                                                                          1,
                                                                    )),
                                                          ),
                                                          ListTile(
                                                            // isThreeLine: true,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            leading: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 8.0),
                                                              child: Container(
                                                                height: 22,
                                                                width: 22,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .red
                                                                        .withOpacity(
                                                                            0.2),
                                                                    shape: BoxShape
                                                                        .circle),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          6),
                                                                  child:
                                                                      Container(
                                                                    // height: 10,
                                                                    // width: 10,
                                                                    decoration: const BoxDecoration(
                                                                        color: Colors
                                                                            .red,
                                                                        shape: BoxShape
                                                                            .circle),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            title: Transform
                                                                .translate(
                                                                    offset:
                                                                        const Offset(
                                                                            -20,
                                                                            0),
                                                                    child: Text(
                                                                      "Destination"
                                                                          .tr,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    )),
                                                            subtitle: Transform
                                                                .translate(
                                                                    offset:
                                                                        const Offset(
                                                                            -20,
                                                                            0),
                                                                    child: Text(
                                                                      "${allRequestDataApiController.allRequestDataModelcompleted!.reuqestList![index].drop!.title}",
                                                                      style: TextStyle(
                                                                          color: notifier
                                                                              .textColor,
                                                                          fontSize:
                                                                              16),
                                                                      maxLines:
                                                                          2,
                                                                    )),
                                                          ),
                                                          // const SizedBox(height: 10,),
                                                          // Row(
                                                          //   crossAxisAlignment: CrossAxisAlignment.center,
                                                          //   mainAxisAlignment: MainAxisAlignment.center,
                                                          //   children: [
                                                          //     Icon(Icons.person,color: theamcolore,),
                                                          //     const SizedBox(width: 10,),
                                                          //     const Text("Driver arrived in",style: TextStyle(color: Colors.black,fontSize: 18),),
                                                          //     Text(" 15mins",style: TextStyle(color: theamcolore,fontSize: 18),),
                                                          //   ],
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                    allRequestDataApiController
                                            .allRequestDataModelcancelled!
                                            .reuqestList!
                                            .isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 150,
                                                  width: 150,
                                                  decoration:
                                                      const BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          "assets/emptyOrder.png"),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  "No Order Found!".tr,
                                                  style: TextStyle(
                                                    color: notifier.textColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "Currently you don’t have order."
                                                      .tr,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ListView.separated(
                                            separatorBuilder: (context, index) {
                                              return const SizedBox(height: 0);
                                            },
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: allRequestDataApiController
                                                .allRequestDataModelcancelled!
                                                .reuqestList!
                                                .length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              MyRideDetailScreen(
                                                            request_id:
                                                                "${allRequestDataApiController.allRequestDataModelcancelled!.reuqestList![index].id}",
                                                            status: "cancel",
                                                          ),
                                                        ));
                                                    print(
                                                        "***:-- ${allRequestDataApiController.allRequestDataModelcancelled!.reuqestList![index].id}");
                                                  },
                                                  child: Container(
                                                    // height: 200,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    decoration: BoxDecoration(
                                                      // color: Colors.red,
                                                      border: Border.all(
                                                          color: Colors.grey
                                                              .withOpacity(
                                                                  0.4)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "${allRequestDataApiController.allRequestDataModelcancelled!.reuqestList![index].mRole}",
                                                                style: TextStyle(
                                                                    color: notifier
                                                                        .textColor),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Container(
                                                                height: 5,
                                                                width: 5,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color: Colors
                                                                      .grey,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                "${allRequestDataApiController.allRequestDataModelcancelled!.reuqestList![index].vehicleName}",
                                                                style: TextStyle(
                                                                    color: notifier
                                                                        .textColor),
                                                              ),
                                                              const Spacer(),
                                                              Text(
                                                                "${currencyy}${allRequestDataApiController.allRequestDataModelcancelled!.reuqestList![index].price}",
                                                                style: TextStyle(
                                                                    color: notifier
                                                                        .textColor,
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              // const Text("18/11/2024, 10:24 AM"),
                                                              Text(
                                                                "${allRequestDataApiController.allRequestDataModelcancelled!.reuqestList![index].startTime.toString().split(",").first}, ${allRequestDataApiController.allRequestDataModelcancelled!.reuqestList![index].startTime.toString().split(",").last}",
                                                                style: TextStyle(
                                                                    color: notifier
                                                                        .textColor),
                                                              ),
                                                              const Spacer(),
                                                              allRequestDataApiController
                                                                          .allRequestDataModelcancelled!
                                                                          .reuqestList![
                                                                              index]
                                                                          .walletPrice ==
                                                                      0
                                                                  ? Text(
                                                                      "${allRequestDataApiController.allRequestDataModelcancelled!.reuqestList![index].pName}",
                                                                      style: TextStyle(
                                                                          color:
                                                                              notifier.textColor),
                                                                    )
                                                                  : allRequestDataApiController
                                                                              .allRequestDataModelcancelled!
                                                                              .reuqestList![index]
                                                                              .paidAmount ==
                                                                          0
                                                                      ? Text(
                                                                          "Wallet"
                                                                              .tr,
                                                                          style:
                                                                              TextStyle(color: notifier.textColor),
                                                                        )
                                                                      : Text(
                                                                          "Wallet + ${allRequestDataApiController.allRequestDataModelcancelled!.reuqestList![index].pName}",
                                                                          style:
                                                                              TextStyle(color: notifier.textColor),
                                                                        )

                                                              // Text("${allRequestDataApiController.allRequestDataModelcancelled!.reuqestList![index].pName}"),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          ListTile(
                                                            // isThreeLine: true,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            leading: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 8.0),
                                                              child: Container(
                                                                height: 22,
                                                                width: 22,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .green
                                                                        .withOpacity(
                                                                            0.2),
                                                                    shape: BoxShape
                                                                        .circle),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          6),
                                                                  child:
                                                                      Container(
                                                                    // height: 10,
                                                                    // width: 10,
                                                                    decoration: const BoxDecoration(
                                                                        color: Colors
                                                                            .green,
                                                                        shape: BoxShape
                                                                            .circle),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            title: Transform.translate(
                                                                offset:
                                                                    const Offset(
                                                                        -20, 0),
                                                                child: Text(
                                                                    "Pickup".tr,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green))),
                                                            subtitle: Transform
                                                                .translate(
                                                                    offset:
                                                                        const Offset(
                                                                            -20,
                                                                            0),
                                                                    child: Text(
                                                                      "${allRequestDataApiController.allRequestDataModelcancelled!.reuqestList![index].pickup!.title}",
                                                                      style: TextStyle(
                                                                          color: notifier
                                                                              .textColor,
                                                                          fontSize:
                                                                              16),
                                                                      maxLines:
                                                                          1,
                                                                    )),
                                                          ),
                                                          ListTile(
                                                            // isThreeLine: true,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            leading: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 8.0),
                                                              child: Container(
                                                                height: 22,
                                                                width: 22,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .red
                                                                        .withOpacity(
                                                                            0.2),
                                                                    shape: BoxShape
                                                                        .circle),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          6),
                                                                  child:
                                                                      Container(
                                                                    // height: 10,
                                                                    // width: 10,
                                                                    decoration: const BoxDecoration(
                                                                        color: Colors
                                                                            .red,
                                                                        shape: BoxShape
                                                                            .circle),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            title: Transform
                                                                .translate(
                                                                    offset:
                                                                        const Offset(
                                                                            -20,
                                                                            0),
                                                                    child: Text(
                                                                      "Destination"
                                                                          .tr,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    )),
                                                            subtitle: Transform
                                                                .translate(
                                                                    offset:
                                                                        const Offset(
                                                                            -20,
                                                                            0),
                                                                    child: Text(
                                                                      "${allRequestDataApiController.allRequestDataModelcancelled!.reuqestList![index].drop!.title}",
                                                                      style: TextStyle(
                                                                          color: notifier
                                                                              .textColor,
                                                                          fontSize:
                                                                              16),
                                                                      maxLines:
                                                                          2,
                                                                    )),
                                                          ),
                                                          // const SizedBox(height: 10,),
                                                          // Row(
                                                          //   crossAxisAlignment: CrossAxisAlignment.center,
                                                          //   mainAxisAlignment: MainAxisAlignment.center,
                                                          //   children: [
                                                          //     Icon(Icons.person,color: theamcolore,),
                                                          //     const SizedBox(width: 10,),
                                                          //     const Text("Driver arrived in",style: TextStyle(color: Colors.black,fontSize: 18),),
                                                          //     Text(" 15 mins",style: TextStyle(color: theamcolore,fontSize: 18),),
                                                          //   ],
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                  ],
                                ),
                              ),
                            ],
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
