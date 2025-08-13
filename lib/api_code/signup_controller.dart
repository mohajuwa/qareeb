import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/common_code/config.dart';
import '../api_model/sign_up_api_model.dart';
import 'package:http/http.dart' as http;
import '../app_screen/map_screen.dart';
import '../app_screen/permisiion_scren.dart';
import '../common_code/common_button.dart';
import '../common_code/push_notification.dart';
import 'login_controller.dart';

class SignupController extends GetxController implements GetxService {
  SignupModel? signupModel;
  LocationPermission? permission;

  Future signupApi({
    required context,
    required String name,
    required String email,
    required String ccode,
    required String mobilenumber,
    required String password,
    required String referral_code,
  }) async {
    Map body = {
      "name": name,
      "email": email,
      "ccode": ccode,
      "phone": mobilenumber,
      "password": password,
      "referral_code": referral_code,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(Uri.parse(Config.baseurl + Config.signup),
        body: jsonEncode(body), headers: userHeader);

    print('+ + + + + + + + + + + $body');
    print('- - - - - - - - - - - ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("++++first iff++++");
      if (data["Result"] == true) {
        signupModel = signupModelFromJson(response.body);
        print("++++secound iff++++");
        permission = await Geolocator.checkPermission();
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString("userLogin", jsonEncode(data["customer_data"]));
        loginSharedPreferencesSet(false);

        onesignalkey = data["general"]["one_app_id"];
        print("==========:----- (${onesignalkey})");
        print("=====Config.oneSignel=====:----- (${Config.oneSignel})");

        // initPlatformState(context: context);
        // var sendTags = {'subscription_user_Type': 'customer', 'Login_ID': data["customer_data"]["id"].toString()};
        // OneSignal.User.addTags(sendTags);

        // Get.offAll(PermissionScreen());

        if (permission == LocationPermission.denied) {
          Get.offAll(const PermissionScreen());
        } else {
          Get.offAll(const MapScreen(
            selectvihical: false,
          ));
        }

        snackbar(context: context, text: "${data["message"]}");
      } else {
        // Fluttertoast.showToast(
        //   msg: "${data["message"]}",
        // );
        snackbar(context: context, text: "${data["message"]}");
      }
    } else {
      // Fluttertoast.showToast(
      //   msg: "Somthing went wrong!.....",
      // );
      snackbar(context: context, text: "Somthing went wrong!.....");
    }
  }
}
