import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../api_model/home_wallete_api_model.dart';
import '../api_model/vihical_information_api_model.dart';
import 'calculate_api_controller.dart';

class VihicalInformationApiController extends GetxController
    implements GetxService {
  VihicalInFormationApiModel? vihicalInFormationApiModel;
  bool isLoading = true;

  Future vihicalinformationApi({context, required String vehicle_id}) async {
    Map body = {
      "vehicle_id": vehicle_id,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.vihicalinformation),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + VihicalDetailApiController + + + + + + :--- $body');
    print(
        '- - - - - VihicalDetailApiController - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        vihicalInFormationApiModel =
            vihicalInFormationApiModelFromJson(response.body);

        if (vihicalInFormationApiModel!.result == true) {
          // Get.offAll(BoardingPage());
          update();

          // showToastForDuration("${data["message"]}", 1);
          isLoading = false;
          return data;
        } else {
          // showToastForDuration("${data["message"]}", 1);
          Get.back();
          return data;
        }
      } else {
        showToastForDuration("${data["message"]}", 1);
        Get.back();
        return data;
      }
    } else {
      showToastForDuration("Somthing went wrong!.....", 3);
    }
  }
}
