// ✅ ENHANCED VERSION (Optional improvements):

import 'package:get/get.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:qareeb/services/running_ride_monitor.dart';
import 'package:qareeb/utils/show_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common_code/config.dart';
import '../api_model/home_api_model.dart';

class HomeApiController extends GetxController implements GetxService {
  HomeModel? homeapimodel;
  bool isLoading = true;

  Future homeApi(
      {required String uid, required String lat, required String lon}) async {
    Map body = {"uid": uid, "lat": lat, "lon": lon};

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(Uri.parse(Config.baseurl + Config.home),
        body: jsonEncode(body), headers: userHeader);

    print('- - - - -  home - - - - - - ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        homeapimodel = homeModelFromJson(response.body);
        if (homeapimodel!.result == true) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString(
              "currenci", jsonEncode(data["general"]["site_currency"]));
          // preferences.setString("plateformfee", jsonEncode(data["plaform_free"]));

          isLoading = false;
          update();

          Future.delayed(const Duration(milliseconds: 500), () {
            RunningRideMonitor.instance.checkNow();
          });

          return data;
        } else {
          showToastForDuration("${data["message"]}", 3);
          return data;
        }
      } else {
        showToastForDuration("${data["message"]}", 3);
      }
    } else {
      showToastForDuration("${data["message"]}", 3);
    }
  }
}
