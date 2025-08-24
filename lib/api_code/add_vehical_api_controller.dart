// ========================================
// ENHANCED Flutter API Controller: AddVihicalCalculateController
// ========================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/utils/show_toast.dart';
import '../common_code/config.dart';
import '../api_model/add_vihical_api_model.dart';
import '../common_code/network_service.dart';

class AddVihicalCalculateController extends GetxController
    implements GetxService {
  AddVihicalCalculateModel? addVihicalCalculateModel;
  bool isLoading = false;

  // ✅ ENHANCED API METHOD WITH COMPREHENSIVE ERROR HANDLING
  Future addvihicalcalculateApi({
    context,
    required String uid,
    required String bidd_auto_status,
    required String payment_id,
    required String coupon_id,
    required String m_role,
    required String tot_km,
    required String vehicle_id,
    required String tot_hour,
    required String tot_minute,
    required List droplistadd,
    required Map dropadd,
    required Map pickupadd,
    required List driverid,
    required String price,
    required String pickup,
    required String drop,
    required List droplist,
  }) async {
    // ✅ INPUT VALIDATION
    if (driverid.isEmpty) {
      showToastForDuration("No drivers available".tr, 3);
      throw Exception("No drivers available");
    }

    if (uid.isEmpty || vehicle_id.isEmpty || price.isEmpty) {
      showToastForDuration("Missing required information".tr, 3);
      throw Exception("Missing required information");
    }

    // ✅ NETWORK CHECK
    if (!await NetworkService().hasInternetConnection()) {
      showToastForDuration('No internet connection available'.tr, 3);
      throw Exception('No internet connection available');
    }

    Map body = {
      "uid": uid,
      "driverid": driverid,
      "price": price,
      "tot_km": tot_km,
      "pickup": pickup,
      "drop": drop,
      "droplist": droplist ?? [],
      "pickupadd": pickupadd,
      "dropadd": dropadd,
      "droplistadd": droplistadd ?? [],
      "tot_hour": tot_hour,
      "tot_minute": tot_minute,
      "vehicle_id": vehicle_id,
      "payment_id": payment_id,
      "m_role": m_role,
      "coupon_id": coupon_id ?? "",
      "bidd_auto_status": bidd_auto_status,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    if (kDebugMode) {
      print('🚀 AddVihicalCalCulate Request Body: $body');
    }

    try {
      isLoading = true;
      update();

      // ✅ ENHANCED HTTP REQUEST WITH LONGER TIMEOUT
      var response = await http
          .post(Uri.parse(Config.baseurl + Config.addvihicalcalculate),
              body: jsonEncode(body), headers: userHeader)
          .timeout(
        const Duration(seconds: 60), // Increased timeout
        onTimeout: () {
          throw TimeoutException(
              'Request timed out. The server is taking longer than expected.',
              const Duration(seconds: 60));
        },
      );

      if (kDebugMode) {
        print('✅ AddVihicalCalCulate Response Status: ${response.statusCode}');
        print('✅ AddVihicalCalCulate Response Body: ${response.body}');
      }

      // ✅ ENHANCED RESPONSE PARSING
      var data;
      try {
        data = jsonDecode(response.body);
      } catch (parseError) {
        if (kDebugMode) {
          print('❌ JSON Parse Error: $parseError');
          print('❌ Raw Response: ${response.body}');
        }

        // Handle HTML error responses (like 504 Gateway Timeout)
        if (response.body.contains('504 Gateway Time-out') ||
            response.body.contains('<html>')) {
          showToastForDuration('Server timeout. Please try again.'.tr, 3);
          throw Exception('Server timeout - please try again');
        } else {
          showToastForDuration('Invalid server response'.tr, 3);
          throw Exception('Invalid server response format');
        }
      }

      // ✅ ENHANCED STATUS CODE HANDLING
      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          addVihicalCalculateModel =
              addVihicalCalculateModelFromJson(response.body);

          if (addVihicalCalculateModel!.result == true) {
            isLoading = false;
            update();

            showToastForDuration("${data["message"]}", 2);

            if (kDebugMode) {
              print(
                  '🎉 AddVihicalCalCulate Success: Request ID ${addVihicalCalculateModel!.id}');
            }

            return data;
          } else {
            isLoading = false;
            update();
            showToastForDuration("${data["message"]}", 3);
            return data;
          }
        } else {
          isLoading = false;
          update();

          String errorMessage = data["message"] ?? "Request failed";

          // ✅ SPECIFIC ERROR HANDLING
          if (errorMessage.contains('timeout') ||
              errorMessage.contains('504')) {
            showToastForDuration("Server timeout. Please try again.".tr, 3);
          } else if (errorMessage.contains('zone')) {
            showToastForDuration("Location not in service area".tr, 3);
          } else if (errorMessage.contains('driver')) {
            showToastForDuration("No drivers available".tr, 3);
          } else {
            showToastForDuration(errorMessage.tr, 3);
          }

          return data;
        }
      } else if (response.statusCode == 408 || response.statusCode == 504) {
        // Handle timeout status codes
        isLoading = false;
        update();
        showToastForDuration("Server timeout. Please try again.".tr, 3);
        throw Exception('Server timeout - status ${response.statusCode}');
      } else {
        isLoading = false;
        update();
        showToastForDuration("Server error. Please try again.".tr, 3);
        throw Exception('Server error - status ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
      update();

      if (kDebugMode) print('❌ AddVihicalCalCulate API Error: $e');

      // ✅ ENHANCED ERROR CATEGORIZATION
      if (e is TimeoutException) {
        showToastForDuration(
            'Request timed out. Please check your connection.'.tr, 3);
      } else if (e.toString().contains('SocketException')) {
        showToastForDuration(
            'Network error. Please check your connection.'.tr, 3);
      } else if (e.toString().contains('504') ||
          e.toString().contains('timeout')) {
        showToastForDuration('Server is busy. Please try again.'.tr, 3);
      } else {
        showToastForDuration('Something went wrong. Please try again.'.tr, 3);
      }

      rethrow;
    }
  }

  // ✅ NEW RETRY METHOD
  Future<Map<String, dynamic>?> retryAddVihicalCalculate({
    required context,
    required String uid,
    required String bidd_auto_status,
    required String payment_id,
    required String coupon_id,
    required String m_role,
    required String tot_km,
    required String vehicle_id,
    required String tot_hour,
    required String tot_minute,
    required List droplistadd,
    required Map dropadd,
    required Map pickupadd,
    required List driverid,
    required String price,
    required String pickup,
    required String drop,
    required List droplist,
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (kDebugMode) {
          print(
              '🔄 Retry attempt $attempt/$maxRetries for AddVihicalCalCulate');
        }

        final result = await addvihicalcalculateApi(
          context: context,
          uid: uid,
          bidd_auto_status: bidd_auto_status,
          payment_id: payment_id,
          coupon_id: coupon_id,
          m_role: m_role,
          tot_km: tot_km,
          vehicle_id: vehicle_id,
          tot_hour: tot_hour,
          tot_minute: tot_minute,
          droplistadd: droplistadd,
          dropadd: dropadd,
          pickupadd: pickupadd,
          driverid: driverid,
          price: price,
          pickup: pickup,
          drop: drop,
          droplist: droplist,
        );

        if (kDebugMode) {
          print('✅ AddVihicalCalCulate succeeded on attempt $attempt');
        }

        return result;
      } catch (e) {
        if (kDebugMode) {
          print('❌ AddVihicalCalCulate attempt $attempt failed: $e');
        }

        if (attempt == maxRetries) {
          if (kDebugMode) {
            print('💥 All retry attempts failed for AddVihicalCalCulate');
          }
          rethrow;
        }

        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    return null;
  }

  // ✅ NEW HEALTH CHECK METHOD
  Future<bool> checkApiHealth() async {
    try {
      final response = await http
          .get(Uri.parse('${Config.baseurl}/health'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('❌ API health check failed: $e');
      return false;
    }
  }
}
