import 'dart:convert';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../api_model/timeout_api_model.dart';

class TimeoutRequestApiController extends GetxController
    implements GetxService {
  TimeOutRequest? timeOutRequest;
  bool isLoading = true;

  Future timeoutrequestApi(
      {required String uid, required String request_id}) async {
    Map body = {
      "uid": uid,
      "request_id": request_id,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.timeoutapi),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + TimeOut + + + + + + $body');
    print('- - - - - - TimeOut  - - - - - ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        timeOutRequest = timeOutRequestFromJson(response.body);
        if (timeOutRequest!.result == true) {
          isLoading = false;
          update();
          return data;
        } else {
          // Notifier.info('');
          return data;
        }
      } else {
        // Notifier.info('');
        return data;
      }
    } else {
      // Notifier.info('');
    }
  }
}
