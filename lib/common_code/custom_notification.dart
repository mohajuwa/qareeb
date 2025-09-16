// lib/common_code/custom_notification.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

enum NotificationType { success, error, info, warning }

class CustomNotification {
  static void show({
    BuildContext? context,
    required String message,
    NotificationType type = NotificationType.info,
    String? icon,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final ctx = context ?? Get.context;
    if (ctx == null) return;

    final theme = Theme.of(ctx);
    final isDark = theme.brightness == Brightness.dark;

    // Choose colors based on type
    Color bg;
    Color fg = isDark ? Colors.white : Colors.black;
    String? lottiePath;
    switch (type) {
      case NotificationType.success:
        bg = Colors.green.shade600;
        lottiePath = 'assets/lottie/payment_success.json';
        title ??= 'Success'.tr;
        break;
      case NotificationType.error:
        bg = Colors.red.shade400;
        lottiePath = 'assets/lottie/warning.json';
        title ??= 'Error'.tr;
        break;
      case NotificationType.warning:
        bg = Colors.orange.shade400;
        lottiePath = 'assets/lottie/warning.json';
        title ??= 'Warning'.tr;
        break;
      case NotificationType.info:
      default:
        bg = Colors.blue.shade700;
        lottiePath = 'assets/lottie/searching.json';
        title ??= 'Info'.tr;
        break;
    }

    // Fallback icon (app icon) if not provided
    final iconPath = icon ?? 'assets/logo.png';

    // Use Get.snackbar for overlay + custom content
    Get.snackbar(
      title,
      message.tr,
      backgroundColor: bg.withOpacity(isDark ? 0.9 : 0.95),
      colorText: fg,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 16,
      isDismissible: true,
      duration: duration,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInCubic,
      icon: Padding(
        padding: const EdgeInsetsDirectional.only(start: 8),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.15),
          radius: 18,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(iconPath, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
              return Icon(Icons.notifications, color: fg);
            }),
          ),
        ),
      ),
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8.0),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Lottie.asset(lottiePath, fit: BoxFit.contain),
            ),
          ),
          Expanded(
            child: Text(
              message.tr,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
