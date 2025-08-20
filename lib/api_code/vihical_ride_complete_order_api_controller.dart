import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../app_screen/pickup_drop_point.dart';
import '../services/notifier.dart';
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
    print("vvvpayment_imgvvv:-- $payment_img");

    if (orederloader) {
      return null;
    } else {
      orederloader = true;
    }

    var request = http.MultipartRequest(
        'POST', Uri.parse(Config.baseurl + Config.vihicalridecomplete));

    request.fields.addAll({
      'uid': uid,
      'd_id': d_id,
      'request_id': request_id,
      'wallet': wallet,
      'payment_id': payment_id,
    });

    if (payment_img != "") {
      request.files
          .add(await http.MultipartFile.fromPath('payment_img', payment_img));
    } else {
      print("ffffffffffff");
    }

    http.StreamedResponse response = await request.send();

    final responseString = await response.stream.bytesToString();
    final responsnessaj = jsonDecode(responseString);

    print("API Response Status Code: ${response.statusCode}");
    print("API Response Body: $responsnessaj");

    if (response.statusCode == 200) {
      orederloader = false;

      print("MMMMMMMMM (bar) MMMMMMMMM:- ${responsnessaj["review_list"]}");

      if (responsnessaj["Result"] == true) {
        isloadoing = false;

        // Extract and store the request_id from response
        String responseRequestId = responsnessaj["request_id"].toString();
        ridecompleterequestid = responseRequestId;

        print("Setting ridecompleterequestid to: $responseRequestId");

        vihicalRideCompleteApiModel =
            VihicalRideCompleteApiModel.fromJson(responsnessaj);

        // Clear pickup/drop data
        pickupcontroller.text = "";
        dropcontroller.text = "";
        latitudepick = 0.00;
        longitudepick = 0.00;
        latitudedrop = 0.00;
        longitudedrop = 0.00;
        picktitle = "";
        picksubtitle = "";
        droptitle = "";
        dropsubtitle = "";
        droptitlelist = [];
        destinationlat = [];
        destinationlong = [];
        textfieldlist = [];

        print("++hahaha++:- (${pickupcontroller.text})");
        print("++hahaha++:- (${dropcontroller.text})");
        print("++hahaha++:- ($latitudepick)");
        print("++hahaha++:- ($longitudepick)");
        print("++hahaha++:- ($latitudedrop)");
        print("++hahaha++:- ($longitudedrop)");
        print("++hahaha++:- ($picktitle)");
        print("++hahaha++:- ($picksubtitle)");
        print("++hahaha++:- ($droptitle)");
        print("++hahaha++:- ($dropsubtitle)");
        print("++hahaha++:- ($droptitlelist)");

        // Return the request_id so it can be used immediately
        return responseRequestId;
      } else {
        print("API Result is false: ${responsnessaj["message"]}");

        return null;
      }
    } else {
      print("API call failed with status code: ${response.statusCode}");
      orederloader = false;

      return null;
    }
  }
}
