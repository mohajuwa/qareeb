import 'package:get/get.dart';
import 'package:qareeb/app/controllers/location_controller.dart';
import 'package:qareeb/controllers/app_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // AppController should already be put in main before runApp
    if (!Get.isRegistered<AppController>()) {
      Get.put(AppController(), permanent: true);
    }
    Get.lazyPut(() => LocationController());
  }
}
