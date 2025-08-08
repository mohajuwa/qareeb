import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationState extends ChangeNotifier {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();

  double _latitudePick = 0.00;
  double _longitudePick = 0.00;
  double _latitudeDrop = 0.00;
  double _longitudeDrop = 0.00;

  String _pickTitle = "";
  String _pickSubtitle = "";
  String _dropTitle = "";
  String _dropSubtitle = "";
  List<dynamic> _dropTitleList = [];

  List<PointLatLng> _destinationLat = [];
  List<dynamic> _onlyPass = [];
  List<LatLng> _destinationLong = [];

  bool _picAndDrop = true;
  dynamic _addressPickup;

  var _latHomeCurrent;
  var _longHomeCurrent;

  // Getters
  TextEditingController get pickupController => _pickupController;
  TextEditingController get dropController => _dropController;
  double get latitudePick => _latitudePick;
  double get longitudePick => _longitudePick;
  double get latitudeDrop => _latitudeDrop;
  double get longitudeDrop => _longitudeDrop;
  String get pickTitle => _pickTitle;
  String get pickSubtitle => _pickSubtitle;
  String get dropTitle => _dropTitle;
  String get dropSubtitle => _dropSubtitle;
  List<dynamic> get dropTitleList => _dropTitleList;
  List<PointLatLng> get destinationLat => _destinationLat;
  List<dynamic> get onlyPass => _onlyPass;
  List<LatLng> get destinationLong => _destinationLong;
  bool get picAndDrop => _picAndDrop;
  dynamic get addressPickup => _addressPickup;
  dynamic get latHomeCurrent => _latHomeCurrent;
  dynamic get longHomeCurrent => _longHomeCurrent;

  // Setters
  void setPickupLocation(
      double lat, double lng, String title, String subtitle) {
    _latitudePick = lat;
    _longitudePick = lng;
    _pickTitle = title;
    _pickSubtitle = subtitle;
    _pickupController.text = title;
    notifyListeners();
  }

  void setDropLocation(double lat, double lng, String title, String subtitle) {
    _latitudeDrop = lat;
    _longitudeDrop = lng;
    _dropTitle = title;
    _dropSubtitle = subtitle;
    _dropController.text = title;
    notifyListeners();
  }

  void addDropLocation(Map<String, dynamic> dropLocation) {
    _dropTitleList.add(dropLocation);
    notifyListeners();
  }

  void updateDestinationLat(List<PointLatLng> destinations) {
    _destinationLat = destinations;
    notifyListeners();
  }

  void updateDestinationLong(List<LatLng> destinations) {
    _destinationLong = destinations;
    notifyListeners();
  }

  void setPicAndDrop(bool status) {
    _picAndDrop = status;
    notifyListeners();
  }

  void setAddressPickup(dynamic address) {
    _addressPickup = address;
    notifyListeners();
  }

  void setCurrentHome(dynamic lat, dynamic lng) {
    _latHomeCurrent = lat;
    _longHomeCurrent = lng;
    notifyListeners();
  }

  void clearLocationData() {
    _pickupController.clear();
    _dropController.clear();
    _latitudePick = 0.00;
    _longitudePick = 0.00;
    _latitudeDrop = 0.00;
    _longitudeDrop = 0.00;
    _pickTitle = "";
    _pickSubtitle = "";
    _dropTitle = "";
    _dropSubtitle = "";
    _dropTitleList.clear();
    _destinationLat.clear();
    _onlyPass.clear();
    _destinationLong.clear();
    _picAndDrop = true;
    _addressPickup = null;
    notifyListeners();
  }

  void removeDropLocation(int index) {
    if (index < _dropTitleList.length) {
      _dropTitleList.removeAt(index);

      if (index < _destinationLat.length) {
        _destinationLat.removeAt(index);
      }

      if (index < _onlyPass.length) {
        _onlyPass.removeAt(index);
      }

      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }
}
