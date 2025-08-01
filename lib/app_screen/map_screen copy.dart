// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math' as math;
// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_svg/svg.dart';

// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:lottie/lottie.dart' as lottie;
// import 'package:provider/provider.dart';
// import 'package:qareeb/common_code/toastification.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// // Import your existing files (adjust paths as needed)
// import 'package:qareeb/common_code/global_variables.dart';
// import 'package:qareeb/common_code/colore_screen.dart';
// import 'package:qareeb/common_code/common_button.dart';
// import 'package:qareeb/common_code/config.dart';

// class ModernMapScreen extends StatefulWidget {
//   final bool selectVehicle;
//   const ModernMapScreen({super.key, required this.selectVehicle});

//   @override
//   State<ModernMapScreen> createState() => _ModernMapScreenState();
// }

// class _ModernMapScreenState extends State<ModernMapScreen>
//     with TickerProviderStateMixin {
//   // Animation Controllers
//   late AnimationController _searchBarController;
//   late AnimationController _bottomSheetController;
//   late AnimationController _fabController;
//   late AnimationController _pulseController;

//   // Animations
//   late Animation<double> _searchBarAnimation;
//   late Animation<double> _bottomSheetAnimation;
//   late Animation<double> _fabAnimation;
//   late Animation<double> _pulseAnimation;

//   // Map Controllers
//   late GoogleMapController _mapController;
//   final Completer<GoogleMapController> _controller = Completer();

//   // Location & Coordinates
//   double? currentLat, currentLng;
//   double? pickupLat, pickupLng;
//   double? dropLat, dropLng;
//   String currentAddress = "Loading location...".tr;
//   String pickupAddress = "";
//   String dropAddress = "";

//   // Map Data
//   Set<Marker> markers = {};
//   Set<Polyline> polylines = {};
//   List<LatLng> polylineCoordinates = [];
//   PolylinePoints polylinePoints = PolylinePoints();

//   // UI State
//   bool isSearching = false;
//   bool isBottomSheetExpanded = false;
//   bool showRouteDetails = false;
//   int selectedVehicleIndex = 0;
//   double bottomSheetHeight = 320.0;

//   // Mock Data (Replace with your API data)
//   List<VehicleType> vehicleTypes = [];
//   List<DriverLocation> nearbyDrivers = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _initializeData();
//     _getCurrentLocation();
//   }

//   void _initializeAnimations() {
//     _searchBarController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _bottomSheetController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _fabController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _searchBarAnimation = CurvedAnimation(
//       parent: _searchBarController,
//       curve: Curves.elasticOut,
//     );

//     _bottomSheetAnimation = CurvedAnimation(
//       parent: _bottomSheetController,
//       curve: Curves.easeInOutCubic,
//     );

//     _fabAnimation = CurvedAnimation(
//       parent: _fabController,
//       curve: Curves.bounceOut,
//     );

//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );

//     // Start animations
//     _searchBarController.forward();
//     _fabController.forward();
//     _pulseController.repeat(reverse: true);
//   }

//   void _initializeData() {
//     vehicleTypes = [
//       VehicleType(
//         id: '1',
//         name: 'Qareeb Go',
//         icon: 'assets/images/car_economy.png',
//         basePrice: 15.0,
//         pricePerKm: 2.5,
//         eta: '2-4 min',
//         capacity: 4,
//         description: 'Affordable rides',
//       ),
//       VehicleType(
//         id: '2',
//         name: 'Qareeb Plus',
//         icon: 'assets/images/car_premium.png',
//         basePrice: 25.0,
//         pricePerKm: 3.5,
//         eta: '3-6 min',
//         capacity: 4,
//         description: 'Premium comfort',
//       ),
//       VehicleType(
//         id: '3',
//         name: 'Qareeb XL',
//         icon: 'assets/images/car_suv.png',
//         basePrice: 35.0,
//         pricePerKm: 4.5,
//         eta: '4-8 min',
//         capacity: 6,
//         description: 'Extra space',
//       ),
//     ];
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       setState(() {
//         currentLat = position.latitude;
//         currentLng = position.longitude;
//         pickupLat = position.latitude;
//         pickupLng = position.longitude;
//       });

//       await _getAddressFromCoordinates(position.latitude, position.longitude);
//       await _addCurrentLocationMarker();
//       await _moveMapToCurrentLocation();
//     } catch (e) {
//       if (kDebugMode) print('Error getting location: $e');
//     }
//   }

//   Future<void> _getAddressFromCoordinates(double lat, double lng) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks.first;
//         setState(() {
//           currentAddress = '${place.name}, ${place.locality}, ${place.country}';
//           if (pickupAddress.isEmpty) pickupAddress = currentAddress;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         currentAddress =
//             'Location: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
//       });
//     }
//   }

//   Future<void> _addCurrentLocationMarker() async {
//     if (currentLat == null || currentLng == null) return;

//     final Uint8List markerIcon = await _createCustomMarker(
//       'assets/current_location.png',
//       size: 100,
//     );

//     final marker = Marker(
//       markerId: const MarkerId('current_location'),
//       position: LatLng(currentLat!, currentLng!),
//       icon: BitmapDescriptor.fromBytes(markerIcon),
//       anchor: const Offset(0.5, 0.5),
//     );

//     setState(() {
//       markers.add(marker);
//     });
//   }

//   Future<Uint8List> _createCustomMarker(String assetPath,
//       {int size = 100}) async {
//     final ByteData data = await rootBundle.load(assetPath);
//     final ui.Codec codec = await ui.instantiateImageCodec(
//       data.buffer.asUint8List(),
//       targetWidth: size,
//       targetHeight: size,
//     );
//     final ui.FrameInfo frameInfo = await codec.getNextFrame();
//     final ByteData? byteData = await frameInfo.image.toByteData(
//       format: ui.ImageByteFormat.png,
//     );
//     return byteData!.buffer.asUint8List();
//   }

//   Future<void> _moveMapToCurrentLocation() async {
//     if (currentLat == null || currentLng == null) return;

//     final GoogleMapController controller = await _controller.future;
//     await controller.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: LatLng(currentLat!, currentLng!),
//           zoom: 16.0,
//           tilt: 45.0,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final notifier = Provider.of<ColorNotifier>(context);

//     return Scaffold(
//       body: Stack(
//         children: [
//           // Map
//           _buildMap(),

//           // Gradient Overlay
//           _buildGradientOverlay(),

//           // Search Bar
//           _buildAnimatedSearchBar(notifier),

//           // Floating Action Buttons
//           _buildFloatingActionButtons(notifier),

//           // Bottom Sheet
//           _buildBottomSheet(notifier),

//           // Loading Overlay
//           if (isSearching) _buildLoadingOverlay(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMap() {
//     return currentLat == null
//         ? Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 lottie.Lottie.asset(
//                   'assets/lottie/loading_map.json',
//                   width: 200,
//                   height: 200,
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Loading map...'.tr,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         : GoogleMap(
//             onMapCreated: (GoogleMapController controller) {
//               _controller.complete(controller);
//               _mapController = controller;
//               _applyMapStyle();
//             },
//             initialCameraPosition: CameraPosition(
//               target: LatLng(currentLat!, currentLng!),
//               zoom: 16.0,
//               tilt: 45.0,
//             ),
//             markers: markers,
//             polylines: polylines,
//             onTap: _onMapTap,
//             myLocationEnabled: false,
//             myLocationButtonEnabled: false,
//             zoomControlsEnabled: false,
//             compassEnabled: false,
//             buildingsEnabled: true,
//             trafficEnabled: false,
//             gestureRecognizers: {
//               Factory<OneSequenceGestureRecognizer>(
//                 () => EagerGestureRecognizer(),
//               ),
//             },
//           );
//   }

//   Widget _buildGradientOverlay() {
//     return IgnorePointer(
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.black.withOpacity(0.3),
//               Colors.transparent,
//               Colors.transparent,
//               Colors.black.withOpacity(0.4),
//             ],
//             stops: const [0.0, 0.2, 0.7, 1.0],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimatedSearchBar(ColorNotifier notifier) {
//     return Positioned(
//       top: MediaQuery.of(context).padding.top + 10,
//       left: 20,
//       right: 20,
//       child: AnimatedBuilder(
//         animation: _searchBarAnimation,
//         builder: (context, child) {
//           return Transform.translate(
//             offset: Offset(0, -50 * (1 - _searchBarAnimation.value)),
//             child: Opacity(
//               opacity: _searchBarAnimation.value
//                   .clamp(0.0, 1.0), // FIX: Clamp opacity
//               child: _buildSearchCard(notifier),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSearchCard(ColorNotifier notifier) {
//     return Container(
//       decoration: BoxDecoration(
//         color: notifier.containercolore,
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Pickup Location
//           _buildLocationRow(
//             icon: Icons.radio_button_checked,
//             iconColor: Colors.green,
//             text: pickupAddress.isEmpty ? currentAddress : pickupAddress,
//             isPickup: true,
//             notifier: notifier,
//           ),

//           // Divider with animated dots
//           _buildAnimatedDivider(),

//           // Drop Location
//           _buildLocationRow(
//             icon: Icons.location_on,
//             iconColor: Colors.red,
//             text: dropAddress.isEmpty ? "Where to?".tr : dropAddress,
//             isPickup: false,
//             notifier: notifier,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLocationRow({
//     required IconData icon,
//     required Color iconColor,
//     required String text,
//     required bool isPickup,
//     required ColorNotifier notifier,
//   }) {
//     return InkWell(
//       onTap: () => _showLocationPicker(isPickup),
//       borderRadius: BorderRadius.circular(25),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: iconColor.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: iconColor,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 15),
//             Expanded(
//               child: Text(
//                 text,
//                 style: TextStyle(
//                   color: notifier.textColor,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             if (isPickup && currentLat != null)
//               IconButton(
//                 onPressed: _getCurrentLocation,
//                 icon: Icon(
//                   Icons.my_location,
//                   color: Colors.blue,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimatedDivider() {
//     return Container(
//       height: 30,
//       child: Row(
//         children: [
//           const SizedBox(width: 35),
//           Container(width: 2, height: 15, color: Colors.grey.withOpacity(0.3)),
//           const SizedBox(width: 13),
//           Expanded(
//             child: Row(
//               children: List.generate(
//                 20,
//                 (index) => AnimatedBuilder(
//                   animation: _pulseController,
//                   builder: (context, child) {
//                     return Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 2),
//                       width: 4,
//                       height: 2,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.withOpacity(
//                           0.3 + (0.4 * _pulseAnimation.value),
//                         ),
//                         borderRadius: BorderRadius.circular(1),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFloatingActionButtons(ColorNotifier notifier) {
//     return Positioned(
//       right: 20,
//       top: MediaQuery.of(context).padding.top + 150,
//       child: Column(
//         children: [
//           // My Location Button
//           AnimatedBuilder(
//             animation: _fabAnimation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: _fabAnimation.value,
//                 child: _buildFAB(
//                   icon: Icons.my_location,
//                   onPressed: _getCurrentLocation,
//                   notifier: notifier,
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 15),

//           // Map Style Button
//           AnimatedBuilder(
//             animation: _fabAnimation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: _fabAnimation.value,
//                 child: _buildFAB(
//                   icon: Icons.layers,
//                   onPressed: _showMapStyleOptions,
//                   notifier: notifier,
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFAB({
//     required IconData icon,
//     required VoidCallback onPressed,
//     required ColorNotifier notifier,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: notifier.containercolore,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(30),
//           child: Container(
//             width: 56,
//             height: 56,
//             child: Icon(
//               icon,
//               color: notifier.textColor,
//               size: 24,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomSheet(ColorNotifier notifier) {
//     return AnimatedPositioned(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOutCubic,
//       bottom: 0,
//       left: 0,
//       right: 0,
//       height: bottomSheetHeight,
//       child: Container(
//         decoration: BoxDecoration(
//           color: notifier.containercolore,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(30),
//             topRight: Radius.circular(30),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 20,
//               offset: const Offset(0, -10),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             // Handle
//             Container(
//               margin: const EdgeInsets.only(top: 15, bottom: 10),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),

//             // Content
//             Expanded(
//               child: dropAddress.isEmpty
//                   ? _buildVehicleSelection(notifier)
//                   : _buildRouteDetails(notifier),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildVehicleSelection(ColorNotifier notifier) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 25),
//           child: Text(
//             'Choose a ride'.tr,
//             style: TextStyle(
//               color: notifier.textColor,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),

//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             itemCount: vehicleTypes.length,
//             itemBuilder: (context, index) {
//               final vehicle = vehicleTypes[index];
//               final isSelected = selectedVehicleIndex == index;

//               return AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () => setState(() => selectedVehicleIndex = index),
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? Colors.blue.withOpacity(0.1)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: isSelected
//                               ? Colors.blue
//                               : Colors.grey.withOpacity(0.2),
//                           width: isSelected ? 2 : 1,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           // Vehicle Icon
//                           Container(
//                             width: 60,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? Colors.blue.withOpacity(0.1)
//                                   : Colors.grey.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Center(
//                               child: Image.asset(
//                                 vehicle.icon,
//                                 width: 35,
//                                 height: 25,
//                                 color: isSelected ? Colors.blue : null,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 15),

//                           // Vehicle Info
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       vehicle.name,
//                                       style: TextStyle(
//                                         color: notifier.textColor,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       '${vehicle.basePrice.toInt()} YER',
//                                       style: TextStyle(
//                                         color: notifier.textColor,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 5),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       vehicle.description,
//                                       style: TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                     Text(
//                                       vehicle.eta,
//                                       style: TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),

//         // Book Button
//         Container(
//           padding: const EdgeInsets.all(20),
//           child: _buildBookButton(notifier),
//         ),
//       ],
//     );
//   }

//   Widget _buildRouteDetails(ColorNotifier notifier) {
//     return Column(
//       children: [
//         // Route Summary
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 20),
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Colors.blue.withOpacity(0.1),
//                 Colors.purple.withOpacity(0.1)
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildRouteStat('Distance', '5.2 km', Icons.straighten, notifier),
//               _buildRouteStat(
//                   'Duration', '12 min', Icons.access_time, notifier),
//               _buildRouteStat('Price', '25 YER', Icons.attach_money, notifier),
//             ],
//           ),
//         ),

//         const SizedBox(height: 20),

//         // Selected Vehicle
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 20),
//           child: _buildSelectedVehicleCard(notifier),
//         ),

//         const Spacer(),

//         // Confirm Button
//         Container(
//           padding: const EdgeInsets.all(20),
//           child: _buildConfirmButton(notifier),
//         ),
//       ],
//     );
//   }

//   Widget _buildRouteStat(
//       String label, String value, IconData icon, ColorNotifier notifier) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.blue, size: 24),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             color: notifier.textColor,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSelectedVehicleCard(ColorNotifier notifier) {
//     final vehicle = vehicleTypes[selectedVehicleIndex];

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.green.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.green, width: 2),
//       ),
//       child: Row(
//         children: [
//           Image.asset(vehicle.icon, width: 50, height: 35),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   vehicle.name,
//                   style: TextStyle(
//                     color: notifier.textColor,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '${vehicle.capacity} seats • ${vehicle.eta}',
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//           Icon(Icons.check_circle, color: Colors.green, size: 30),
//         ],
//       ),
//     );
//   }

//   Widget _buildBookButton(ColorNotifier notifier) {
//     return Container(
//       width: double.infinity,
//       height: 56,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF667eea).withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _bookRide,
//           borderRadius: BorderRadius.circular(28),
//           child: Center(
//             child: Text(
//               'Book ${vehicleTypes[selectedVehicleIndex].name}'.tr,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildConfirmButton(ColorNotifier notifier) {
//     return Container(
//       width: double.infinity,
//       height: 56,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF11998e).withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _confirmBooking,
//           borderRadius: BorderRadius.circular(28),
//           child: Center(
//             child: Text(
//               'Confirm Booking'.tr,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingOverlay() {
//     return Container(
//       color: Colors.black.withOpacity(0.5),
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.all(30),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               lottie.Lottie.asset(
//                 'assets/lottie/map_loading.json',
//                 width: 100,
//                 height: 100,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Finding your ride...'.tr,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Event Handlers
//   void _onMapTap(LatLng point) async {
//     await _getAddressFromCoordinates(point.latitude, point.longitude);

//     // Add marker for tapped location
//     final Uint8List markerIcon = await _createCustomMarker(
//       'assets/location_pin.png',
//       size: 80,
//     );

//     final marker = Marker(
//       markerId:
//           MarkerId('tapped_location_${DateTime.now().millisecondsSinceEpoch}'),
//       position: point,
//       icon: BitmapDescriptor.fromBytes(markerIcon),
//       onTap: () => _showLocationOptions(point),
//     );

//     setState(() {
//       markers.add(marker);
//     });
//   }

//   void _showLocationOptions(LatLng point) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(25),
//             topRight: Radius.circular(25),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ListTile(
//               leading:
//                   const Icon(Icons.radio_button_checked, color: Colors.green),
//               title: const Text('Set as pickup location'),
//               onTap: () {
//                 setState(() {
//                   pickupLat = point.latitude;
//                   pickupLng = point.longitude;
//                 });
//                 Navigator.pop(context);
//                 _getAddressFromCoordinates(point.latitude, point.longitude);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.location_on, color: Colors.red),
//               title: const Text('Set as drop location'),
//               onTap: () {
//                 setState(() {
//                   dropLat = point.latitude;
//                   dropLng = point.longitude;
//                   showRouteDetails = true;
//                   bottomSheetHeight = 400;
//                 });
//                 Navigator.pop(context);
//                 _getAddressFromCoordinates(point.latitude, point.longitude);
//                 _calculateRoute();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showLocationPicker(bool isPickup) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => LocationPickerSheet(
//         isPickup: isPickup,
//         onLocationSelected: (lat, lng, address) {
//           setState(() {
//             if (isPickup) {
//               pickupLat = lat;
//               pickupLng = lng;
//               pickupAddress = address;
//             } else {
//               dropLat = lat;
//               dropLng = lng;
//               dropAddress = address;
//               showRouteDetails = true;
//               bottomSheetHeight = 400;
//             }
//           });
//           if (!isPickup) _calculateRoute();
//         },
//       ),
//     );
//   }

//   void _showMapStyleOptions() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Map Style'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               title: const Text('Normal'),
//               onTap: () {
//                 _mapController.setMapStyle(null);
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Dark'),
//               onTap: () {
//                 _applyMapStyle();
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _applyMapStyle() async {
//     try {
//       final String style =
//           await rootBundle.loadString('assets/map_styles/dark_style.json');
//       await _mapController.setMapStyle(style);
//     } catch (e) {
//       if (kDebugMode) print('Error applying map style: $e');
//     }
//   }

//   Future<void> _calculateRoute() async {
//     if (pickupLat == null ||
//         pickupLng == null ||
//         dropLat == null ||
//         dropLng == null) return;

//     setState(() {
//       polylines.clear();
//     });

//     try {
//       PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         Config.mapkey, // Your Google Maps API key
//         PointLatLng(pickupLat!, pickupLng!),
//         PointLatLng(dropLat!, dropLng!),
//         travelMode: TravelMode.driving,
//       );

//       if (result.points.isNotEmpty) {
//         polylineCoordinates.clear();
//         for (var point in result.points) {
//           polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//         }

//         setState(() {
//           polylines.add(
//             Polyline(
//               polylineId: const PolylineId('route'),
//               color: const Color(0xFF667eea),
//               width: 6,
//               points: polylineCoordinates,
//               patterns: [PatternItem.dash(20), PatternItem.gap(10)],
//               startCap: Cap.roundCap,
//               endCap: Cap.roundCap,
//             ),
//           );
//         });

//         await _addRouteMarkers();
//         await _fitMapToRoute();
//       }
//     } catch (e) {
//       if (kDebugMode) print('Error calculating route: $e');
//     }
//   }

//   Future<void> _addRouteMarkers() async {
//     if (pickupLat == null || dropLat == null) return;

//     // Clear existing route markers
//     markers.removeWhere((marker) =>
//         marker.markerId.value == 'pickup' || marker.markerId.value == 'drop');

//     // Add pickup marker
//     final pickupIcon = await _createCustomMarker('assets/pickup_marker.png');
//     markers.add(
//       Marker(
//         markerId: const MarkerId('pickup'),
//         position: LatLng(pickupLat!, pickupLng!),
//         icon: BitmapDescriptor.fromBytes(pickupIcon),
//         infoWindow: InfoWindow(title: 'Pickup', snippet: pickupAddress),
//       ),
//     );

//     // Add drop marker
//     final dropIcon = await _createCustomMarker('assets/drop_marker.png');
//     markers.add(
//       Marker(
//         markerId: const MarkerId('drop'),
//         position: LatLng(dropLat!, dropLng!),
//         icon: BitmapDescriptor.fromBytes(dropIcon),
//         infoWindow: InfoWindow(title: 'Drop', snippet: dropAddress),
//       ),
//     );

//     setState(() {});
//   }

//   Future<void> _fitMapToRoute() async {
//     if (polylineCoordinates.isEmpty) return;

//     double minLat = polylineCoordinates.first.latitude;
//     double maxLat = polylineCoordinates.first.latitude;
//     double minLng = polylineCoordinates.first.longitude;
//     double maxLng = polylineCoordinates.first.longitude;

//     for (LatLng point in polylineCoordinates) {
//       minLat = math.min(minLat, point.latitude);
//       maxLat = math.max(maxLat, point.latitude);
//       minLng = math.min(minLng, point.longitude);
//       maxLng = math.max(maxLng, point.longitude);
//     }

//     await _mapController.animateCamera(
//       CameraUpdate.newLatLngBounds(
//         LatLngBounds(
//           southwest: LatLng(minLat, minLng),
//           northeast: LatLng(maxLat, maxLng),
//         ),
//         100.0, // padding
//       ),
//     );
//   }

//   void _bookRide() {
//     if (dropAddress.isEmpty) {
//       ToastService.showToast(
//         'Please select a destination'.tr,
//       );
//       return;
//     }

//     setState(() {
//       isSearching = true;
//     });

//     // Simulate booking process
//     Timer(const Duration(seconds: 3), () {
//       setState(() {
//         isSearching = false;
//         showRouteDetails = true;
//         bottomSheetHeight = 400;
//       });

//       ToastService.showToast(
//         'Ride booked successfully!'.tr,
//       );
//     });
//   }

//   void _confirmBooking() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Booking'),
//         content: const Text('Are you sure you want to book this ride?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _processBooking();
//             },
//             child: const Text('Confirm'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _processBooking() {
//     setState(() {
//       isSearching = true;
//     });

//     // Simulate booking confirmation
//     Timer(const Duration(seconds: 2), () {
//       setState(() {
//         isSearching = false;
//       });

//       // Navigate to ride tracking screen or show success
//       ToastService.showToast(
//         'Booking confirmed! Driver will arrive soon.'.tr,
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _searchBarController.dispose();
//     _bottomSheetController.dispose();
//     _fabController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }
// }

// // Supporting Classes
// class VehicleType {
//   final String id;
//   final String name;
//   final String icon;
//   final double basePrice;
//   final double pricePerKm;
//   final String eta;
//   final int capacity;
//   final String description;

//   VehicleType({
//     required this.id,
//     required this.name,
//     required this.icon,
//     required this.basePrice,
//     required this.pricePerKm,
//     required this.eta,
//     required this.capacity,
//     required this.description,
//   });
// }

// class DriverLocation {
//   final String id;
//   final double latitude;
//   final double longitude;
//   final String vehicleType;
//   final double rating;

//   DriverLocation({
//     required this.id,
//     required this.latitude,
//     required this.longitude,
//     required this.vehicleType,
//     required this.rating,
//   });
// }

// // Location Picker Bottom Sheet
// class LocationPickerSheet extends StatefulWidget {
//   final bool isPickup;
//   final Function(double, double, String) onLocationSelected;

//   const LocationPickerSheet({
//     super.key,
//     required this.isPickup,
//     required this.onLocationSelected,
//   });

//   @override
//   State<LocationPickerSheet> createState() => _LocationPickerSheetState();
// }

// class _LocationPickerSheetState extends State<LocationPickerSheet> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Placemark> searchResults = [];
//   bool isSearching = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.8,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(25),
//           topRight: Radius.circular(25),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Handle
//           Container(
//             margin: const EdgeInsets.only(top: 15, bottom: 20),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),

//           // Title
//           Text(
//             widget.isPickup ? 'Select Pickup Location' : 'Select Drop Location',
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 20),

//           // Search Field
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             decoration: BoxDecoration(
//               color: Colors.grey.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search for a location...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: isSearching
//                     ? const Padding(
//                         padding: EdgeInsets.all(12),
//                         child: SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                       )
//                     : null,
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 15,
//                 ),
//               ),
//               onChanged: _searchLocation,
//             ),
//           ),

//           const SizedBox(height: 20),

//           // Quick Options
//           if (!widget.isPickup) ...[
//             _buildQuickOption(
//               icon: Icons.home,
//               title: 'Home',
//               subtitle: 'Add your home address',
//               onTap: () {/* Add home logic */},
//             ),
//             _buildQuickOption(
//               icon: Icons.work,
//               title: 'Work',
//               subtitle: 'Add your work address',
//               onTap: () {/* Add work logic */},
//             ),
//           ],

//           // Search Results
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               itemCount: searchResults.length,
//               itemBuilder: (context, index) {
//                 final result = searchResults[index];
//                 return ListTile(
//                   leading: const Icon(Icons.location_on),
//                   title: Text(result.name ?? 'Unknown'),
//                   subtitle: Text(result.locality ?? ''),
//                   onTap: () {
//                     // Get coordinates and return
//                     Navigator.pop(context);
//                     widget.onLocationSelected(
//                       0.0, 0.0, // You'd get actual coordinates here
//                       result.name ?? 'Selected Location',
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickOption({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.blue.withOpacity(0.1),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: Colors.blue),
//       ),
//       title: Text(title),
//       subtitle: Text(subtitle),
//       onTap: onTap,
//     );
//   }

//   void _searchLocation(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         searchResults.clear();
//       });
//       return;
//     }

//     setState(() {
//       isSearching = true;
//     });

//     try {
//       // Simulate search delay
//       await Future.delayed(const Duration(milliseconds: 500));

//       // Here you would implement actual location search
//       // using Google Places API or similar service

//       setState(() {
//         isSearching = false;
//         // Add mock results for demonstration
//         searchResults = [
//           Placemark(name: query, locality: 'Sample Area 1'),
//           Placemark(name: '$query Center', locality: 'Sample Area 2'),
//         ];
//       });
//     } catch (e) {
//       setState(() {
//         isSearching = false;
//         searchResults.clear();
//       });
//     }
//   }
// }
