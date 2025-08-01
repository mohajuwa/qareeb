import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:qareeb/common_code/toastification.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/remove_request_api_model.dart';

class RemoveRequest extends GetxController implements GetxService {
  RemoveVihicalRequest? removeVihicalRequest;
  bool isLoading = true;

  Future removeApi({required String uid}) async {
    try {
      Map body = {"uid": uid};

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.removerequestapi;

      if (kDebugMode) {
        print('Remove Request URL: $url');
        print('Remove Request Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Remove Request Response Status: ${response.statusCode}');
        print('Remove Request Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          removeVihicalRequest = removeVihicalRequestFromJson(response.body);
          if (removeVihicalRequest!.result == true) {
            isLoading = false;
            ToastService.showToast("${removeVihicalRequest!.message}");
            update();
            return data;
          }
        }
      } else {
        ToastService.showToast(
            "خطأ في HTTP: ${response.statusCode}"); // "HTTP Error: ${response.statusCode}"
      }
    } catch (e) {
      if (kDebugMode) {
        print("Remove Request API Error: $e");
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
    }
  }
}
