// lib/common_code/enhanced_modern_loading.dart

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

// Enhanced overlay with different positioning options
class ModernLoadingOverlay extends StatelessWidget {
  final String? message;
  final double size;
  final String? customAnimation;
  final bool dismissible;
  final Color? backgroundColor;
  final LoadingPosition position;

  const ModernLoadingOverlay({
    super.key,
    this.message,
    this.size = 120,
    this.customAnimation,
    this.dismissible = false,
    this.backgroundColor,
    this.position = LoadingPosition.center,
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
          child: _buildPositionedLoading(),
        ),
      ),
    );
  }

  Widget _buildPositionedLoading() {
    final Widget loadingWidget = ModernLoadingWidget(
      message: message,
      size: size,
      customAnimation: customAnimation,
      backgroundColor: backgroundColor,
    );

    switch (position) {
      case LoadingPosition.top:
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: loadingWidget,
          ),
        );
      case LoadingPosition.bottom:
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: loadingWidget,
          ),
        );
      case LoadingPosition.center:
      default:
        return Center(child: loadingWidget);
    }
  }
}

enum LoadingPosition { center, top, bottom }

// Enhanced loading service with different loading types
class LoadingService {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  // Full screen overlay loading
  static void showOverlay({
    required BuildContext context,
    String? message,
    double size = 120,
    String? customAnimation,
    bool dismissible = false,
    LoadingPosition position = LoadingPosition.center,
  }) {
    if (_isShowing) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => ModernLoadingOverlay(
        message: message,
        size: size,
        customAnimation: customAnimation,
        dismissible: dismissible,
        position: position,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isShowing = true;
  }

  // Dialog-based loading - FIXED METHOD NAME
  static void showLoadingDialog({
    required BuildContext context,
    String? message,
    double size = 120,
    String? customAnimation,
    bool dismissible = false,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: dismissible,
      builder: (BuildContext dialogContext) => ModernLoadingOverlay(
        message: message,
        size: size,
        customAnimation: customAnimation,
        dismissible: dismissible,
      ),
    );
  }

  // Bottom sheet loading
  static void showBottomSheet({
    required BuildContext context,
    String? message,
    double size = 100,
    String? customAnimation,
    bool dismissible = true,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: dismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: ModernLoadingWidget(
          message: message,
          size: size,
          customAnimation: customAnimation,
        ),
      ),
    );
  }

  // In-widget loading (for replacing CircularProgressIndicator)
  static Widget inline({
    String? message,
    double size = 60,
    String? customAnimation,
    Color? backgroundColor,
    bool showMessage = true,
  }) {
    return ModernLoadingWidget(
      message: message,
      size: size,
      customAnimation: customAnimation,
      backgroundColor: backgroundColor,
      showMessage: showMessage,
    );
  }

  // Hide any active loading
  static void hide(BuildContext context) {
    if (_isShowing && _overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowing = false;
    }

    // Also try to dismiss dialog-based loading
    try {
      Navigator.of(context).pop();
    } catch (e) {
      if (kDebugMode) {
        print("No dialog to dismiss: $e");
      }
    }
  }
}

enum LoadingType { dialog, overlay, bottomSheet }

// Direct replacements for CircularProgressIndicator
Widget modernCircularProgress({
  double size = 50,
  String? customAnimation,
  Color? color,
}) {
  return LoadingService.inline(
    size: size,
    customAnimation: customAnimation,
    backgroundColor: color ?? Colors.transparent,
    showMessage: false,
  );
}

// Specialized loading for different contexts
class ContextualLoading {
  // For API calls
  static Widget api({String message = "جاري التحميل..."}) {
    return LoadingService.inline(
      message: message,
      customAnimation: 'assets/lottie/loading_.json',
    );
  }

  // For map operations
  static Widget map({String message = "جاري تحضير الخريطة..."}) {
    return LoadingService.inline(
      message: message,
      customAnimation: 'assets/lottie/loading.json',
    );
  }

  // For payment operations
  static Widget payment({String message = "جاري معالجة الدفع..."}) {
    return LoadingService.inline(
      message: message,
      customAnimation: 'assets/lottie/payment_loading.json',
    );
  }

  // For driver search
  static Widget driverSearch({String message = "جاري البحث عن سائق..."}) {
    return LoadingService.inline(
      message: message,
      customAnimation: 'assets/lottie/search_loading.json',
    );
  }
}

// Loading button that shows loading state
class ModernLoadingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final String? loadingText;

  const ModernLoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height = 50,
    this.width,
    this.loadingText,
  });

  @override
  State<ModernLoadingButton> createState() => _ModernLoadingButtonState();
}

class _ModernLoadingButtonState extends State<ModernLoadingButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width ?? double.infinity,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? theamcolore,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: widget.isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.textColor ?? Colors.white,
                      ),
                    ),
                  ),
                  if (widget.loadingText != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      widget.loadingText!,
                      style: TextStyle(
                        color: widget.textColor ?? Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              )
            : Text(
                widget.text,
                style: TextStyle(
                  color: widget.textColor ?? Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// For Future operations that need loading
class FutureWithLoading<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final String? loadingMessage;
  final String? customAnimation;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  const FutureWithLoading({
    super.key,
    required this.future,
    required this.builder,
    this.loadingMessage,
    this.customAnimation,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: ModernLoadingWidget(
              message: loadingMessage,
              customAnimation: customAnimation,
            ),
          );
        }

        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error!) ??
              Center(
                child: Text(
                  'خطأ: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
        }

        return builder(context, snapshot.data as T);
      },
    );
  }
}
