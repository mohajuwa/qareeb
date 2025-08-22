import 'dart:convert';

import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../services/notifier.dart';
import '../api_model/remove_request_api_model.dart';

class RemoveRequest extends GetxController implements GetxService {
  RemoveVihicalRequest? removeVihicalRequest;
  bool isLoading = true;

  Future removeApi({required String uid}) async {
    Map body = {
      "uid": uid,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.removerequestapi),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + Remove + + + + + + $body');
    print('- - - - - Remove - - - - - - ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        removeVihicalRequest = removeVihicalRequestFromJson(response.body);
        if (removeVihicalRequest!.result == true) {
          isLoading = false;
          Notifier.success("${removeVihicalRequest!.message}");
          update();
          return data;
        } else {
          Notifier.error("${data["message"]}");
        }
      } else {
        Notifier.error("${data["message"]}");
      }
    } else {
      Notifier.error("${data["message"]}");
    }
  }
}
