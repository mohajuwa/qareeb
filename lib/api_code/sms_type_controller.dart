import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/common_code/config.dart';
import '../api_model/sms_type_api_model.dart';
import '../common_code/common_button.dart'; // Assuming snackbar is defined here

class SmstypeApiController extends GetxController {
  SmaApiModel? smaApiModel;
  bool isLoading = true;

  Future<void> smsApi(BuildContext context) async {
    isLoading = true;
    update(); // Update UI to show loader immediately

    try {
      final response = await http.get(
        Uri.parse(Config.baseurl + Config.smstypeapi),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      // ✅ 1. Check for a successful status code FIRST.
      if (response.statusCode == 200) {
        // ✅ 2. Decode the JSON body only after confirming success.
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          smaApiModel = smaApiModelFromJson(response.body);
        } else {
          // Handle API-level errors (e.g., "Result": false)
          snackbar(
              context: context,
              text: data["message"]?.toString() ??
                  "An unknown API error occurred.");
        }
      } else {
        // ❌ Handle HTTP errors (e.g., 404 Not Found, 500 Server Error)
        snackbar(
            context: context, text: "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      // ❌ This catches any other error, like no internet connection or
      // if the server returns HTML instead of JSON (FormatException).
      print("Error in smsApi: $e"); // For your debugging
      snackbar(
          context: context,
          text: "Something went wrong. Please check your connection.");
    } finally {
      // ✅ 3. This block ALWAYS runs, ensuring the loading indicator is hidden.
      isLoading = false;
      update();
    }
  }
}
