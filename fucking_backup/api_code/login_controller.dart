import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../common_code/config.dart';
import '../api_model/login_api_model.dart';
import '../app_screen/map_screen.dart';
import '../app_screen/permisiion_scren.dart';
import '../common_code/common_button.dart';

String onesignalkey = "44d5202c-02e8-4c86-98ec-fb2c018366c4";

void loginSharedPreferencesSet(bool value) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool("UserLogin", value);
}

class LoginController extends GetxController implements GetxService {
  LoginModel? loginModel;
  LocationPermission? permission;

  Future loginApi(
      {required context,
      required String phone,
      required String password,
      required String ccode}) async {
    Map body = {"phone": phone, "password": password, "ccode": ccode};

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(Uri.parse(Config.baseurl + Config.login),
        body: jsonEncode(body), headers: userHeader);

    print('+ + + + + + + + + + +$body');
    print('- - - - - - - - - - -${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        loginModel = loginModelFromJson(response.body);
        if (loginModel!.result == true) {
          permission = await Geolocator.checkPermission();
          print("{{{{{data}}}}} :--  ${jsonEncode(data["customer_data"])}");

          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString("userLogin", jsonEncode(data["customer_data"]));
          loginSharedPreferencesSet(false);

          onesignalkey = data["general"]["one_app_id"];
          print("==========:----- ($onesignalkey)");
          print("=====Config.oneSignel=====:----- (${Config.oneSignel})");

          // initPlatformState(context: context);
          // var sendTags = {'subscription_user_Type': 'customer', 'Login_ID': data["customer_data"]["id"].toString()};
          // OneSignal.User.addTags(sendTags);

          if (permission == LocationPermission.denied) {
            Get.offAll(const PermissionScreen());
          } else {
            Get.offAll(const MapScreen(
              selectvihical: false,
            ));
          }

          snackbar(context: context, text: "${data["message"]}");

          return data;
        } else {
          snackbar(context: context, text: "${data["message"]}");
        }
      } else {
        snackbar(context: context, text: "${data["message"]}");
      }
    } else {
      snackbar(context: context, text: "Something went Wrong....!!!");
    }
  }
}
