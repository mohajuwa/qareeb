import 'package:qareeb/common_code/custom_notification.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../api_model/payment_api_model.dart';

class PaymentGetApiController extends GetxController implements GetxService {
  Paymentgetwayapi? paymentgetwayapi;
  bool isLoading = true;

  Future paymentlistApi(context) async {
    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };
    var response = await http.get(Uri.parse(Config.baseurl + Config.payment),
        headers: userHeader);

    print("++++payment++++:-- ${response.body}");

    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        paymentgetwayapi = paymentgetwayapiFromJson(response.body);
        isLoading = false;
        update();
      } else {
        Get.back();
        CustomNotification.show(message: "${data["message"]}", type: NotificationType.info);;
      }
    } else {
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went Wrong....!!!")));
    }
  }
}
