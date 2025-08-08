import 'package:flutter/foundation.dart';

class RideRequestState extends ChangeNotifier {
  String _requestId = "";

  String _status = "";

  String _acceptedDriverId = "";

  Map<String, dynamic> _currentRequest = {};

  List<Map<String, dynamic>> _biddingDrivers = [];

  // Getters

  String get requestId => _requestId;

  String get status => _status;

  String get acceptedDriverId => _acceptedDriverId;

  Map<String, dynamic> get currentRequest => _currentRequest;

  List<Map<String, dynamic>> get biddingDrivers => _biddingDrivers;

  // ADD THESE METHODS:

  void updateFromVehicleBidding(Map<String, dynamic> data) {
    _requestId = data['request_id']?.toString() ?? "";

    _status = data['status']?.toString() ?? "";

    if (data['bidding_drivers'] != null) {
      _biddingDrivers =
          List<Map<String, dynamic>>.from(data['bidding_drivers']);
    }

    notifyListeners();
  }

  void handleTimeout(Map<String, dynamic> data) {
    _status = "timeout";

    _requestId = "";

    _biddingDrivers.clear();

    notifyListeners();
  }

  void updateAcceptedDriver(Map<String, dynamic> data) {
    _acceptedDriverId = data['driver_id']?.toString() ?? "";

    _status = "accepted";

    _currentRequest = data;

    notifyListeners();
  }

  void setRequestId(String id) {
    _requestId = id;
    notifyListeners();
  }

  void clearRideRequest() {
    _requestId = "";

    _status = "";

    _acceptedDriverId = "";

    _currentRequest.clear();

    _biddingDrivers.clear();

    notifyListeners();
  }
}
