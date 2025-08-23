// ===== REMOVE REQUEST API CONTROLLER =====

// lib/api_code/remove_request.dart

import 'dart:async';

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:qareeb/api_model/remove_request_api_model.dart';

import '../common_code/config.dart';

import '../common_code/network_service.dart';

import '../utils/show_toast.dart';

class RemoveRequest extends GetxController implements GetxService {
  RemoveVihicalRequest? removeVihicalRequest;

  bool isLoading = false;

  Future removeApi({
    context,
    required String uid,
  }) async {
    // ✅ Network check

    if (!await NetworkService().hasInternetConnection()) {
      throw Exception(
          'No internet connection available. Please check your network and try again.'
              .tr);
    }

    Map body = {
      "uid": uid,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    try {
      isLoading = true;

      update();

      var response = await http
          .post(Uri.parse(Config.baseurl + Config.removerequestapi),
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
        print('+ + + + + RemoveRequest + + + + + + :--- $body');

        print('- - - - - RemoveRequest - - - - - - :--- ${response.body}');
      }

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          removeVihicalRequest = removeVihicalRequestFromJson(response.body);

          if (removeVihicalRequest!.result == true) {
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

      if (kDebugMode) print('RemoveRequest API Error: $e');

      rethrow;
    }
  }
}
