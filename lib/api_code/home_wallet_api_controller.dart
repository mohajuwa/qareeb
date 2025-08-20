import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../api_model/home_wallete_api_model.dart';

class HomeWalletApiController extends GetxController implements GetxService {
  HomeWalleteApiModel? homeWalleteApiModel;
  bool isLoading = true;

  Future homwwalleteApi({context, required String uid}) async {
    Map body = {
      "uid": uid,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.homewallte),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + HomeWalletApiController + + + + + + :--- $body');
    print(
        '- - - - - HomeWalletApiController - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        homeWalleteApiModel = homeWalleteApiModelFromJson(response.body);

        if (homeWalleteApiModel!.result == true) {
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
        // showToastForDuration("${data["message"]}", 1);
        Get.back();
        return data;
      }
    } else {
      // showToastForDuration("Somthing went wrong!.....", 3);
    }
  }
}
