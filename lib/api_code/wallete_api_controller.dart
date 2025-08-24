import 'package:qareeb/common_code/custom_notification.dart';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';

import '../api_model/wallete_api_model.dart';
import '../app_screen/top_up_screen.dart';

class WalletApiController extends GetxController implements GetxService {
  WalletAddApiModel? walletAddApiModel;
  bool isLoading = true;

  Future walletaddapi(
      {required String amount,
      required String uid,
      required String payment_id,
      context}) async {
    Map body = {
      "amount": amount,
      "uid": uid,
      "payment_id": payment_id,
    };
    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.walletupapi),
        body: jsonEncode(body),
        headers: userHeader);

    print(body);
    print("///////////:---  ${response.body}");

    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      walletAddApiModel = walletAddApiModelFromJson(response.body);
      if (data["Result"] == true) {
        CustomNotification.show(
            message: walletAddApiModel!.message.toString(),
            type: NotificationType.info);
        showModalBottomSheet(
          isDismissible: false,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15))),
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
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xff7D2AFF),
                    child: Center(
                        child: Icon(
                      Icons.check,
                      color: Colors.white,
                    )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Top up $currencybol${walletController.text}.00',
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Successfuly',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  Text(
                    '$currencybol${walletController.text} has been added to your wallet',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: const ButtonStyle(
                                fixedSize:
                                    WidgetStatePropertyAll(Size(0, 50)),
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.white),
                                side: WidgetStatePropertyAll(
                                    BorderSide(color: Colors.black)),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))))),
                            onPressed: () {
                              Get.back();
                              // Get.back();
                            },
                            child: const Text('Done For Now',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: const ButtonStyle(
                                fixedSize:
                                    WidgetStatePropertyAll(Size(0, 50)),
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.black),
                                side: WidgetStatePropertyAll(
                                    BorderSide(color: Colors.black)),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))))),
                            onPressed: () {
                              Get.back();
                              // Get.back();
                            },
                            child: Text('Another Top Up'.tr,
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
        isLoading = false;
        update();
        return jsonDecode(response.body);
      } else {
        CustomNotification.show(
            message: "${data["message"]}", type: NotificationType.info);
      }
    } else {
      CustomNotification.show(
          message: "Something went Wrong....!!!", type: NotificationType.info);
    }
  }
}
