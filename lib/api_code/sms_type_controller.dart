import 'dart:convert';


import 'package:get/get.dart';
import '../common_code/config.dart';

import '../api_model/sms_type_api_model.dart';
import 'package:http/http.dart' as http;

import '../common_code/common_button.dart';

class SmstypeApiController extends GetxController implements GetxService {
  SmaApiModel? smaApiModel;
  bool isLoading = true;

  smsApi(context) async {
    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };
    var response = await http.get(Uri.parse(Config.baseurl + Config.smstypeapi),
        headers: userHeader);

    print("++++:---- ${response.body}");

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        smaApiModel = smaApiModelFromJson(response.body);

        // SharedPreferences preferences = await SharedPreferences.getInstance();
        // preferences.setString("otpvalue", jsonEncode(data["message"]));

        isLoading = false;
        update();
      } else {
        Get.back();
        // CustomNotification.show(message: "${data["message"]}", type: NotificationType.info);;
        snackbar(context: context, text: "${data["message"]}");
      }
    } else {
      Get.back();
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went Wrong....!!!")));
      snackbar(context: context, text: "Something went Wrong....!!!");
    }
  }
}
