import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../api_model/vihical_driver_detail_api_model.dart';
import 'calculate_api_controller.dart';

class VihicalDriverDetailApiController extends GetxController
    implements GetxService {
  VihicalDriverDetailModel? vihicalDriverDetailModel;

  Future vihicaldriverdetailapi(
      {context,
      required String uid,
      required String d_id,
      required String request_id}) async {
    Map body = {
      "uid": uid,
      "d_id": d_id,
      "request_id": request_id,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.vihicaldriverdetail),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + VihicalDriverDetailApiController + + + + + + :--- $body');
    print(
        '- - - - - VihicalDriverDetailApiController - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        vihicalDriverDetailModel =
            vihicalDriverDetailModelFromJson(response.body);
        if (vihicalDriverDetailModel!.result == true) {
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
