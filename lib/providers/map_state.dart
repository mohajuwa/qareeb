import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapState extends ChangeNotifier {
  GoogleMapController? _mapController;
  Map<MarkerId, Marker> _markers = {};
  Map<MarkerId, Marker> _markers11 = {};
  Map<PolylineId, Polyline> _polylines = {};
  Map<PolylineId, Polyline> _polylines11 = {};
  List<LatLng> _polylineCoordinates = [];
  PolylinePoints _polylinePoints = PolylinePoints();
  PolylinePoints _polylinePoints11 = PolylinePoints();

  // ✅ ADDED - Flag to prevent build-time updates
  bool _isUpdating = false;

  // Getters
  GoogleMapController? get mapController => _mapController;
  Map<MarkerId, Marker> get markers => _markers;
  Map<MarkerId, Marker> get markers11 => _markers11;
  Map<PolylineId, Polyline> get polylines => _polylines;
  Map<PolylineId, Polyline> get polylines11 => _polylines11;
  List<LatLng> get polylineCoordinates => _polylineCoordinates;
  PolylinePoints get polylinePoints => _polylinePoints;
  PolylinePoints get polylinePoints11 => _polylinePoints11;

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

  // ✅ FIXED - Methods with safe notification
  void setMapController(GoogleMapController controller) {
    _isUpdating = true;
    _mapController = controller;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void updateMarkers(Map<MarkerId, Marker> newMarkers) {
    _isUpdating = true;
    _markers = newMarkers;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void addMarker(MarkerId markerId, Marker marker) {
    _isUpdating = true;
    _markers[markerId] = marker;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void addMarker11(MarkerId markerId, Marker marker) {
    _isUpdating = true;
    _markers11[markerId] = marker;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void addPolyline11(PolylineId polylineId, Polyline polyline) {
    _isUpdating = true;
    _polylines11[polylineId] = polyline;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void clearPolylines11() {
    _isUpdating = true;
    _polylines11.clear();
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void updateMarkerPosition(MarkerId markerId, LatLng newPosition) {
    if (_markers.containsKey(markerId)) {
      _isUpdating = true;
      final Marker oldMarker = _markers[markerId]!;
      final Marker updatedMarker = oldMarker.copyWith(
        positionParam: newPosition,
      );
      _markers[markerId] = updatedMarker;
      _isUpdating = false;
      _safeNotifyListeners();
    }
  }

  void addPolyline(PolylineId polylineId, Polyline polyline) {
    _isUpdating = true;
    _polylines[polylineId] = polyline;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void updatePolylineCoordinates(List<LatLng> coordinates) {
    _isUpdating = true;
    _polylineCoordinates = coordinates;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void clearMapData() {
    _isUpdating = true;
    _markers.clear();
    _markers11.clear();
    _polylines.clear();
    _polylines11.clear();
    _polylineCoordinates.clear();
    _isUpdating = false;
    _safeNotifyListeners();
  }

  // ✅ ADDED - Batch update method for multiple operations
  void batchUpdateMap({
    Map<MarkerId, Marker>? markers,
    Map<MarkerId, Marker>? markers11,
    Map<PolylineId, Polyline>? polylines,
    Map<PolylineId, Polyline>? polylines11,
    List<LatLng>? polylineCoordinates,
  }) {
    _isUpdating = true;

    if (markers != null) _markers = markers;
    if (markers11 != null) _markers11 = markers11;
    if (polylines != null) _polylines = polylines;
    if (polylines11 != null) _polylines11 = polylines11;
    if (polylineCoordinates != null) _polylineCoordinates = polylineCoordinates;

    _isUpdating = false;
    _safeNotifyListeners();
  }

  // ✅ ADDED - Bulk marker operations
  void addMultipleMarkers(Map<MarkerId, Marker> markersToAdd) {
    _isUpdating = true;
    _markers.addAll(markersToAdd);
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void removeMarker(MarkerId markerId) {
    _isUpdating = true;
    _markers.remove(markerId);
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void removePolyline(PolylineId polylineId) {
    _isUpdating = true;
    _polylines.remove(polylineId);
    _isUpdating = false;
    _safeNotifyListeners();
  }

  // ✅ ADDED - Helper methods
  bool hasMarkers() => _markers.isNotEmpty;
  bool hasPolylines() => _polylines.isNotEmpty;
  int get markerCount => _markers.length;
  int get polylineCount => _polylines.length;

  // ✅ ADDED - Map camera operations
  Future<void> animateCameraToPosition(LatLng position,
      {double zoom = 14.0}) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: zoom),
        ),
      );
    }
  }

  Future<void> animateCameraToBounds(LatLngBounds bounds) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }
  }

  // ✅ ADDED - Debug helper
  void debugPrintMapState() {
    if (kDebugMode) {
      print("🗺️ MapState Debug:");
      print("Markers: ${_markers.length}");
      print("Markers11: ${_markers11.length}");
      print("Polylines: ${_polylines.length}");
      print("Polylines11: ${_polylines11.length}");
      print("Polyline coordinates: ${_polylineCoordinates.length}");
      print("Map controller: ${_mapController != null ? 'Set' : 'Not set'}");
    }
  }
}
