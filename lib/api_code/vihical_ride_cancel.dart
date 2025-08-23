import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/utils/show_toast.dart';
import '../common_code/config.dart';
import '../api_model/vihical_cancel_ride_api_model.dart';

class VihicalCancelRideApiController extends GetxController
    implements GetxService {
  VihicalRideCancelModel? vihicalRideCancelModel;

  Future vihicalcancelapi(
      {context,
      required String uid,
      required String lat,
      required String lon,
      required String cancel_id,
      required String request_id}) async {
    Map body = {
      "uid": uid,
      "request_id": request_id,
      "cancel_id": cancel_id,
      "lat": lat,
      "lon": lon
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.vihicalcancelride),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + vehicle_ride_cancel + + + + + + :--- $body');
    print('- - - - - vehicle_ride_cancel - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        vihicalRideCancelModel = vihicalRideCancelModelFromJson(response.body);
        if (vihicalRideCancelModel!.result == true) {
          // Get.offAll(BoardingPage());
          update();
          showToastForDuration("${data["message"]}", 2);
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
