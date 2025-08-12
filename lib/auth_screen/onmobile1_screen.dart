// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/colore_screen.dart';

// TextEditingController signupmobilecontroller = TextEditingController();
// String ccode ="";
// String smscode = '';

class Onmobile1Screen extends StatefulWidget {
  const Onmobile1Screen({super.key});

  @override
  State<Onmobile1Screen> createState() => _Onmobile1ScreenState();
}

class _Onmobile1ScreenState extends State<Onmobile1Screen> {
  // SmstypeApiController smstypeApiController = Get.put(SmstypeApiController());
  // MobilCheckController mobilCheckController = Get.put(MobilCheckController());
  // MasgapiController masgapiController = Get.put(MasgapiController());
  // TwilioapiController twilioapiController = Get.put(TwilioapiController());
  // LoginController loginController = Get.put(LoginController());
  // ForgotController forgotController = Get.put(ForgotController());
  //
  // TextEditingController loginpassword = TextEditingController();
  // TextEditingController forgotmobile = TextEditingController();
  // TextEditingController newpasswordController = TextEditingController();
  // TextEditingController conformpasswordController = TextEditingController();
  // OtpFieldController otpController = OtpFieldController();
  //
  // String ccodeforgot ="";
  // String? otpvarableforgot;
  //
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   smstypeApiController.smsApi(context);
  //   super.initState();
  // }
  //
  //
  // bool login = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            color: theamcolore,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: SvgPicture.asset(
                          "assets/svgpicture/lestarroe.svg",
                          color: Colors.white,
                          height: 35,
                        )),
                    const Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 2,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 2,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 2,
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Step 1/3".tr,
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                // Spacer(),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Let's get you trip-ready!".tr,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          //   Padding(
          //   padding: const EdgeInsets.all(15),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Text("Enter your Mobile Number",style: TextStyle(color: Colors.black),),
          //       const SizedBox(height: 15,),
          //       IntlPhoneField(
          //         controller: signupmobilecontroller,
          //         decoration:  InputDecoration(
          //           counterText: "",
          //           enabledBorder: OutlineInputBorder(
          //             borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
          //             borderRadius: BorderRadius.circular(15),
          //           ),
          //           labelText: 'Phone Number'.tr,
          //           labelStyle: const TextStyle(
          //             color: Colors.grey,
          //             fontSize: 14,
          //           ),
          //           border: OutlineInputBorder(
          //             borderSide: const BorderSide(color: Colors.grey,),
          //             borderRadius: BorderRadius.circular(15),
          //           ),
          //           focusedBorder: OutlineInputBorder(
          //             borderSide: BorderSide(color: theamcolore),
          //             borderRadius: BorderRadius.circular(15),
          //           ),
          //         ),
          //         style: const TextStyle(color: Colors.black),
          //         flagsButtonPadding: EdgeInsets.zero,
          //         showCountryFlag: false,
          //         showDropdownIcon: false,
          //         initialCountryCode: 'YE',
          //         dropdownTextStyle: const TextStyle(color: Colors.black,fontSize: 15),
          //         onCountryChanged: (value) {
          //           setState(() {
          //             // langth = value.maxLength;
          //             // ccode = number.countryCode;
          //           });
          //         },
          //         onChanged: (number) {
          //           setState(() {
          //             ccode = number.countryCode;
          //           });
          //         },
          //       ),
          //       const SizedBox(height: 15,),
          //       login == true ?  Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           const Text("Enter Password",style: TextStyle(color: Colors.black),),
          //           const SizedBox(height: 10,),
          //           CommonTextfiled200(txt: "Password", context: context,controller: loginpassword),
          //           const SizedBox(height: 15,),
          //         ],
          //       ) : SizedBox(),
          //       Row(
          //         children: [
          //           const Text("By clicking Continue.you agree tp our "),
          //           Text("T&Cs",style: TextStyle(color: theamcolore, decoration: TextDecoration.underline,)),
          //         ],
          //       ),
          //       const SizedBox(height: 15,),
          //       CommonButton(containcolore: theamcolore, onPressed1: () {
          //
          //         // Navigator.push(context, MaterialPageRoute(builder: (context) => const Onmobile2Screen()));
          //
          //         if(signupmobilecontroller.text.isEmpty){
          //           Fluttertoast.showToast(msg: "All fields are required.".tr);
          //         }else{
          //
          //          setState(() {
          //            login = false;
          //          });
          //           mobilCheckController.MobileCheckApi(phone: signupmobilecontroller.text, ccode: ccode,context: context).then((value) {
          //             print("//////////:---   ${value}");
          //
          //             if(value['Result'] == true) {
          //               if (smstypeApiController.smaApiModel!.message == "MSG91") {
          //
          //                 masgapiController.msgApi(mobilenumber: ccode + signupmobilecontroller.text, context: context).then((value) {
          //                   Navigator.push(context, MaterialPageRoute(builder: (context) => Onmobile2Screen(otpvariable: int.parse("${masgapiController.msgApiModel!.otp}"),)));
          //                 },);
          //
          //               }
          //               else if (smstypeApiController.smaApiModel!.message == "Twilio") {
          //                 print("******* Twilio *******");
          //
          //                 twilioapiController.twilioApi(mobilenumber: ccode + signupmobilecontroller.text, context: context).then((value) {
          //                   Navigator.push(context, MaterialPageRoute(builder: (context) => Onmobile2Screen(otpvariable: int.parse("${twilioapiController.twilioApiModel!.otp}"),)));
          //                 },);
          //
          //               }
          //               else {
          //                 Fluttertoast.showToast(msg: "No Service".tr);
          //               }
          //
          //             }
          //             else{
          //
          //              setState(() {
          //                login = true;
          //              });
          //
          //              if(signupmobilecontroller.text.isNotEmpty && loginpassword.text.isNotEmpty){
          //                loginController.loginApi(context: context, phone: signupmobilecontroller.text, password: loginpassword.text, ccode: ccode);
          //              }else{
          //
          //                if(loginpassword.text.isEmpty){
          //                  Fluttertoast.showToast(msg: "Enter Password".tr);
          //                }else{
          //                  Fluttertoast.showToast(msg: "All fields are required.".tr);
          //                }
          //
          //              }
          //
          //               // print("not done condition");
          //               // Fluttertoast.showToast(msg: "${value['message']}".tr);
          //             }
          //
          //           },);
          //
          //
          //
          //         }
          //
          //
          //
          //
          //       },context: context,txt1: "Continue"),
          //       SizedBox(height: 15,),
          //       Row(
          //         children: [
          //           const Spacer(),
          //           InkWell(
          //               onTap: () {
          //
          //                 Get.bottomSheet(
          //                     Container(
          //                       height: 220,
          //                       decoration:  BoxDecoration(
          //                           color: Colors.white,
          //                           borderRadius: const BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10))
          //                       ),
          //                       child: Padding(
          //                         padding: const EdgeInsets.only(left: 15,right: 15),
          //                         child: Column(
          //                           mainAxisAlignment: MainAxisAlignment.start,
          //                           crossAxisAlignment: CrossAxisAlignment.start,
          //                           children: [
          //                             const SizedBox(height: 20,),
          //                             Text("Forget Password ?".tr,style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold)),
          //                             const SizedBox(height: 10,),
          //                             IntlPhoneField(
          //                               controller: forgotmobile,
          //                               decoration:  InputDecoration(
          //                                 counterText: "",
          //                                 enabledBorder: OutlineInputBorder(
          //                                   borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
          //                                   borderRadius: BorderRadius.circular(15),
          //                                 ),
          //                                 labelText: 'Phone Number'.tr,
          //                                 labelStyle: const TextStyle(
          //                                   color: Colors.grey,
          //                                   fontSize: 14,
          //                                 ),
          //                                 border: OutlineInputBorder(
          //                                   borderSide: const BorderSide(color: Colors.grey,),
          //                                   borderRadius: BorderRadius.circular(15),
          //                                 ),
          //                                 focusedBorder: OutlineInputBorder(
          //                                   borderSide:  BorderSide(color: theamcolore),
          //                                   borderRadius: BorderRadius.circular(15),
          //                                 ),
          //
          //                               ),
          //                               style: TextStyle(color: Colors.black),
          //                               flagsButtonPadding: EdgeInsets.zero,
          //                               showCountryFlag: false,
          //                               showDropdownIcon: false,
          //                               initialCountryCode: 'YE',
          //                               dropdownTextStyle:   TextStyle(color: Colors.black,fontSize: 15),
          //                               onCountryChanged: (value) {
          //
          //                               },
          //                               onChanged: (number) {
          //                                 setState(() {
          //                                   ccodeforgot = number.countryCode;
          //                                 });
          //                               },
          //                             ),
          //                             const SizedBox(height: 20,),
          //                             CommonButton(txt1: 'Continue'.tr,containcolore: theamcolore,context: context,onPressed1: () async{
          //
          //                               if(forgotmobile.text.isEmpty){
          //                                 Fluttertoast.showToast(msg: 'Enter Mobile Number...!!!'.tr,);
          //                               }else{
          //
          //
          //
          //
          //                                 mobilCheckController.MobileCheckApi(phone: forgotmobile.text, ccode: ccodeforgot,context: context).then((value) {
          //                                   print("//////////:---   ${value}");
          //
          //                                   if(value['Result'] == false) {
          //                                     if (smstypeApiController.smaApiModel!.message == "MSG91") {
          //
          //
          //                                       masgapiController.msgApi(mobilenumber: ccodeforgot + forgotmobile.text, context: context).then((value) {
          //                                         Get.bottomSheet(
          //                                             Container(
          //                                               height: 230,
          //                                               decoration: const BoxDecoration(
          //                                                   color: Colors.white,
          //                                                   borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
          //                                               ),
          //                                               child: Padding(
          //                                                 padding: const EdgeInsets.only(left: 15,right: 15),
          //                                                 child: Column(
          //                                                   mainAxisAlignment: MainAxisAlignment.start,
          //                                                   crossAxisAlignment: CrossAxisAlignment.start,
          //                                                   children: [
          //                                                     const SizedBox(height: 20,),
          //                                                     Text('Awesome'.tr,style: TextStyle(color: Colors.black,fontFamily: 'SofiaProBold',fontSize: 20),),
          //                                                     const SizedBox(height: 5,),
          //                                                     Text('We have sent the OTP to ${ccode}${forgotmobile.text}'.tr,style:  TextStyle(color: Colors.black,fontFamily: "SofiaProBold"),),
          //                                                     const SizedBox(height: 20,),
          //                                                     Center(
          //                                                       child: OTPTextField(
          //                                                         otpFieldStyle: OtpFieldStyle(
          //                                                           enabledBorderColor: Colors.grey.withOpacity(0.4),
          //                                                         ),
          //                                                         controller: otpController,
          //                                                         length: 6,
          //                                                         width: MediaQuery.of(context).size.width,
          //                                                         textFieldAlignment: MainAxisAlignment.spaceAround,
          //                                                         fieldWidth: 45,
          //                                                         fieldStyle: FieldStyle.box,
          //                                                         outlineBorderRadius: 5,
          //                                                         contentPadding: const EdgeInsets.all(15),
          //                                                         style:  TextStyle(fontSize: 17,color: Colors.black,fontFamily: "SofiaProBold"),
          //                                                         onChanged: (pin) {
          //                                                           setState(() {
          //                                                             otpvarableforgot = smscode;
          //                                                           });
          //                                                         },
          //                                                         onCompleted: (pin) {
          //                                                           setState(() {
          //                                                             smscode = pin;
          //                                                           });
          //                                                         },
          //                                                       ),
          //                                                     ),
          //                                                     const SizedBox(height: 20,),
          //                                                     CommonButton(txt1: 'VERIFY OTP'.tr,containcolore: theamcolore,context: context,onPressed1: () async{
          //
          //                                                       if (masgapiController.msgApiModel!.otp == otpvarableforgot) {
          //                                                         Get.bottomSheet(Container(
          //                                                           height: 250,
          //                                                           decoration: const BoxDecoration(
          //                                                             color: Colors.white,
          //                                                             borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
          //                                                           ),
          //                                                           child: Padding(
          //                                                             padding: const EdgeInsets.only(left: 10,right: 10),
          //                                                             child: Column(
          //                                                               mainAxisSize: MainAxisSize.min,
          //                                                               children: <Widget>[
          //                                                                 const SizedBox(height: 15,),
          //                                                                 Text('Create A New Password'.tr,style: const TextStyle(fontSize: 18,fontFamily: "SofiaProBold",color: Colors.black)),
          //                                                                 const SizedBox(height: 15,),
          //                                                                 CommonTextfiled2(txt: 'New Password'.tr,controller: newpasswordController,context: context),
          //                                                                 const SizedBox(height: 15,),
          //                                                                 CommonTextfiled2(txt: 'Confirm Password'.tr,controller: conformpasswordController,context: context),
          //                                                                 const SizedBox(height: 15,),
          //                                                                 CommonButton(containcolore: theamcolore,txt1: 'Confirm'.tr,context: context,onPressed1: () {
          //                                                                   if(newpasswordController.text.compareTo(conformpasswordController.text) == 0){
          //                                                                     forgotController.forgotApi(phone: forgotmobile.text, password: conformpasswordController.text, ccode: ccodeforgot).then((value) {
          //                                                                       // print("++++++$value");
          //                                                                       // if(value["ResponseCode"] == "200"){
          //                                                                       //   Get.back();
          //                                                                       //   Fluttertoast.showToast(
          //                                                                       //     msg: value["message"],
          //                                                                       //   );
          //                                                                       // }else{
          //                                                                       //
          //                                                                       //   Fluttertoast.showToast(
          //                                                                       //     msg: value["message"],
          //                                                                       //   );
          //                                                                       //
          //                                                                       // }
          //                                                                     });
          //                                                                   }else{
          //
          //                                                                     Fluttertoast.showToast(
          //                                                                       msg: "Please enter current password".tr,
          //                                                                     );
          //                                                                   }
          //                                                                 }),
          //                                                               ],
          //                                                             ),
          //                                                           ),
          //                                                         ));
          //                                                       } else {
          //                                                         Fluttertoast.showToast(msg: "Incorrect OTP. Please try again.".tr);
          //                                                       }
          //
          //
          //
          //                                                     }),
          //                                                     const SizedBox(height: 20,),
          //
          //                                                   ],
          //                                                 ),
          //                                               ),
          //                                             )
          //                                         );
          //                                       },);
          //
          //
          //
          //                                     }
          //                                     else if (smstypeApiController.smaApiModel!.message == "Twilio") {
          //                                       print("******* Twilio *******");
          //
          //                                       twilioapiController.twilioApi(mobilenumber: ccodeforgot + forgotmobile.text, context: context).then((value) {
          //                                         Get.bottomSheet(
          //                                             Container(
          //                                               height: 230,
          //                                               decoration: const BoxDecoration(
          //                                                   color: Colors.white,
          //                                                   borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15))
          //                                               ),
          //                                               child: Padding(
          //                                                 padding: const EdgeInsets.only(left: 15,right: 15),
          //                                                 child: Column(
          //                                                   mainAxisAlignment: MainAxisAlignment.start,
          //                                                   crossAxisAlignment: CrossAxisAlignment.start,
          //                                                   children: [
          //                                                     const SizedBox(height: 20,),
          //                                                     Text('Awesome'.tr,style: TextStyle(color: Colors.black,fontFamily: 'SofiaProBold',fontSize: 20),),
          //                                                     const SizedBox(height: 5,),
          //                                                     Text('We have sent the OTP to ${ccode}${forgotmobile.text}'.tr,style:  TextStyle(color: Colors.black,fontFamily: "SofiaProBold"),),
          //                                                     const SizedBox(height: 20,),
          //                                                     Center(
          //                                                       child: OTPTextField(
          //                                                         otpFieldStyle: OtpFieldStyle(
          //                                                           enabledBorderColor: Colors.grey.withOpacity(0.4),
          //                                                         ),
          //                                                         controller: otpController,
          //                                                         length: 6,
          //                                                         width: MediaQuery.of(context).size.width,
          //                                                         textFieldAlignment: MainAxisAlignment.spaceAround,
          //                                                         fieldWidth: 45,
          //                                                         fieldStyle: FieldStyle.box,
          //                                                         outlineBorderRadius: 5,
          //                                                         contentPadding: const EdgeInsets.all(15),
          //                                                         style:  TextStyle(fontSize: 17,color: Colors.black,fontFamily: "SofiaProBold"),
          //                                                         onChanged: (pin) {
          //                                                          setState(() {
          //                                                            otpvarableforgot = smscode;
          //                                                          });
          //                                                           // otpvarable = int.parse(smscode);
          //                                                         },
          //                                                         onCompleted: (pin) {
          //                                                           setState(() {
          //                                                             smscode = pin;
          //                                                           });
          //                                                         },
          //                                                       ),
          //                                                     ),
          //                                                     const SizedBox(height: 20,),
          //                                                     CommonButton(txt1: 'VERIFY OTP'.tr,containcolore: theamcolore,context: context,onPressed1: () async{
          //
          //                                                       if (twilioapiController.twilioApiModel!.otp == otpvarableforgot) {
          //                                                         Get.bottomSheet(Container(
          //                                                           height: 250,
          //                                                           decoration: const BoxDecoration(
          //                                                             color: Colors.white,
          //                                                             borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
          //                                                           ),
          //                                                           child: Padding(
          //                                                             padding: const EdgeInsets.only(left: 10,right: 10),
          //                                                             child: Column(
          //                                                               mainAxisSize: MainAxisSize.min,
          //                                                               children: <Widget>[
          //                                                                 const SizedBox(height: 15,),
          //                                                                 Text('Create A New Password'.tr,style: const TextStyle(fontSize: 18,fontFamily: "SofiaProBold",color: Colors.black)),
          //                                                                 const SizedBox(height: 15,),
          //                                                                 CommonTextfiled2(txt: 'New Password'.tr,controller: newpasswordController,context: context),
          //                                                                 const SizedBox(height: 15,),
          //                                                                 CommonTextfiled2(txt: 'Confirm Password'.tr,controller: conformpasswordController,context: context),
          //                                                                 const SizedBox(height: 15,),
          //                                                                 CommonButton(containcolore: theamcolore,txt1: 'Confirm'.tr,context: context,onPressed1: () {
          //                                                                   if(newpasswordController.text.compareTo(conformpasswordController.text) == 0){
          //                                                                     forgotController.forgotApi(phone: forgotmobile.text, password: conformpasswordController.text, ccode: ccodeforgot).then((value) {
          //                                                                       print("++++++$value");
          //                                                                       if(value["ResponseCode"] == "200"){
          //                                                                         Get.back();
          //                                                                         Fluttertoast.showToast(
          //                                                                           msg: value["message"],
          //                                                                         );
          //                                                                       }else{
          //
          //                                                                         Fluttertoast.showToast(
          //                                                                           msg: value["message"],
          //                                                                         );
          //
          //                                                                       }
          //                                                                     });
          //                                                                   }else{
          //
          //                                                                     Fluttertoast.showToast(
          //                                                                       msg: "Please enter current password".tr,
          //                                                                     );
          //                                                                   }
          //                                                                 }),
          //                                                               ],
          //                                                             ),
          //                                                           ),
          //                                                         ));
          //                                                       } else {
          //                                                         Fluttertoast.showToast(msg: "Incorrect OTP. Please try again.".tr);
          //                                                       }
          //
          //
          //                                                     }),
          //                                                     const SizedBox(height: 20,),
          //
          //                                                   ],
          //                                                 ),
          //                                               ),
          //                                             )
          //                                         );
          //                                       },);
          //
          //                                     }
          //                                     else {
          //                                       Fluttertoast.showToast(msg: "No Service".tr);
          //                                     }
          //                                   }
          //                                   else{
          //                                     Fluttertoast.showToast(msg: "${value['message']}",);
          //                                   }
          //
          //                                 },);
          //
          //
          //
          //
          //                               }
          //
          //
          //
          //                             }),
          //                             const SizedBox(height: 20,),
          //
          //                           ],
          //                         ),
          //                       ),
          //                     )
          //                 );
          //
          //               },
          //               child:  Center(child: Text('Forgot Password ?'.tr,style: TextStyle(color: Colors.black,fontFamily: "SofiaProBold",fontSize: 14)),)),
          //
          //         ],
          //       ),
          //
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}
