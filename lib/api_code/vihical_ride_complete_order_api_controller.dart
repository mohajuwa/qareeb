import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../app_screen/pickup_drop_point.dart';
import '../api_model/vihical_ride_api_model.dart';
import '../common_code/config.dart';

String ridecompleterequestid = "";

class VihicalRideCompleteOrderApiController extends GetxController
    implements GetxService {
  VihicalRideCompleteApiModel? vihicalRideCompleteApiModel;
  bool orederloader = false;
  bool isloadoing = false;
  Future<String?> vihicalridecomplete({
    required String payment_id,
    required String payment_img,
    required String uid,
    required String d_id,
    required String request_id,
    required String wallet,
    context,
  }) async {
    if (kDebugMode) {
      print("🚀 Starting ride completion with params:");
      print("uid: $uid, d_id: $d_id, request_id: $request_id");
      print("wallet: $wallet, payment_id: $payment_id");
    }

    if (orederloader) return null;
    orederloader = true;

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse(Config.baseurl + Config.vihicalridecomplete));

      request.fields.addAll({
        'uid': uid.toString(),
        'd_id': d_id.toString(),
        'request_id': request_id.toString(),
        'wallet': wallet.toString(),
        'payment_id': payment_id.toString(),
      });

      if (payment_img.isNotEmpty) {
        request.files
            .add(await http.MultipartFile.fromPath('payment_img', payment_img));
      }

      http.StreamedResponse response = await request.send().timeout(
            const Duration(seconds: 30),
          );

      final responseString = await response.stream.bytesToString();

      if (kDebugMode) {
        print("📡 API Response Status: ${response.statusCode}");
        print("📄 API Response Body: $responseString");
      }

      if (response.statusCode == 200) {
        final responsnessaj = jsonDecode(responseString);

        if (responsnessaj["Result"] == true) {
          String newRequestId = responsnessaj["request_id"].toString();
          ridecompleterequestid = newRequestId;

          if (kDebugMode) {
            print(
                "✅ Ride completed successfully! New request_id: $newRequestId");
          }

          // Clear ride data...

          return newRequestId;
        } else {
          if (kDebugMode) {
            print("❌ API returned false: ${responsnessaj["message"]}");
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print("🔥 HTTP Error ${response.statusCode}: $responseString");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("💥 Exception in ride completion: $e");
      }
      return null;
    } finally {
      orederloader = false;
    }
  }
}
