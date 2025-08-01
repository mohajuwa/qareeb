import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:qareeb/common_code/toastification.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/home_api_model.dart';

class HomeApiController extends GetxController implements GetxService {
  HomeModel? homeapimodel;
  bool isLoading = true;

  Future homeApi(
      {required String uid, required String lat, required String lon}) async {
    try {
      Map body = {"uid": uid, "lat": lat, "lon": lon};

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.home;

      if (kDebugMode) {
        print('Home API URL: $url');
        print('Home API Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Home API Response Status: ${response.statusCode}');
        print('Home API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          homeapimodel = homeModelFromJson(response.body);
          if (homeapimodel!.result == true) {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            if (data["general"]?["site_currency"] != null) {
              preferences.setString(
                  "currenci", jsonEncode(data["general"]["site_currency"]));
            }

            isLoading = false;
            update();
            return data;
          } else {
            ToastService.showToast("${homeapimodel!.message}");
            return data;
          }
        } else {
          ToastService.showToast("${data["message"]}");
          return null;
        }
      } else {
        if (kDebugMode) {
          print('Home API HTTP Error: ${response.statusCode}');
        }
        ToastService.showToast(
            "خطأ في HTTP: ${response.statusCode}"); // "HTTP Error: ${response.statusCode}"
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Home API Error: $e");
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
            "حدث خطأ ما. حاول مرة أخرى."; // "Something went wrong. Please try again."
      }

      ToastService.showToast(errorMessage);
      return null;
    }
  }
}
