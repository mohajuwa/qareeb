import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static void showToast(
    String message, {
    ToastType type = ToastType.info,
    int timeInSecForIosWeb = 3,
    BuildContext? context,
  }) {
    try {
      if (context != null) {
        // Use context-based toastification
        toastification.show(
          context: context,
          title: Text(message),
          autoCloseDuration: Duration(seconds: timeInSecForIosWeb),
          type: _getToastificationType(type),
          style: ToastificationStyle.flat,
          showProgressBar: false,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: lowModeShadow,
          direction: TextDirection.ltr,
          animationDuration: const Duration(milliseconds: 300),
        );
      } else {
        // Fallback - print to console
        if (kDebugMode) {
          print('Toast [$type]: $message');
        }
      }
    } catch (e) {
      // Ultimate fallback
      if (kDebugMode) {
        print('Toast Error: $e - Message: $message');
      }
    }
  }

  static ToastificationType _getToastificationType(ToastType type) {
    switch (type) {
      case ToastType.error:
        return ToastificationType.error;
      case ToastType.success:
        return ToastificationType.success;
      case ToastType.warning:
        return ToastificationType.warning;
      case ToastType.info:
        return ToastificationType.info;
    }
  }
}

enum ToastType { info, success, error, warning }
