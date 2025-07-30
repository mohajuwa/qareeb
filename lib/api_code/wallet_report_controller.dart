import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/wallet_api_model.dart';

class WalletReportApiController extends GetxController implements GetxService {
  WalletReportApiModel? walletReportApiModel;
  bool isLoading = true;

  Future walletreportApi({required String uid}) async {
    try {
      Map body = {"uid": uid};

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.walletreportapi;

      if (kDebugMode) {
        print('Wallet Report URL: $url');
        print('Wallet Report Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(Duration(seconds: 30));

      if (kDebugMode) {
        print('Wallet Report Response Status: ${response.statusCode}');
        print('Wallet Report Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          walletReportApiModel = walletReportApiModelFromJson(response.body);
          if (walletReportApiModel!.result == true) {
            isLoading = false;
            update();
          } else {
            Fluttertoast.showToast(msg: "${walletReportApiModel!.message}");
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
        print("Wallet Report API Error: $e");
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
