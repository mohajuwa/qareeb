// ✅ UPDATED: lib/api_code/calculate_api_controller.dart

import 'package:qareeb/common_code/custom_notification.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // ✅ Added for kDebugMode

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../common_code/network_service.dart'; // ✅ Added network service
import '../api_model/calculate_api_model.dart';

class CalculateController extends GetxController implements GetxService {
  CalCulateModel? calCulateModel;
  bool isLoading = false; // ✅ Added loading state

  Future calculateApi(
      {context,
      required String uid,
      required String mid,
      required String mrole,
      required String pickup_lat_lon,
      required String drop_lat_lon,
      required List drop_lat_lon_list}) async {
    // ✅ NEW: Network check with Arabic error message
    if (!await NetworkService().hasInternetConnection()) {
      throw Exception(
          'No internet connection available. Please check your network and try again.'
              .tr);
    }

    Map body = {
      "uid": uid,
      "mid": mid,
      "mrole": mrole,
      "pickup_lat_lon": pickup_lat_lon,
      "drop_lat_lon": drop_lat_lon,
      "drop_lat_lon_list": drop_lat_lon_list,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    try {
      // ✅ NEW: Set loading state
      isLoading = true;
      update();

      var response = await http
          .post(Uri.parse(Config.baseurl + Config.calculate),
              body: jsonEncode(body), headers: userHeader)
          .timeout(
        const Duration(seconds: 10), // ✅ Added timeout
        onTimeout: () {
          throw Exception(
              'Request timed out. Please check your connection and try again.'
                  .tr);
        },
      );

      print('+ + + + + CalCulate + + + + + + :--- $body');
      print('- - - - - CalCulate - - - - - - :--- ${response.body}');

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          calCulateModel = calCulateModelFromJson(response.body);
          if (calCulateModel!.result == true) {
            isLoading = false;
            update();

            if (kDebugMode) {
              print("✅ Calculate API successful");
            }

            return data;
          } else {
            isLoading = false;
            update();

            // ✅ Arabic error message
            String errorMessage = data["message"] ?? "Calculation failed".tr;

            CustomNotification.show(
                message: errorMessage.tr, type: NotificationType.error);

            throw Exception(errorMessage);
          }
        } else {
          isLoading = false;
          update();

          // ✅ Arabic error message
          String errorMessage = data["message"] ?? "API request failed".tr;

          CustomNotification.show(
              message: errorMessage.tr, type: NotificationType.error);

          throw Exception(errorMessage);
        }
      } else {
        isLoading = false;
        update();

        // ✅ Arabic HTTP error message
        String errorMessage = "Server error. Please try again later.".tr;

        CustomNotification.show(
            message: errorMessage, type: NotificationType.error);

        throw Exception(
            'Server error (${response.statusCode}). Please try again later.'
                .tr);
      }
    } catch (e) {
      // ✅ Always reset loading state on error
      isLoading = false;
      update();

      if (kDebugMode) print('Calculate API Error: $e');
      rethrow; // Re-throw for StatusHelper to handle
    }
  }

  // ✅ NEW: Retry method for convenience
  Future<void> retryCalculateApi(
      {context,
      required String uid,
      required String mid,
      required String mrole,
      required String pickup_lat_lon,
      required String drop_lat_lon,
      required List drop_lat_lon_list}) async {
    try {
      await calculateApi(
        context: context,
        uid: uid,
        mid: mid,
        mrole: mrole,
        pickup_lat_lon: pickup_lat_lon,
        drop_lat_lon: drop_lat_lon,
        drop_lat_lon_list: drop_lat_lon_list,
      );
    } catch (e) {
      if (kDebugMode) print('Calculate API retry failed: $e');
      rethrow;
    }
  }
}

// ✅ EXAMPLE: How to use this in your MapScreen
// Replace your existing calculateApi calls with this pattern:

/*
try {
  // Show loading if needed
  StatusHelper.showStatusDialog(context,
    statusType: StatusType.loading,
    customTitle: "Calculating fare".tr,
    showRetryButton: false,
  );

  final result = await calculateController.calculateApi(
    context: context,
    uid: userid.toString(),
    mid: mid,
    mrole: mroal,
    pickup_lat_lon: "$latitudepick,$longitudepick",
    drop_lat_lon: "$latitudedrop,$longitudedrop",
    drop_lat_lon_list: onlypass,
  );

  // Hide loading
  if (Navigator.canPop(context)) Navigator.pop(context);

  // Process successful result
  // Your existing logic here...

} catch (e) {
  // Hide loading first
  if (Navigator.canPop(context)) Navigator.pop(context);

  // Show error with Arabic support
  StatusHelper.handleError(context, e, onRetry: () {
    Navigator.pop(context);
    // Retry the calculation
    _retryCalculation();
  });
}
*/
