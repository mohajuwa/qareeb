import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/api_model/vihical_driver_detail_api_model.dart';
import 'package:qareeb/common_code/config.dart';

class CheckActiveRideApiController extends GetxController {
  VihicalDriverDetailModel? activeRideModel;

  Future checkActiveRide({required String uid}) async {
    Map body = {"uid": uid};
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };
    var response = await http.post(
        Uri.parse(Config.baseurl + Config.checkActiveRide),
        body: jsonEncode(body),
        headers: headers);

    var data = jsonDecode(response.body);
    if (data["Result"] == true && data["active_ride"] != null) {
      // Wrap the active_ride data in the expected format
      var wrappedData = {
        "ResponseCode": data["ResponseCode"],
        "Result": data["Result"],
        "message": data["message"],
        "accepted_d_detail": data["active_ride"]
      };
      activeRideModel =
          vihicalDriverDetailModelFromJson(jsonEncode(wrappedData));
    }
    return data;
  }
}
