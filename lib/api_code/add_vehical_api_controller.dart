// ========================================
// ENHANCED Flutter API Controller: AddVihicalCalculateController
// ========================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/utils/show_toast.dart';
import '../common_code/config.dart';
import '../api_model/add_vihical_api_model.dart';

class AddVihicalCalculateController extends GetxController
    implements GetxService {
  AddVihicalCalculateModel? addVihicalCalculateModel;

  Future addvihicalcalculateApi(
      {context,
      required String uid,
      required String bidd_auto_status,
      required String payment_id,
      required String coupon_id,
      required String m_role,
      required String tot_km,
      required String vehicle_id,
      required String tot_hour,
      required String tot_minute,
      required List droplistadd,
      required Map dropadd,
      required Map pickupadd,
      required List driverid,
      required String price,
      required String pickup,
      required String drop,
      required List droplist}) async {
    Map body = {
      "uid": uid,
      "driverid": driverid,
      "price": price,
      "tot_km": tot_km,
      "pickup": pickup,
      "drop": drop,
      "droplist": droplist,
      "pickupadd": pickupadd,
      "dropadd": dropadd,
      "droplistadd": droplistadd,
      "tot_hour": tot_hour,
      "tot_minute": tot_minute,
      "vehicle_id": vehicle_id,
      "payment_id": payment_id,
      "m_role": m_role,
      "coupon_id": coupon_id,
      "bidd_auto_status": bidd_auto_status,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.addvihicalcalculate),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + AddVihicalCalCulate + + + + + + :--- $body');
    print('- - - - - AddVihicalCalCulate - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        addVihicalCalculateModel =
            addVihicalCalculateModelFromJson(response.body);
        if (addVihicalCalculateModel!.result == true) {
          // Get.offAll(BoardingPage());
          update();
          showToastForDuration("${data["message"]}", 2);
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
