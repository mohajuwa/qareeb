import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../api_model/resend_api_model.dart';

class ResendRequestApiController extends GetxController implements GetxService {
  ResendRequest? resendRequest;
  bool isLoading = true;

  Future resendrequestApi({required String uid, required List driverid}) async {
    Map body = {"uid": uid, "driverid": driverid};

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.resendrequestapi),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + ResendRequest + + + + + + $body');
    print('- - - - - - ResendRequest  - - - - - ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        resendRequest = resendRequestFromJson(response.body);
        if (resendRequest!.result == true) {
          isLoading = false;
          Fluttertoast.showToast(
            msg: "${resendRequest!.message}",
          );
          update();
          return data;
        } else {
          Fluttertoast.showToast(
            msg: "${resendRequest!.message}",
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "${data["ResponseMsg"]}",
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Somthing went wrong!.....",
      );
    }
  }
}
