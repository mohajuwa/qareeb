// lib/api_code/signup_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/common_code/config.dart';
import '../api_model/sign_up_api_model.dart';
import '../app_screen/map_screen.dart';
import '../app_screen/permisiion_scren.dart';
import '../common_code/common_button.dart';
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
    try {
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

      String url = Config.baseurl + Config.signup;

      if (kDebugMode) {
        print('Signup URL: $url');
        print('Signup Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Signup Response Status: ${response.statusCode}');
        print('Signup Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          signupModel = signupModelFromJson(response.body);
          permission = await Geolocator.checkPermission();

          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString("userLogin", jsonEncode(data["customer_data"]));
          loginSharedPreferencesSet(false);

          onesignalkey = data["general"]["one_app_id"];

          if (kDebugMode) {
            print("OneSignal Key: $onesignalkey");
          }

          if (permission == LocationPermission.denied) {
            Get.offAll(const Permission_screen());
          } else {
            Get.offAll(const MapScreen(selectvihical: false));
          }

          snackbar(context: context, text: "${data["message"]}");
        } else {
          snackbar(context: context, text: "${data["message"]}");
        }
      } else {
        snackbar(context: context, text: "HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Signup API Error: $e");
      }

      String errorMessage = "Connection failed";
      if (e.toString().contains('Failed host lookup')) {
        errorMessage = "Server not reachable. Check your internet connection.";
      } else if (e.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
        errorMessage =
            "SSL Certificate error. Using self-signed certificate bypass.";
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = "Request timeout. Please try again.";
      }

      snackbar(context: context, text: errorMessage);
    }
  }
}
