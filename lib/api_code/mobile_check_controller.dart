import 'dart:convert';

import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/common_code/config.dart';

import '../api_model/mobile_check_api_model.dart';
import '../common_code/common_button.dart';

class MobilCheckController extends GetxController implements GetxService {
  MobilcheckModel? mobilecheckModel;

  Future MobileCheckApi(
      {context, required String phone, required String ccode}) async {
    Map body = {"phone": phone, "ccode": ccode};

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.mobilecheck),
        body: jsonEncode(body),
        headers: userHeader);

    print('0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 - - - - - - - $body');
    print('1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 + + + + + + + ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      mobilecheckModel = mobilcheckModelFromJson(response.body);
      return data;
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text("Something went Wrong....!!!"),
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      //   ),
      // );
      snackbar(context: context, text: "Something went Wrong....!!!");
    }
  }
}
