// lib/common_code/global_variables.dart
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qareeb/controllers/app_controller.dart';

// Get AppController instance
final appController = AppController.instance;

// ===========================================
// MAP RELATED GLOBALS - SAFE TO KEEP
// ===========================================
late GoogleMapController mapController;
Map<MarkerId, Marker> markers = {};
Map<MarkerId, Marker> markers11 = {};
Map<PolylineId, Polyline> polylines = {};
Map<PolylineId, Polyline> polylines11 = {};
List<LatLng> polylineCoordinates = [];
PolylinePoints polylinePoints = PolylinePoints();
PolylinePoints polylinePoints11 = PolylinePoints();

// ===========================================
// ROUTING DATA - SAFE TO KEEP
// ===========================================
List<PointLatLng> destinationlat = [];
List onlypass = [];
List<LatLng> destinationlong = [];
bool picanddrop = true;
var addresspickup;

// ===========================================
// BIDDING & VEHICLE DATA - SAFE TO KEEP
// ===========================================
List vehicle_bidding_driver = [];
List vehicle_bidding_secounde = [];

// ===========================================
// APP SETTINGS - SAFE TO KEEP
// ===========================================
bool buttontimer = false;
bool darkMode = false;
num priceyourfare = 0;
bool isControllerDisposed = false;
bool isanimation = false;
String mid = "";
String mroal = "";
int select1 = 0;
String globalcurrency = "";
num walleteamount = 0.00;

// Location for home
var lathomecurrent;
var longhomecurrent;

// Animation duration (safe primitive)
int durationInSeconds = 0;

// ===========================================
// MIGRATION HELPERS - Use these instead of removed globals
// ===========================================

// Replace: pickupcontroller
TextEditingController get pickupcontroller => appController.pickupController;

// Replace: dropcontroller
TextEditingController get dropcontroller => appController.dropController;

// Replace: latitudepick
double get latitudepick => appController.pickupLat.value;
set latitudepick(double value) => appController.pickupLat.value = value;

// Replace: longitudepick
double get longitudepick => appController.pickupLng.value;
set longitudepick(double value) => appController.pickupLng.value = value;

// Replace: latitudedrop
double get latitudedrop => appController.dropLat.value;
set latitudedrop(double value) => appController.dropLat.value = value;

// Replace: longitudedrop
double get longitudedrop => appController.dropLng.value;
set longitudedrop(double value) => appController.dropLng.value = value;

// Replace: picktitle
String get picktitle => appController.pickupTitle.value;
set picktitle(String value) => appController.pickupTitle.value = value;

// Replace: picksubtitle
String get picksubtitle => appController.pickupSubtitle.value;
set picksubtitle(String value) => appController.pickupSubtitle.value = value;

// Replace: droptitle
String get droptitle => appController.dropTitle.value;
set droptitle(String value) => appController.dropTitle.value = value;

// Replace: dropsubtitle
String get dropsubtitle => appController.dropSubtitle.value;
set dropsubtitle(String value) => appController.dropSubtitle.value = value;

// Replace: droptitlelist
List get droptitlelist => appController.dropTitleList;

// Replace: request_id
String get request_id => appController.requestId.value;
set request_id(String value) => appController.requestId.value = value;

// Socket access - use AppController's SocketService
bool get socketInitialized => appController.socketService.isConnected;

// ===========================================
// REFRESH DATA HELPER
// ===========================================
void resetAllRideData() {
  appController.resetAllRideData();

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
  destinationlat.clear();
  onlypass.clear();
  destinationlong.clear();
}

// ===========================================
// USAGE NOTES FOR MIGRATION
// ===========================================
/*
MIGRATION GUIDE:

OLD CODE:                           NEW CODE:
pickupcontroller.text = "test"   → appController.pickupController.text = "test"
latitudepick = 23.45            → appController.pickupLat.value = 23.45
request_id = "123"              → appController.requestId.value = "123"
socket.emit(...)                → appController.socketService.emit(...)

The getters/setters above provide backward compatibility during migration.
*/
