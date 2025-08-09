import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/calculate_api_model.dart';

class CalculateController extends GetxController implements GetxService {
  CalCulateModel? calCulateModel;

  Future calculateApi(
      {context,
      required String uid,
      required String mid,
      required String mrole,
      required String pickup_lat_lon,
      required String drop_lat_lon,
      required List drop_lat_lon_list}) async {
    try {
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

      String url = Config.baseurl + Config.calculate;

      if (kDebugMode) {
        print('Calculate URL: $url');
        print('Calculate Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(Duration(seconds: 30));

      if (kDebugMode) {
        print('Calculate Response Status: ${response.statusCode}');
        print('Calculate Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["Result"] == true) {
          calCulateModel = calCulateModelFromJson(response.body);
          if (calCulateModel!.result == true) {
            update();
            return data;
          } else {
            return data;
          }
        } else {
          return data;
        }
      } else {
        if (kDebugMode) {
          print('Calculate API HTTP Error: ${response.statusCode}');
        }
        showToastForDuration("خطأ في HTTP: ${response.statusCode}",
            3); // "HTTP Error: ${response.statusCode}"
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Calculate API Error: $e");
      }

      String errorMessage = "فشل الاتصال"; // "Connection failed"
      if (e.toString().contains('Failed host lookup')) {
        errorMessage =
            "لا يمكن الوصول إلى الخادم. تحقق من اتصال الإنترنت."; // "Server not reachable. Check your internet connection."
      } else if (e.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
        errorMessage =
            "خطأ في شهادة الأمان. جاري استخدام تجاوز الشهادة المؤقتة."; // "SSL Certificate error. Using self-signed certificate bypass."
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage =
            "انتهت مهلة الطلب. حاول مرة أخرى."; // "Request timeout. Please try again."
      }

      showToastForDuration(errorMessage, 3);
      return null;
    }
  }
}

void showToastForDuration(String message, int durationInSeconds) {
  int interval = 2; // Duration of each toast
  int elapsed = 0;

  Timer.periodic(Duration(seconds: interval), (timer) {
    if (elapsed >= durationInSeconds) {
      timer.cancel();
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      elapsed += interval;
    }
  });
}
