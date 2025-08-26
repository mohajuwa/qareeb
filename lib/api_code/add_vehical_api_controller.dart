// ========================================
// ENHANCED Flutter API Controller: AddVihicalCalculateController
// ========================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/utils/show_toast.dart';
import '../common_code/config.dart';
import '../api_model/add_vihical_api_model.dart';

class AddVihicalCalculateController extends GetxController
    implements GetxService {
  AddVihicalCalculateModel? addVihicalCalculateModel;
  bool isLoading = false;

  // ✅ ENHANCED API METHOD WITH COMPREHENSIVE ERROR HANDLING
  Future<Map<String, dynamic>?> addvihicalcalculateApi({
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
  }) async {
    // Enhanced data validation before sending request

    if (uid.isEmpty) {
      showToastForDuration('User ID is required'.tr, 3);

      return null;
    }

    if (driverid.isEmpty) {
      showToastForDuration('No drivers available'.tr, 3);

      return null;
    }

    if (vehicle_id.isEmpty) {
      showToastForDuration('Vehicle selection is required'.tr, 3);

      return null;
    }

    if (pickup.isEmpty || drop.isEmpty) {
      showToastForDuration('Pickup and drop locations are required'.tr, 3);

      return null;
    }

    // Validate numeric values

    double? priceValue = double.tryParse(price);

    if (priceValue == null || priceValue < 0) {
      showToastForDuration('Invalid price value'.tr, 3);

      return null;
    }

    double? kmValue = double.tryParse(tot_km);

    if (kmValue == null || kmValue < 0) {
      showToastForDuration('Invalid distance value'.tr, 3);

      return null;
    }

    int? hourValue = int.tryParse(tot_hour);

    if (hourValue == null || hourValue < 0) {
      showToastForDuration('Invalid hour value'.tr, 3);

      return null;
    }

    int? minuteValue = int.tryParse(tot_minute);

    if (minuteValue == null || minuteValue < 0) {
      showToastForDuration('Invalid minute value'.tr, 3);

      return null;
    }

    // Enhanced request body with proper validation

    Map<String, dynamic> body = {
      "uid": uid.trim(),
      "driverid": driverid
          .where((id) => id != null && id.toString().isNotEmpty)
          .toList(),
      "price": priceValue.toStringAsFixed(2),
      "tot_km": kmValue.toStringAsFixed(2),
      "pickup": pickup.trim(),
      "drop": drop.trim(),
      "droplist": droplist
          .where((item) => item != null && item.toString().isNotEmpty)
          .toList(),
      "pickupadd": _validateAddressObject(pickupadd),
      "dropadd": _validateAddressObject(dropadd),
      "droplistadd": _validateAddressList(droplistadd),

      // FIXED: Convert to strings
      "tot_hour": hourValue.toString(), // Changed from hourValue
      "tot_minute": minuteValue.toString(), // Changed from minuteValue

      "vehicle_id": vehicle_id.trim(),
      "payment_id": payment_id.trim().isEmpty ? "9" : payment_id.trim(),
      "m_role": m_role.trim(),
      "coupon_id": coupon_id.trim().isEmpty ? null : coupon_id.trim(),
      "bidd_auto_status": bidd_auto_status,
    };
// ADDITIONAL DEBUG: Add this before sending the request

    if (kDebugMode) {
      print('🔍 Validating address data:');

      print('   pickupadd: ${body["pickupadd"]}');

      print('   dropadd: ${body["dropadd"]}');

      print('   droplistadd length: ${body["droplistadd"].length}');

      print('   droplist length: ${body["droplist"].length}');
    }

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

      // Enhanced HTTP request with retry logic

      var response =
          await _makeRequestWithRetry(body, userHeader, maxRetries: 3);

      if (kDebugMode) {
        print('✅ AddVihicalCalCulate Response Status: ${response.statusCode}');

        print('✅ AddVihicalCalCulate Response Body: ${response.body}');
      }

      // Enhanced response parsing

      Map<String, dynamic> data;

      try {
        data = jsonDecode(response.body);
      } catch (parseError) {
        if (kDebugMode) {
          print('❌ JSON Parse Error: $parseError');

          print('❌ Raw Response: ${response.body}');
        }

        if (response.body.contains('504') || response.body.contains('<html>')) {
          showToastForDuration('Server timeout. Please try again.'.tr, 3);

          throw Exception('Server timeout - please try again');
        } else {
          showToastForDuration('Invalid server response'.tr, 3);

          throw Exception('Invalid server response format');
        }
      }

      isLoading = false;

      update();

      // Enhanced status handling
      if (droplist.length != droplistadd.length) {
        showToastForDuration('Location data mismatch. Please try again.'.tr, 3);
        return null;
      }
      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          addVihicalCalculateModel =
              addVihicalCalculateModelFromJson(response.body);

          if (addVihicalCalculateModel!.result == true) {
            showToastForDuration("${data["message"]}", 2);

            if (kDebugMode) {
              print(
                  '🎉 AddVihicalCalCulate Success: Request ID ${addVihicalCalculateModel!.id}');
            }

            return data;
          } else {
            _handleApiError(data["message"]);

            return data;
          }
        } else {
          _handleApiError(data["message"]);

          return data;
        }
      } else {
        _handleHttpError(response.statusCode, data);

        throw Exception('Server error - status ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;

      update();

      if (kDebugMode) print('❌ AddVihicalCalCulate API Error: $e');

      _handleException(e);

      rethrow;
    }
  }

  // Helper method to validate address objects

  Map<String, dynamic> _validateAddressObject(Map addressObj) {
    if (addressObj.isEmpty) {
      return {"title": "Location", "subt": "Not specified"};
    }

    // Ensure both title and subt have valid values

    String title = (addressObj["title"] ?? "").toString().trim();

    String subt = (addressObj["subt"] ?? "").toString().trim();

    // If subt is empty, use title or provide default

    if (subt.isEmpty) {
      subt = title.isNotEmpty ? title : "Not specified";
    }

    // If title is empty, provide default

    if (title.isEmpty) {
      title = "Location";
    }

    return {
      "title": title,
      "subt": subt,
    };
  }
  // Helper method to validate address list

  List<Map<String, dynamic>> _validateAddressList(List addressList) {
    if (addressList.isEmpty) return [];

    return addressList.map((addr) {
      if (addr is Map) {
        return {
          "title": (addr["title"] ?? "").toString().trim(),
          "subt": (addr["subt"] ?? "").toString().trim(),
        };
      }

      return {"title": addr.toString().trim(), "subt": ""};
    }).toList();
  }

  // Enhanced HTTP request with retry logic

  Future<http.Response> _makeRequestWithRetry(
      Map<String, dynamic> body, Map<String, String> headers,
      {int maxRetries = 3}) async {
    int attempt = 0;

    Duration delay = const Duration(seconds: 1);

    while (attempt < maxRetries) {
      try {
        attempt++;

        if (kDebugMode && attempt > 1) {
          print('🔄 Retry attempt $attempt/$maxRetries');
        }

        var response = await http
            .post(Uri.parse(Config.baseurl + Config.addvihicalcalculate),
                body: jsonEncode(body), headers: headers)
            .timeout(const Duration(seconds: 30));

        // If we get a successful response or a client error (4xx), don't retry

        if (response.statusCode < 500) {
          return response;
        }

        // If it's a server error (5xx) and we have retries left, continue

        if (attempt == maxRetries) {
          return response;
        }

        if (kDebugMode) {
          print(
              '⚠️ Server error ${response.statusCode}, retrying in ${delay.inSeconds}s...');
        }

        await Future.delayed(delay);

        delay = Duration(seconds: delay.inSeconds * 2); // Exponential backoff
      } catch (e) {
        if (attempt == maxRetries) {
          rethrow;
        }

        if (kDebugMode) {
          print('⚠️ Request failed: $e, retrying in ${delay.inSeconds}s...');
        }

        await Future.delayed(delay);

        delay = Duration(seconds: delay.inSeconds * 2);
      }
    }

    throw Exception('Max retries exceeded');
  }

  // Enhanced error handling

  void _handleApiError(String? message) {
    String errorMessage = message ?? "Unknown error occurred";

    if (errorMessage.contains('timeout') || errorMessage.contains('504')) {
      showToastForDuration("Server timeout. Please try again.".tr, 3);
    } else if (errorMessage.contains('zone') ||
        errorMessage.contains('service area')) {
      showToastForDuration("Location not in service area".tr, 3);
    } else if (errorMessage.contains('driver')) {
      showToastForDuration("No drivers available".tr, 3);
    } else if (errorMessage.contains('Licence Error')) {
      showToastForDuration("License validation failed. Contact support.".tr, 3);
    } else if (errorMessage.contains('Database insert failed')) {
      showToastForDuration("Server error. Please try again.".tr, 3);
    } else {
      showToastForDuration(errorMessage.tr, 3);
    }
  }

  void _handleHttpError(int statusCode, Map<String, dynamic>? data) {
    switch (statusCode) {
      case 400:
        showToastForDuration("Invalid request data".tr, 3);

        break;

      case 408:
        showToastForDuration("Request timeout. Please try again.".tr, 3);

        break;

      case 409:
        showToastForDuration(
            "Duplicate request. Please wait and try again.".tr, 3);

        break;

      case 500:
        showToastForDuration("Server error. Please try again.".tr, 3);

        break;

      case 502:
      case 503:
      case 504:
        showToastForDuration("Server temporarily unavailable".tr, 3);

        break;

      default:
        showToastForDuration(
            "Network error. Please check your connection.".tr, 3);
    }
  }

  void _handleException(dynamic e) {
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
  }

  // Method to check connectivity before making requests

  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
