import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/common_code/config.dart';
import '../api_model/notification_api_model.dart';
import 'calculate_api_controller.dart';

class NotificationApiController extends GetxController implements GetxService {
  NotiFicationApiModel? notiFicationApiModel;
  bool isLoading = true;

  Future notificationApi({required String uid}) async {
    Map body = {
      "uid": uid,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.notificationurl),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + Notification Api Controller + + + + + + :--- $body');
    print(
        '- - - - - Notification Api Controller - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        notiFicationApiModel = notiFicationApiModelFromJson(response.body);
        if (notiFicationApiModel!.result == true) {
          update();
          isLoading = false;
          return data;
        } else {
          showToastForDuration("${data["message"]}", 2);
          return data;
        }
      } else {
        showToastForDuration("${data["message"]}", 2);
        return data;
      }
    } else {
      showToastForDuration("Somthing went wrong!.....", 2);
    }
  }
}
