import 'dart:async';

import 'dart:convert';

import 'package:get/get.dart';

import 'package:qareeb/common_code/config.dart';

import 'package:qareeb/common_code/http_helper.dart';

import '../api_model/my_ride_detail_api_model.dart';

import 'calculate_api_controller.dart';

class MyRideDetailApiController extends GetxController implements GetxService {
  MyRideDetailApiModel? myRideDetailApiModel;

  bool isLoading = true;

  Future mydetailApi(
      {context,
      required String uid,
      required String request_id,
      required String status}) async {
    try {
      Map body = {
        "uid": uid,
        "request_id": request_id,
        "status": status,
      };

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      var response = await HttpHelper.post(Config.baseurl + Config.myridedetail,
              body: jsonEncode(body), headers: userHeader)
          .timeout(Duration(seconds: 30));

      print('+ + + + + MyRideDetailApiController + + + + + + :--- $body');

      print(
          '- - - - - MyRideDetailApiController - - - - - - :--- ${response.body}');

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          myRideDetailApiModel = myRideDetailApiModelFromJson(response.body);

          if (myRideDetailApiModel!.result == true) {
            update();

            isLoading = false;

            return data;
          } else {
            showToastForDuration("${data["message"]}", 3);

            return data;
          }
        } else {
          showToastForDuration("${data["message"]}", 3);

          return data;
        }
      } else {
        showToastForDuration("HTTP Error: ${response.statusCode}", 3);
      }
    } catch (e) {
      print("My Ride Detail API Error: $e");

      showToastForDuration("Connection failed. Please try again.", 3);
    }
  }
}
