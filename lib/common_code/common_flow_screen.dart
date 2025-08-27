import 'package:qareeb/common_code/custom_loading_widget.dart';
// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../api_code/add_vehical_api_controller.dart';
import '../api_code/cancel_rason_request_api_controller.dart';
import '../api_code/remove_request.dart';
import '../api_code/review_api_controller.dart';
import '../api_code/review_data_api_controller.dart';
import '../api_code/vihical_calculate_api_controller.dart';
import '../api_code/vihical_driver_detail_api_controller.dart';
import '../api_code/vihical_ride_cancel.dart';
import '../api_code/vihical_ride_complete_order_api_controller.dart';
import '../app_screen/counter_bottom_sheet.dart';
import '../app_screen/driver_detail_screen.dart';
import '../app_screen/driver_startride_screen.dart';
import '../app_screen/home_screen.dart';
import '../app_screen/map_screen.dart';
import '../app_screen/my_ride_screen.dart';
import '../app_screen/pickup_drop_point.dart';
import '../app_screen/ride_complete_payment_screen.dart';
import 'colore_screen.dart';
import 'common_button.dart';
import 'config.dart';
import 'package:lottie/lottie.dart' as lottie;

bool cancelloader = false;

Future commonbottomsheetrequestsend({required context}) {
  socket.connect();
  RemoveRequest removeRequest = Get.put(RemoveRequest());
  VihicalCalculateController vihicalCalculateController = Get.put(
    VihicalCalculateController(),
  );
  return Get.bottomSheet(
    enableDrag: false,
    isDismissible: false,
    StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 420,
              width: Get.width,
              decoration: BoxDecoration(
                color: notifier.containercolore,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Finding Ride for you",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: notifier.textColor,
                          ),
                        ),
                        subtitle: Text(
                          "$vihicalname ride",
                          style: TextStyle(
                            color: notifier.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        trailing: InkWell(
                          onTap: () {
                            commonbottomsheetcancelflow(context: context);
                          },
                          child: Container(
                            height: 35,
                            width: 110,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.4),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "Trip Details",
                                style: TextStyle(color: notifier.textColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const CounterBottomSheet(),
                      const SizedBox(height: 10),
                      lottie.Lottie.asset(
                        'assets/lottie/find.json',
                        height: 200,
                      ),
                      const SizedBox(height: 10),
                      cancelloader == true
                          ? Center(
                              child: CustomLoadingWidget(),
                            )
                          : CommonOutLineButton(
                              bordercolore: theamcolore,
                              onPressed1: () {
                                cancelloader = true;
                                removeRequest
                                    .removeApi(uid: useridgloable.toString())
                                    .then((value) {
                                  socket.emit('AcceRemoveOther', {
                                    'requestid': request_id,
                                    'driverid': vihicalCalculateController
                                        .vihicalCalculateModel!.driverId!,
                                  });
                                  Future.delayed(
                                    Duration(microseconds: 500),
                                    () {
                                      setState(() {
                                        setState(() {});
                                      });
                                    },
                                  );
                                  Get.back();
                                  cancelloader = false;
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      socket.close();
                                      print('Action performed!');
                                    },
                                  );
                                });
                              },
                              context: context,
                              txt1: "Cancel Request",
                            ),
                    ],
                  ),
                ),
              ),
            ),
            // Positioned(
            //   top: -50,
            //   right: 10,
            //   child: InkWell(
            //     onTap: () {
            //
            //         print("vvvvvvv");
            //         removeRequest.removeApi(uid: useridgloable.toString()).then((value) {
            //           socket.emit('AcceRemoveOther',{
            //             'requestid': request_id,
            //             'driverid' : vihicalCalculateController.vihicalCalculateModel!.driverId!,
            //           });
            //         },);
            //         // Get.back();
            //         print("aaaaaaa");
            //
            //       // Navigator.of(context).pop();
            //     },
            //     child: Container(
            //       alignment: Alignment.center,
            //       height: 40,
            //       width: 100,
            //       padding: const EdgeInsets.symmetric(horizontal: 15),
            //       decoration: BoxDecoration(
            //         color: Colors.white,
            //         borderRadius: BorderRadius.circular(30),
            //       ),
            //       child: const Text("Cancel".tr,style: TextStyle(
            //         color: Colors.black,
            //         fontSize: 14,
            //         letterSpacing: 0.5,
            //       ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        );
      },
    ),
  );
}

Future commonbottomsheetcancelflow({required context}) {
  CancelRasonRequestApiController cancelRasonRequestApiController = Get.put(
    CancelRasonRequestApiController(),
  );
  VihicalCancelRideApiController vihicalCancelRideApiController = Get.put(
    VihicalCancelRideApiController(),
  );
  cancelRasonRequestApiController.cancelreasonApi(context);
  String cancel_id = "";
  // late IO.Socket socket;
  //
  // socket = IO.io(Config.imageurl,<String,dynamic>{
  //   'autoConnect': false,
  //   'transports': ['websocket'],
  // });
  socket.connect();

  return Get.bottomSheet(
    isScrollControlled: true,
    StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              // height: 800,
              // width: Get.width,
              decoration: BoxDecoration(
                color: notifier.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Image(
                        image: NetworkImage("${Config.imageurl}$vihicalimage"),
                        height: 40,
                      ),
                      title: Text(
                        "Traveling by",
                        style: TextStyle(color: notifier.textColor),
                      ),
                      subtitle: Text(
                        "$vihicalname ride",
                        style: TextStyle(
                          color: notifier.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    loadertimer == true
                        ? const SizedBox()
                        : const CounterBottomSheet(),
                    const SizedBox(height: 20),
                    Text(
                      "Location Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: notifier.textColor,
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16,
                                    bottom: 20,
                                    left: 0,
                                  ),
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
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 10,
                                        width: 3,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 10,
                                        width: 3,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      textfieldlist.isNotEmpty
                                          ? const SizedBox()
                                          : Container(
                                              height: 10,
                                              width: 3,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(
                                                  0.4,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 15,
                                        width: 15,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.red,
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      textfieldlist.isEmpty
                                          ? const SizedBox()
                                          : Container(
                                              height: 10,
                                              width: 3,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(
                                                  0.4,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 12,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                            "${picktitle == "" ? addresspickup : picktitle}",
                                            style: TextStyle(
                                              color: notifier.textColor,
                                            ),
                                          ),
                                          subtitle: Text(
                                            picksubtitle,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Transform.translate(
                                        offset: const Offset(0, -30),
                                        child: ListTile(
                                          // isThreeLine: true,
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            droptitle,
                                            style: TextStyle(
                                              color: notifier.textColor,
                                            ),
                                          ),
                                          subtitle: Text(
                                            dropsubtitle,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
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
                        const SizedBox(height: 20),
                        textfieldlist.isEmpty
                            ? const SizedBox()
                            : Transform.translate(
                                offset: const Offset(0, -40),
                                child: ListView.builder(
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
                                                offset: const Offset(-5, -25),
                                                child: Column(
                                                  children: [
                                                    // const SizedBox(height: 4,),
                                                    Container(
                                                      height: 10,
                                                      width: 3,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .withOpacity(0.4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      height: 10,
                                                      width: 3,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .withOpacity(0.4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      height: 15,
                                                      width: 15,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.red,
                                                          width: 4,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      height: 10,
                                                      width: 3,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .withOpacity(0.4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10,
                                                        ),
                                                      ),
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
                                                    "${droptitlelist[index]["title"]}",
                                                    style: TextStyle(
                                                      color: notifier.textColor,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    "${droptitlelist[index]["subt"]}",
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
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
                        driveridloader == true
                            ? Transform.translate(
                                offset: const Offset(0, -40),
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: droptitlelist.length,
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
                                                offset: const Offset(-5, -25),
                                                child: Column(
                                                  children: [
                                                    // const SizedBox(height: 4,),
                                                    Container(
                                                      height: 10,
                                                      width: 3,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .withOpacity(0.4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      height: 10,
                                                      width: 3,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .withOpacity(0.4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      height: 15,
                                                      width: 15,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.red,
                                                          width: 4,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      height: 10,
                                                      width: 3,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .withOpacity(0.4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10,
                                                        ),
                                                      ),
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
                                                    "${droptitlelist[index]["title"]}",
                                                    style: TextStyle(
                                                      color: notifier.textColor,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    "${droptitlelist[index]["subt"]}",
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
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
                              )
                            : SizedBox(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Total Fare",
                          style: TextStyle(
                            color: notifier.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "$globalcurrency $vihicalrice",
                          style: TextStyle(
                            color: notifier.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Paying via cash",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    // const Spacer(),
                    // const SizedBox(height: 40,),
                    const SizedBox(height: 10),
                    statusridestart == "5"
                        ? const SizedBox()
                        : CommonOutLineButton(
                            bordercolore: theamcolore,
                            onPressed1: () {
                              Get.back();
                              Get.bottomSheet(
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          height: 500,
                                          width: Get.width,
                                          decoration: BoxDecoration(
                                            color: notifier.containercolore,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 20),
                                                Text(
                                                  "Why do you want to cancel?",
                                                  style: TextStyle(
                                                    color: notifier.textColor,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  "Please provide the reason for cancellation",
                                                  style: TextStyle(
                                                    color: notifier.textColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Expanded(
                                                  child: ListView.separated(
                                                    // physics: const NeverScrollableScrollPhysics(),
                                                    separatorBuilder:
                                                        (context, index) {
                                                      return const SizedBox(
                                                        width: 0,
                                                      );
                                                    },
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    itemCount:
                                                        cancelRasonRequestApiController
                                                            .cancelReasonModel!
                                                            .rideCancelList!
                                                            .length,
                                                    itemBuilder: (
                                                      BuildContext context,
                                                      int index,
                                                    ) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 10,
                                                          right: 10,
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  cancel_id = cancelRasonRequestApiController
                                                                      .cancelReasonModel!
                                                                      .rideCancelList![
                                                                          index]
                                                                      .id
                                                                      .toString();
                                                                  Get.back();
                                                                  Get.bottomSheet(
                                                                    StatefulBuilder(
                                                                      builder: (
                                                                        context,
                                                                        setState,
                                                                      ) {
                                                                        return Stack(
                                                                          clipBehavior:
                                                                              Clip.none,
                                                                          children: [
                                                                            Container(
                                                                              height: 600,
                                                                              width: Get.width,
                                                                              decoration: BoxDecoration(
                                                                                color: notifier.containercolore,
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(
                                                                                    15,
                                                                                  ),
                                                                                  topRight: Radius.circular(
                                                                                    15,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(
                                                                                  left: 15,
                                                                                  right: 15,
                                                                                ),
                                                                                child: Container(
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      const SizedBox(
                                                                                        height: 10,
                                                                                      ),
                                                                                      Center(
                                                                                        child: Container(
                                                                                          height: 5,
                                                                                          width: 50,
                                                                                          decoration: BoxDecoration(
                                                                                            color: Colors.grey.withOpacity(
                                                                                              0.4,
                                                                                            ),
                                                                                            borderRadius: BorderRadius.circular(
                                                                                              10,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      // SizedBox(height: 20,),
                                                                                      // const Image(image: AssetImage("assets/rapido.png")),
                                                                                      lottie.Lottie.asset(
                                                                                        "assets/lottie/canceljson.json",
                                                                                      ),
                                                                                      Text(
                                                                                        "Are you sure you want to cancel this ride?",
                                                                                        style: TextStyle(
                                                                                          color: notifier.textColor,
                                                                                          fontSize: 22,
                                                                                        ),
                                                                                        maxLines: 2,
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 20,
                                                                                      ),
                                                                                      Text(
                                                                                        "We have found captains near you, please wait for a while, your ride should be confirmed any minutes.",
                                                                                        style: TextStyle(
                                                                                          color: notifier.textColor,
                                                                                          fontSize: 16,
                                                                                        ),
                                                                                        maxLines: 2,
                                                                                      ),
                                                                                      const Spacer(),
                                                                                      CommonOutLineButton(
                                                                                        bordercolore: theamcolore,
                                                                                        onPressed1: () {},
                                                                                        context: context,
                                                                                        txt1: "Keep searching",
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 5,
                                                                                      ),
                                                                                      CommonButton(
                                                                                        containcolore: theamcolore,
                                                                                        onPressed1: () {
                                                                                          vihicalCancelRideApiController
                                                                                              .vihicalcancelapi(
                                                                                            uid: useridgloable.toString(),
                                                                                            lat: lathomecurrent.toString(),
                                                                                            lon: longhomecurrent.toString(),
                                                                                            cancel_id: cancel_id.toString(),
                                                                                            request_id: request_id.toString(),
                                                                                          )
                                                                                              .then(
                                                                                            (
                                                                                              value,
                                                                                            ) {
                                                                                              socket.emit(
                                                                                                'Vehicle_Ride_Cancel',
                                                                                                {
                                                                                                  'uid': "$useridgloable",
                                                                                                  'driverid': value["driverid"],
                                                                                                },
                                                                                              );
                                                                                              Get.close(
                                                                                                2,
                                                                                              );
                                                                                              // Get.offAll(MapScreen());
                                                                                              // Get.to(PickupDropPoint(pagestate: false,bidding: homeApiController.homeapimodel!.categoryList![select1].bidding.toString(),));
                                                                                              // Get.to(HomeScreen(latpic: latitudepick,longpic: longitudepick,latdrop: latitudedrop,longdrop: longitudedrop,destinationlat: destinationlat));
                                                                                              // vihicaleridecancelemit();
                                                                                            },
                                                                                          );
                                                                                        },
                                                                                        context: context,
                                                                                        txt1: "Cancel my ride",
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 5,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Positioned(
                                                                              top: -50,
                                                                              right: 5,
                                                                              child: InkWell(
                                                                                onTap: () {
                                                                                  Get.back();
                                                                                },
                                                                                child: Container(
                                                                                  height: 40,
                                                                                  width: 40,
                                                                                  decoration: BoxDecoration(
                                                                                    color: notifier.containercolore,
                                                                                    shape: BoxShape.circle,
                                                                                  ),
                                                                                  child: Center(
                                                                                    child: Image(
                                                                                      image: AssetImage(
                                                                                        "assets/close.png",
                                                                                      ),
                                                                                      height: 20,
                                                                                      color: notifier.textColor,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    ),
                                                                  );
                                                                });
                                                              },
                                                              child: ListTile(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                // title: Text("Selected Wrong Pickup Location"),
                                                                title: Text(
                                                                  "${cancelRasonRequestApiController.cancelReasonModel!.rideCancelList![index].title}",
                                                                  style:
                                                                      TextStyle(
                                                                    color: notifier
                                                                        .textColor,
                                                                  ),
                                                                ),
                                                                trailing: Image(
                                                                  image:
                                                                      AssetImage(
                                                                    "assets/angle-right-small.png",
                                                                  ),
                                                                  height: 25,
                                                                  color: notifier
                                                                      .textColor,
                                                                ),
                                                              ),
                                                            ),
                                                            const Divider(
                                                              color:
                                                                  Colors.grey,
                                                              height: 5,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: -50,
                                          left: 5,
                                          child: InkWell(
                                            onTap: () {
                                              Get.back();
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                color: notifier.containercolore,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Image(
                                                  image: AssetImage(
                                                    "assets/arrow-left.png",
                                                  ),
                                                  height: 20,
                                                  color: notifier.textColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                            context: context,
                            txt1: "Cancel Ride",
                          ),
                    const SizedBox(height: 10),
                    CommonButton(
                      containcolore: theamcolore,
                      onPressed1: () {
                        Get.back();
                      },
                      context: context,
                      txt1: "Back".tr,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -50,
              left: 5,
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: notifier.background,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image(
                      image: AssetImage("assets/arrow-left.png"),
                      height: 20,
                      color: notifier.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

String drivername = "";
String drivervihicalnumber = "";
String driverlanguage = "";
String driverrating = "";
String driverimage = "";
String drivercountrycode = "";
String driverphonenumber = "";

String statusridestart = "";
String totaldropmint = "";
String totaldrophour = "";
String totaldropsecound = "";
double livelat = 0.00;
double livelong = 0.00;
String imagenetwork = "";
double tRate = 1.0;

num total = 0.00;
num finaltotal = 0.00;
num coupontotal = 0.00;
num additionaltotal = 0.00;
num whthercharge = 0.00;
num platformfee = 0.00;
num additionaltime = 0.00;

// List<int> drive_id_list = [];

List<PointLatLng> droppointstartscreen = [];
List listdrop = [];

class GlobalDriverAcceptClass extends GetxController implements GetxService {
  driverdetailfunction({
    required String d_id,
    required String request_id,
    required context,
    required double lat,
    required double long,
  }) {
    print("object@@@@@@@1");
    // print("firt time +++:-- $driver_id");
    // print("secound time +++:-- ${driver_id.toString()}");
    VihicalCalculateController vihicalCalculateController = Get.put(
      VihicalCalculateController(),
    );
    AddVihicalCalculateController addVihicalCalculateController = Get.put(
      AddVihicalCalculateController(),
    );
    VihicalDriverDetailApiController vihicalDriverDetailApiController = Get.put(
      VihicalDriverDetailApiController(),
    );
    otpstatus = false;

    // late IO.Socket socket;
    //
    // socket = IO.io(Config.imageurl,<String,dynamic>{
    //   'autoConnect': false,
    //   'transports': ['websocket'],
    // });

    socket.connect();

    // socket.on('Vehicle_Ride_Start_End$useridgloable', (Vehicle_Ride_Start_End) {
    //
    //   print("++++++ /Vehicle_Ride_Start_End/ ++++ :---  $Vehicle_Ride_Start_End");
    //   print("Vehicle_Ride_Start_End is of type: ${Vehicle_Ride_Start_End.runtimeType}");
    //   print("Vehicle_Ride_Start_End keys: ${Vehicle_Ride_Start_End.keys}");
    //   print("++++Vehicle_Ride_Start_End userid+++++: $useridgloable");
    //   print("++++Vehicle_Ride_Start_End gggg +++++: ${Vehicle_Ride_Start_End["uid"].toString()}");
    //   print("++++driver_id gggg +++++: $driver_id");
    //
    //   statusridestart = "";
    //   totaldropmint = "";
    //
    //   if(driver_id == Vehicle_Ride_Start_End["uid"].toString()){
    //     print("SuccessFully1");
    //     statusridestart = Vehicle_Ride_Start_End["status"];
    //     totaldropmint = Vehicle_Ride_Start_End["tot_min"].toString();
    //     totaldrophour = Vehicle_Ride_Start_End["tot_hour"].toString();
    //     print("+++++++totaldropmint++++:-- $totaldropmint");
    //     print("+++++++totaldrophour++++:-- $totaldrophour");
    //     print("++++++++ststus++++:-- $statusridestart");
    //
    //
    //
    //     if(statusridestart == "5"){
    //       print("555555555555555555555555");
    //       droppointstartscreen = [];
    //       listdrop = [];
    //       listdrop = Vehicle_Ride_Start_End["drop_list"];
    //       print("xxxxxxxxx droppointstartscreen xxxxxxxxx$listdrop");
    //       print("xxxxxxxxx listdrop length:- ${listdrop.length}");
    //
    //       for(int i=0; i<listdrop.length; i++){
    //         print("objectMMMMMMMMM:-- ($i)");
    //         droppointstartscreen.add(PointLatLng(double.parse(Vehicle_Ride_Start_End["drop_list"][i]["latitude"]), double.parse(Vehicle_Ride_Start_End["drop_list"][i]["longitude"])));
    //         print("vvvvvvvvv droppointstartscreen vvvvvvvvv:-- $droppointstartscreen");
    //       }
    //       Get.to(const DriverStartrideScreen());
    //       // Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverStartrideScreen(),));
    //
    //     }
    //     else if(statusridestart == "6"){
    //       print("6666666666666666");
    //       droppointstartscreen = [];
    //       listdrop = [];
    //       listdrop = Vehicle_Ride_Start_End["drop_list"];
    //       print("xxxxxxxxx droppointstartscreen xxxxxxxxx$listdrop");
    //       print("xxxxxxxxx listdrop length${listdrop.length}");
    //       for(int i=0; i<listdrop.length; i++){
    //         print("objectHHHHH:-- (${i})");
    //         droppointstartscreen.add(PointLatLng(double.parse(Vehicle_Ride_Start_End["drop_list"][i]["latitude"]), double.parse(Vehicle_Ride_Start_End["drop_list"][i]["longitude"])));
    //         print("vvvvvvvvv droppointstartscreen vvvvvvvvv:-- $droppointstartscreen");
    //       }
    //       // Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverStartrideScreen(),));
    //     }
    //     else if(statusridestart == "7"){
    //       print("7777777777777777");
    //       Get.to(const RideCompletePaymentScreen());
    //       // Navigator.push(context, MaterialPageRoute(builder: (context) => const RideCompletePaymentScreen(),));
    //     }
    //     else{
    //
    //     }
    //
    //   }else{
    //     statusridestart = "";
    //     print("UnSuccessFully1");
    //   }
    //
    // });

    print("object@@@@@@@2");

    socket.on('Vehicle_Ride_Payment$useridgloable', (Vehicle_Ride_Payment) {
      print("++++++ /Vehicle_Ride_Payment1/ ++++ :---  $Vehicle_Ride_Payment");
      print(
        "Vehicle_Ride_Payment1 is of type: ${Vehicle_Ride_Payment.runtimeType}",
      );
      print("Vehicle_Ride_Payment1 keys: ${Vehicle_Ride_Payment.keys}");
      print(
        "Vehicle_Ride_Payment1 total1........: ${Vehicle_Ride_Payment["ResponseCode"]}",
      );
      print(
        "Vehicle_Ride_Payment1 total1: ${Vehicle_Ride_Payment["price_list"]}",
      );
      print(
        "Vehicle_Ride_Payment1 total3: ${Vehicle_Ride_Payment["price_list"]["tot_price"]}",
      );

      total = Vehicle_Ride_Payment["price_list"]["tot_price"];
      finaltotal = Vehicle_Ride_Payment["price_list"]["final_price"];
      coupontotal = Vehicle_Ride_Payment["price_list"]["coupon_amount"];
      additionaltotal = Vehicle_Ride_Payment["price_list"]["addi_time_price"];
      whthercharge = Vehicle_Ride_Payment["price_list"]["weather_price"];
      platformfee = Vehicle_Ride_Payment["price_list"]["platform_fee"];
      additionaltime = Vehicle_Ride_Payment["price_list"]["addi_time"];

      finaltotalsecounde = finaltotal;

      print("+++++(total)++++++:---- $total");
      print("+++++(finaltotal)++++++:---- $finaltotal");
      print("++++++(coupontotal)+++++:---- $coupontotal");
      print("+++++(additionaltotal)++++++:---- $additionaltotal");
      print("+++++(platformfee)++++++:---- $platformfee");
      print("+++++(whthercharge)++++++:---- $whthercharge");
      print(
        "+++++(finaltotalsecounde finaltotalsecounde)++++++:---- $finaltotalsecounde",
      );
    });

    socket.on('Vehicle_Ride_OTP', (Vehicle_Ride_OTP) {
      print("++++++ /Vehicle_Ride_OTP/ ++++ :---  $Vehicle_Ride_OTP");
      print("Vehicle_Ride_OTP is of type: ${Vehicle_Ride_OTP.runtimeType}");
      print("Vehicle_Ride_OTP keys: ${Vehicle_Ride_OTP.keys}");
      print("++++userid+++++: $useridgloable");

      print("++++otpstatus+++++:- $otpstatus");

      if (useridgloable.toString() == Vehicle_Ride_OTP["c_id"].toString()) {
        otpstatus = Vehicle_Ride_OTP["status"];
      } else {
        otpstatus = false;
        print("++++nmnmnmnmnmnmnnnmnmn+++++:- ${otpstatus}");
      }
    });

    // socket.on('Vehicle_Time_update$useridgloable', (Vehicle_Time_update) {
    //
    //   print("++++++ /Vehicle_Time_update/ ++++ :---  $Vehicle_Time_update");
    //   print("Vehicle_Time_update is of type: ${Vehicle_Time_update.runtimeType}");
    //   print("Vehicle_Time_update keys: ${Vehicle_Time_update.keys}");
    //
    //   tot_hour = "0";
    //   tot_time = Vehicle_Time_update["time"].toString();
    //
    //   print("+++tot_hour+++:-- $tot_hour");
    //   print("+++tot_time+++:-- $tot_time");
    //
    // });

    drivername = "";
    drivervihicalnumber = "";
    driverlanguage = "";
    driverrating = "";
    driverimage = "";

    print("object@@@@@@@3");
    print("object@@@@@@@333 (${driveridloader})");

    // driveridloader == false ? drive_id_list = vihicalCalculateController.vihicalCalculateModel!.driverId! : [];

    print("object@@@@@@@4");

    // vihicalDriverDetailApiController.vihicaldriverdetailapi(driver_list: vihicalCalculateController.vihicalCalculateModel!.driverId!,uid: useridgloable.toString(), d_id: d_id, request_id: request_id).then((value) {
    vihicalDriverDetailApiController
        .vihicaldriverdetailapi(
      uid: useridgloable.toString(),
      d_id: d_id,
      request_id: request_id,
    )
        .then((value) {
      print("object@@@@@@@5");
      if (value["Result"] == true) {
        driveridloader == false
            ? tot_hour = value["accepted_d_detail"]["tot_hour"].toString()
            : "";
        driveridloader == false
            ? tot_time = value["accepted_d_detail"]["tot_minute"].toString()
            : "";
        timeincressstatus = value["accepted_d_detail"]["status"].toString();

        livelat = double.parse(value["accepted_d_detail"]["latitude"]);
        livelong = double.parse(value["accepted_d_detail"]["longitude"]);
        imagenetwork =
            "${Config.imageurl}${value["accepted_d_detail"]["map_img"]}";

        print("-----livelat---:-- $livelat");
        print("-----livelong---:-- $livelong");
        print("-----imagenetwork---:-- $imagenetwork");
        print("-----timeincressstatus---:-- $timeincressstatus");

        // socket.emit('AcceRemoveOther',{
        //   'requestid': driveridloader == false ? addVihicalCalculateController.addVihicalCalculateModel!.id : appstatusid,
        //   'driverid' : value["driverlist"],
        // });

        Get.back();

        drivername =
            "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.firstName} ${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.lastName}";
        drivervihicalnumber =
            "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.vehicleNumber}";
        driverlanguage =
            "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.language}";
        driverrating =
            "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.rating}";
        driverimage =
            "${Config.imageurl}${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.profileImage}";
        drivercountrycode =
            "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.primaryCcode}";
        driverphonenumber =
            "${vihicalDriverDetailApiController.vihicalDriverDetailModel!.acceptedDDetail!.primaryPhoneNo}";

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverDetailScreen(lat: lat, long: long),
          ),
        );
      } else {
        print("papapapapapapapapapapapappaappaapapappapapapapa");
      }
    });
  }
}

totalRateUpdate(double rating) {
  tRate = rating;
  // update();
}

Future rateBottomSheet() {
  DriverReviewDetailApiController driverReviewDetailApiController = Get.put(
    DriverReviewDetailApiController(),
  );
  // VihicalRideCompleteOrderApiController vihicalRideCompleteOrderApiController = Get.put(VihicalRideCompleteOrderApiController());
  TextEditingController reviewtextcontroller = TextEditingController();
  ReviewDataApiController reviewDataApiController = Get.put(
    ReviewDataApiController(),
  );

  // String reviewid = '';
  List reviewid = [];
  String reviewtitle = '';

  reviewDataApiController.reviewdataApi().then((value) {
    print("****11111@@@@@***:--- (${value})");
  });

  return Get.bottomSheet(
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    GetBuilder<ReviewDataApiController>(
      builder: (reviewDataApiController) {
        return reviewDataApiController.isLoading
            ? Center(child: CustomLoadingWidget())
            : StatefulBuilder(
                builder: (context, setState) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        width: Get.width,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: notifier.containercolore,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/svgpicture/check-circle.svg",
                                    color: notifier.textColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Paid $globalcurrency$finaltotal",
                                    style: TextStyle(
                                      fontSize: 15,
                                      // fontWeight: FontWeight.w500,
                                      color: notifier.textColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: notifier.languagecontainercolore,
                                      borderRadius: BorderRadius.circular(40),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.help_outline,
                                          size: 21,
                                          color: notifier.textColor,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          "Help",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: notifier.textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    // color: theamcolore,
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage("$driverimage"),
                                      fit: BoxFit.cover,
                                    ),
                                    // image: DecorationImage(image: NetworkImage("https://cdn.prod.website-files.com/595d6b420002832258c527cb/602edff72af06859a9cf846a_driver-behavior-professional-truck-driver-driving-truck-vehicle-1000.jpg"),fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                "How was your ride with $drivername",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: notifier.textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              RatingBar(
                                initialRating: 1,
                                direction: Axis.horizontal,
                                itemCount: 5,
                                allowHalfRating: true,
                                ratingWidget: RatingWidget(
                                  full: Image.asset(
                                    'assets/starBold.png',
                                    color: theamcolore,
                                  ),
                                  half: Image.asset(
                                    'assets/star-half.png',
                                    color: theamcolore,
                                  ),
                                  empty: Image.asset(
                                    'assets/star.png',
                                    color: theamcolore,
                                  ),
                                ),
                                itemPadding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                onRatingUpdate: (rating) {
                                  setState(() {
                                    totalRateUpdate(rating);
                                    print("---:-- $rating");
                                    print("+++:-- $tRate");
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Great, what did you like the most? 😍",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 13,
                                runSpacing: 13,
                                alignment: WrapAlignment.start,
                                clipBehavior: Clip.none,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                runAlignment: WrapAlignment.start,
                                children: [
                                  for (int a = 0;
                                      a <
                                          reviewDataApiController
                                              .reviewDataApiModel!
                                              .reviewList!
                                              .length;
                                      a++)
                                    Builder(
                                      builder: (context) {
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              // reviewid = reviewDataApiController.reviewDataApiModel!.reviewList![a].id.toString();

                                              reviewtitle =
                                                  reviewDataApiController
                                                      .reviewDataApiModel!
                                                      .reviewList![a]
                                                      .title
                                                      .toString();
                                              setState(() {
                                                if (reviewid.contains(
                                                  reviewDataApiController
                                                      .reviewDataApiModel!
                                                      .reviewList![a]
                                                      .id,
                                                )) {
                                                  reviewid.remove(
                                                    reviewDataApiController
                                                        .reviewDataApiModel!
                                                        .reviewList![a]
                                                        .id,
                                                  );
                                                  print(
                                                    "-------remove--------- ${reviewid}",
                                                  );
                                                } else {
                                                  reviewid.add(
                                                    reviewDataApiController
                                                        .reviewDataApiModel!
                                                        .reviewList![a]
                                                        .id,
                                                  );
                                                  print(
                                                    "+++++++Add+++++++ ${reviewid}",
                                                  );
                                                }
                                              });

                                              print(
                                                " + + + +  + + + $reviewid",
                                              );
                                            });
                                            // Get.back();
                                          },
                                          child: Container(
                                            height: 40,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: reviewid.contains(
                                                reviewDataApiController
                                                    .reviewDataApiModel!
                                                    .reviewList![a]
                                                    .id,
                                              )
                                                  ? theamcolore
                                                  : notifier.containercolore,
                                              // color: reviewtitle == reviewDataApiController.reviewDataApiModel!.reviewList![a].title ?  theamcolore : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(
                                                color: Colors.grey.withOpacity(
                                                  0.4,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  reviewDataApiController
                                                      .reviewDataApiModel!
                                                      .reviewList![a]
                                                      .title
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        fontSize: 15,
                                                        color:
                                                            reviewid.contains(
                                                          reviewDataApiController
                                                              .reviewDataApiModel!
                                                              .reviewList![a]
                                                              .id,
                                                        )
                                                                ? Colors.white
                                                                : notifier
                                                                    .textColor,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              CommonTextfiled200(
                                txt: "Tell us more...",
                                context: context,
                                controller: reviewtextcontroller,
                              ),
                              const SizedBox(height: 20),
                              CommonButton(
                                txt1: "Done",
                                onPressed1: () {
                                  print("userid:-- ($useridgloable)");
                                  print("driver_id:-- ($driver_id)");
                                  print(
                                    "reviewtextcontroller.text:-- (${reviewtextcontroller.text})",
                                  );
                                  print("tRate:-- ($tRate)");
                                  print(
                                    "ridecompleterequestid:-- ($ridecompleterequestid)",
                                  );
                                  driverReviewDetailApiController.reviewapi(
                                    def_review: reviewid,
                                    uid: useridgloable.toString(),
                                    d_id: "$driver_id",
                                    review: reviewtextcontroller.text,
                                    tot_star: "$tRate",
                                    request_id: "$ridecompleterequestid",
                                    context: context,
                                  );
                                },
                                containcolore: theamcolore,
                                context: context,
                              ),
                              const SizedBox(height: 10),
                              CommonOutLineButton(
                                bordercolore: theamcolore,
                                onPressed1: () {
                                  Get.offAll(MapScreen(selectvihical: false));
                                },
                                txt1: "Skip",
                                context: context,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
      },
    ),
  );
}
