import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/twilyo_api_model.dart';
import '../common_code/common_button.dart';

class TwilioapiController extends GetxController implements GetxService {
  TwilioApiModel? twilioApiModel;

  Future twilioApi({required String mobilenumber, context}) async {
    try {
      Map body = {"mobile": mobilenumber};

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.twilioapi;

      if (kDebugMode) {
        print('Twilio API URL: $url');
        print('Twilio API Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Twilio API Response Status: ${response.statusCode}');
        print('Twilio API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == "true") {
          twilioApiModel = twilioApiModelFromJson(response.body);
          update();
          snackbar(context: context, text: "${data["message"]}");
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
        print("Twilio API Error: $e");
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
