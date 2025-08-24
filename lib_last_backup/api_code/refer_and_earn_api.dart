import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api_model/refer_and_earn_api_model.dart';
import '../common_code/config.dart';
import 'calculate_api_controller.dart';


class referandearnApiController extends GetxController implements GetxService {

  ReferAndEarnApiModel? referAndEarnApiModel;
  bool isLoading = true;

  Future referapi({context,required String uid}) async {
    Map body = {
      "uid" : uid,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(Uri.parse(Config.baseurl + Config.referearnapi),
        body: jsonEncode(body), headers: userHeader);

    print('+ + + + + referapi + + + + + + :--- $body');
    print('- - - - - referapi t - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {

        referAndEarnApiModel = referAndEarnApiModelFromJson(response.body);
        if (referAndEarnApiModel!.result == true) {
          // Get.offAll(BoardingPage());
          isLoading = false;
          update();

          return data;

        } else {

          return data;
        }

      } else {

        return data;
      }

    } else {

      showToastForDuration("Somthing went wrong!.....", 3);


    }
  }
}