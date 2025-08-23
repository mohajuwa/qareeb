// ===== ALL REQUEST DATA API CONTROLLER =====

// lib/api_code/all_request_data_api_controller.dart

import 'dart:async';

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import '../common_code/config.dart';

import '../common_code/network_service.dart';

import '../api_model/all_request_api_model.dart';

import '../utils/show_toast.dart';

class AllRequestDataApiController extends GetxController
    implements GetxService {
  AllRequestDataModel? allRequestDataModelupcoming;
  AllRequestDataModel? allRequestDataModelcompleted;
  AllRequestDataModel? allRequestDataModelcancelled;
  bool isLoading = true;

  Future allrequestApi(
      {context, required String uid, required String status}) async {
    Map body = {
      "uid": uid,
      "status": status,
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
          .post(Uri.parse(Config.baseurl + Config.allrequest),
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
        print('+ + + + + AddVihicalCalCulate + + + + + + :--- $body');

        print(
            '- - - - - AddVihicalCalCulate - - - - - - :--- ${response.body}');
      }

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          if (status == "upcoming") {
            if (kDebugMode) print("+++++ upcoming +++++");

            allRequestDataModelupcoming =
                allRequestDataModelFromJson(response.body);
          } else if (status == "completed") {
            if (kDebugMode) print("+++++ completed +++++");

            allRequestDataModelcompleted =
                allRequestDataModelFromJson(response.body);
          } else {
            if (kDebugMode) print("+++++ cancelled +++++");

            allRequestDataModelcancelled =
                allRequestDataModelFromJson(response.body);
          }

          update();

          if (allRequestDataModelupcoming!.result == true) {
            isLoading = false;

            update();
          } else {
            showToastForDuration("${allRequestDataModelupcoming!.message}", 2);
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

      if (kDebugMode) print('AllRequestData API Error: $e');

      rethrow;
    }
  }
}
