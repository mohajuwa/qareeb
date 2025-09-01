import 'package:flutter/cupertino.dart';
import 'package:qareeb/services/running_ride_monitor.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - check for running rides
        RunningRideMonitor.instance.checkNow();
        break;
      case AppLifecycleState.paused:
        // App went to background - can reduce monitoring frequency
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        RunningRideMonitor.instance.stopMonitoring();
        break;
      default:
        break;
    }
  }
}
