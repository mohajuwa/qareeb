import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/my_ride_detail_api_model.dart';
import 'calculate_api_controller.dart';

class MyRideDetailApiController extends GetxController implements GetxService {
  MyRideDetailApiModel? myRideDetailApiModel;
  bool isLoading = true;

  Future mydetailApi(
      {context,
      required String uid,
      required String request_id,
      required String status}) async {
    try {
      Map body = {
        "uid": uid,
        "request_id": request_id,
        "status": status,
      };

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.myridedetail;

      if (kDebugMode) {
        print('MyRideDetail URL: $url');
        print('MyRideDetail Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('MyRideDetail Response Status: ${response.statusCode}');
        print('MyRideDetail Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          myRideDetailApiModel = myRideDetailApiModelFromJson(response.body);

          if (myRideDetailApiModel!.result == true) {
            update();
            isLoading = false;
            return data;
          } else {
            showToastForDuration("${data["message"]}", 3);
            return data;
          }
        } else {
          showToastForDuration("${data["message"]}", 3);
          return data;
        }
      } else {
        showToastForDuration("خطأ في HTTP: ${response.statusCode}",
            3); // "HTTP Error: ${response.statusCode}"
      }
    } catch (e) {
      if (kDebugMode) {
        print("My Ride Detail API Error: $e");
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
