// lib/api_code/login_controller.dart

import 'dart:convert';

import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:qareeb/common_code/config.dart';

import 'package:qareeb/common_code/http_helper.dart';

import '../api_model/login_api_model.dart';

import '../app_screen/map_screen.dart';

import '../app_screen/permisiion_scren.dart';

import '../common_code/common_button.dart';

String onesignalkey = "44d5202c-02e8-4c86-98ec-fb2c018366c4";

void loginSharedPreferencesSet(bool value) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  preferences.setBool("UserLogin", value);
}

class LoginController extends GetxController implements GetxService {
  LoginModel? loginModel;

  LocationPermission? permission;

  Future loginApi(
      {required context,
      required String phone,
      required String password,
      required String ccode}) async {
    try {
      Map body = {"phone": phone, "password": password, "ccode": ccode};

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.login;

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(Duration(seconds: 30));

      print('Login API Body: $body');

      print('Login API Response: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          loginModel = loginModelFromJson(response.body);

          if (loginModel!.result == true) {
            permission = await Geolocator.checkPermission();

            print("Login Data: ${jsonEncode(data["customer_data"])}");

            SharedPreferences preferences =
                await SharedPreferences.getInstance();

            preferences.setString(
                "userLogin", jsonEncode(data["customer_data"]));

            loginSharedPreferencesSet(false);

            onesignalkey = data["general"]["one_app_id"];

            print("OneSignal Key: $onesignalkey");

            if (permission == LocationPermission.denied) {
              Get.offAll(const Permission_screen());
            } else {
              Get.offAll(const MapScreen(selectvihical: false));
            }

            snackbar(context: context, text: "${data["message"]}");

            return data;
          } else {
            snackbar(context: context, text: "${data["message"]}");
          }
        } else {
          snackbar(context: context, text: "${data["message"]}");
        }
      } else {
        snackbar(context: context, text: "HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Login API Error: $e");

      snackbar(context: context, text: "Login failed. Please try again.");
    }
  }
}
