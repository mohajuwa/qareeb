// lib/api_code/vihical_ride_complete_api_controller.dart

import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/app_screen/pickup_drop_point.dart';
import 'package:qareeb/common_code/global_variables.dart'
   ;
import '../api_model/vihical_ride_api_model.dart';
import '../common_code/config.dart';

String ridecompleterequestid = "";

class VihicalRideCompleteOrderApiController extends GetxController
    implements GetxService {
  VihicalRideCompleteApiModel? vihicalRideCompleteApiModel;
  bool orederloader = false;
  bool isloadoing = false;

  Future vihicalridecomplete(
      {required String payment_id,
      required String payment_img,
      required String uid,
      required String d_id,
      required String request_id,
      required String wallet,
      context}) async {
    print("vvvpayment_imgvvv:-- $payment_img");

    if (orederloader) {
      return;
    } else {
      orederloader = true;
    }

    var request = http.MultipartRequest(
        'POST', Uri.parse(Config.baseurl + Config.vihicalridecomplete));

    request.fields.addAll({
      'uid': uid,
      'd_id': d_id,
      'request_id': request_id,
      'wallet': wallet,
      'payment_id': payment_id,
    });

    if (payment_img.isNotEmpty) {
      request.files
          .add(await http.MultipartFile.fromPath('payment_img', payment_img));
    } else {
      print("Payment image is empty");
    }

    http.StreamedResponse response = await request.send();
    final responseString = await response.stream.bytesToString();
    final responsnessaj = jsonDecode(responseString);

    if (response.statusCode == 200) {
      orederloader = false;

      if (responsnessaj["Result"] == true) {
        isloadoing = false;
        ridecompleterequestid = responsnessaj["request_id"].toString();
        vihicalRideCompleteApiModel =
            VihicalRideCompleteApiModel.fromJson(responsnessaj);

        // ✅ FIX: Reset state correctly
        pickupcontroller.text = "";
        dropcontroller.text = "";
        latitudepick = 0.00;
        longitudepick = 0.00;
        latitudedrop = 0.00;
        longitudedrop = 0.00;
        picktitle = "";
        picksubtitle = "";
        droptitle = "";
        dropsubtitle = "";

        // ✅ FIX: Changed assignments from '= []' to '.clear()'
        droptitlelist.clear();
        destinationlat.clear();
        destinationlong.clear();
        textfieldlist.clear(); // Using .clear() for consistency

        print("State reset successfully.");

        Fluttertoast.showToast(
          msg: responsnessaj["message"],
        );
      } else {
        Fluttertoast.showToast(
          msg: responsnessaj["message"],
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: responsnessaj["message"],
      );
    }
  }
}
