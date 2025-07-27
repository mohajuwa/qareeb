import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
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

  Future faqlistapi(context) async{

    Map<String,String> userHeader = {"Content-type": "application/json", "Accept": "application/json"};
    var response = await http.get(Uri.parse(Config.baseurl + Config.faqapi),headers: userHeader);

    print("++++payment++++:-- ${response.body}");

    var data = jsonDecode(response.body);
    if(response.statusCode == 200){
      if(data["Result"] == true){
        faqApiiimodel = faqApiiimodelFromJson(response.body);
        isLoading = false;
        update();
      }
      else{
        Get.back();
        Fluttertoast.showToast(msg: "${data["message"]}");
      }
    }
    else{
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went Wrong....!!!")));
    }
  }
}