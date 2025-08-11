import 'package:flutter_polyline_points/src/PointLatLng.dart';
import 'package:get/get.dart';
import 'package:qareeb/controllers/app_controller.dart';

class LocationController extends GetxController {
  final AppController appController = Get.find<AppController>();

  RxList<PointLatLng> get destinationLat => appController.destinationLat;
  List<double> get destinationLng => appController.destinationLng;

  void clearDestinations() {
    appController.destinationLat.clear();
    appController.destinationLng.clear();
  }

  void addDestination(PointLatLng lat, double lng) {
    appController.destinationLat.add(lat);
    appController.destinationLng.add(lng);
  }
}
