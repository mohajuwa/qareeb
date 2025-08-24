import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../api_model/all_request_api_model.dart';
import 'calculate_api_controller.dart';

class AllRequestDataApiController extends GetxController
    implements GetxService {
  AllRequestDataModel? allRequestDataModelupcoming;
  AllRequestDataModel? allRequestDataModelcompleted;
  AllRequestDataModel? allRequestDataModelcancelled;
  bool isLoading = true;

  Future allrequestApi(
      {context, required String uid, required String status}) async {
    Map body = {
      "uid": uid,
      "status": status,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(
        Uri.parse(Config.baseurl + Config.allrequest),
        body: jsonEncode(body),
        headers: userHeader);

    print('+ + + + + AddVihicalCalCulate + + + + + + :--- $body');
    print('- - - - - AddVihicalCalCulate - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        if (status == "upcoming") {
          print("+++++ upcoming +++++");
          allRequestDataModelupcoming =
              allRequestDataModelFromJson(response.body);
        } else if (status == "completed") {
          print("+++++ completed +++++");
          allRequestDataModelcompleted =
              allRequestDataModelFromJson(response.body);
        } else {
          print("+++++ cancelled +++++");
          allRequestDataModelcancelled =
              allRequestDataModelFromJson(response.body);
        }

        update();

        if (allRequestDataModelupcoming!.result == true) {
          isLoading = false;
          update();
        } else {
          Fluttertoast.showToast(
            msg: "${allRequestDataModelupcoming!.message}",
          );
        }
      } else {
        showToastForDuration("${data["message"]}", 2);
        return data;
      }
    } else {
      showToastForDuration("Somthing went wrong!.....", 2);
    }
  }
}
