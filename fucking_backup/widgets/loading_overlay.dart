
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget? child;
  const LoadingOverlay({super.key, this.isLoading = true, this.child});

  @override
  Widget build(BuildContext context) {
    if (!isLoading && child != null) return child!;
    return Center(
      child: Lottie.asset('assets/lottie/loading.json', width: 160, height: 160),
    );
  }
}
