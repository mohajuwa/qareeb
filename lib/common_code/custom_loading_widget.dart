import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'colore_screen.dart';

import 'status_page.dart';

class CustomLoadingWidget extends StatelessWidget {
  final String? loadingText;

  final double size;

  final bool showAppLogo;

  const CustomLoadingWidget({
    super.key,
    this.loadingText,
    this.size = 50,
    this.showAppLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showAppLogo) {
      // Use the modern status page for app-wide loading

      return ModernStatusPage(
        statusType: StatusType.loading,
        customTitle: loadingText ?? "Loading...",
        showRetryButton: false,
        isFullScreen: false,
      );
    }

    // Simple loading indicator

    final notifier = Provider.of<ColorNotifier>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                notifier.isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          if (loadingText != null) ...[
            SizedBox(height: 16),
            Text(
              loadingText!,
              style: TextStyle(
                color: notifier.textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
