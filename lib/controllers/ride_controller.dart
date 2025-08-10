import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../app_screen/pickup_drop_point.dart';
import '../app_screen/home_screen.dart';

class RideController extends GetxController {
  static RideController get instance => Get.find();

  void resetAllRideData() {
    if (kDebugMode) {
      print("--- 🔄 Resetting ALL ride data via GetX ---");
    }

    // Reset all variables from all screens
    midseconde = 0;
    select = -1;
    vihicalrice = 0.00;
    totalkm = 0.00;
    tot_time = "";
    tot_hour = "";
    tot_secound = "";
    vihicalname = "";
    vihicalimage = "";
    vehicle_id = "";
    extratime = "";
    timeincressstatus = "";
    request_id = "";
    driver_id = "";
    loadertimer = false;
    otpstatus = false;

    latitudepick = 0.00;
    longitudepick = 0.00;
    latitudedrop = 0.00;
    longitudedrop = 0.00;
    picktitle = "";
    picksubtitle = "";
    droptitle = "";
    dropsubtitle = "";
    droptitlelist.clear();
    destinationlat.clear();
    onlypass.clear();
    destinationlong.clear();

    pickupcontroller.clear();
    dropcontroller.clear();

    update(); // Refresh all GetX consumers
  }
}
