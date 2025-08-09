// lib/api_code/global_driver_accept_class_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/app_screen/driver_detail_screen.dart';
import 'package:qareeb/app_screen/home_screen.dart';
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/map_state.dart';
import 'package:qareeb/providers/pricing_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';
import 'package:qareeb/providers/socket_service.dart';
import '../common_code/global_variables.dart';

class GlobalDriverAcceptClass extends GetxController {
  // Request and driver data
  String request_id = "";
  String driver_id = "";
  String driver_name = "";
  String driver_phone = "";
  String driver_image = "";
  String driver_rating = "";
  String vehicle_type = "";
  String vehicle_number = "";
  String vehicle_color = "";
  double driver_lat = 0.0;
  double driver_lng = 0.0;

  // Ride status
  String ride_status = "";
  bool is_driver_accepted = false;
  bool is_ride_started = false;
  bool is_ride_completed = false;

  // Bidding data
  List<dynamic> vehicleBiddingDriver = [];
  List<dynamic> vehicleBiddingSecounds = [];
  bool buttonTimer = false;

  // Vehicle selection
  int select1 = 0;
  String mid = "";
  String mroal = "";

  // Getters
  String get requestId => request_id;
  String get driverId => driver_id;
  String get driverName => driver_name;
  String get driverPhone => driver_phone;
  String get driverImage => driver_image;
  String get driverRating => driver_rating;
  String get vehicleType => vehicle_type;
  String get vehicleNumber => vehicle_number;
  String get vehicleColor => vehicle_color;
  double get driverLat => driver_lat;
  double get driverLng => driver_lng;
  String get rideStatus => ride_status;
  bool get isDriverAccepted => is_driver_accepted;
  bool get isRideStarted => is_ride_started;
  bool get isRideCompleted => is_ride_completed;
  List<dynamic> get biddingDrivers => vehicleBiddingDriver;
  List<dynamic> get biddingSeconds => vehicleBiddingSecounds;
  bool get timerStatus => buttonTimer;
  int get selectedVehicle => select1;

  // Setters
  void setRequestId(String id) {
    request_id = id;
    update();
  }

  void setDriverData({
    required String id,
    required String name,
    required String phone,
    required String image,
    required String rating,
    required String vType,
    required String vNumber,
    required String vColor,
    required double lat,
    required double lng,
  }) {
    driver_id = id;
    driver_name = name;
    driver_phone = phone;
    driver_image = image;
    driver_rating = rating;
    vehicle_type = vType;
    vehicle_number = vNumber;
    vehicle_color = vColor;
    driver_lat = lat;
    driver_lng = lng;
    update();
  }

  void setRideStatus(String status) {
    ride_status = status;
    update();
  }

  void setDriverAccepted(bool accepted) {
    is_driver_accepted = accepted;
    update();
  }

  void setRideStarted(bool started) {
    is_ride_started = started;
    update();
  }

  void setRideCompleted(bool completed) {
    is_ride_completed = completed;
    update();
  }

  void updateVehicleBiddingDriver(List<dynamic> drivers) {
    vehicleBiddingDriver = drivers;
    update();
  }

  void updateVehicleBiddingSeconds(List<dynamic> seconds) {
    vehicleBiddingSecounds = seconds;
    update();
  }

  void setButtonTimer(bool status) {
    buttonTimer = status;
    update();
  }

  void setSelectedVehicle(int index) {
    select1 = index;
    update();
  }

  void setMidAndRole(String midValue, String roleValue) {
    mid = midValue;
    mroal = roleValue;
    update();
  }

// ✅ LEGACY FUNCTION TO MAINTAIN COMPATIBILITY WITH OLD CALLS
  void driverdetailfunction({
    required dynamic context,
    required double lat,
    required double long,
    required String d_id,
    required String request_id,
  }) {
    try {
      if (kDebugMode) {
        print("=== Legacy Driver Detail Function Called ===");
        print("Driver ID: $d_id");
        print("Request ID: $request_id");
        print("Location: $lat, $long");
      }

      // Set the global variables
      this.request_id = request_id;
      driver_id = d_id;

      // Update global variables

      // Set driver as accepted
      setDriverAccepted(true);
      setRideStatus("driver_accepted");

      // Navigate to driver detail screen
      if (context != null) {
        Get.to(() => DriverDetailScreen(
              lat: lat,
              long: long,
            ));
      }

      if (kDebugMode) {
        print("✅ Legacy driver detail function completed successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error in legacy driverdetailfunction: $e");
      }
    }
  }

  // Clear all data
  void clearAllData() {
    request_id = "";
    driver_id = "";
    driver_name = "";
    driver_phone = "";
    driver_image = "";
    driver_rating = "";
    vehicle_type = "";
    vehicle_number = "";
    vehicle_color = "";
    driver_lat = 0.0;
    driver_lng = 0.0;
    ride_status = "";
    is_driver_accepted = false;
    is_ride_started = false;
    is_ride_completed = false;
    vehicleBiddingDriver.clear();
    vehicleBiddingSecounds.clear();
    buttonTimer = false;
    select1 = 0;
    mid = "";
    mroal = "";
    update();
  }

  // Update from socket data
  void updateFromSocketData(Map<String, dynamic> data) {
    try {
      if (data['request_id'] != null) {
        setRequestId(data['request_id'].toString());
      }

      if (data['driver_data'] != null) {
        final driverData = data['driver_data'];
        setDriverData(
          id: driverData['id']?.toString() ?? "",
          name: driverData['name']?.toString() ?? "",
          phone: driverData['phone']?.toString() ?? "",
          image: driverData['image']?.toString() ?? "",
          rating: driverData['rating']?.toString() ?? "0",
          vType: driverData['vehicle_type']?.toString() ?? "",
          vNumber: driverData['vehicle_number']?.toString() ?? "",
          vColor: driverData['vehicle_color']?.toString() ?? "",
          lat: double.tryParse(driverData['lat']?.toString() ?? "0") ?? 0.0,
          lng: double.tryParse(driverData['lng']?.toString() ?? "0") ?? 0.0,
        );
      }

      if (data['status'] != null) {
        setRideStatus(data['status'].toString());
      }

      if (data['bidding_drivers'] != null) {
        updateVehicleBiddingDriver(data['bidding_drivers']);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error updating from socket data: $e");
      }
    }
  }

  // Socket event handlers
  void handleDriverLocation(Map<String, dynamic> data) {
    try {
      if (data['driver_id'] == driver_id) {
        final lat = double.tryParse(data['latitude']?.toString() ?? "0") ?? 0.0;
        final lng =
            double.tryParse(data['longitude']?.toString() ?? "0") ?? 0.0;

        if (lat != 0.0 && lng != 0.0) {
          driver_lat = lat;
          driver_lng = lng;
          update();

          if (kDebugMode) {
            print("📍 Driver location updated: $lat, $lng");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error handling driver location: $e");
      }
    }
  }

  void handleRideStatusUpdate(Map<String, dynamic> data) {
    try {
      if (data['request_id'] == request_id) {
        final status = data['status']?.toString() ?? "";
        setRideStatus(status);

        switch (status) {
          case "driver_arrived":
            // Driver has arrived at pickup
            break;
          case "ride_started":
            setRideStarted(true);
            break;
          case "ride_completed":
            setRideCompleted(true);
            break;
          case "ride_cancelled":
            clearAllData();
            break;
        }

        if (kDebugMode) {
          print("🚗 Ride status updated: $status");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error handling ride status: $e");
      }
    }
  }
}
