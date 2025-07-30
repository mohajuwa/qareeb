import 'dart:async';

import 'dart:convert';

import 'package:get/get.dart';

import 'package:qareeb/common_code/config.dart';

import 'package:qareeb/common_code/http_helper.dart';

import '../api_model/driver_detail_api_model.dart';

import 'calculate_api_controller.dart';

class DriverDetailApiController extends GetxController implements GetxService {
  DriverDetailApiModel? driverDetailApiModel;

  bool isLoading = true;

  Future driverdetailApi({required String d_id}) async {
    try {
      Map body = {
        "d_id": d_id,
      };

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      var response = await HttpHelper.post(
              Config.baseurl + Config.driverdetailprofile,
              body: jsonEncode(body),
              headers: userHeader)
          .timeout(Duration(seconds: 30));

      print('+ + + + + DriverDetailApiController + + + + + + :--- $body');

      print(
          '- - - - - DriverDetailApiController - - - - - - :--- ${response.body}');

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          driverDetailApiModel = driverDetailApiModelFromJson(response.body);

          if (driverDetailApiModel!.result == true) {
            update();

            isLoading = false;

            return data;
          } else {
            showToastForDuration("${data["message"]}", 2);

            return data;
          }
        } else {
          showToastForDuration("${data["message"]}", 2);

          return data;
        }
      } else {
        showToastForDuration("HTTP Error: ${response.statusCode}", 2);
      }
    } catch (e) {
      print("Driver Detail API Error: $e");

      showToastForDuration("Connection failed. Please try again.", 2);
    }
  }
}
