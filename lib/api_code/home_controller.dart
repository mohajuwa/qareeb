// ✅ ENHANCED VERSION (Optional improvements):

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/custom_notification.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:qareeb/common_code/network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common_code/config.dart';
import '../api_model/home_api_model.dart';

class HomeApiController extends GetxController implements GetxService {
  HomeModel? homeapimodel;
  bool isLoading = true;

  Future homeApi(
      {required String uid, required String lat, required String lon}) async {
    // ✅ Arabic network error message

    if (!await NetworkService().hasInternetConnection()) {
      throw Exception(
          'No internet connection available. Please check your network and try again.'
              .tr);
    }

    Map body = {"uid": uid, "lat": lat, "lon": lon};

    try {
      isLoading = true;

      update();

      var response = await http.post(Uri.parse(Config.baseurl + Config.home),
          body: jsonEncode(body),
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json"
          }).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          // ✅ Arabic timeout message

          throw Exception(
              'Request timed out. Please check your connection and try again.'
                  .tr);
        },
      );

      if (kDebugMode) {
        print('- - - - -  home - - - - - - ${response.body}');
      }

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          homeapimodel = homeModelFromJson(response.body);

          if (homeapimodel!.result == true) {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();

            preferences.setString(
                "currenci", jsonEncode(data["general"]["site_currency"]));

            isLoading = false;

            update();

            return data;
          } else {
            isLoading = false;

            update();

            CustomNotification.show(
                message: "${homeapimodel!.message}".tr, // ✅ Added .tr

                type: NotificationType.info);

            throw Exception(
                homeapimodel!.message ?? 'API returned false result'.tr);
          }
        } else {
          isLoading = false;

          update();

          CustomNotification.show(
              message: "${data["message"]}".tr, // ✅ Added .tr

              type: NotificationType.info);

          throw Exception(data["message"] ?? 'API request failed'.tr);
        }
      } else {
        isLoading = false;

        update();

        CustomNotification.show(
            message:
                "Something went wrong! Please try again.".tr, // ✅ Added .tr

            type: NotificationType.error);

        throw Exception('Server error. Please try again later.'.tr);
      }
    } catch (e) {
      isLoading = false;

      update();

      if (kDebugMode) print('Home API Error: $e');

      rethrow;
    }
  }
}
