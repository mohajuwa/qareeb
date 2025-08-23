// ===== NOTIFICATION API CONTROLLER =====

// lib/api_code/notification_api_controller.dart

import 'dart:async';

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import '../common_code/config.dart';

import '../common_code/network_service.dart';

import '../api_model/notification_api_model.dart';

import '../utils/show_toast.dart';

class NotificationApiController extends GetxController implements GetxService {
  NotiFicationApiModel? notiFicationApiModel;

  bool isLoading = true;

  Future notificationApi({required String uid}) async {
    // ✅ Network check

    if (!await NetworkService().hasInternetConnection()) {
      throw Exception(
          'No internet connection available. Please check your network and try again.'
              .tr);
    }

    Map body = {"uid": uid};

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    try {
      isLoading = true;

      update();

      var response = await http
          .post(Uri.parse(Config.baseurl + Config.notificationurl),
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
        print('+ + + + + Notification Api Controller + + + + + + :--- $body');

        print(
            '- - - - - Notification Api Controller - - - - - - :--- ${response.body}');
      }

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          notiFicationApiModel = notiFicationApiModelFromJson(response.body);

          if (notiFicationApiModel!.result == true) {
            update();

            isLoading = false;

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
        showToastForDuration("Something went wrong!.....", 2);
      }
    } catch (e) {
      isLoading = false;

      update();

      if (kDebugMode) print('Notification API Error: $e');

      rethrow;
    }
  }
}
