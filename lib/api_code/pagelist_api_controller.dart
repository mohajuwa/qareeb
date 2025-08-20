import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../services/notifier.dart';
import '../api_model/pagelist_api_model.dart';
import '../common_code/config.dart';


class pagelistApiController extends GetxController implements GetxService {

  PageListApiiimodel? pageListApiiimodel;
  bool isLoading = true;

  pagelistttApi(context) async{

    Map<String,String> userHeader = {"Content-type": "application/json", "Accept": "application/json"};
    var response = await http.get(Uri.parse(Config.baseurl + Config.pagelistapi),headers: userHeader);

    print(response.body);

    var data = jsonDecode(response.body);
    if(response.statusCode == 200){
      if(data["Result"] == true){
        pageListApiiimodel = pageListApiiimodelFromJson(response.body);
        isLoading = false;
        update();
      }
      else{
        Get.back();
        Notifier.info('');
      }
    }
    else{
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went Wrong....!!!")));
    }
  }
}