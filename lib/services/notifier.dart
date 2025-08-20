
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Notifier {
  static void success(String message, {String? title}) {
    Get.snackbar(
      title ?? 'OK'.tr,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      backgroundColor: Colors.green.withOpacity(0.1),
      duration: const Duration(seconds: 2),
    );
  }

  static void error(String message, {String? title}) {
    Get.snackbar(
      title ?? 'error_generic'.tr,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      backgroundColor: Colors.red.withOpacity(0.1),
      duration: const Duration(seconds: 3),
    );
  }

  static void info(String message, {String? title}) {
    Get.snackbar(
      title ?? 'app_name'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}
