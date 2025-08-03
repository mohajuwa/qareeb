import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'colore_screen.dart';

class ModernLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final String? customAnimation;
  final Color? backgroundColor;
  final bool showMessage;

  const ModernLoadingWidget({
    super.key,
    this.message,
    this.size = 100,
    this.customAnimation,
    this.backgroundColor,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColorNotifier>(context);

    // Debug print - separate from widget tree
    if (kDebugMode) {
      print(
          "Loading with animation: ${customAnimation ?? 'assets/lottie/loading.json'}");
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? notifier.containercolore.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Lottie.asset(
              customAnimation ?? 'assets/lottie/loading.json',
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                if (kDebugMode) {
                  print("Lottie loading error: $error");
                }
                // Fallback to a simple animated container
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theamcolore.withOpacity(0.2),
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(theamcolore),
                    strokeWidth: 3,
                  ),
                );
              },
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'SofiaRegular',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class ModernLoadingOverlay extends StatelessWidget {
  final String? message;
  final double size;
  final String? customAnimation;
  final bool dismissible;

  const ModernLoadingOverlay({
    super.key,
    this.message,
    this.size = 120,
    this.customAnimation,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: InkWell(
        onTap: dismissible ? () => Navigator.of(context).pop() : null,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: ModernLoadingWidget(
              message: message,
              size: size,
              customAnimation: customAnimation,
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function to show loading overlay
void showModernLoading({
  required BuildContext context,
  String? message,
  double size = 120,
  String? customAnimation,
  bool dismissible = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: dismissible,
    builder: (context) => ModernLoadingOverlay(
      message: message,
      size: size,
      customAnimation: customAnimation,
      dismissible: dismissible,
    ),
  );
}

void hideModernLoading(BuildContext context) {
  Navigator.of(context).pop();
}
