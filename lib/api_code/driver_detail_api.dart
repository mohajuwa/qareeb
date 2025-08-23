// ===== VIHICAL DRIVER DETAIL API CONTROLLER =====

// lib/api_code/vihical_driver_detail_api_controller.dart

import 'dart:async';

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:qareeb/api_model/driver_detail_api_model.dart';

import '../common_code/config.dart';

import '../common_code/network_service.dart';

import '../api_model/vihical_driver_detail_api_model.dart';

import '../utils/show_toast.dart';

class DriverDetailApiController extends GetxController implements GetxService {
  DriverDetailApiModel? driverDetailApiModel;
  bool isLoading = true;

  Future driverdetailApi({required String d_id}) async {
    Map body = {
      "d_id": d_id,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    // ✅ Network check

    if (!await NetworkService().hasInternetConnection()) {
      throw Exception(
          'No internet connection available. Please check your network and try again.'
              .tr);
    }

    try {
      isLoading = true;

      update();

      var response = await http
          .post(Uri.parse(Config.baseurl + Config.vihicaldriverdetail),
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
        print('+ + + + + DriverDetailApiController + + + + + + :--- $body');

        print(
            '- - - - - DriverDetailApiController - - - - - - :--- ${response.body}');
      }

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          driverDetailApiModel = driverDetailApiModelFromJson(response.body);

          if (driverDetailApiModel!.result == true) {
            isLoading = false;

            update();

            showToastForDuration("${data["message"]}", 2);

            return data;
          } else {
            isLoading = false;

            update();

            showToastForDuration("${data["message"]}", 2);

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

      if (kDebugMode) print('VihicalDriverDetail API Error: $e');

      rethrow;
    }
  }
}
