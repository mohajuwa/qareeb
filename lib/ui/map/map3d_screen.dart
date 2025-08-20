import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map3DScreen extends StatefulWidget {
  const Map3DScreen({super.key});

  @override
  State<Map3DScreen> createState() => _Map3DScreenState();
}

class _Map3DScreenState extends State<Map3DScreen> {
  GoogleMapController? _controller;

  final CameraPosition _initial = const CameraPosition(
    target: LatLng(15.3694, 44.1910), // Sana'a
    zoom: 16,
    tilt: 60, // 3D feel
    bearing: 30,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خريطة ثلاثية الأبعاد')),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initial,
        buildingsEnabled: true,
        tiltGesturesEnabled: true,
        compassEnabled: true,
        onMapCreated: (c) => _controller = c,
      ),
    );
  }
}
