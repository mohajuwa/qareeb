// lib/common_code/global_variables.dart
// Create this new file to hold all shared global variables

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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

// ===========================================
// PRICING RELATED GLOBALS
// ===========================================
var dropprice = 0.0;
var minimumfare = 0.0;
var maximumfare = 0.0;
String amountresponse = "";
String responsemessage = "";

// ===========================================
// REQUEST RELATED GLOBALS
// ===========================================
String request_id = "";

// ===========================================
// SOCKET RELATED GLOBALS
// ===========================================
bool socketInitialized = false;
late IO.Socket socket;

// ===========================================
// APP STATE GLOBALS
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
List vehicle_bidding_driver = [];
List vehicle_bidding_secounde = [];
num walleteamount = 0.00;

var lathomecurrent;
var longhomecurrent;
AnimationController? controller;
late Animation<Color?> colorAnimation;
int durationInSeconds = 0;

// ===========================================
// REFRESH DATA CLASS
// ===========================================

