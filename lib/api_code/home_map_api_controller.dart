import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/common_code/config.dart';
import '../api_model/home_map_api_model.dart';
import 'calculate_api_controller.dart';

class HomeMapController extends GetxController implements GetxService {
  HomeMapApiModel? homeMapApiModel;

  Future homemapApi(
      {context,
      required String mid,
      required String lat,
      required String lon}) async {
    Map body = {
      "mid": mid,
      "lat": lat,
      "lon": lon,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(Uri.parse(Config.baseurl + Config.homemap),
        body: jsonEncode(body), headers: userHeader);

    print('+ + + + + HomeMapApi + + + + + + :--- $body');
    print('- - - - - HomeMapApi - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        homeMapApiModel = homeMapApiModelFromJson(response.body);
        if (homeMapApiModel!.result == true) {
          update();

          return data;
        } else {
          showToastForDuration("${data["message"]}", 3);

          return data;
        }
      } else {
        showToastForDuration("${data["message"]}", 3);

        return data;
      }
    } else {
      showToastForDuration("Somthing went wrong!.....", 3);
    }
  }
}
