// ===== CANCEL REASON REQUEST API CONTROLLER =====
// lib/api_code/cancel_rason_request_api_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/api_model/cancel_reason_api_model.dart';
import '../common_code/config.dart';
import '../common_code/network_service.dart';
import '../utils/show_toast.dart';

class CancelRasonRequestApiController extends GetxController
    implements GetxService {
  CancelReasonModel? cancelReasonModel;
  bool isLoading = true;

  cancelreasonApi(context) async {
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

      var response = await http.post(
          Uri.parse(Config.baseurl + Config.vehicalcancelreason),
          headers: userHeader);

      if (kDebugMode) {
        print('- - - - - CancelRasonRequest - - - - - - :--- ${response.body}');
      }

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          cancelReasonModel = cancelReasonModelFromJson(response.body);
          if (cancelReasonModel!.result == true) {
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
      if (kDebugMode) print('CancelRasonRequest API Error: $e');
      rethrow;
    }
  }
}
