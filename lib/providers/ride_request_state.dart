import 'package:flutter/foundation.dart';

class RideRequestState extends ChangeNotifier {
  String _requestId = "";
  List<dynamic> _vehicleBiddingDriver = [];
  List<dynamic> _vehicleBiddingSecounds = [];
  bool _buttonTimer = false;
  String _mid = "";
  String _mroal = "";
  int _select1 = 0;

  // Getters
  String get requestId => _requestId;
  List<dynamic> get vehicleBiddingDriver => _vehicleBiddingDriver;
  List<dynamic> get vehicleBiddingSecounds => _vehicleBiddingSecounds;
  bool get buttonTimer => _buttonTimer;
  String get mid => _mid;
  String get mroal => _mroal;
  int get select1 => _select1;

  // Setters with notifications
  void setRequestId(String id) {
    _requestId = id;
    notifyListeners();
  }

  void updateVehicleBiddingDriver(List<dynamic> drivers) {
    _vehicleBiddingDriver = drivers;
    notifyListeners();
  }

  void updateVehicleBiddingSecounds(List<dynamic> secounds) {
    _vehicleBiddingSecounds = secounds;
    notifyListeners();
  }

  void setButtonTimer(bool status) {
    _buttonTimer = status;
    notifyListeners();
  }

  void setMid(String mid) {
    _mid = mid;
    notifyListeners();
  }

  void setMroal(String mroal) {
    _mroal = mroal;
    notifyListeners();
  }

  void setSelect1(int select) {
    _select1 = select;
    notifyListeners();
  }

  void clearRideRequest() {
    _requestId = "";
    _vehicleBiddingDriver.clear();
    _vehicleBiddingSecounds.clear();
    _buttonTimer = false;
    _mid = "";
    _mroal = "";
    _select1 = 0;
    notifyListeners();
  }
}
