import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/common_code/config.dart';
import '../api_model/vihical_calculte_api_model.dart';
import 'calculate_api_controller.dart';

class VihicalCalculateController extends GetxController implements GetxService {
  VihicalCalculateModel? vihicalCalculateModel;

  Future vihicalcalculateApi(
      {context,
      required String uid,
      required String mid,
      required String pickup_lat_lon,
      required String drop_lat_lon,
      required List drop_lat_lon_list}) async {
    Map body = {
      "uid": uid,
      "mid": mid,
      "pickup_lat_lon": pickup_lat_lon,
      "drop_lat_lon": drop_lat_lon,
      "drop_lat_lon_list": drop_lat_lon_list,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.vihicalcalculate),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + VihicalCalCulate + + + + + + :--- $body');
    print('- - - - - VihicalCalCulate - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        vihicalCalculateModel = vihicalCalculateModelFromJson(response.body);
        if (vihicalCalculateModel!.result == true) {
          // Get.offAll(BoardingPage());
          update();
          // showToastForDuration("${data["message"]}", 2);
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
