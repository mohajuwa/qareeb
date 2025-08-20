import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';

import '../api_model/forgot_api_model.dart';
import '../common_code/common_button.dart';

class ForgotController extends GetxController implements GetxService {
  ForgotModel? forgotModel;

  forgotApi(
      {required String phone,
      required String password,
      required String ccode,
      context}) async {
    Map body = {"phone": phone, "password": password, "ccode": ccode};

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(Uri.parse(Config.baseurl + Config.forgot),
        body: jsonEncode(body), headers: userHeader);

    print('+ + + + + + + + + + +$body');
    print('- - - - - - - - - - -${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        forgotModel = forgotModelFromJson(response.body);
        if (forgotModel!.result == true) {
          // Get.offAll(BoardingPage());
          update();
          Get.back();
          Get.back();
          Get.back();
          // Notifier.info('');
          snackbar(context: context, text: "${data["message"]}");
          return data;
        } else {
          // Notifier.info('');
          snackbar(context: context, text: "${forgotModel!.message}");
          return data;
        }
      } else {
        // Notifier.info('');
        snackbar(context: context, text: "${data["message"]}");
      }
    } else {
      // Notifier.info('');
      snackbar(context: context, text: "Somthing went wrong!.....");
    }
  }
}
