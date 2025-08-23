import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/custom_notification.dart';

void showToastForDuration(String message, int durationInSeconds) {
  // ✅ Show single notification instead of repeating timer
  CustomNotification.show(
      message: message.tr, // ✅ Added .tr for Arabic
      type: NotificationType.info);

  if (kDebugMode) {
    print("📱 Toast shown: ${message.tr}");
  }
}
