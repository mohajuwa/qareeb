import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/all_request_api_model.dart';
import 'calculate_api_controller.dart';

class AllRequestDataApiController extends GetxController
    implements GetxService {
  AllRequestDataModel? allRequestDataModelupcoming;
  AllRequestDataModel? allRequestDataModelcompleted;
  AllRequestDataModel? allRequestDataModelcancelled;
  bool isLoading = true;

  Future allrequestApi(
      {context, required String uid, required String status}) async {
    try {
      Map body = {"uid": uid, "status": status};

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.allrequest;

      if (kDebugMode) {
        print('All Request URL: $url');
        print('All Request Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(Duration(seconds: 30));

      if (kDebugMode) {
        print('All Request Response Status: ${response.statusCode}');
        print('All Request Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          if (status == "upcoming") {
            if (kDebugMode) print("+++++ upcoming +++++");
            allRequestDataModelupcoming =
                allRequestDataModelFromJson(response.body);
          } else if (status == "completed") {
            if (kDebugMode) print("+++++ completed +++++");
            allRequestDataModelcompleted =
                allRequestDataModelFromJson(response.body);
          } else {
            if (kDebugMode) print("+++++ cancelled +++++");
            allRequestDataModelcancelled =
                allRequestDataModelFromJson(response.body);
          }

          update();

          if (allRequestDataModelupcoming?.result == true ||
              allRequestDataModelcompleted?.result == true ||
              allRequestDataModelcancelled?.result == true) {
            isLoading = false;
            update();
          } else {
            String message = allRequestDataModelupcoming?.message ??
                allRequestDataModelcompleted?.message ??
                allRequestDataModelcancelled?.message ??
                "حدث خطأ ما"; // "Something went wrong"
            Fluttertoast.showToast(msg: message);
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
        print("All Request API Error: $e");
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
