import 'package:flutter/material.dart';

import 'status_page.dart';

import 'network_service.dart';

class StatusHelper {
  static final StatusHelper _instance = StatusHelper._internal();

  factory StatusHelper() => _instance;

  StatusHelper._internal();

  // Show status page as dialog

  static void showStatusDialog(
    BuildContext context, {
    required StatusType statusType,
    String? customTitle,
    String? customSubtitle,
    VoidCallback? onRetry,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernStatusPage(
          statusType: statusType,
          customTitle: customTitle,
          customSubtitle: customSubtitle,
          onRetry: onRetry ?? () => Navigator.of(context).pop(),
          isFullScreen: false,
        ),
      ),
    );
  }

  // Show status page as full screen

  static void showStatusScreen(
    BuildContext context, {
    required StatusType statusType,
    String? customTitle,
    String? customSubtitle,
    VoidCallback? onRetry,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ModernStatusPage(
          statusType: statusType,
          customTitle: customTitle,
          customSubtitle: customSubtitle,
          onRetry: onRetry ?? () => Navigator.of(context).pop(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // Show bottom sheet status

  static void showStatusBottomSheet(
    BuildContext context, {
    required StatusType statusType,
    String? customTitle,
    String? customSubtitle,
    VoidCallback? onRetry,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: ModernStatusPage(
          statusType: statusType,
          customTitle: customTitle,
          customSubtitle: customSubtitle,
          onRetry: onRetry ?? () => Navigator.of(context).pop(),
          isFullScreen: false,
        ),
      ),
    );
  }

  // Check connection and show appropriate status

  static Future<bool> checkConnectionAndShow(
    BuildContext context, {
    VoidCallback? onRetry,
  }) async {
    if (!NetworkService().isConnected) {
      showStatusDialog(
        context,
        statusType: StatusType.noInternet,
        onRetry: onRetry ?? () => Navigator.of(context).pop(),
      );

      return false;
    }

    bool hasInternet = await NetworkService().hasInternetConnection();

    if (!hasInternet) {
      showStatusDialog(
        context,
        statusType: StatusType.noInternet,
        onRetry: onRetry ?? () => Navigator.of(context).pop(),
      );

      return false;
    }

    return true;
  }

  // Generic error handler

  static void handleError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    String errorMessage = error.toString().toLowerCase();

    StatusType statusType;

    if (errorMessage.contains('timeout') || errorMessage.contains('time')) {
      statusType = StatusType.timeout;
    } else if (errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      statusType = StatusType.noInternet;
    } else if (errorMessage.contains('server') ||
        errorMessage.contains('500')) {
      statusType = StatusType.serverError;
    } else {
      statusType = StatusType.error;
    }

    showStatusDialog(
      context,
      statusType: statusType,
      onRetry: onRetry,
    );
  }
}
