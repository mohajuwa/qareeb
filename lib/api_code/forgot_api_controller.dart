import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/forgot_api_model.dart';
import '../common_code/common_button.dart';

class ForgotController extends GetxController implements GetxService {
  ForgotModel? forgotModel;

  Future forgotApi(
      {required String phone,
      required String password,
      required String ccode,
      context}) async {
    try {
      Map body = {"phone": phone, "password": password, "ccode": ccode};

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.forgot;

      if (kDebugMode) {
        print('Forgot Password URL: $url');
        print('Forgot Password Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(Duration(seconds: 30));

      if (kDebugMode) {
        print('Forgot Password Response Status: ${response.statusCode}');
        print('Forgot Password Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          forgotModel = forgotModelFromJson(response.body);
          if (forgotModel!.result == true) {
            update();
            Get.back();
            Get.back();
            Get.back();
            snackbar(context: context, text: "${data["message"]}");
            return data;
          } else {
            snackbar(context: context, text: "${forgotModel!.message}");
            return data;
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
        print("Forgot Password API Error: $e");
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

      snackbar(context: context, text: errorMessage);
    }
  }
}
