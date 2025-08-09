import 'dart:convert';
import 'package:flutter/foundation.dart';
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

      if (kDebugMode) {
        print('Login URL: $url');
        print('Login Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(Duration(seconds: 30));

      if (kDebugMode) {
        print('Login Response Status: ${response.statusCode}');
        print('Login Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          loginModel = loginModelFromJson(response.body);

          if (loginModel!.result == true) {
            permission = await Geolocator.checkPermission();

            if (kDebugMode) {
              print("Login Data: ${jsonEncode(data["customer_data"])}");
            }

            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.setString(
                "userLogin", jsonEncode(data["customer_data"]));
            loginSharedPreferencesSet(false);

            onesignalkey = data["general"]["one_app_id"];

            if (kDebugMode) {
              print("OneSignal Key: $onesignalkey");
            }

            if (permission == LocationPermission.denied) {
              Get.offAll(const PermissionScreen());
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
        snackbar(
            context: context,
            text:
                "خطأ في HTTP: ${response.statusCode}"); // "HTTP Error: ${response.statusCode}"
      }
    } catch (e) {
      if (kDebugMode) {
        print("Login API Error: $e");
      }

      String errorMessage = "فشل الاتصال"; // "Connection failed"
      if (e.toString().contains('Failed host lookup')) {
        errorMessage =
            "لا يمكن الوصول إلى الخادم. تحقق من اتصال الإنترنت."; // "Server not reachable. Check your internet connection."
      } else if (e.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
        errorMessage =
            "خطأ في شهادة الأمان. جاري استخدام تجاوز الشهادة المؤقتة."; // "SSL Certificate error. Using self-signed certificate bypass."
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage =
            "انتهت مهلة الطلب. حاول مرة أخرى."; // "Request timeout. Please try again."
      } else {
        errorMessage =
            "فشل تسجيل الدخول. حاول مرة أخرى."; // "Login failed. Please try again."
      }

      snackbar(context: context, text: errorMessage);
    }
  }
}
