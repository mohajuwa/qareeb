// lib/api_code/sms_type_controller.dart

import 'dart:convert';

import 'package:get/get.dart';

import 'package:qareeb/common_code/config.dart';

import 'package:qareeb/common_code/http_helper.dart';

import '../api_model/sms_type_api_model.dart';

import '../common_code/common_button.dart';

class SmstypeApiController extends GetxController implements GetxService {
  SmaApiModel? smaApiModel;

  bool isLoading = true;

  smsApi(context) async {
    try {
      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.smstypeapi;

      print("SMS API URL: $url");

      var response = await HttpHelper.get(url, headers: userHeader)
          .timeout(Duration(seconds: 30));

      print("SMS API Response Status: ${response.statusCode}");

      print("SMS API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          smaApiModel = smaApiModelFromJson(response.body);

          isLoading = false;

          update();
        } else {
          Get.back();

          snackbar(context: context, text: "${data["message"]}");
        }
      } else {
        Get.back();

        snackbar(context: context, text: "HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("SMS API Error: $e");

      Get.back();

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
    }
  }
}
