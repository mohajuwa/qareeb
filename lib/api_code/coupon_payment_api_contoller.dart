import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/payment_api_model.dart';

class PaymentGetApiController extends GetxController implements GetxService {
  Paymentgetwayapi? paymentgetwayapi;
  bool isLoading = true;

  Future paymentlistApi(context) async {
    try {
      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.payment;

      if (kDebugMode) {
        print("Payment API URL: $url");
      }

      var response = await HttpHelper.get(url, headers: userHeader)
          .timeout(Duration(seconds: 30));

      if (kDebugMode) {
        print("Payment API Response Status: ${response.statusCode}");
        print("Payment API Response Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          paymentgetwayapi = paymentgetwayapiFromJson(response.body);
          isLoading = false;
          update();
        } else {
          Get.back();
          Fluttertoast.showToast(msg: "${data["message"]}");
        }
      } else {
        Get.back();
        Fluttertoast.showToast(
            msg:
                "خطأ في HTTP: ${response.statusCode}"); // "HTTP Error: ${response.statusCode}"
      }
    } catch (e) {
      if (kDebugMode) {
        print("Payment API Error: $e");
      }

      Get.back();

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

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }
}
