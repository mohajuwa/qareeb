import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../api_model/wallet_api_model.dart';

class WalletReportApiController extends GetxController implements GetxService {
  WalletReportApiModel? walletReportApiModel;
  bool isLoading = true;

  Future walletreportApi({required String uid}) async {
    Map body = {
      "uid": uid,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.walletreportapi),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + + + + + + + $body');
    print('- - - - - - - - - - - ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        walletReportApiModel = walletReportApiModelFromJson(response.body);
        if (walletReportApiModel!.result == true) {
          isLoading = false;
          update();
        } else {
          Fluttertoast.showToast(
            msg: "${walletReportApiModel!.message}",
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "${data["ResponseMsg"]}",
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Somthing went wrong!.....",
      );
    }
  }
}
