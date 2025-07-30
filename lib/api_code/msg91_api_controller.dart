// lib/api_code/msg91_api_controller.dart

import 'dart:convert';

import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import 'package:qareeb/common_code/config.dart';

import 'package:qareeb/common_code/http_helper.dart';

import '../api_model/mag91_api_model.dart';

import '../common_code/common_button.dart';

class MasgapiController extends GetxController implements GetxService {
  MsgApiModel? msgApiModel;

  Future msgApi({required String mobilenumber, context}) async {
    try {
      Map body = {
        "phoneno": mobilenumber,
      };

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.msgapi;

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(const Duration(seconds: 30));

      print('MSG91 API Body: $body');

      print('MSG91 API Response: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          msgApiModel = msgApiModelFromJson(response.body);

          update();

          snackbar(context: context, text: "${data["message"]}");
        } else {
          snackbar(context: context, text: "${data["message"]}");
        }
      } else {
        snackbar(context: context, text: "HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("MSG91 API Error: $e");

      snackbar(context: context, text: "Connection failed. Please try again.");
    }
  }
}
