// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/app_screen/map_screen.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import 'package:qareeb/common_code/common_button.dart';
import 'package:qareeb/common_code/push_notification.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Permission_screen extends StatefulWidget {
  const Permission_screen({super.key});

  @override
  State<Permission_screen> createState() => _Permission_screenState();
}

class _Permission_screenState extends State<Permission_screen> {
  @override
  void initState() {
    getdata();
    // TODO: implement initState
    super.initState();
    // notification();
  }

  var decodeUid;
  getdata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("userLogin");

    decodeUid = jsonDecode(uid!);
    print("DECODADE DATA FOR LOGIN ID :- ${decodeUid["id"]}");
  }

  LocationPermission? permission;
  Future getLocation() async {
    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Get.offAll(MapScreen());
    } else {
      Get.bottomSheet(Container(
        height: 450,
        decoration: BoxDecoration(
            color: notifier.containercolore,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              Center(
                child: Container(
                  height: 5,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SvgPicture.asset("assets/svgpicture/image1.svg"),
                title: Text(
                  "Allow Notifications and on-ride alerts".tr,
                  style: TextStyle(
                      color: notifier.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SvgPicture.asset("assets/svgpicture/image2.svg"),
                title: Text(
                  "Real-time Captain updates".tr,
                  style: TextStyle(
                      color: notifier.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Get notified about captain`s allocation, arrival and more"
                        .tr,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SvgPicture.asset("assets/svgpicture/image3.svg"),
                title: Text(
                  "Offer and news",
                  style: TextStyle(
                      color: notifier.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Be the first to know about our offers and new features".tr,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const Spacer(),
              CommonButton(
                  containcolore: theamcolore,
                  onPressed1: () {
                    // initPlatformState();
                    // requestNotificationPermission();
                    // requestNotificationPermissions();
                    initPlatformState();
                    var sendTags = {
                      'subscription_user_Type': 'customer',
                      'Login_ID': decodeUid["id"].toString()
                    };
                    OneSignal.User.addTags(sendTags);
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen(),));
                  },
                  context: context,
                  txt1: "Allow".tr),
              const SizedBox(
                height: 10,
              ),
              CommonOutLineButton(
                  bordercolore: Colors.grey,
                  onPressed1: () {
                    Get.back();
                  },
                  context: context,
                  txt1: "Maybe, later".tr),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ));
    }
  }

  // Future<void> requestNotificationPermissions() async {
  //   final PermissionStatus status = await Permission.notification.request();
  //   if (status.isGranted) {
  //     print("GRANTED DONE");
  //     Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen(),));
  //     // Notification permissions granted
  //   } else if (status.isDenied) {
  //     print("GRANTED isDenied");
  //     // Notification permissions denied
  //   } else if (status.isPermanentlyDenied) {
  //     print("GRANTED isPermanentlyDenied");
  //     // Notification permissions permanently denied, open app settings
  //     await openAppSettings();
  //   }
  // }

  Future notification() async {
    await Permission.notification.request();
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Lottie.asset("assets/lottie/location_permission.json", height: 200),
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Text(
                  "Location permission not enabled".tr,
                  style: TextStyle(color: notifier.textColor, fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Sharing Location permission helps us improve your ride booking and pickup experience"
                      .tr,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                CommonButton(
                    containcolore: theamcolore,
                    onPressed1: () {
                      getLocation();
                    },
                    context: context,
                    txt1: "Allow Permission".tr),
                const SizedBox(
                  height: 10,
                ),
                CommonOutLineButton(
                    bordercolore: Colors.grey,
                    onPressed1: () {},
                    context: context,
                    txt1: "Enter pickup manually".tr)
              ],
            ),
          )
        ],
      ),
    );
  }
}
