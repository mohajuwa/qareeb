// ✅ UPDATED: lib/api_code/calculate_api_controller.dart

import 'package:qareeb/common_code/custom_notification.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // ✅ Added for kDebugMode

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../common_code/network_service.dart'; // ✅ Added network service
import '../api_model/calculate_api_model.dart';

class CalculateController extends GetxController implements GetxService {
  CalCulateModel? calCulateModel;
  bool isLoading = false; // ✅ Added loading state

  Future calculateApi(
      {context,
      required String uid,
      required String mid,
      required String mrole,
      required String pickup_lat_lon,
      required String drop_lat_lon,
      required List drop_lat_lon_list}) async {
    // ✅ NEW: Network check with Arabic error message
    if (!await NetworkService().hasInternetConnection()) {
      throw Exception(
          'No internet connection available. Please check your network and try again.'
              .tr);
    }

    Map body = {
      "uid": uid,
      "mid": mid,
      "mrole": mrole,
      "pickup_lat_lon": pickup_lat_lon,
      "drop_lat_lon": drop_lat_lon,
      "drop_lat_lon_list": drop_lat_lon_list,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    try {
      // ✅ NEW: Set loading state
      isLoading = true;
      update();

      var response = await http
          .post(Uri.parse(Config.baseurl + Config.calculate),
              body: jsonEncode(body), headers: userHeader)
          .timeout(
        const Duration(seconds: 15), // ✅ Added timeout
        onTimeout: () {
          throw Exception(
              'Request timed out. Please check your connection and try again.'
                  .tr);
        },
      );

      print('+ + + + + CalCulate + + + + + + :--- $body');
      print('- - - - - CalCulate - - - - - - :--- ${response.body}');

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data["Result"] == true) {
          calCulateModel = calCulateModelFromJson(response.body);
          if (calCulateModel!.result == true) {
            isLoading = false;
            update();

            if (kDebugMode) {
              print("✅ Calculate API successful");
            }

            return data;
          } else {
            isLoading = false;
            update();

            // ✅ Arabic error message
            String errorMessage = data["message"] ?? "Calculation failed".tr;

            CustomNotification.show(
                message: errorMessage.tr, type: NotificationType.error);

            throw Exception(errorMessage);
          }
        } else {
          isLoading = false;
          update();

          // ✅ Arabic error message
          String errorMessage = data["message"] ?? "API request failed".tr;

          CustomNotification.show(
              message: errorMessage.tr, type: NotificationType.error);

          throw Exception(errorMessage);
        }
      } else {
        isLoading = false;
        update();

        // ✅ Arabic HTTP error message
        String errorMessage = "Server error. Please try again later.".tr;

        CustomNotification.show(
            message: errorMessage, type: NotificationType.error);

        throw Exception(
            'Server error (${response.statusCode}). Please try again later.'
                .tr);
      }
    } catch (e) {
      // ✅ Always reset loading state on error
      isLoading = false;
      update();

      if (kDebugMode) print('Calculate API Error: $e');
      rethrow; // Re-throw for StatusHelper to handle
    }
  }

  // ✅ NEW: Retry method for convenience
  Future<void> retryCalculateApi(
      {context,
      required String uid,
      required String mid,
      required String mrole,
      required String pickup_lat_lon,
      required String drop_lat_lon,
      required List drop_lat_lon_list}) async {
    try {
      await calculateApi(
        context: context,
        uid: uid,
        mid: mid,
        mrole: mrole,
        pickup_lat_lon: pickup_lat_lon,
        drop_lat_lon: drop_lat_lon,
        drop_lat_lon_list: drop_lat_lon_list,
      );
    } catch (e) {
      if (kDebugMode) print('Calculate API retry failed: $e');
      rethrow;
    }
  }
}

// ✅ ENHANCED: showToastForDuration with Arabic support
void showToastForDuration(String message, int durationInSeconds) {
  // ✅ Show single notification instead of repeating timer
  CustomNotification.show(
      message: message.tr, // ✅ Added .tr for Arabic
      type: NotificationType.info);

  if (kDebugMode) {
    print("📱 Toast shown: ${message.tr}");
  }
}

// ✅ REQUIRED: Add these translations to lib/common_code/language_translate.dart

/*
Update your AppTranslations class to include these entries:

'en_English': {
  // Existing translations...

  // ✅ NEW Network & API translations:
  "WiFi": "WiFi",
  "Mobile Data": "Mobile Data",
  "Ethernet": "Ethernet",
  "No Connection": "No Connection",
  "Unknown": "Unknown",
  "Connected": "Connected",
  "Disconnected": "Disconnected",

  // Status page translations:
  "No Internet Connection": "No Internet Connection",
  "Please check your internet connection and try again. Make sure you're connected to Wi-Fi or mobile data.": "Please check your internet connection and try again. Make sure you're connected to Wi-Fi or mobile data.",
  "Server Error": "Server Error",
  "We're having trouble connecting to our servers. Our team has been notified and is working on a fix.": "We're having trouble connecting to our servers. Our team has been notified and is working on a fix.",
  "Request Timeout": "Request Timeout",
  "The request is taking longer than expected. Please check your connection and try again.": "The request is taking longer than expected. Please check your connection and try again.",
  "No Data Available": "No Data Available",
  "There's no data to show right now. Please try again later or refresh to check for updates.": "There's no data to show right now. Please try again later or refresh to check for updates.",
  "Loading...": "Loading...",
  "Please wait while we fetch your data. This should only take a moment.": "Please wait while we fetch your data. This should only take a moment.",
  "Under Maintenance": "Under Maintenance",
  "We're currently performing maintenance to improve your experience. Please try again shortly.": "We're currently performing maintenance to improve your experience. Please try again shortly.",
  "Something Went Wrong": "Something Went Wrong",
  "We encountered an unexpected error. Please try again or contact support if the problem persists.": "We encountered an unexpected error. Please try again or contact support if the problem persists.",

  // Button translations:
  "Try Again": "Try Again",
  "Retry": "Retry",
  "Refresh": "Refresh",
  "Check Again": "Check Again",
  "Loading": "Loading",

  // API error translations:
  "No internet connection available. Please check your network and try again.": "No internet connection available. Please check your network and try again.",
  "Request timed out. Please check your connection and try again.": "Request timed out. Please check your connection and try again.",
  "Calculation failed": "Calculation failed",
  "API returned false result": "API returned false result",
  "API request failed": "API request failed",
  "Something went wrong! Please try again.": "Something went wrong! Please try again.",
  "Server error. Please try again later.": "Server error. Please try again later.",
},

'ar_Arabic': {
  // Existing Arabic translations...

  // ✅ NEW Network & API translations in Arabic:
  "WiFi": "واي فاي",
  "Mobile Data": "بيانات الجوال",
  "Ethernet": "إيثرنت",
  "No Connection": "لا يوجد اتصال",
  "Unknown": "غير معروف",
  "Connected": "متصل",
  "Disconnected": "غير متصل",

  // Status page translations in Arabic:
  "No Internet Connection": "لا يوجد اتصال بالإنترنت",
  "Please check your internet connection and try again. Make sure you're connected to Wi-Fi or mobile data.": "يرجى فحص اتصال الإنترنت والمحاولة مرة أخرى. تأكد من الاتصال بالواي فاي أو بيانات الجوال.",
  "Server Error": "خطأ في الخادم",
  "We're having trouble connecting to our servers. Our team has been notified and is working on a fix.": "نواجه مشكلة في الاتصال بخوادمنا. تم إبلاغ فريقنا ويعمل على حل المشكلة.",
  "Request Timeout": "انتهت مهلة الطلب",
  "The request is taking longer than expected. Please check your connection and try again.": "يستغرق الطلب وقتاً أطول من المتوقع. يرجى فحص الاتصال والمحاولة مرة أخرى.",
  "No Data Available": "لا توجد بيانات متاحة",
  "There's no data to show right now. Please try again later or refresh to check for updates.": "لا توجد بيانات للعرض حالياً. يرجى المحاولة لاحقاً أو التحديث للبحث عن تحديثات.",
  "Loading...": "جاري التحميل...",
  "Please wait while we fetch your data. This should only take a moment.": "يرجى الانتظار بينما نحضر بياناتك. يجب أن يستغرق هذا لحظة فقط.",
  "Under Maintenance": "تحت الصيانة",
  "We're currently performing maintenance to improve your experience. Please try again shortly.": "نقوم حالياً بصيانة لتحسين تجربتك. يرجى المحاولة قريباً.",
  "Something Went Wrong": "حدث خطأ ما",
  "We encountered an unexpected error. Please try again or contact support if the problem persists.": "واجهنا خطأ غير متوقع. يرجى المحاولة مرة أخرى أو الاتصال بالدعم إذا استمرت المشكلة.",

  // Button translations in Arabic:
  "Try Again": "حاول مرة أخرى",
  "Retry": "إعادة المحاولة",
  "Refresh": "تحديث",
  "Check Again": "تحقق مرة أخرى",
  "Loading": "جاري التحميل",

  // API error translations in Arabic:
  "No internet connection available. Please check your network and try again.": "لا يوجد اتصال إنترنت متاح. يرجى فحص الشبكة والمحاولة مرة أخرى.",
  "Request timed out. Please check your connection and try again.": "انتهت مهلة الطلب. يرجى فحص الاتصال والمحاولة مرة أخرى.",
  "Calculation failed": "فشل في الحساب",
  "API returned false result": "أرجع API نتيجة خاطئة",
  "API request failed": "فشل طلب API",
  "Something went wrong! Please try again.": "حدث خطأ ما! يرجى المحاولة مرة أخرى.",
  "Server error. Please try again later.": "خطأ في الخادم. يرجى المحاولة لاحقاً.",
}
*/

// ✅ EXAMPLE: How to use this in your MapScreen
// Replace your existing calculateApi calls with this pattern:

/*
try {
  // Show loading if needed
  StatusHelper.showStatusDialog(context,
    statusType: StatusType.loading,
    customTitle: "Calculating fare".tr,
    showRetryButton: false,
  );

  final result = await calculateController.calculateApi(
    context: context,
    uid: userid.toString(),
    mid: mid,
    mrole: mroal,
    pickup_lat_lon: "$latitudepick,$longitudepick",
    drop_lat_lon: "$latitudedrop,$longitudedrop",
    drop_lat_lon_list: onlypass,
  );

  // Hide loading
  if (Navigator.canPop(context)) Navigator.pop(context);

  // Process successful result
  // Your existing logic here...

} catch (e) {
  // Hide loading first
  if (Navigator.canPop(context)) Navigator.pop(context);

  // Show error with Arabic support
  StatusHelper.handleError(context, e, onRetry: () {
    Navigator.pop(context);
    // Retry the calculation
    _retryCalculation();
  });
}
*/
