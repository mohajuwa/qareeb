// lib/controllers/app_controller.dart
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class AppController extends GetxController {
  static AppController get instance => Get.find();

  // Controllers that were causing memory leaks
  final pickupController = TextEditingController();
  final dropController = TextEditingController();

  // Ride state - REPLACE ALL GLOBAL VARIABLES
  final RxDouble vehiclePrice = 0.0.obs;
  final RxString requestId = "".obs;
  final RxString driverId = "".obs;
  final RxBool isLoading = false.obs;
  final RxString loadingMessage = "".obs;
  final RxInt selectedVehicleIndex = (-1).obs;
  final RxString vehicleName = "".obs;
  final RxString vehicleImage = "".obs;
  final RxString vehicleId = "".obs;
  final RxDouble totalKm = 0.0.obs;
  final RxString totalTime = "".obs;
  final RxString totalHour = "".obs;
  final RxString totalSecond = "".obs;
  final RxBool loadingTimer = false.obs;
  final RxBool otpStatus = false.obs;
  final RxString timeIncreaseStatus = "".obs;
  final RxString extraTime = "".obs;

  // Location state
  final RxDouble pickupLat = 0.0.obs;
  final RxDouble pickupLng = 0.0.obs;
  final RxDouble dropLat = 0.0.obs;
  final RxDouble dropLng = 0.0.obs;
  final RxString pickupTitle = "".obs;
  final RxString pickupSubtitle = "".obs;
  final RxString dropTitle = "".obs;
  final RxString dropSubtitle = "".obs;
  final RxList dropTitleList = [].obs;

  // User state
  final RxString userId = "".obs;
  final RxString userName = "".obs;
  final RxMap userProfile = {}.obs;
  final RxString globalUserId = "".obs;

  // Socket service
  final socketService = Get.put(SocketService(), permanent: true);

  void resetAllRideData() {
    if (kDebugMode) {
      print("🔄 Resetting ALL ride data via AppController");
    }

    vehiclePrice.value = 0.0;
    requestId.value = "";
    driverId.value = "";
    isLoading.value = false;
    loadingMessage.value = "";
    selectedVehicleIndex.value = -1;
    vehicleName.value = "";
    vehicleImage.value = "";
    vehicleId.value = "";
    totalKm.value = 0.0;
    totalTime.value = "";
    totalHour.value = "";
    totalSecond.value = "";
    loadingTimer.value = false;
    otpStatus.value = false;
    timeIncreaseStatus.value = "";
    extraTime.value = "";

    // Reset location data
    pickupLat.value = 0.0;
    pickupLng.value = 0.0;
    dropLat.value = 0.0;
    dropLng.value = 0.0;
    pickupTitle.value = "";
    pickupSubtitle.value = "";
    dropTitle.value = "";
    dropSubtitle.value = "";
    dropTitleList.clear();

    // Clear controllers
    pickupController.clear();
    dropController.clear();
  }

  void showLoading(String message) {
    loadingMessage.value = message;
    isLoading.value = true;
  }

  void hideLoading() {
    isLoading.value = false;
    loadingMessage.value = "";
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print("🗑️ AppController disposing");
    }

    // Dispose controllers to prevent memory leaks
    pickupController.dispose();
    dropController.dispose();

    socketService.disconnect();
    super.onClose();
  }
}
