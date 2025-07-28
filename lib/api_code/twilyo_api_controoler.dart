import 'dart:convert';

import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/common_code/config.dart';

import '../api_model/twilyo_api_model.dart';
import '../common_code/common_button.dart';

class TwilioapiController extends GetxController implements GetxService {
  TwilioApiModel? twilioApiModel;

  Future twilioApi({required String mobilenumber, context}) async {
    Map body = {
      "mobile": mobilenumber,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(Uri.parse(Config.baseurl + Config.twilioapi),
        body: jsonEncode(body), headers: userHeader);

    print('+ + + + + + + + + + + $body');
    print('- - - - - - - - - - - ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == "true") {
        twilioApiModel = twilioApiModelFromJson(response.body);
        update();

        // Fluttertoast.showToast(
        //   msg: "${data["message"]}",
        // );
        snackbar(context: context, text: "${data["message"]}");
      } else {
        // Fluttertoast.showToast(
        //   msg: "${data["message"]}",
        // );
        snackbar(context: context, text: "${data["message"]}");
      }
    } else {
      // Fluttertoast.showToast(
      //   msg: "Somthing went wrong!.....",
      // );
      snackbar(context: context, text: "Somthing went wrong!.....");
    }
  }
}
