import 'package:flutter/foundation.dart';
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

  // Getters
  GoogleMapController? get mapController => _mapController;
  Map<MarkerId, Marker> get markers => _markers;
  Map<MarkerId, Marker> get markers11 => _markers11;
  Map<PolylineId, Polyline> get polylines => _polylines;
  Map<PolylineId, Polyline> get polylines11 => _polylines11;
  List<LatLng> get polylineCoordinates => _polylineCoordinates;
  PolylinePoints get polylinePoints => _polylinePoints;
  PolylinePoints get polylinePoints11 => _polylinePoints11;

  // Methods
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  void updateMarkers(Map<MarkerId, Marker> newMarkers) {
    _markers = newMarkers;
    notifyListeners();
  }

  void addMarker(MarkerId markerId, Marker marker) {
    _markers[markerId] = marker;
    notifyListeners();
  }

  void addMarker11(MarkerId markerId, Marker marker) {
    _markers11[markerId] = marker;

    notifyListeners();
  }

  void addPolyline11(PolylineId polylineId, Polyline polyline) {
    _polylines11[polylineId] = polyline;

    notifyListeners();
  }

  void clearPolylines11() {
    _polylines11.clear();

    notifyListeners();
  }

  void updateMarkerPosition(MarkerId markerId, LatLng newPosition) {
    if (_markers.containsKey(markerId)) {
      final Marker oldMarker = _markers[markerId]!;

      final Marker updatedMarker = oldMarker.copyWith(
        positionParam: newPosition,
      );

      _markers[markerId] = updatedMarker;

      notifyListeners();
    }
  }

  void addPolyline(PolylineId polylineId, Polyline polyline) {
    _polylines[polylineId] = polyline;

    notifyListeners();
  }

  void clearMapData() {
    _markers.clear();
    _markers11.clear();
    _polylines.clear();
    _polylines11.clear();
    _polylineCoordinates.clear();
    notifyListeners();
  }
}
