import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/http_helper.dart';
import 'package:qareeb/common_code/modern_loading_widget.dart';
import 'package:qareeb/common_code/type_utils.dart';
import '../api_model/calculate_api_model.dart';
import '../common_code/config.dart';

class CalculateController extends GetxController implements GetxService {
  CalCulateModel? calCulateModel;
  bool isLoading = false;

  // Store service zones fetched from API
  List<ServiceZone> serviceZones = [];
  bool zonesLoaded = false;

  // Enhanced timeout settings
  static const Duration _defaultTimeout = Duration(seconds: 20);
  static const Duration _extendedTimeout = Duration(seconds: 30);

  Future calculateApi({
    context,
    required String uid,
    required String mid,
    required String mrole,
    required String pickup_lat_lon,
    required String drop_lat_lon,
    required List drop_lat_lon_list,
    Duration? timeout,
  }) async {
    try {
      isLoading = true;

      update();

      // Show loading overlay

      if (context != null) {
        showModernLoading(
          context: context,
          message: "جاري حساب المسافة والأجرة...",
          dismissible: false,
        );
      }

      // Enhanced coordinate validation

      if (!_isValidCoordinate(pickup_lat_lon) ||
          !_isValidCoordinate(drop_lat_lon)) {
        if (context != null) hideModernLoading(context);

        _showErrorToast("إحداثيات غير صحيحة");

        isLoading = false;

        update();

        return _createErrorResponse("Invalid coordinates format");
      }

      // Validate coordinates are within reasonable bounds for Yemen

      if (!_isWithinYemenBounds(pickup_lat_lon) ||
          !_isWithinYemenBounds(drop_lat_lon)) {
        if (context != null) hideModernLoading(context);

        _showZoneErrorToast("الموقع خارج نطاق اليمن");

        isLoading = false;

        update();

        return _createZoneErrorResponse({});
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
        "Accept": "application/json",
        "User-Agent": "QareebApp/1.0",
      };

      String url = Config.baseurl + Config.calculate;

      if (kDebugMode) {
        print('🚗 Calculate URL: $url');

        print('📍 Calculate Body: $body');

        print(
            '🔍 Pickup coordinates: ${pickup_lat_lon.split(',')[0]}, ${pickup_lat_lon.split(',')[1]}');

        print(
            '🔍 Drop coordinates: ${drop_lat_lon.split(',')[0]}, ${drop_lat_lon.split(',')[1]}');
      }

      // Use provided timeout or default (increased to 30 seconds)

      Duration apiTimeout = timeout ?? const Duration(seconds: 30);

      var response = await HttpHelper.post(
        url,
        body: jsonEncode(body),
        headers: userHeader,
      ).timeout(apiTimeout);

      // Hide loading overlay

      if (context != null) {
        hideModernLoading(context);
      }

      if (kDebugMode) {
        print('📡 Response Status: ${response.statusCode}');

        print('📨 Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["ResponseCode"] == 200 && data["Result"] == true) {
          calCulateModel = CalCulateModel.fromJson(data);

          // Safe parsing for UI updates

          double distance = safeParseDouble(data["tot_km"]);

          double price = safeParseDouble(data["drop_price"]);

          int hours = data["tot_hour"] as int? ?? 0;

          int minutes = data["tot_minute"] as int? ?? 0;

          if (kDebugMode) {
            print('✅ Calculation successful:');

            print('   Distance: $distance km');

            print('   Price: $price');

            print('   Time: ${hours}h ${minutes}m');
          }

          _showSuccessToast("تم حساب الأجرة بنجاح");

          isLoading = false;

          update();

          return data;
        } else if (data["ResponseCode"] == 401) {
          // Handle specific error cases

          isLoading = false;

          update();

          return _handleAPIError(data);
        } else {
          String message = data["message"] ?? "حدث خطأ في الحساب";

          _showErrorToast(message);

          isLoading = false;

          update();

          return _createErrorResponse(message);
        }
      } else {
        _showErrorToast("خطأ في الاتصال بالخادم");

        isLoading = false;

        update();

        return _createErrorResponse("Server error: ${response.statusCode}");
      }
    } catch (e) {
      // Hide loading overlay in case of error

      if (context != null) {
        try {
          hideModernLoading(context);
        } catch (_) {}
      }

      isLoading = false;

      update();

      if (kDebugMode) {
        print('❌ Calculate API Error: $e');
      }

      if (e is TimeoutException) {
        _showErrorToast("انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى");

        return _createErrorResponse("Request timeout");
      } else {
        _showErrorToast("حدث خطأ غير متوقع");
        isLoading = false;

        return _createErrorResponse("Unexpected error: $e");
      }
    }
  }

  // Check if coordinates are within Yemen bounds
  bool _isWithinYemenBounds(String coordinate) {
    try {
      List<String> parts = coordinate.split(',');
      double lat = double.parse(parts[0]);
      double lng = double.parse(parts[1]);

      // Yemen approximate bounds
      // Latitude: 12.0 to 19.0
      // Longitude: 42.0 to 54.0
      return lat >= 12.0 && lat <= 19.0 && lng >= 42.0 && lng <= 54.0;
    } catch (e) {
      return false;
    }
  }

  // Fetch service zones from API
  Future<void> loadServiceZones() async {
    try {
      String url = "${Config.baseurl}/customer/service_zones";

      var response = await HttpHelper.get(url).timeout(_defaultTimeout);

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
      // Fallback to hardcoded zones for Yemen
      _loadFallbackZones();
    }
  }

  // Fallback zones for Yemen
  void _loadFallbackZones() {
    serviceZones = [
      ServiceZone(
        id: 7,
        name: "إب",
        bounds: ZoneBounds(
          minLat: 13.9400,
          maxLat: 13.9900,
          minLng: 44.1600,
          maxLng: 44.2100,
        ),
      ),
      ServiceZone(
        id: 8,
        name: "صنعاء",
        bounds: ZoneBounds(
          minLat: 15.3500,
          maxLat: 15.3800,
          minLng: 44.1700,
          maxLng: 44.2100,
        ),
      ),
      ServiceZone(
        id: 9,
        name: "عدن",
        bounds: ZoneBounds(
          minLat: 12.7500,
          maxLat: 12.8000,
          minLng: 45.0000,
          maxLng: 45.0500,
        ),
      ),
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

    if (kDebugMode) {
      print('❌ Coordinates outside service area:');
      print('   Pickup: ${data["pickup_coords"] ?? "unknown"}');
      print('   Drop: ${data["drop_coords"] ?? "unknown"}');
    }

    if (message.contains("calculate = 0") ||
        message.contains("No valid route segments")) {
      _showZoneErrorToast("لا يمكن حساب المسار - تحقق من نقاط التوصيل");

      // Show debug info in development
      if (kDebugMode && data["debug"] != null) {
        print('🐛 Debug info: ${data["debug"]}');
      }
    } else if (message.contains("zone") ||
        message.contains("Address is not in the zone")) {
      _showZoneErrorToast("إحدى النقاط خارج منطقة الخدمة");
    } else if (message.contains("Vehicle Not Found")) {
      _showErrorToast("المركبة غير متوفرة حالياً");
    } else if (message.contains("Distance calculation failed")) {
      _showErrorToast("فشل في حساب المسافة - تحقق من مفتاح Google Maps API");
    } else {
      _showErrorToast(message);
    }

    return data;
  }

  // Format drop list to handle different input formats
  List<String> _formatDropList(List dropLatLonList) {
    List<String> formattedDropList = [];
    for (var item in dropLatLonList) {
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

  // Create error response with consistent structure
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

  // Create zone error response
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

  // Get localized error messages
  String _getLocalizedErrorMessage(String error) {
    if (error.contains('Failed host lookup')) {
      return "لا يمكن الوصول إلى الخادم. تحقق من اتصال الإنترنت.";
    } else if (error.contains('CERTIFICATE_VERIFY_FAILED')) {
      return "خطأ في شهادة الأمان.";
    } else if (error.contains('TimeoutException')) {
      return "انتهت مهلة الطلب. حاول مرة أخرى.";
    } else if (error.contains('SocketException')) {
      return "فشل الاتصال بالشبكة.";
    } else if (error.contains('PlatformException')) {
      return "خطأ في النظام. حاول مرة أخرى.";
    } else if (error.contains('DEADLINE_EXCEEDED')) {
      return "انتهت مهلة الاتصال. تحقق من اتصال الإنترنت.";
    } else {
      return "حدث خطأ غير متوقع.";
    }
  }

  // Private toast methods using enhanced toast service
  void _showErrorToast(String message) {
    if (kDebugMode) {
      print("🚨 Error Toast: $message");
    }

    try {
      // Try to use ToastService if available
      ToastService.showToast(
        message,
        type: ToastType.error,
        length: ToastLength.long,
        gravity: ToastGravity.center,
      );
    } catch (e) {
      // Fallback to basic toast
      showToastForDuration(message, 3);
    }
  }

  void _showSuccessToast(String message) {
    if (kDebugMode) {
      print("✅ Success Toast: $message");
    }

    try {
      ToastService.showToast(
        message,
        type: ToastType.success,
        length: ToastLength.short,
        gravity: ToastGravity.bottom,
      );
    } catch (e) {
      showToastForDuration(message, 2);
    }
  }

  void _showZoneErrorToast(String message) {
    if (kDebugMode) {
      print("⚠️ Zone Error Toast: $message");
    }

    try {
      ToastService.showToast(
        message,
        type: ToastType.warning,
        length: ToastLength.long,
        gravity: ToastGravity.center,
      );
    } catch (e) {
      showToastForDuration(message, 4);
    }
  }

  // Clear calculation data
  void clearCalculation() {
    calCulateModel = null;
    update();
  }

  // Retry calculation with exponential backoff
  Future<Map<String, dynamic>> retryCalculation({
    required String uid,
    required String mid,
    required String mrole,
    required String pickup_lat_lon,
    required String drop_lat_lon,
    required List drop_lat_lon_list,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;
    Duration delay = const Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        var result = await calculateApi(
          uid: uid,
          mid: mid,
          mrole: mrole,
          pickup_lat_lon: pickup_lat_lon,
          drop_lat_lon: drop_lat_lon,
          drop_lat_lon_list: drop_lat_lon_list,
          timeout: _extendedTimeout,
        );

        if (result["Result"] == true) {
          return result;
        } else if (retryCount == maxRetries - 1) {
          return result; // Return the last error result
        }
      } catch (e) {
        if (kDebugMode) {
          print("💥 Retry $retryCount failed: $e");
        }

        if (retryCount == maxRetries - 1) {
          return _createErrorResponse(
              "فشل بعد $maxRetries محاولات: ${_getLocalizedErrorMessage(e.toString())}");
        }
      }

      retryCount++;
      await Future.delayed(delay);
      delay *= 2; // Exponential backoff
    }

    return _createErrorResponse("فشل بعد $maxRetries محاولات");
  }
}

// Service Zone model classes
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
        minLat: double.parse(json['min_lat'].toString()),
        maxLat: double.parse(json['max_lat'].toString()),
        minLng: double.parse(json['min_lng'].toString()),
        maxLng: double.parse(json['max_lng'].toString()),
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

// Enhanced toast service enums
enum ToastType { success, error, warning, info }

enum ToastLength { short, long }

enum ToastGravity { top, center, bottom }

// Enhanced toast service class
class ToastService {
  static void showToast(
    String message, {
    required ToastType type,
    required ToastLength length,
    required ToastGravity gravity,
  }) {
    // Implementation depends on your toast library
    // This is a placeholder that should be replaced with actual toast implementation
    if (kDebugMode) {
      print("Toast [$type]: $message");
    }

    // Fallback to basic toast function
    int duration = length == ToastLength.short ? 2 : 4;
    showToastForDuration(message, duration);
  }
}

// Updated showToastForDuration function with error handling
void showToastForDuration(String message, int durationInSeconds) {
  try {
    // Your existing toast implementation
    if (kDebugMode) {
      print("Toast: $message (Duration: ${durationInSeconds}s)");
    }

    // Add your actual toast implementation here
    // For example, using fluttertoast package:
    // Fluttertoast.showToast(
    //   msg: message,
    //   toastLength: durationInSeconds > 2 ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.CENTER,
    // );
  } catch (e) {
    if (kDebugMode) {
      print("❌ Toast error: $e");
    }
  }
}
