// ===== ADD VEHICAL API CONTROLLER =====
// lib/api_code/add_vehical_api_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/api_model/add_vihical_api_model.dart';
import '../common_code/config.dart';
import '../common_code/network_service.dart';
import '../utils/show_toast.dart';

class AddVihicalCalculateController extends GetxController
    implements GetxService {
  AddVihicalCalculateModel? addVihicalCalculateModel;
  bool isLoading = false;

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
    // ✅ Network check
    if (!await NetworkService().hasInternetConnection()) {
      throw Exception(
          'No internet connection available. Please check your network and try again.'
              .tr);
    }

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    try {
      isLoading = true;
      update();

      var response = await http
          .post(Uri.parse(Config.baseurl + Config.addvihicalcalculate),
              body: jsonEncode(body), headers: userHeader)
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
              'Request timed out. Please check your connection and try again.'
                  .tr);
        },
      );

      if (kDebugMode) {
        print('+ + + + + AddVihicalCalculate + + + + + + :--- $body');
        print(
            '- - - - - AddVihicalCalculate - - - - - - :--- ${response.body}');
      }

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          addVihicalCalculateModel =
              addVihicalCalculateModelFromJson(response.body);
          if (addVihicalCalculateModel!.result == true) {
            isLoading = false;
            update();
            return data;
          } else {
            isLoading = false;
            update();
            showToastForDuration("${addVihicalCalculateModel!.message}", 2);
            return data;
          }
        } else {
          isLoading = false;
          update();
          showToastForDuration("${data["message"]}", 2);
          return data;
        }
      } else {
        isLoading = false;
        update();
        showToastForDuration("Something went wrong!.....", 2);
      }
    } catch (e) {
      isLoading = false;
      update();
      if (kDebugMode) print('AddVihical API Error: $e');
      rethrow;
    }
  }
}
