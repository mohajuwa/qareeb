import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:get/get.dart';

import 'package:flutter/material.dart';

import 'package:qareeb/common_code/http_helper.dart';

import '../api_model/faq_model.dart';

import '../common_code/config.dart';



class FaqApiController extends GetxController implements GetxService {

  FaqApiiimodel? faqApiiimodel;

  bool isLoading = true;



  Future faqlistapi(context) async {

    try {

      Map<String, String> userHeader = {

        "Content-type": "application/json", 

        "Accept": "application/json"

      };

      

      var response = await HttpHelper.get(Config.baseurl + Config.faqapi, headers: userHeader)

          .timeout(Duration(seconds: 30));



      print("++++faq++++:-- ${response.body}");



      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {

        if (data["Result"] == true) {

          faqApiiimodel = faqApiiimodelFromJson(response.body);

          isLoading = false;

          update();

        } else {

          Get.back();

          Fluttertoast.showToast(msg: "${data["message"]}");

        }

      } else {

        Get.back();

        Fluttertoast.showToast(msg: "HTTP Error: ${response.statusCode}");

      }

    } catch (e) {

      print("FAQ API Error: $e");

      Get.back();

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text("Connection failed. Please try again."))

      );

    }

  }

}