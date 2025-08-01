import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/calculate_api_model.dart';

// Toast Service for unified toast handling
class ToastService {
  static void showToast(
    String message, {
    ToastType type = ToastType.info,
    ToastLength length = ToastLength.short,
    ToastGravity gravity = ToastGravity.bottom,
  }) {
    // Since we can't use context-dependent toastification globally,
    // we'll use a simple print for debugging and you can integrate
    // with your preferred toast solution
    if (kDebugMode) {
      print('Toast [${type.name}]: $message');
    }

    // You can replace this with your actual toast implementation
    // For example: Fluttertoast.showToast() or toastification.show()
  }
}

enum ToastType { info, success, error, warning }

enum ToastLength { short, long }

enum ToastGravity { top, center, bottom }

class CalculateController extends GetxController implements GetxService {
  CalCulateModel? calCulateModel;
  bool isLoading = false;

  // Store service zones fetched from API
  List<ServiceZone> serviceZones = [];
  bool zonesLoaded = false;

  Future calculateApi(
      {context,
      required String uid,
      required String mid,
      required String mrole,
      required String pickup_lat_lon,
      required String drop_lat_lon,
      required List drop_lat_lon_list}) async {
    try {
      isLoading = true;
      update();

      // Validate coordinates format
      if (!_isValidCoordinate(pickup_lat_lon) ||
          !_isValidCoordinate(drop_lat_lon)) {
        _showErrorToast("إحداثيات غير صحيحة");
        return _createErrorResponse("Invalid coordinates format");
      }

      // Convert drop_lat_lon_list to proper format
      List<String> formattedDropList = _formatDropList(drop_lat_lon_list);

      Map body = {
        "uid": uid,
        "mid": mid,
        "mrole": mrole,
        "pickup_lat_lon": pickup_lat_lon,
        "drop_lat_lon": drop_lat_lon,
        "drop_lat_lon_list": formattedDropList,
      };

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.calculate;

      if (kDebugMode) {
        print('🚗 Calculate URL: $url');
        print('📍 Calculate Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('📡 Response Status: ${response.statusCode}');
        print('📨 Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["ResponseCode"] == 200 && data["Result"] == true) {
          // Successful calculation
          calCulateModel = calCulateModelFromJson(response.body);
          _showSuccessToast("تم حساب الأجرة بنجاح");
          return data;
        } else if (data["ResponseCode"] == 401) {
          // Handle specific error cases
          return _handleAPIError(data);
        } else {
          _showErrorToast(data["message"] ?? "فشل في حساب الأجرة");
          return data;
        }
      } else {
        _showErrorToast("خطأ في الشبكة: ${response.statusCode}");
        return _createErrorResponse("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("💥 Calculate API Error: $e");
      }
      String errorMessage = _getLocalizedErrorMessage(e.toString());
      _showErrorToast(errorMessage);
      return _createErrorResponse(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  // Fetch service zones from API
  Future<void> loadServiceZones() async {
    try {
      String url =
          "${Config.baseurl}/customer/service_zones"; // Adjust endpoint

      var response =
          await HttpHelper.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["Result"] == true && data["zones"] != null) {
          serviceZones.clear();
          for (var zone in data["zones"]) {
            serviceZones.add(ServiceZone.fromJson(zone));
          }
          zonesLoaded = true;
          update();
          if (kDebugMode) {
            print('🗺️ Loaded ${serviceZones.length} service zones');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load service zones: $e');
      }
      // Fallback to hardcoded zones for testing
      _loadFallbackZones();
    }
  }

  // Fallback zones for testing/development
  void _loadFallbackZones() {
    serviceZones = [
      ServiceZone(
          id: 8,
          name: "Ibb",
          bounds: ZoneBounds(
              minLat: 13.9400,
              maxLat: 13.9900,
              minLng: 44.1600,
              maxLng: 44.2100)),
      ServiceZone(
          id: 7,
          name: "Sana'a",
          bounds: ZoneBounds(
              minLat: 15.3500,
              maxLat: 15.3800,
              minLng: 44.1700,
              maxLng: 44.2100)),
    ];
    zonesLoaded = true;
    update();
  }

  // Check if coordinates are within any service zone
  ServiceZone? getServiceZoneForCoordinates(double lat, double lng) {
    if (!zonesLoaded) {
      loadServiceZones();
      return null;
    }

    for (var zone in serviceZones) {
      if (zone.containsPoint(lat, lng)) {
        return zone;
      }
    }
    return null;
  }

  // Validate coordinates are in service area
  bool validateCoordinatesInServiceArea(double lat, double lng,
      {bool showToast = true}) {
    var zone = getServiceZoneForCoordinates(lat, lng);

    if (zone == null) {
      if (showToast) {
        String availableZones = serviceZones.map((z) => z.name).join("، ");
        _showZoneErrorToast(
            "هذه المنطقة غير مخدومة. المناطق المتاحة: $availableZones");
      }
      return false;
    }

    if (showToast && kDebugMode) {
      print('✅ Coordinates are in service zone: ${zone.name}');
    }
    return true;
  }

  // Get the nearest service zone center for suggestions
  Map<String, double> getNearestServiceZoneCenter(double lat, double lng) {
    if (serviceZones.isEmpty)
      return {"lat": 13.9667, "lng": 44.1833}; // Default to Ibb

    double minDistance = double.infinity;
    ServiceZone? nearestZone;

    for (var zone in serviceZones) {
      double distance = _calculateDistance(
          lat, lng, zone.center["lat"]!, zone.center["lng"]!);
      if (distance < minDistance) {
        minDistance = distance;
        nearestZone = zone;
      }
    }

    return nearestZone?.center ?? {"lat": 13.9667, "lng": 44.1833};
  }

  // Calculate distance between two points
  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    double dLat = _toRadians(lat2 - lat1);
    double dLng = _toRadians(lng2 - lng1);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);

  Map<String, dynamic> _handleAPIError(Map<String, dynamic> data) {
    String message = data["message"] ?? "خطأ غير معروف";

    if (message.contains("calculate = 0") ||
        message.contains("No valid route segments")) {
      _showZoneErrorToast("لا يمكن حساب المسار - تحقق من نقاط التوصيل");

      // Show debug info in development
      if (kDebugMode && data["debug"] != null) {
        print('🐛 Debug info: ${data["debug"]}');
      }
    } else if (message.contains("zone") ||
        message.contains("Address is not in the zone")) {
      // Handle zone errors...
      _showZoneErrorToast("المنطقة غير مخدومة حالياً");
    } else if (message.contains("Vehicle Not Found")) {
      _showErrorToast("المركبة غير متوفرة حالياً");
    } else {
      _showErrorToast(message);
    }

    return data;
  }

  // Format drop list to handle different input formats
  List<String> _formatDropList(List drop_lat_lon_list) {
    List<String> formattedDropList = [];
    for (var item in drop_lat_lon_list) {
      if (item is Map) {
        if (item.containsKey('lat') && item.containsKey('long')) {
          formattedDropList.add("${item['lat']},${item['long']}");
        }
      } else if (item is String) {
        formattedDropList.add(item);
      }
    }
    return formattedDropList;
  }

  // Helper methods for validation and error handling
  bool _isValidCoordinate(String coordinate) {
    if (coordinate.isEmpty) return false;
    List<String> parts = coordinate.split(',');
    if (parts.length != 2) return false;
    try {
      double lat = double.parse(parts[0]);
      double lng = double.parse(parts[1]);
      return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> _createErrorResponse(String error) {
    return {
      "ResponseCode": 500,
      "Result": false,
      "message": error,
      "offer_expire_time": 0,
      "tot_km": 0,
      "drop_price": 0,
      "tot_hour": 0,
      "tot_minute": 0,
      "tot_second": 0,
      "driver_id": [],
      "vehicle": {}
    };
  }

  Map<String, dynamic> _createZoneErrorResponse(
      Map<String, dynamic> originalData) {
    return {
      "ResponseCode": 401,
      "Result": false,
      "message": "المنطقة غير مخدومة حالياً",
      "offer_expire_time": originalData["offer_expire_time"] ?? 180,
      "zoneresult": originalData["zoneresult"] ?? [],
      "tot_km": 0,
      "drop_price": 0,
      "tot_hour": 0,
      "tot_minute": 0,
      "tot_second": 0,
      "driver_id": [],
      "vehicle": []
    };
  }

  String _getLocalizedErrorMessage(String error) {
    if (error.contains('Failed host lookup')) {
      return "لا يمكن الوصول إلى الخادم. تحقق من اتصال الإنترنت.";
    } else if (error.contains('CERTIFICATE_VERIFY_FAILED')) {
      return "خطأ في شهادة الأمان.";
    } else if (error.contains('TimeoutException')) {
      return "انتهت مهلة الطلب. حاول مرة أخرى.";
    } else if (error.contains('SocketException')) {
      return "فشل الاتصال بالشبكة.";
    } else {
      return "حدث خطأ غير متوقع.";
    }
  }

  // Private toast methods using ToastService
  void _showErrorToast(String message) {
    ToastService.showToast(
      message,
      type: ToastType.error,
      length: ToastLength.long,
      gravity: ToastGravity.center,
    );
  }

  void _showSuccessToast(String message) {
    ToastService.showToast(
      message,
      type: ToastType.success,
      length: ToastLength.short,
      gravity: ToastGravity.bottom,
    );
  }

  void _showZoneErrorToast(String message) {
    ToastService.showToast(
      message,
      type: ToastType.warning,
      length: ToastLength.long,
      gravity: ToastGravity.center,
    );
  }

  void clearCalculation() {
    calCulateModel = null;
    update();
  }
}

// Service Zone model
class ServiceZone {
  final int id;
  final String name;
  final ZoneBounds bounds;
  late final Map<String, double> center;

  ServiceZone({required this.id, required this.name, required this.bounds}) {
    center = {
      "lat": (bounds.minLat + bounds.maxLat) / 2,
      "lng": (bounds.minLng + bounds.maxLng) / 2,
    };
  }

  bool containsPoint(double lat, double lng) {
    return lat >= bounds.minLat &&
        lat <= bounds.maxLat &&
        lng >= bounds.minLng &&
        lng <= bounds.maxLng;
  }

  factory ServiceZone.fromJson(Map<String, dynamic> json) {
    return ServiceZone(
      id: json['id'],
      name: json['name'],
      bounds: ZoneBounds(
        minLat: json['min_lat'],
        maxLat: json['max_lat'],
        minLng: json['min_lng'],
        maxLng: json['max_lng'],
      ),
    );
  }
}

class ZoneBounds {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  ZoneBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });
}

// Updated showToastForDuration function
void showToastForDuration(String message, int durationInSeconds) {
  int interval = 2; // Duration of each toast
  int elapsed = 0;

  Timer.periodic(Duration(seconds: interval), (timer) {
    if (elapsed >= durationInSeconds) {
      timer.cancel();
    } else {
      ToastService.showToast(
        message,
        type: ToastType.info,
        length: ToastLength.short,
        gravity: ToastGravity.bottom,
      );
      elapsed += interval;
    }
  });
}
