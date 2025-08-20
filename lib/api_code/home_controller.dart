import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../services/notifier.dart';
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
          return data;
        } else {
          Notifier.info('');
          return data;
        }
      } else {
        Notifier.info('');
      }
    } else {
      Notifier.info('');
    }
  }
}
