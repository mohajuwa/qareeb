import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:get/get.dart';
import '../app_screen/map_screen.dart';

Future<void> initPlatformState({context}) async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(Config.oneSignel);
  bool permissionGranted =
      await OneSignal.Notifications.requestPermission(true);

  if (permissionGranted) {
    print("Notification permission granted.");
    Get.offAll(MapScreen(
      selectvihical: false,
    ));
  } else {
    print("Notification permission denied.");
  }
}
