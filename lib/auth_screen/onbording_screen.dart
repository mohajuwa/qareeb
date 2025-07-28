// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/auth_screen/onmobile1_screen.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import 'package:qareeb/common_code/language_toggle_button.dart';
import 'dart:ui' as ui;
import '../api_code/forgot_api_controller.dart';
import '../api_code/login_controller.dart';
import '../api_code/mobile_check_controller.dart';
import '../api_code/msg91_api_controller.dart';
import '../api_code/sms_type_controller.dart';
import '../api_code/twilyo_api_controoler.dart';
import '../common_code/common_button.dart';
import 'onmobile2_screen.dart';
import 'onmobile3_screen.dart';

TextEditingController signupmobilecontroller = TextEditingController();
String ccode = "";
String smscode = '';

class OnbordingScreen extends StatefulWidget {
  const OnbordingScreen({super.key});

  @override
  State<OnbordingScreen> createState() => _OnbordingScreenState();
}

class _OnbordingScreenState extends State<OnbordingScreen> {
  @override
  void initState() {
    super.initState();

    smstypeApiController.smsApi(context);

    _currentPage = 0;

    _slides = [
      Slide("assets/lottie/1st.json", provider.discover, provider.healthy),
      Slide("assets/lottie/2nd.json", provider.order, provider.orderthe),
      Slide("assets/lottie/3rd.json", provider.lets, provider.cooking),
    ];

    _pageController = PageController(initialPage: _currentPage);
  }

  int _currentPage = 0;
  List<Slide> _slides = [];
  PageController _pageController = PageController();

  SmstypeApiController smstypeApiController = Get.put(SmstypeApiController());
  MobilCheckController mobilCheckController = Get.put(MobilCheckController());
  MasgapiController masgapiController = Get.put(MasgapiController());
  TwilioapiController twilioapiController = Get.put(TwilioapiController());
  LoginController loginController = Get.put(LoginController());
  ForgotController forgotController = Get.put(ForgotController());

  TextEditingController loginpassword = TextEditingController();
  TextEditingController forgotmobile = TextEditingController();
  TextEditingController newpasswordController = TextEditingController();
  TextEditingController conformpasswordController = TextEditingController();
  OtpFieldController otpController = OtpFieldController();

  String ccodeforgot = "";
  String? otpvarableforgot;

  bool login = false;
  bool islogincontroller = false;

  ColorNotifier notifier = ColorNotifier();

  List<Widget> _buildSlides() {
    return _slides.map(_buildSlide).toList();
  }

  Widget _buildSlide(Slide slide) {
    return Scaffold(
      backgroundColor: theamcolore,
      body: Container(
        height: 300,
        width: Get.width,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        child: Lottie.asset(slide.image, fit: BoxFit.cover, height: 250),
      ),
    );
  }

  void _handlingOnPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  Widget sliderText() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            width: Get.width,
            child: Text(
              _currentPage == 0
                  ? "Welcome to Your Qareeb Ride!".tr
                  : _currentPage == 1
                      ? "Your Journey, Just a Tap Away".tr
                      : _currentPage == 2
                          ? "Wherever You Go, We're Here".tr
                          : "",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  color: notifier.textColor,
                  fontFamily: 'Khebrat'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: Get.width * 0.90,
            child: Text(
              _currentPage == 0
                  ? "Book a ride in just a few taps and reach your destination comfortably"
                      .tr
                  : _currentPage == 1
                      ? "Experience fast, reliable, and safe rides with ease."
                          .tr
                      : _currentPage == 2
                          ? "Find a ride quickly and enjoy your journey hassle-free"
                              .tr
                          : "",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          // Top half - Slides
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: Get.height * 0.5, // Top half of screen
            child: PageView(
              controller: _pageController,
              onPageChanged: _handlingOnPageChanged,
              physics: const BouncingScrollPhysics(),
              children: _buildSlides(),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: const LanguageToggleButton(),
          ),
          // Center - Phone Number Field
          Center(
            child: Container(
              width: Get.width * 0.9,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: notifier.containergreaycolore,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Slider text
                  sliderText(),
                  SizedBox(height: 30),

                  // Phone number field
                  SizedBox(
                    height: 60,
                    child: IntlPhoneField(
                      controller: signupmobilecontroller,
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        labelText: 'Phone Number'.tr,
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theamcolore),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: TextStyle(color: notifier.textColor),
                      flagsButtonPadding: EdgeInsets.zero,
                      showCountryFlag: false,
                      showDropdownIcon: false,
                      initialCountryCode: 'YE',
                      dropdownTextStyle:
                          TextStyle(color: notifier.textColor, fontSize: 15),
                      onCountryChanged: (value) {
                        setState(() {});
                      },
                      onChanged: (number) {
                        setState(() {
                          ccode = number.countryCode;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Password field if login is true
                  if (login)
                    Column(
                      children: [
                        TextFormField(
                          obscureText: true,
                          controller: loginpassword,
                          style: TextStyle(color: notifier.textColor),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.red)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.4))),
                            labelText: "Password".tr,
                            labelStyle: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: theamcolore)),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),

                  // Terms and conditions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "By clicking Continue.you agree tp our ".tr,
                        style:
                            TextStyle(color: notifier.textColor, fontSize: 12),
                      ),
                      Text("T&Cs".tr,
                          style: TextStyle(
                            color: theamcolore,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          )),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Continue button
                  CommonButton(
                      containcolore: theamcolore,
                      onPressed1: () {
                        if (signupmobilecontroller.text.isEmpty) {
                          snackbar(
                            context: context,
                            text: "All fields are required".tr,
                          );
                        } else {
                          setState(() {
                            login = false;
                          });
                          mobilCheckController.MobileCheckApi(
                                  phone: signupmobilecontroller.text,
                                  ccode: ccode,
                                  context: context)
                              .then((value) {
                            print("//////////:---   ${value}");

                            if (value['Result'] == true) {
                              if (smstypeApiController.smaApiModel!.message ==
                                  "MSG91") {
                                masgapiController
                                    .msgApi(
                                        mobilenumber:
                                            ccode + signupmobilecontroller.text,
                                        context: context)
                                    .then((value) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Onmobile2Screen(
                                                otpvariable: int.parse(
                                                    "${masgapiController.msgApiModel!.otp}"),
                                              )));
                                });
                              } else if (smstypeApiController
                                      .smaApiModel!.message ==
                                  "Twilio") {
                                print("******* Twilio *******");

                                twilioapiController
                                    .twilioApi(
                                        mobilenumber:
                                            ccode + signupmobilecontroller.text,
                                        context: context)
                                    .then((value) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Onmobile2Screen(
                                                otpvariable: int.parse(
                                                    "${twilioapiController.twilioApiModel!.otp}"),
                                              )));
                                });
                              } else if (smstypeApiController
                                      .smaApiModel!.message ==
                                  "No Auth") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const Onmobile3Screen(),
                                    ));
                              } else {
                                Fluttertoast.showToast(msg: "No Service".tr);
                              }
                            } else {
                              setState(() {
                                login = true;
                              });

                              if (signupmobilecontroller.text.isNotEmpty &&
                                  loginpassword.text.isNotEmpty) {
                                islogincontroller = true;
                                loginController
                                    .loginApi(
                                        context: context,
                                        phone: signupmobilecontroller.text,
                                        password: loginpassword.text,
                                        ccode: ccode)
                                    .then((value) {
                                  if (value["Result"] == true) {
                                    islogincontroller = false;
                                  } else {}
                                });
                              } else {
                                if (loginpassword.text.isEmpty) {
                                  snackbar(
                                      context: context, text: "Enter Password");
                                } else {
                                  snackbar(
                                      context: context,
                                      text: "All fields are required.");
                                }
                              }
                            }
                          });
                        }
                      },
                      context: context,
                      txt1: "Continue".tr),

                  SizedBox(height: 15),

                  // Forgot password
                  InkWell(
                      onTap: () {
                        Get.bottomSheet(_buildForgotPasswordBottomSheet());
                      },
                      child: Center(
                        child: Text('Forgot Password ?'.tr,
                            style: TextStyle(
                                color: notifier.textColor,
                                fontFamily: "Khebrat",
                                fontSize: 14)),
                      )),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (islogincontroller)
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                  height: Get.height,
                  width: Get.width,
                  alignment: Alignment.center,
                  child: Center(
                    child: CircularProgressIndicator(color: theamcolore),
                  )),
            ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordBottomSheet() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
          color: notifier.containercolore,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text("Forget Password ?".tr,
                style: TextStyle(
                    color: notifier.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: IntlPhoneField(
                controller: forgotmobile,
                decoration: InputDecoration(
                  counterText: "",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  labelText: 'Phone Number'.tr,
                  labelStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theamcolore),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                style: TextStyle(color: notifier.textColor),
                flagsButtonPadding: EdgeInsets.zero,
                showCountryFlag: false,
                showDropdownIcon: false,
                initialCountryCode: 'IN',
                dropdownTextStyle:
                    TextStyle(color: notifier.textColor, fontSize: 15),
                onCountryChanged: (value) {},
                onChanged: (number) {
                  setState(() {
                    ccodeforgot = number.countryCode;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            CommonButton(
                txt1: 'Continue'.tr,
                containcolore: theamcolore,
                context: context,
                onPressed1: () async {
                  if (forgotmobile.text.isEmpty) {
                    Fluttertoast.showToast(
                      msg: 'Enter Mobile Number...!!!'.tr,
                    );
                  } else {
                    _handleForgotPassword();
                  }
                }),
          ],
        ),
      ),
    );
  }

  void _handleForgotPassword() {
    mobilCheckController.MobileCheckApi(
            phone: forgotmobile.text, ccode: ccodeforgot, context: context)
        .then((value) {
      print("//////////:---   ${value}");

      if (value['Result'] == false) {
        if (smstypeApiController.smaApiModel!.message == "MSG91") {
          _handleMsg91ForgotPassword();
        } else if (smstypeApiController.smaApiModel!.message == "Twilio") {
          _handleTwilioForgotPassword();
        } else if (smstypeApiController.smaApiModel!.message == "No Auth") {
          _showCreatePasswordBottomSheet();
        } else {
          Fluttertoast.showToast(msg: "No Service".tr);
        }
      } else {
        Fluttertoast.showToast(msg: "${value['message']}");
      }
    });
  }

  void _handleMsg91ForgotPassword() {
    masgapiController
        .msgApi(mobilenumber: ccodeforgot + forgotmobile.text, context: context)
        .then((value) {
      Get.bottomSheet(_buildOtpVerificationBottomSheet(isMsg91: true));
    });
  }

  void _handleTwilioForgotPassword() {
    twilioapiController
        .twilioApi(
            mobilenumber: ccodeforgot + forgotmobile.text, context: context)
        .then((value) {
      Get.bottomSheet(_buildOtpVerificationBottomSheet(isMsg91: false));
    });
  }

  Widget _buildOtpVerificationBottomSheet({required bool isMsg91}) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: notifier.containercolore,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(15), topLeft: Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Awesome'.tr,
              style: TextStyle(
                  color: notifier.textColor,
                  fontFamily: 'Khebrat',
                  fontSize: 20),
            ),
            const SizedBox(height: 5),
            Text(
              'We have sent the OTP to ${ccode}${forgotmobile.text}'.tr,
              style:
                  TextStyle(color: notifier.textColor, fontFamily: "Khebrat"),
            ),
            const SizedBox(height: 20),
            Center(
              child: OTPTextField(
                otpFieldStyle: OtpFieldStyle(
                  enabledBorderColor: Colors.grey.withOpacity(0.4),
                ),
                controller: otpController,
                length: 6,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldWidth: 45,
                fieldStyle: FieldStyle.box,
                outlineBorderRadius: 5,
                contentPadding: const EdgeInsets.all(15),
                style: TextStyle(
                    fontSize: 17,
                    color: notifier.textColor,
                    fontFamily: "Khebrat"),
                onChanged: (pin) {
                  setState(() {
                    otpvarableforgot = smscode;
                  });
                },
                onCompleted: (pin) {
                  setState(() {
                    smscode = pin;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            CommonButton(
                txt1: 'VERIFY OTP'.tr,
                containcolore: theamcolore,
                context: context,
                onPressed1: () async {
                  _verifyOtpForForgotPassword(isMsg91: isMsg91);
                }),
          ],
        ),
      ),
    );
  }

  void _verifyOtpForForgotPassword({required bool isMsg91}) {
    bool isOtpValid = false;

    if (isMsg91) {
      isOtpValid = masgapiController.msgApiModel!.otp == otpvarableforgot;
    } else {
      isOtpValid = twilioapiController.twilioApiModel!.otp == otpvarableforgot;
    }

    if (isOtpValid) {
      _showCreatePasswordBottomSheet();
    } else {
      Fluttertoast.showToast(msg: "Incorrect OTP. Please try again.".tr);
    }
  }

  void _showCreatePasswordBottomSheet() {
    Get.bottomSheet(Container(
      height: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(15), topLeft: Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 15),
            Text('Create A New Password'.tr,
                style: const TextStyle(
                    fontSize: 18, fontFamily: "Khebrat", color: Colors.black)),
            const SizedBox(height: 15),
            CommonTextfiled2(
                txt: 'New Password'.tr,
                controller: newpasswordController,
                context: context),
            const SizedBox(height: 15),
            CommonTextfiled2(
                txt: 'Confirm Password'.tr,
                controller: conformpasswordController,
                context: context),
            const SizedBox(height: 15),
            CommonButton(
                containcolore: theamcolore,
                txt1: 'Confirm'.tr,
                context: context,
                onPressed1: () {
                  if (newpasswordController.text
                          .compareTo(conformpasswordController.text) ==
                      0) {
                    forgotController
                        .forgotApi(
                            context: context,
                            phone: forgotmobile.text,
                            password: conformpasswordController.text,
                            ccode: ccodeforgot)
                        .then((value) {
                      print("++++++$value");
                      if (value["ResponseCode"] == "200") {
                        Get.back();
                        Fluttertoast.showToast(
                          msg: value["message"],
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: value["message"],
                        );
                      }
                    });
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please enter current password".tr,
                    );
                  }
                }),
          ],
        ),
      ),
    ));
  }
}

class Slide {
  String image;
  String heading;
  String subtext;

  Slide(this.image, this.heading, this.subtext);
}

class provider {
  static String discover = "Milk made modern!".tr;
  static String healthy =
      "Our app combines the convenience of technology with the tradition of the milkman"
          .tr;
  static String order = "Never miss a delivery again!".tr;
  static String orderthe =
      "With our app, you'll receive real-time notifications about your milk deliveries"
          .tr;
  static String lets = "Milk at your fingertips!".tr;
  static String cooking =
      "order fresh milk and dairy products for delivery straight to your doorstep"
          .tr;
  static String getstart = "Get Started".tr;
  static String skip = "Skip".tr;
  static String next = "Next".tr;
}

const double _kCurveHeight = 35;

class ShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path();
    p.lineTo(0, size.height - _kCurveHeight);
    p.relativeQuadraticBezierTo(
        size.width / 2, 2 * _kCurveHeight, size.width, 0);
    p.lineTo(size.width, 0);
    p.close();

    canvas.drawPath(p, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
