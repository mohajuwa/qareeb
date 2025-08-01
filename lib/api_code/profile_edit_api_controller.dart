// lib/api_code/profile_edit_api_controller.dart

import 'dart:convert';

import 'dart:io';

import 'package:qareeb/common_code/toastification.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import 'package:http/io_client.dart';

import '../common_code/config.dart';

class ProfileeditApiController extends GetxController implements GetxService {
  bool isLoading = true;

  Future PrifileediteApi(
      {required String id,
      required String name,
      required String email,
      required String password,
      required String profile_img,
      context}) async {
    try {
      // Create HTTP client that handles SSL certificates

      HttpClient httpClient = HttpClient();

      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      httpClient.connectionTimeout = const Duration(seconds: 30);

      http.Client client = IOClient(httpClient);

      var request = http.MultipartRequest(
          'POST', Uri.parse(Config.baseurl + Config.editprofile));

      request.fields.addAll({
        'id': id,
        'name': name,
        'email': email,
        'password': password,
      });

      if (profile_img != "") {
        request.files
            .add(await http.MultipartFile.fromPath('profile_img', profile_img));
      }

      http.StreamedResponse response = await client.send(request);

      final responseString = await response.stream.bytesToString();

      final responsnessaj = jsonDecode(responseString);

      if (response.statusCode == 200) {
        if (responsnessaj["Result"] == true) {
          isLoading = false;

          ToastService.showToast(responsnessaj["message"]);

          return responsnessaj;
        } else {
          ToastService.showToast(responsnessaj["message"]);
        }
      } else {
        ToastService.showToast("HTTP Error: ${response.statusCode}");
      }

      client.close();
    } catch (e) {
      print("Profile Edit API Error: $e");

      ToastService.showToast("Update failed. Please try again.");
    }
  }
}
