import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../api_model/modual_calculate_api_model.dart';
import 'calculate_api_controller.dart';

class Modual_CalculateController extends GetxController implements GetxService {
  ModualCalculateApiModel? modualCalculateApiModel;
  bool isLoading = true;

  Future modualcalculateApi(
      {context,
      required String uid,
      required String mid,
      required String mrole,
      required String pickup_lat_lon,
      required String drop_lat_lon,
      required List drop_lat_lon_list}) async {
    Map body = {
      "uid": uid,
      "mid": mid,
      "mrole": mrole,
      "pickup_lat_lon": pickup_lat_lon,
      "drop_lat_lon": drop_lat_lon,
      "drop_lat_lon_list": drop_lat_lon_list,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.modualcalculate),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + Modual_CalCulate + + + + + + :--- $body');
    print('- - - - - Modual_CalCulate - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        modualCalculateApiModel =
            modualCalculateApiModelFromJson(response.body);

        if (modualCalculateApiModel!.result == true) {
          // Get.offAll(BoardingPage());
          update();

          showToastForDuration("${data["message"]}", 3);
          isLoading = false;
          return data;
        } else {
          showToastForDuration("${data["message"]}", 3);
          Get.back();
          return data;
        }
      } else {
        showToastForDuration("${data["message"]}", 3);
        Get.back();
        // snackbar(context: context, text: "${data["message"]}");
        return data;
      }
    } else {
      showToastForDuration("Somthing went wrong!.....", 3);

      // snackbar(context: context, text: "Somthing went wrong!.....");
    }
  }
}
