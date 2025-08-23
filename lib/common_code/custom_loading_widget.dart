// lib/common_code/custom_loading_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final bool showOverlay;
  final Color backgroundColor;

  const CustomLoadingWidget({
    super.key,
    this.width = 80,
    this.height = 80,
    this.showOverlay = false,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    final loading = Lottie.asset(
      'assets/lottie/loading.json',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );

    if (showOverlay) {
      return Container(
        color: backgroundColor.withOpacity(0.3),
        child: Center(child: loading),
      );
    }
    return loading;
  }
}

class CustomLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const CustomLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
                child: CustomLoadingWidget(width: 100, height: 100)),
          ),
      ],
    );
  }
}
