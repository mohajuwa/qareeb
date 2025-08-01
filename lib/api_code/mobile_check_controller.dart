// lib/api_code/mobile_check_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/mobile_check_api_model.dart';
import '../common_code/common_button.dart';

class MobilCheckController extends GetxController implements GetxService {
  MobilcheckModel? mobilecheckModel;

  Future MobileCheckApi(
      {context, required String phone, required String ccode}) async {
    try {
      Map body = {"phone": phone, "ccode": ccode};

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.mobilecheck;
      if (kDebugMode) {
        print("Mobile Check API URL: $url");
        print("Mobile Check API Body: $body");
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Mobile Check API Response Status: ${response.statusCode}');
        print('Mobile Check API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        mobilecheckModel = mobilcheckModelFromJson(response.body);
        return data;
      } else {
        snackbar(context: context, text: "HTTP Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Mobile Check API Error: $e");
      }

      String errorMessage = "Connection failed";
      if (e.toString().contains('Failed host lookup')) {
        errorMessage = "Server not reachable. Check your internet connection.";
      } else if (e.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
        errorMessage =
            "SSL Certificate error. Using self-signed certificate bypass.";
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = "Request timeout. Please try again.";
      }

      snackbar(context: context, text: errorMessage);
      return null;
    }
  }
}
