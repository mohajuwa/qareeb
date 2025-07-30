import 'dart:convert';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/twilyo_api_model.dart';
import '../common_code/common_button.dart';

class TwilioapiController extends GetxController implements GetxService {
  TwilioApiModel? twilioApiModel;

  Future twilioApi({required String mobilenumber, context}) async {
    try {
      Map body = {
        "mobile": mobilenumber,
      };

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      var response = await HttpHelper.post(Config.baseurl + Config.twilioapi,
              body: jsonEncode(body), headers: userHeader)
          .timeout(Duration(seconds: 30));

      print('+ + + + + + + + + + + $body');
      print('- - - - - - - - - - - ${response.body}');

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == "true") {
          twilioApiModel = twilioApiModelFromJson(response.body);
          update();
          snackbar(context: context, text: "${data["message"]}");
        } else {
          snackbar(context: context, text: "${data["message"]}");
        }
      } else {
        snackbar(context: context, text: "HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Twilio API Error: $e");
      String errorMessage = "Connection failed";
      if (e.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
        errorMessage =
            "SSL Certificate error. Using self-signed certificate bypass.";
      }
      snackbar(context: context, text: errorMessage);
    }
  }
}
