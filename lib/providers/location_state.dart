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

  // ✅ ADDED - Flag to prevent build-time updates
  bool _isUpdating = false;

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

  // ✅ FIXED - Setters with safe notification
  void setPickupLocation(
      double lat, double lng, String title, String subtitle) {
    _isUpdating = true;
    _latitudePick = lat;
    _longitudePick = lng;
    _pickTitle = title;
    _pickSubtitle = subtitle;
    _pickupController.text = title;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void setDropLocation(double lat, double lng, String title, String subtitle) {
    _isUpdating = true;
    _latitudeDrop = lat;
    _longitudeDrop = lng;
    _dropTitle = title;
    _dropSubtitle = subtitle;
    _dropController.text = title;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void addDropLocation(Map<String, dynamic> dropLocation) {
    _isUpdating = true;
    _dropTitleList.add(dropLocation);
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void updateDestinationLat(List<PointLatLng> destinations) {
    _isUpdating = true;
    _destinationLat = destinations;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void updateDestinationLong(List<LatLng> destinations) {
    _isUpdating = true;
    _destinationLong = destinations;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void updateOnlyPass(List<dynamic> onlyPassList) {
    _isUpdating = true;
    _onlyPass = onlyPassList;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void setPicAndDrop(bool status) {
    _isUpdating = true;
    _picAndDrop = status;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void setAddressPickup(dynamic address) {
    _isUpdating = true;
    _addressPickup = address;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void setCurrentHome(dynamic lat, dynamic lng) {
    _isUpdating = true;
    _latHomeCurrent = lat;
    _longHomeCurrent = lng;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  // ✅ FIXED - Batch update method to avoid multiple notifications
  void updateLocationData({
    double? pickupLat,
    double? pickupLng,
    String? pickupTitle,
    String? pickupSubtitle,
    double? dropLat,
    double? dropLng,
    String? dropTitle,
    String? dropSubtitle,
    List<dynamic>? dropTitleList,
    List<PointLatLng>? destinationLat,
    List<dynamic>? onlyPass,
    List<LatLng>? destinationLong,
    bool? picAndDrop,
    dynamic addressPickup,
  }) {
    _isUpdating = true;

    if (pickupLat != null) _latitudePick = pickupLat;
    if (pickupLng != null) _longitudePick = pickupLng;
    if (pickupTitle != null) {
      _pickTitle = pickupTitle;
      _pickupController.text = pickupTitle;
    }
    if (pickupSubtitle != null) _pickSubtitle = pickupSubtitle;

    if (dropLat != null) _latitudeDrop = dropLat;
    if (dropLng != null) _longitudeDrop = dropLng;
    if (dropTitle != null) {
      _dropTitle = dropTitle;
      _dropController.text = dropTitle;
    }
    if (dropSubtitle != null) _dropSubtitle = dropSubtitle;

    if (dropTitleList != null) _dropTitleList = dropTitleList;
    if (destinationLat != null) _destinationLat = destinationLat;
    if (onlyPass != null) _onlyPass = onlyPass;
    if (destinationLong != null) _destinationLong = destinationLong;
    if (picAndDrop != null) _picAndDrop = picAndDrop;
    if (addressPickup != null) _addressPickup = addressPickup;

    _isUpdating = false;
    _safeNotifyListeners();
  }

  void clearLocationData() {
    _isUpdating = true;
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
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void removeDropLocation(int index) {
    if (index < _dropTitleList.length) {
      _isUpdating = true;
      _dropTitleList.removeAt(index);

      if (index < _destinationLat.length) {
        _destinationLat.removeAt(index);
      }

      if (index < _onlyPass.length) {
        _onlyPass.removeAt(index);
      }

      _isUpdating = false;
      _safeNotifyListeners();
    }
  }

  // ✅ ADDED - Method to check if location data is valid
  bool get hasValidPickupLocation =>
      _latitudePick != 0.00 && _longitudePick != 0.00;
  bool get hasValidDropLocation =>
      _latitudeDrop != 0.00 && _longitudeDrop != 0.00;
  bool get hasValidLocations => hasValidPickupLocation && hasValidDropLocation;

  // ✅ ADDED - Distance calculation helper
  double getDistanceBetweenPickupAndDrop() {
    if (!hasValidLocations) return 0.0;

    // Simple distance calculation (you can implement Haversine formula here)
    double deltaLat = _latitudeDrop - _latitudePick;
    double deltaLng = _longitudeDrop - _longitudePick;
    return (deltaLat * deltaLat + deltaLng * deltaLng).abs();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  // ✅ ADDED - Debug helper
  void debugPrintState() {
    if (kDebugMode) {
      print("📍 LocationState Debug:");
      print("Pickup: $_pickTitle ($_latitudePick, $_longitudePick)");
      print("Drop: $_dropTitle ($_latitudeDrop, $_longitudeDrop)");
      print("Drop locations count: ${_dropTitleList.length}");
      print("Valid locations: $hasValidLocations");
    }
  }
}
