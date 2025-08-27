// ✅ UPDATED: lib/api_code/calculate_api_controller.dart

import 'package:qareeb/common_code/custom_notification.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // ✅ Added for kDebugMode

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../common_code/network_service.dart'; // ✅ Added network service
import '../api_model/calculate_api_model.dart';

class CalculateController extends GetxController implements GetxService {
  CalCulateModel? calCulateModel;

  Future calculateApi(
      {context,
      required String uid,
      required String mid,
      required String mrole,
      required String pickup_lat_lon,
      required String drop_lat_lon,
      required List drop_lat_lon_list}) async {
    Map body = {
      "uid": uid,
      "mid": mid,
      "mrole": mrole,
      "pickup_lat_lon": pickup_lat_lon,
      "drop_lat_lon": drop_lat_lon,
      "drop_lat_lon_list": drop_lat_lon_list,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(Uri.parse(Config.baseurl + Config.calculate),
        body: jsonEncode(body), headers: userHeader);

    print('+ + + + + CalCulate + + + + + + :--- $body');
    print('- - - - - CalCulate - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        calCulateModel = calCulateModelFromJson(response.body);
        if (calCulateModel!.result == true) {
          // Get.offAll(BoardingPage());
          update();

          return data;
        } else {
          return data;
        }
      } else {
        return data;
      }
    } else {}
  }
}
