// ✅ FIXED - RideRequestState Provider
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequestState extends ChangeNotifier {
  String _requestId = "";
  String _status = "";
  String _acceptedDriverId = "";
  Map<String, dynamic> _currentRequest = {};
  List<Map<String, dynamic>> _biddingDrivers = [];

  // ✅ ADDED - Flag to prevent build-time updates
  bool _isUpdating = false;

  // Getters
  String get requestId => _requestId;
  String get status => _status;
  String get acceptedDriverId => _acceptedDriverId;
  Map<String, dynamic> get currentRequest => _currentRequest;
  List<Map<String, dynamic>> get biddingDrivers => _biddingDrivers;

  // ✅ FIXED - Safe notification method
  void _safeNotifyListeners() {
    if (!_isUpdating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isUpdating) {
          notifyListeners();
        }
      });
    }
  }

  void updateFromVehicleBidding(Map<String, dynamic> data) {
    _isUpdating = true;
    _requestId = data['request_id']?.toString() ?? "";
    _status = data['status']?.toString() ?? "";
    if (data['bidding_drivers'] != null) {
      _biddingDrivers =
          List<Map<String, dynamic>>.from(data['bidding_drivers']);
    }
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void handleTimeout(Map<String, dynamic> data) {
    _isUpdating = true;
    _status = "timeout";
    _requestId = "";
    _biddingDrivers.clear();
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void updateAcceptedDriver(Map<String, dynamic> data) {
    _isUpdating = true;
    _acceptedDriverId = data['driver_id']?.toString() ?? "";
    _status = "accepted";
    _currentRequest = data;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void setRequestId(String id) {
    _isUpdating = true;
    _requestId = id;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void clearRideRequest() {
    _isUpdating = true;
    _requestId = "";
    _status = "";
    _acceptedDriverId = "";
    _currentRequest.clear();
    _biddingDrivers.clear();
    _isUpdating = false;
    _safeNotifyListeners();
  }
}
