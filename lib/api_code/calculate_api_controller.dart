import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../services/notifier.dart';
import '../api_model/calculate_api_model.dart';

class CalculateController extends GetxController implements GetxService {
  CalCulateModel? calCulateModel;

  Future calculateApi(
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

    var response = await http.post(Uri.parse(Config.baseurl + Config.calculate),
        body: jsonEncode(body), headers: userHeader);

    print('+ + + + + CalCulate + + + + + + :--- $body');
    print('- - - - - CalCulate - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        calCulateModel = calCulateModelFromJson(response.body);
        if (calCulateModel!.result == true) {
          // Get.offAll(BoardingPage());
          update();

          return data;
        } else {
          return data;
        }
      } else {
        return data;
      }
    } else {}
  }
}

void showToastForDuration(String message, int durationInSeconds) {
  int interval = 2; // Duration of each toast
  int elapsed = 0;

  Timer.periodic(Duration(seconds: interval), (timer) {
    if (elapsed >= durationInSeconds) {
      timer.cancel();
    } else {
      Notifier.info('');
      elapsed += interval;
    }
  });
}


// ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBartimer({required context,required String text}){
//   return  ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text(text),behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 10),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
//   );
// }