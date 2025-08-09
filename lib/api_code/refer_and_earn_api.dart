import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/refer_and_earn_api_model.dart';
import '../common_code/config.dart';
import 'calculate_api_controller.dart';

class referandearnApiController extends GetxController implements GetxService {
  ReferAndEarnApiModel? referAndEarnApiModel;
  bool isLoading = true;

  Future referapi({context, required String uid}) async {
    try {
      Map body = {"uid": uid};

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.referearnapi;

      if (kDebugMode) {
        print('Refer and Earn URL: $url');
        print('Refer and Earn Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(Duration(seconds: 30));

      if (kDebugMode) {
        print('Refer and Earn Response Status: ${response.statusCode}');
        print('Refer and Earn Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          referAndEarnApiModel = referAndEarnApiModelFromJson(response.body);

          if (referAndEarnApiModel!.result == true) {
            isLoading = false;
            update();
            return data;
          } else {
            return data;
          }
        } else {
          return data;
        }
      } else {
        showToastForDuration("خطأ في HTTP: ${response.statusCode}",
            3); // "HTTP Error: ${response.statusCode}"
      }
    } catch (e) {
      if (kDebugMode) {
        print("Refer and Earn API Error: $e");
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

      showToastForDuration(errorMessage, 3);
    }
  }
}
