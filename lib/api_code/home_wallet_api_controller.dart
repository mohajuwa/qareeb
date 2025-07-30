import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/home_wallete_api_model.dart';

class HomeWalletApiController extends GetxController implements GetxService {
  HomeWalleteApiModel? homeWalleteApiModel;
  bool isLoading = true;

  Future homwwalleteApi({context, required String uid}) async {
    try {
      Map body = {"uid": uid};

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.homewallte;

      if (kDebugMode) {
        print('Home Wallet URL: $url');
        print('Home Wallet Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(Duration(seconds: 30));

      if (kDebugMode) {
        print('Home Wallet Response Status: ${response.statusCode}');
        print('Home Wallet Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          homeWalleteApiModel = homeWalleteApiModelFromJson(response.body);

          if (homeWalleteApiModel!.result == true) {
            update();
            isLoading = false;
            return data;
          } else {
            Get.back();
            return data;
          }
        } else {
          Get.back();
          return data;
        }
      } else {
        if (kDebugMode) {
          print('Home Wallet API HTTP Error: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Home Wallet API Error: $e");
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

      // Don't show error to user, just return null
      return null;
    }
  }
}
