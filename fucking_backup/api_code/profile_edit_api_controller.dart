import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../services/notifier.dart';
import '../common_code/config.dart';

// class ProfileeditApiController extends GetxController implements GetxService {
//
//   // PageListApiiimodel? pageListApiiimodel;
//   bool isLoading = true;
//
//   Future PrifileediteApi({required String id,required String name,required String email,required String password,required String profile_img}) async {
//
//     Map body = {
//       'id' : id,
//       'name': name,
//       'email': email,
//       'password':password,
//       'profile_img':profile_img,
//     };
//
//     print("+++ $body");
//     try{
//       var response2 = await http.post(Uri.parse('${Config.baseurl}${Config.editprofile}'), body: jsonEncode(body), headers: {
//         'Content-Type': 'application/json',
//       });
//
//       print(response2.body);
//       if(response2.statusCode == 200){
//         return jsonDecode(response2.body);
//       }else{
//         print('failed');
//       }
//
//     }catch(e){
//       print(e.toString());
//     }
//   }
//
// }

class ProfileeditApiController extends GetxController implements GetxService {
  bool isLoading = true;

  Future PrifileediteApi(
      {required String id,
      required String name,
      required String email,
      required String password,
      required String profile_img,
      context}) async {
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
    } else {
      print("ffffffffffff");
    }

    http.StreamedResponse response = await request.send();

    final responseString = await response.stream.bytesToString();
    final responsnessaj = jsonDecode(responseString);

    if (response.statusCode == 200) {
      if (responsnessaj["Result"] == true) {
        isLoading = false;

        Notifier.info("${responsnessaj["message"]}");
        return responsnessaj;
      } else {
        Notifier.error("${responsnessaj["message"]}");
      }
    } else {
      Notifier.error("${responsnessaj["message"]}");
    }
  }
}
