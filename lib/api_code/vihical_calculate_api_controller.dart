// ===== VIHICAL CALCULATE API CONTROLLER =====

// lib/api_code/vihical_calculate_api_controller.dart

import 'dart:async';

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:qareeb/api_model/vihical_calculte_api_model.dart';

import '../common_code/config.dart';

import '../common_code/network_service.dart';

import '../utils/show_toast.dart';

class VihicalCalculateController extends GetxController implements GetxService {
  VihicalCalculateModel? vihicalCalculateModel;

  bool isLoading = false;

  Future vihicalcalculateApi({
    context,
    required String uid,
    required String mid,
    required String pickup_lat_lon,
    required String drop_lat_lon,
    required List drop_lat_lon_list,
  }) async {
    // ✅ Network check

    if (!await NetworkService().hasInternetConnection()) {
      throw Exception(
          'No internet connection available. Please check your network and try again.'
              .tr);
    }

    Map body = {
      "uid": uid,
      "pickup_lat_lon": pickup_lat_lon,
      "drop_lat_lon": drop_lat_lon,
      "drop_lat_lon_list": drop_lat_lon_list,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    try {
      isLoading = true;

      update();

      var response = await http
          .post(Uri.parse(Config.baseurl + Config.vihicalcalculate),
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
        print('+ + + + + VihicalCalculate + + + + + + :--- $body');

        print('- - - - - VihicalCalculate - - - - - - :--- ${response.body}');
      }

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          vihicalCalculateModel = vihicalCalculateModelFromJson(response.body);

          if (vihicalCalculateModel!.result == true) {
            isLoading = false;

            update();

            return data;
          } else {
            isLoading = false;

            update();

            showToastForDuration("${vihicalCalculateModel!.message}", 2);

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

      if (kDebugMode) print('VihicalCalculate API Error: $e');

      rethrow;
    }
  }
}
