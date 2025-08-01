import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qareeb/common_code/toastification.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/config.dart';
import 'package:qareeb/common_code/http_helper.dart';
import '../api_model/wallete_api_model.dart';

class WalletApiController extends GetxController implements GetxService {
  WalletAddApiModel? walletAddApiModel;
  bool isLoading = true;

  Future walletaddapi(
      {required String amount,
      required String uid,
      required String payment_id,
      context}) async {
    try {
      Map body = {
        "amount": amount,
        "uid": uid,
        "payment_id": payment_id,
      };

      Map<String, String> userHeader = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      String url = Config.baseurl + Config.walletupapi;

      if (kDebugMode) {
        print('Wallet Add URL: $url');
        print('Wallet Add Body: $body');
      }

      var response = await HttpHelper.post(url,
              body: jsonEncode(body), headers: userHeader)
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Wallet Add Response Status: ${response.statusCode}');
        print('Wallet Add Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        walletAddApiModel = walletAddApiModelFromJson(response.body);

        if (data["Result"] == true) {
          ToastService.showToast(walletAddApiModel!.message.toString());

          showModalBottomSheet(
            isDismissible: false,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 330,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 100,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Payment Successful!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Amount: $amount",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          ToastService.showToast("${data["message"]}");
        }
      } else {
        ToastService.showToast(
            "خطأ في HTTP: ${response.statusCode}"); // "HTTP Error: ${response.statusCode}"
      }
    } catch (e) {
      if (kDebugMode) {
        print("Wallet Add API Error: $e");
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
      } else {
        errorMessage =
            "حدث خطأ ما. حاول مرة أخرى."; // "Something went wrong. Please try again."
      }

      ToastService.showToast(errorMessage);
    }
  }
}
