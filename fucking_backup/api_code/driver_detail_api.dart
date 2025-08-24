import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../api_model/driver_detail_api_model.dart';
import 'calculate_api_controller.dart';

class DriverDetailApiController extends GetxController implements GetxService {
  DriverDetailApiModel? driverDetailApiModel;
  bool isLoading = true;

  Future driverdetailApi({required String d_id}) async {
    Map body = {
      "d_id": d_id,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.driverdetailprofile),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + DriverDetailApiController + + + + + + :--- $body');
    print(
        '- - - - - DriverDetailApiController - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        driverDetailApiModel = driverDetailApiModelFromJson(response.body);
        if (driverDetailApiModel!.result == true) {
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
