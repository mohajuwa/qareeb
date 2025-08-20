import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../services/notifier.dart';
import '../api_model/cancel_reason_api_model.dart';
import '../api_model/payment_api_model.dart';

class CancelRasonRequestApiController extends GetxController
    implements GetxService {
  CancelReasonModel? cancelReasonModel;
  bool isLoading = true;

  cancelreasonApi(context) async {
    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };
    var response = await http.get(
        Uri.parse(Config.baseurl + Config.vehicalcancelreason),
        headers: userHeader);

    print("++++vehicle_cancel++++:-- ${response.body}");

    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        cancelReasonModel = cancelReasonModelFromJson(response.body);
        isLoading = false;
        update();
      } else {
        Get.back();
        Notifier.info('');
      }
    } else {
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went Wrong....!!!")));
    }
  }
}
