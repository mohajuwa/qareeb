import 'dart:async';

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import '../common_code/config.dart';

import '../api_model/vihical_driver_detail_api_model.dart';

import 'calculate_api_controller.dart';

class VihicalDriverDetailApiController extends GetxController
    implements GetxService {
  VihicalDriverDetailModel? vihicalDriverDetailModel;

  Future vihicaldriverdetailapi({
    context,
    required String uid,
    required String d_id,
    required String request_id,
  }) async {
    if (kDebugMode) {
      print("🚗 Driver detail API called with:");

      print("   uid: $uid");

      print("   d_id: $d_id");

      print("   request_id: '$request_id'");
    }

    // ✅ CRITICAL FIX: If request_id is empty, try to get it from global variable

    // or find the active cart for this user and driver

    String actualRequestId = request_id;

    if (request_id.isEmpty || request_id == "") {
      if (kDebugMode) {
        print("⚠️ request_id is empty, attempting to find active cart...");
      }

      // Try to find active cart without request_id

      Map body = {
        "uid": uid,

        "d_id": d_id,

        "request_id": "", // Send empty but let server handle it
      };

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      var response = await http.post(
          Uri.parse(Config.baseurl + Config.vihicaldriverdetail),
          body: jsonEncode(body),
          headers: userHeader);

      if (kDebugMode) {
        print('📤 VihicalDriverDetailApiController request: $body');

        print('📥 VihicalDriverDetailApiController response: ${response.body}');
      }

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          vihicalDriverDetailModel =
              vihicalDriverDetailModelFromJson(response.body);

          if (vihicalDriverDetailModel!.result == true) {
            update();

            if (kDebugMode) {
              print("✅ Driver detail loaded successfully");
            }

            return data;
          } else {
            if (kDebugMode) {
              print("❌ Driver detail API returned false: ${data["message"]}");
            }

            showToastForDuration("${data["message"]}", 2);

            return data;
          }
        } else {
          if (kDebugMode) {
            print("❌ Driver detail API failed: ${data["message"]}");

            print("🔍 Debug info: ${data["debug"]}");
          }

          // Show user-friendly error

          showToastForDuration(
              "Unable to load driver details. Please try again.", 2);

          return data;
        }
      } else {
        if (kDebugMode) {
          print("❌ HTTP Error ${response.statusCode}");
        }

        showToastForDuration("Connection error. Please try again.", 2);

        return null;
      }
    } else {
      // Original flow with request_id

      Map body = {
        "uid": uid,
        "d_id": d_id,
        "request_id": request_id,
      };

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      var response = await http.post(
          Uri.parse(Config.baseurl + Config.vihicaldriverdetail),
          body: jsonEncode(body),
          headers: userHeader);

      if (kDebugMode) {
        print('📤 VihicalDriverDetailApiController request: $body');

        print('📥 VihicalDriverDetailApiController response: ${response.body}');
      }

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          vihicalDriverDetailModel =
              vihicalDriverDetailModelFromJson(response.body);

          if (vihicalDriverDetailModel!.result == true) {
            update();

            if (kDebugMode) {
              print("✅ Driver detail loaded successfully with request_id");
            }

            return data;
          } else {
            showToastForDuration("${data["message"]}", 2);

            return data;
          }
        } else {
          if (kDebugMode) {
            print("❌ Driver detail API failed: ${data["message"]}");
          }

          showToastForDuration("${data["message"]}", 2);

          return data;
        }
      } else {
        showToastForDuration("Connection error. Please try again.", 2);

        return null;
      }
    }
  }
}
