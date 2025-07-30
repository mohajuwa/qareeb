import 'dart:convert';

import 'package:get/get.dart';

import 'package:qareeb/common_code/http_helper.dart';

import '../api_model/refer_and_earn_api_model.dart';

import '../common_code/config.dart';

import 'calculate_api_controller.dart';

class referandearnApiController extends GetxController implements GetxService {
  ReferAndEarnApiModel? referAndEarnApiModel;

  bool isLoading = true;

  Future referapi({context, required String uid}) async {
    try {
      Map body = {
        "uid": uid,
      };

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      var response = await HttpHelper.post(Config.baseurl + Config.referearnapi,
              body: jsonEncode(body), headers: userHeader)
          .timeout(Duration(seconds: 30));

      print('+ + + + + referapi + + + + + + :--- $body');

      print('- - - - - referapi - - - - - - :--- ${response.body}');

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          referAndEarnApiModel = referAndEarnApiModelFromJson(response.body);

          if (referAndEarnApiModel!.result == true) {
            isLoading = false;

            update();

            return data;
          } else {
            return data;
          }
        } else {
          return data;
        }
      } else {
        showToastForDuration("HTTP Error: ${response.statusCode}", 3);
      }
    } catch (e) {
      print("Refer and Earn API Error: $e");

      showToastForDuration("Connection failed. Please try again.", 3);
    }
  }
}
