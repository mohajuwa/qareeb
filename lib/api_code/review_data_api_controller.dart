import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../services/notifier.dart';
import '../api_model/review_data_api_model.dart';

class ReviewDataApiController extends GetxController implements GetxService {
  ReviewDataApiModel? reviewDataApiModel;
  bool isLoading = true;

  Future reviewdataApi() async {
    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };
    var response = await http.get(Uri.parse(Config.baseurl + Config.reviewdata),
        headers: userHeader);

    print("++++payment++++:-- ${response.body}");

    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        reviewDataApiModel = reviewDataApiModelFromJson(response.body);
        isLoading = false;
        update();
        return data;
      } else {
        Get.back();
        Notifier.info('');
      }
    } else {
      Get.back();
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went Wrong....!!!")));
    }
  }
}
