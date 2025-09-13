import 'package:qareeb/common_code/custom_notification.dart';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_model/faq_model.dart';
import '../common_code/config.dart';

// class FaqApiController extends GetxController implements GetxService {
//   FaqApiiimodel? faqApiiimodel;
//   bool isLoading = true;
//
//   Future faqlistapi({
//     required String uid,
//   }) async {
//     Map body = {
//       "uid": uid,
//     };
//
//     Map<String, String> userHeader = {"Content-type": "application/json", "Accept": "application/json"};
//
//     var response = await http.post(Uri.parse(Config.baseurl + Config.faqapi), body: jsonEncode(body), headers: userHeader);
//
//     print(body);
//     print(response.body);
//
//     var data = jsonDecode(response.body);
//     if(response.statusCode == 200){
//       faqApiiimodel = faqApiiimodelFromJson(response.body);
//       if(data["Result"] == true){
//
//         isLoading = false;
//         update();
//         return jsonDecode(response.body);
//       }
//       else{
//       }
//     }
//     else{
//     }
//
//
//   }
// }

class FaqApiController extends GetxController implements GetxService {
  FaqApiiimodel? faqApiiimodel;
  bool isLoading = true;

  Future faqlistapi(context) async {
    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };
    var response = await http.get(Uri.parse(Config.baseurl + Config.faqapi),
        headers: userHeader);

    print("++++payment++++:-- ${response.body}");

    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        faqApiiimodel = faqApiiimodelFromJson(response.body);
        isLoading = false;
        update();
      } else {
        Get.back();
        CustomNotification.show(
            message: "${data["message"]}", type: NotificationType.info);
      }
    } else {
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Something went Wrong....!!!".tr)));
    }
  }
}
