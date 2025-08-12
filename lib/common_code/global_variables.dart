// lib/common_code/global_variables.dart - CLEANED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qareeb/common_code/daynamic_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../controllers/app_controller.dart';

// ✅ GET APPCONTROLLER INSTANCE FOR MIGRATION
final appController = AppController.instance;

// ===========================================
// DEPRECATED GLOBALS - TO BE REMOVED AFTER MIGRATION
// ===========================================
// ⚠️ These are kept temporarily for backward compatibility
// Remove these once all files are migrated to AppController

@Deprecated('Use AppController.instance instead')
var useridgloable;

@Deprecated('Use AppController.vehiclePrice instead')
double vihicalrice = 0.00;

@Deprecated('Use AppController.totalKm instead')
double totalkm = 0.00;

@Deprecated('Use AppController.totalTime instead')
String tot_time = "";

@Deprecated('Use AppController.totalHour instead')
String tot_hour = "";

@Deprecated('Use AppController.totalSecond instead')
String tot_secound = "";

@Deprecated('Use AppController.vehicleName instead')
String vihicalname = "";

@Deprecated('Use AppController.vehicleImage instead')
String vihicalimage = "";

@Deprecated('Use AppController.vehicleId instead')
String vehicle_id = "";

@Deprecated('Use AppController.extraTime instead')
String extratime = "";

@Deprecated('Use AppController.timeIncreaseStatus instead')
String timeincressstatus = "";

@Deprecated('Use AppController.requestId instead')
String request_id = "";

@Deprecated('Use AppController.driverId instead')
String driver_id = "";

@Deprecated('Use AppController.loadingTimer instead')
bool loadertimer = false;

@Deprecated('Use AppController.otpStatus instead')
bool otpstatus = false;

@Deprecated('Use AppController.selectedVehicleIndex instead')
int select = -1;

@Deprecated('Use AppController.midSecond instead')
int midseconde = 0;

// ===========================================
// SAFE GLOBALS - Keep these (primitives and non-memory leak risks)
// ===========================================

// Theme and UI state
bool darkMode = false;
bool light = false;
List<DynamicWidget> textfieldlist = [];

// API response states
String amountresponse = "";
String responsemessage = "";

// Map data (safe collections)
Set<Marker> markers = {};
Set<Marker> markers11 = {};
Map<PolylineId, Polyline> polylines = {};
Set<Polyline> polylines11 = {};
List<LatLng> polylineCoordinates = [];

// Timer and animation state (safe primitives)
bool buttontimer = false;
bool isControllerDisposed = false;
bool isanimation = false;

// Misc variables (safe)
String mid = "";
String mroal = "";
int select1 = 0;

// Bidding arrays (safe when properly managed)
List vehicle_bidding_driver = [];
List<int> vehicle_bidding_secounde = [];

// Location for home (safe primitives)
var lathomecurrent;
var longhomecurrent;

// Socket instance (managed carefully)
late IO.Socket socket;

// Wallet amount (safe primitive)
double walleteamount = 0.00;

// ===========================================
// MIGRATION HELPERS - BACKWARD COMPATIBILITY
// ===========================================

// ✅ These getters/setters provide backward compatibility during migration
// Replace usage gradually with AppController.instance
// MIGRATION HELPERS - BACKWARD COMPATIBILITY

// Location helpers
double get latitudepick => appController.pickupLat.value;
set latitudepick(double value) => appController.pickupLat.value = value;

double get longitudepick => appController.pickupLng.value;
set longitudepick(double value) => appController.pickupLng.value = value;

double get latitudedrop => appController.dropLat.value;
set latitudedrop(double value) => appController.dropLat.value = value;

double get longitudedrop => appController.dropLng.value;
set longitudedrop(double value) => appController.dropLng.value = value;

String get picktitle => appController.pickupTitle.value;
set picktitle(String value) => appController.pickupTitle.value = value;

String get picksubtitle => appController.pickupSubtitle.value;
set picksubtitle(String value) => appController.pickupSubtitle.value = value;

String get droptitle => appController.dropTitle.value;
set droptitle(String value) => appController.dropTitle.value = value;

String get dropsubtitle => appController.dropSubtitle.value;
set dropsubtitle(String value) => appController.dropSubtitle.value = value;

// RxList setters use assignAll to update contents, not replace the object
List get droptitlelist => appController.dropTitleList;
set droptitlelist(List value) => appController.dropTitleList.assignAll(value);

List<PointLatLng> get destinationlat => appController.destinationLat;
set destinationlat(List<PointLatLng> value) =>
    appController.destinationLat.assignAll(value);

List<double> get destinationlong => appController.destinationLng;
set destinationlong(List<double> value) =>
    appController.destinationLng.assignAll(value);

// TextEditingController getters only, no setters (final fields)
TextEditingController get pickupcontroller => appController.pickupController;
TextEditingController get dropcontroller => appController.dropController;

// Socket helper
bool get socketInitialized => appController.socketService.isConnected;
// ===========================================
// CENTRALIZED RESET FUNCTION
// ===========================================
void resetAllRideData() {
  if (Get.isRegistered<AppController>()) {
    appController.resetAllRideData();
  }

  // Reset safe globals
  buttontimer = false;
  isControllerDisposed = false;
  isanimation = false;
  mid = "";
  mroal = "";
  select1 = 0;
  vehicle_bidding_driver.clear();
  vehicle_bidding_secounde.clear();

  // Clear map data
  markers.clear();
  markers11.clear();
  polylines.clear();
  polylines11.clear();
  polylineCoordinates.clear();

  print("✅ Global variables reset completed");
}
