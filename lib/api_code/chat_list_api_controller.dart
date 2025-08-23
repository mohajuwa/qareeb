import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qareeb/utils/show_toast.dart';
import '../common_code/config.dart';
import '../api_model/chat_list_model.dart';

class ChatListApiController extends GetxController implements GetxService {
  ChatListApiModel? chatListApiModel;
  bool isLoading = true;

  Future chatlistApi(
      {context,
      required String uid,
      required String sender_id,
      required String recevier_id,
      required String status}) async {
    Map body = {
      "uid": uid,
      "sender_id": sender_id,
      "recevier_id": recevier_id,
      "status": status,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(Uri.parse(Config.chaturl + Config.chatlist),
        body: jsonEncode(body), headers: userHeader);

    print('+ + + + + chatlistApi + + + + + + :--- $body');
    print('- - - - - chatlistApi t - - - - - - :--- ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == true) {
        chatListApiModel = chatListApiModelFromJson(response.body);
        if (chatListApiModel!.result == true) {
          // Get.offAll(BoardingPage());
          isLoading = false;
          update();

          // showToastForDuration("${data["message"]}", 3);

          return data;
        } else {
          // showToastForDuration("${data["message"]}", 3);

          return data;
        }
      } else {
        // showToastForDuration("${data["message"]}", 3);

        return data;
      }
    } else {
      showToastForDuration("Somthing went wrong!.....", 3);
    }
  }
}
