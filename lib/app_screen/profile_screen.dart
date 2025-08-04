// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/modern_loading_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/api_code/profile_edit_api_controller.dart';
import 'package:qareeb/app_screen/map_screen.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import 'package:qareeb/common_code/common_button.dart';
import 'package:qareeb/common_code/config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    // TODO: implement initState
    dataget();
    super.initState();
  }

  var decodeUid;

  bool loading = true;

  dataget() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("userLogin");

    decodeUid = jsonDecode(uid!);
    print("===:-- ${decodeUid["name"]}");
    print("===:-- ${decodeUid["email"]}");
    print("===:-- ${decodeUid["phone"]}");
    print("===:-- ${decodeUid["country_code"]}");
    print("===:-- ${decodeUid["profile_image"]}");

    namecontroller.text = decodeUid["name"];
    emailcontroller.text = decodeUid["email"];
    phonecontroller.text = decodeUid["phone"];

    setState(() {
      loading = false;
    });
  }

  File? _selectedprofile;

  Future<void> _profileimage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedprofile = File(pickedFile.path);
      });
    }
  }

  Future getlocledata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      decodeUid = jsonDecode(prefs.getString("userLogin")!);

      // fun();
      // print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+bhjgbkjsnlskn-+-+${userData["id"]}');
    });
  }

  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  ProfileeditApiController profileeditApiController =
      Get.put(ProfileeditApiController());
  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: CommonButton(
            containcolore: theamcolore,
            onPressed1: () {
              // print("*****:-------()()():-- ${_selectedprofile!.path}");
              if (namecontroller.text.isNotEmpty &&
                  emailcontroller.text.isNotEmpty) {
                profileeditApiController.PrifileediteApi(
                        profile_img: _selectedprofile == null
                            ? ""
                            : _selectedprofile!.path,
                        id: decodeUid["id"].toString(),
                        name: namecontroller.text,
                        email: emailcontroller.text,
                        password: passwordcontroller.text)
                    .then((value) async {
                  // SharedPreferences pre = await SharedPreferences.getInstance();
                  // pre.setString("loginData", jsonEncode(value["UserLogin"]));
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.setString(
                      "userLogin", jsonEncode(value["customer_data"]));
                  getlocledata().then(
                    (value) async {
                      // await Future.delayed(Duration(seconds: 10),() {
                      //   Navigator.push(context, MaterialPageRoute(builder: (context) => const ModernMapScreen(),));
                      Get.offAll(const ModernMapScreen(
                        selectVehicle: false,
                      ));
                      // },);
                    },
                  );

                  // Get.back();
                  // Get.back();
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text(value["message"].toString()),behavior: SnackBarBehavior.floating,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                  // );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Enter Input'.tr),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            context: context,
            txt1: "Update".tr),
      ),
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        iconTheme: IconThemeData(color: notifier.textColor),
        centerTitle: true,
        title: Text(
          "My Profile".tr,
          style: TextStyle(color: notifier.textColor),
        ),
      ),
      body: loading == true
          ? const Center(
              child: ModernLoadingWidget(
                message: "جaري تحميل الملف الشخصي...",
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  // const SizedBox(height: 60,),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _profileimage().then(
                          (value) {
                            setState(() {});
                          },
                        );
                      });
                    },
                    child: Stack(
                      children: [
                        // Container(
                        //   height: 90,
                        //   width: 90,
                        //   decoration: BoxDecoration(
                        //       color: theamcolore,
                        //       shape: BoxShape.circle
                        //   ),
                        //   child: decodeUid["profile_image"] == "" ?  _selectedprofile != null
                        //       ? ClipRRect(borderRadius: BorderRadius.circular(65), child: Image.file(_selectedprofile!, fit: BoxFit.cover,))
                        //       : Center(child: Text("${decodeUid["name"][0]}",style: const TextStyle(color: Colors.white,fontSize: 25))) :
                        //   ClipRRect(borderRadius: BorderRadius.circular(65), child: Image.network("${Config.imageurl}${decodeUid["profile_image"]}",fit: BoxFit.cover,)),
                        // ),

                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                              color: greaycolore, shape: BoxShape.circle),
                          child: _selectedprofile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(65),
                                  child: Image.file(
                                    _selectedprofile!,
                                    fit: BoxFit.cover,
                                  ))
                              : decodeUid["profile_image"] == ""
                                  ? Center(
                                      child: Text("${decodeUid["name"][0]}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 25)))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(65),
                                      child: Image.network(
                                        "${Config.imageurl}${decodeUid["profile_image"]}",
                                        fit: BoxFit.cover,
                                      )),
                        ),

                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                color: theamcolore,
                                border: Border.all(color: Colors.white),
                                shape: BoxShape.circle),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    decodeUid["name"] == "" ? "" : decodeUid["name"],
                    style: TextStyle(
                        color: notifier.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CommonTextfiled200(
                      txt: "Name".tr,
                      context: context,
                      controller: namecontroller),
                  const SizedBox(
                    height: 10,
                  ),
                  CommonTextfiled200(
                      txt: "Email".tr,
                      context: context,
                      controller: emailcontroller),
                  const SizedBox(
                    height: 10,
                  ),
                  CommonTextfiled200(
                      txt: "Password".tr,
                      context: context,
                      controller: passwordcontroller),
                  const SizedBox(
                    height: 10,
                  ),
                  IntlPhoneField(
                    controller: phonecontroller,
                    readOnly: true,
                    style: TextStyle(color: notifier.textColor),
                    decoration: InputDecoration(
                      counterText: "",
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: EdgeInsets.only(top: 8),
                      hintText: '${phonecontroller.text}',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xff7D2AFF)),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    flagsButtonPadding: EdgeInsets.zero,
                    showCountryFlag: false,
                    showDropdownIcon: false,
                    initialCountryCode: 'IN',
                    dropdownTextStyle:
                        TextStyle(color: notifier.textColor, fontSize: 15),
                    // style: const TextStyle(color: Colors.black,fontSize: 16),
                    onChanged: (number) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
