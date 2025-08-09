import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/resend_api_model.dart';

class ResendRequestApiController extends GetxController implements GetxService {
  ResendRequest? resendRequest;
  bool isLoading = true;

  Future resendrequestApi({required String uid, required List driverid}) async {
    try {
      Map body = {"uid": uid, "driverid": driverid};

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.resendrequestapi;

      if (kDebugMode) {
        print('Resend Request URL: $url');
        print('Resend Request Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(Duration(seconds: 30));

      if (kDebugMode) {
        print('Resend Request Response Status: ${response.statusCode}');
        print('Resend Request Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          resendRequest = resendRequestFromJson(response.body);
          if (resendRequest!.result == true) {
            isLoading = false;
            Fluttertoast.showToast(msg: "${resendRequest!.message}");
            update();
            return data;
          } else {
            Fluttertoast.showToast(msg: "${resendRequest!.message}");
          }
        } else {
          Fluttertoast.showToast(msg: "${data["ResponseMsg"]}");
        }
      } else {
        Fluttertoast.showToast(
            msg:
                "خطأ في HTTP: ${response.statusCode}"); // "HTTP Error: ${response.statusCode}"
      }
    } catch (e) {
      if (kDebugMode) {
        print("Resend Request API Error: $e");
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

      Fluttertoast.showToast(msg: errorMessage);
    }
  }
}
