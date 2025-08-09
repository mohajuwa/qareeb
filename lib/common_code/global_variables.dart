// lib/common_code/global_variables.dart
// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ===========================================
// MAP RELATED GLOBALS
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
// LOCATION RELATED GLOBALS
// ===========================================
TextEditingController pickupcontroller = TextEditingController();
TextEditingController dropcontroller = TextEditingController();

double latitudepick = 0.00;
double longitudepick = 0.00;
double latitudedrop = 0.00;
double longitudedrop = 0.00;

String picktitle = "";
String picksubtitle = "";
String droptitle = "";
String dropsubtitle = "";
List droptitlelist = [];

List<PointLatLng> destinationlat = [];
List onlypass = [];
List<LatLng> destinationlong = [];

bool picanddrop = true;
var addresspickup;
var useridgloable;

// ===========================================
// PRICING RELATED GLOBALS
// ===========================================
var dropprice = 0.0;
var minimumfare = 0.0;
var maximumfare = 0.0;
String amountresponse = "";
String responsemessage = "";

// ===========================================
// APP STATE GLOBALS
// ===========================================
bool buttontimer = false;
bool darkMode = false;
num priceyourfare = 0;
String mid = "";
String mroal = "";
int select1 = 0;
String globalcurrency = "";
num walleteamount = 0.00;

var lathomecurrent;
var longhomecurrent;

var d_id;
String driver_id = "";
String price = "0";
String request_id = "";

// ===========================================
// REFRESH DATA CLASS
// ===========================================
class RefreshData {
  final bool shouldRefresh;
  RefreshData(this.shouldRefresh);
}
