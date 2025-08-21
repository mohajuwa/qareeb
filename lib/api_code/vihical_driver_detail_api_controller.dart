import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/common_code/config.dart';
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
    int maxRetries = 3,
  }) async {
    Map body = {
      "uid": uid,
      "d_id": d_id,
      "request_id": request_id,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    print('+ + + + + VihicalDriverDetailApiController + + + + + + :--- $body');

    // Retry loop
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        var response = await http.post(
          Uri.parse(Config.baseurl + Config.vihicaldriverdetail),
          body: jsonEncode(body),
          headers: userHeader,
        );

        print(
            '- - - - - VihicalDriverDetailApiController - - - - - - :--- ${response.body}');

        var data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          if (data["Result"] == true) {
            vihicalDriverDetailModel =
                vihicalDriverDetailModelFromJson(response.body);
            if (vihicalDriverDetailModel!.result == true) {
              update();
              showToastForDuration("${data["message"]}", 2);
              return data;
            } else {
              showToastForDuration("${data["message"]}", 2);
              return data;
            }
          } else {
            // Check if this is a timing issue (recent request found but not in cart)
            if (data["debug"] != null &&
                data["debug"]["recent_request_records"] != null &&
                data["debug"]["recent_request_records"].isNotEmpty &&
                attempt < maxRetries) {
              print(
                  "⏳ Timing issue detected on attempt $attempt, retrying in ${attempt}s...");
              await Future.delayed(Duration(seconds: attempt));
              continue; // Retry
            }

            // If it's the last attempt or no timing issue, return the result
            showToastForDuration("${data["message"]}", 2);
            return data;
          }
        } else {
          if (attempt < maxRetries) {
            print(
                "❌ HTTP ${response.statusCode} on attempt $attempt, retrying...");
            await Future.delayed(Duration(seconds: attempt));
            continue;
          } else {
            showToastForDuration("Something went wrong!.....", 2);
            return {"Result": false, "message": "Network error"};
          }
        }
      } catch (e) {
        print("❌ Exception on attempt $attempt: $e");
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
          continue;
        } else {
          showToastForDuration("Connection error!.....", 2);
          return {"Result": false, "message": "Connection error"};
        }
      }
    }
  }
}
