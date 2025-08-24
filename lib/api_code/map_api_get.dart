import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common_code/config.dart';
import '../api_model/map_api_model.dart';

class MapSuggestGetApiController extends GetxController implements GetxService {
  MapApiModel? mapApiModel;
  bool isLoading = true;
  mapApi({required context, required String suggestkey}) async {
    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };
    // https://maps.googleapis.com/maps/api/place/textsearch/json?query=katargam%20pi&key=AIzaSyB-Vi0HNjZs8eNOMMTazt-T01Gw6EYckHg
    var response = await http.get(
        Uri.parse(
            "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$suggestkey%20pi&key=${Config.mapkey}"),
        headers: userHeader);

    var data = jsonDecode(response.body);

    print("hhhhhhhhhhhhhhhhhhhhhhhhhhh");

    if (data["status"] == "OK") {
      mapApiModel = mapApiModelFromJson(response.body);
      isLoading = false;
      update();
    } else {}
  }
}
