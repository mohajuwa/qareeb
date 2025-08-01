import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/driver_detail_api_model.dart';
import 'calculate_api_controller.dart';

class DriverDetailApiController extends GetxController implements GetxService {
  DriverDetailApiModel? driverDetailApiModel;
  bool isLoading = true;

  Future driverdetailApi({required String d_id}) async {
    try {
      Map body = {"d_id": d_id};

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.driverdetailprofile;

      if (kDebugMode) {
        print('Driver Detail URL: $url');
        print('Driver Detail Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Driver Detail Response Status: ${response.statusCode}');
        print('Driver Detail Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          driverDetailApiModel = driverDetailApiModelFromJson(response.body);

          if (driverDetailApiModel!.result == true) {
            update();
            isLoading = false;
            return data;
          } else {
            showToastForDuration("${data["message"]}", 2);
            return data;
          }
        } else {
          showToastForDuration("${data["message"]}", 2);
          return data;
        }
      } else {
        showToastForDuration("خطأ في HTTP: ${response.statusCode}",
            2); // "HTTP Error: ${response.statusCode}"
      }
    } catch (e) {
      if (kDebugMode) {
        print("Driver Detail API Error: $e");
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

      showToastForDuration(errorMessage, 2);
    }
  }
}
