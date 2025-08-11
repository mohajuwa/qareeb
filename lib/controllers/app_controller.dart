// lib/controllers/app_controller.dart - COMPLETE VERSION
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/socket_service.dart';

class AppController extends GetxController {
  static AppController get instance => Get.find();

  // ✅ MEMORY-SAFE CONTROLLERS (properly managed)
  final pickupController = TextEditingController();
  final dropController = TextEditingController();

  // ✅ RIDE STATE - ALL MISSING VARIABLES FROM MAP_SCREEN
  final RxDouble vehiclePrice = 0.0.obs;      // vihicalrice
  final RxString requestId = "".obs;          // request_id
  final RxString driverId = "".obs;           // driver_id
  final RxBool isLoading = false.obs;
  final RxString loadingMessage = "".obs;
  final RxInt selectedVehicleIndex = (-1).obs; // select
  final RxString vehicleName = "".obs;        // vihicalname
  final RxString vehicleImage = "".obs;       // vihicalimage
  final RxString vehicleId = "".obs;          // vehicle_id
  final RxDouble totalKm = 0.0.obs;           // totalkm
  final RxString totalTime = "".obs;          // tot_time
  final RxString totalHour = "".obs;          // tot_hour
  final RxString totalSecond = "".obs;        // tot_secound
  final RxBool loadingTimer = false.obs;      // loadertimer
  final RxBool otpStatus = false.obs;         // otpstatus
  final RxString timeIncreaseStatus = "".obs; // timeincressstatus
  final RxString extraTime = "".obs;          // extratime

  // ✅ ADDITIONAL RIDE VARIABLES
  final RxInt midSecond = 0.obs;              // midseconde
  final RxString statusRideStart = "".obs;    // statusridestart
  final RxString platformFee = "".obs;
  final RxString weatherCharge = "".obs;
  final RxString additionalTime = "".obs;
  final RxDouble finalTotal = 0.0.obs;
  final RxDouble couponTotal = 0.0.obs;
  final RxDouble additionalTotal = 0.0.obs;

  // ✅ LOCATION STATE
  final RxDouble pickupLat = 0.0.obs;         // latitudepick
  final RxDouble pickupLng = 0.0.obs;         // longitudepick
  final RxDouble dropLat = 0.0.obs;           // latitudedrop
  final RxDouble dropLng = 0.0.obs;           // longitudedrop
  final RxString pickupTitle = "".obs;        // picktitle
  final RxString pickupSubtitle = "".obs;     // picksubtitle
  final RxString dropTitle = "".obs;          // droptitle
  final RxString dropSubtitle = "".obs;       // dropsubtitle
  final RxList dropTitleList = [].obs;        // droptitlelist

  // ✅ DESTINATION LISTS
  final RxList<double> destinationLat = <double>[].obs; // destinationlat
  final RxList<double> destinationLng = <double>[].obs; // destinationlong
  final RxList<String> onlyPass = <String>[].obs;       // onlypass

  // ✅ USER STATE
  final RxString userId = "".obs;
  final RxString userName = "".obs;
  final RxMap userProfile = {}.obs;
  final RxString globalUserId = "".obs;       // useridgloable

  // ✅ DRIVER INFORMATION
  final RxString driverName = "".obs;
  final RxString driverVehicleNumber = "".obs;
  final RxString driverLanguage = "".obs;
  final RxString driverRating = "".obs;
  final RxString driverImage = "".obs;
  final RxBool driverIdLoader = false.obs;

  // ✅ PAYMENT VARIABLES
  final RxString paymentName = "".obs;
  final RxString selectedOption = "".obs;
  final RxString selectBoring = "".obs;
  final RxInt couponAmt = 0.obs;
  final RxString couponId = "".obs;
  final RxString couponName = "".obs;
  final RxString mainAmount = "".obs;
  final RxDouble walletAmount = 0.0.obs;

  // ✅ CURRENCY AND PRICING VARIABLES
  final RxString globalCurrency = "".obs;        // globalcurrency
  final RxDouble priceYourFare = 0.0.obs;        // priceyourfare - FIXED TYPE
  final RxString currencySymbol = "".obs;        // Currency symbol
  final RxString currencyCode = "".obs;          // Currency code

  // ✅ TIMER AND ANIMATION STATE
  final RxBool buttonTimer = false.obs;       // buttontimer
  final RxBool isAnimation = false.obs;       // isanimation
  final RxBool isControllerDisposed = false.obs; // isControllerDisposed
  final RxInt durationInSeconds = 0.obs;      // durationInSeconds (safe)

  // ✅ VEHICLE BIDDING VARIABLES
  final RxList<int> vehicleBiddingDriver = <int>[].obs;      // vehicle_bidding_driver
  final RxList<int> vehicleBiddingSecond = <int>[].obs;      // vehicle_bidding_secounde
  final RxList<int> driverIdList = <int>[].obs;              // drive_id_list

  // ✅ MAP AND MARKERS - FIXED TYPES
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Marker> markers11 = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxSet<Polyline> polylines11 = <Polyline>{}.obs;
  final RxList<LatLng> polylineCoordinates = <LatLng>[].obs;

  // ✅ SOCKET SERVICE
  final socketService = Get.put(SocketService(), permanent: true);

  // ✅ CENTRALIZED RESET METHOD
  void resetAllRideData() {
    if (kDebugMode) {
      print("🔄 Resetting ALL ride data via AppController");
    }

    // Reset ride state
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

    // Reset additional variables
    midSecond.value = 0;
    statusRideStart.value = "";
    platformFee.value = "";
    weatherCharge.value = "";
    additionalTime.value = "";
    finalTotal.value = 0.0;
    couponTotal.value = 0.0;
    additionalTotal.value = 0.0;

    // Reset location state
    pickupLat.value = 0.0;
    pickupLng.value = 0.0;
    dropLat.value = 0.0;
    dropLng.value = 0.0;
    pickupTitle.value = "";
    pickupSubtitle.value = "";
    dropTitle.value = "";
    dropSubtitle.value = "";
    dropTitleList.clear();

    // Reset destination lists
    destinationLat.clear();
    destinationLng.clear();
    onlyPass.clear();

    // Reset driver info
    driverName.value = "";
    driverVehicleNumber.value = "";
    driverLanguage.value = "";
    driverRating.value = "";
    driverImage.value = "";
    driverIdLoader.value = false;

    // Reset payment
    paymentName.value = "";
    selectedOption.value = "";
    selectBoring.value = "";
    couponAmt.value = 0;
    couponId.value = "";
    couponName.value = "";
    mainAmount.value = "";

    // Reset currency and pricing
    globalCurrency.value = "";
    priceYourFare.value = 0;
    currencySymbol.value = "";
    currencyCode.value = "";

    // Reset timer state
    buttonTimer.value = false;
    isAnimation.value = false;
    isControllerDisposed.value = false;
    durationInSeconds.value = 0;

    // Reset bidding
    vehicleBiddingDriver.clear();
    vehicleBiddingSecond.clear();
    driverIdList.clear();

    // Reset map data
    markers.clear();
    markers11.clear();
    polylines.clear();
    polylines11.clear();
    polylineCoordinates.clear();

    // Clear text controllers safely
    pickupController.clear();
    dropController.clear();

    if (kDebugMode) {
      print("✅ All ride data reset completed");
    }
  }

  // ✅ SAFE CONTROLLER DISPOSAL
  @override
  void onClose() {
    if (kDebugMode) {
      print("🗑️ AppController disposing...");
    }

    // Dispose text controllers safely
    pickupController.dispose();
    dropController.dispose();

    // Close socket service
    socketService.disconnect();

    super.onClose();
  }

  // ✅ HELPER METHODS FOR BACKWARD COMPATIBILITY

  // Getters for backward compatibility with existing code
  String get useridgloable => globalUserId.value;
  set useridgloable(String value) => globalUserId.value = value;

  double get vihicalrice => vehiclePrice.value;
  set vihicalrice(double value) => vehiclePrice.value = value;

  double get totalkm => totalKm.value;
  set totalkm(double value) => totalKm.value = value;

  String get tot_time => totalTime.value;
  set tot_time(String value) => totalTime.value = value;

  String get tot_hour => totalHour.value;
  set tot_hour(String value) => totalHour.value = value;

  String get tot_secound => totalSecond.value;
  set tot_secound(String value) => totalSecond.value = value;

  String get vihicalname => vehicleName.value;
  set vihicalname(String value) => vehicleName.value = value;

  String get vihicalimage => vehicleImage.value;
  set vihicalimage(String value) => vehicleImage.value = value;

  String get vehicle_id => vehicleId.value;
  set vehicle_id(String value) => vehicleId.value = value;

  String get request_id => requestId.value;
  set request_id(String value) => requestId.value = value;

  String get driver_id => driverId.value;
  set driver_id(String value) => driverId.value = value;

  bool get loadertimer => loadingTimer.value;
  set loadertimer(bool value) => loadingTimer.value = value;

  bool get otpstatus => otpStatus.value;
  set otpstatus(bool value) => otpStatus.value = value;

  int get select => selectedVehicleIndex.value;
  set select(int value) => selectedVehicleIndex.value = value;

  int get midseconde => midSecond.value;
  set midseconde(int value) => midSecond.value = value;

  String get extratime => extraTime.value;
  set extratime(String value) => extraTime.value = value;

  String get timeincressstatus => timeIncreaseStatus.value;
  set timeincressstatus(String value) => timeIncreaseStatus.value = value;

  // Location getters/setters
  double get latitudepick => pickupLat.value;
  set latitudepick(double value) => pickupLat.value = value;

  double get longitudepick => pickupLng.value;
  set longitudepick(double value) => pickupLng.value = value;

  double get latitudedrop => dropLat.value;
  set latitudedrop(double value) => dropLat.value = value;

  double get longitudedrop => dropLng.value;
  set longitudedrop(double value) => dropLng.value = value;

  String get picktitle => pickupTitle.value;
  set picktitle(String value) => pickupTitle.value = value;

  String get picksubtitle => pickupSubtitle.value;
  set picksubtitle(String value) => pickupSubtitle.value = value;

  String get droptitle => dropTitle.value;
  set droptitle(String value) => dropTitle.value = value;

  String get dropsubtitle => dropSubtitle.value;
  set dropsubtitle(String value) => dropSubtitle.value = value;

  List get droptitlelist => dropTitleList;

  List<double> get destinationlat => destinationLat;
  List<double> get destinationlong => destinationLng;
  List<String> get onlypass => onlyPass;

  // Text controller getters
  TextEditingController get pickupcontroller => pickupController;
  TextEditingController get dropcontroller => dropController;
}