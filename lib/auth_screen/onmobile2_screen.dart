// ignore_for_file: avoid_prin
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_field
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/custom_notification.dart';
import 'onmobile3_screen.dart';
import '../api_code/msg91_api_controller.dart';
import '../api_code/sms_type_controller.dart';
import '../api_code/twilyo_api_controoler.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';
import 'onbording_screen.dart';

class Onmobile2Screen extends StatefulWidget {
  final int otpvariable;

  const Onmobile2Screen({super.key, required this.otpvariable});

  @override
  State<Onmobile2Screen> createState() => _Onmobile2ScreenState();
}

class _Onmobile2ScreenState extends State<Onmobile2Screen> {
  @override
  void initState() {
    otpvarable2 = widget.otpvariable;
    startTimer();
    smstypeApiController.smsApi(context);
    print("::::::::::::::------- ${otpvarable2}");
    super.initState();
  }

  String smscode = '';
  late int otpvarable2;

  OtpFieldController signotpController = OtpFieldController();

  MasgapiController masgapiController = Get.put(MasgapiController());
  SmstypeApiController smstypeApiController = Get.put(SmstypeApiController());
  TwilioapiController twilioapiController = Get.put(TwilioapiController());

  int secondsRemaining = 30;
  bool enableResend = false;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          enableResend = true;
          t.cancel();
        }
      });
    });
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
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
                      width: 15,
                    ),
                    Text(
                      "Step 1/2".tr,
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Got an OTP?".tr,
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
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    "Login using the OTP sent ${ccode}${signupmobilecontroller.text}"
                        .tr,
                    style: TextStyle(color: notifier.textColor),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  OTPTextField(
                    otpFieldStyle: OtpFieldStyle(
                      enabledBorderColor: Colors.grey.withOpacity(0.4),
                    ),
                    controller: signotpController,
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
                        fontFamily: "SofiaProBold"),
                    onChanged: (pin) {
                      setState(() {
                        otpvarable2 = int.parse(pin);
                        print(
                            "++++++widget.otpvariable+++++ :- ${widget.otpvariable}");
                        print("smscode ${smscode}");
                        print("++++++otpvarable2+++++ :- ${otpvarable2}");
                        print("++++++pin+++++ :- ${pin}");
                      });
                    },
                    onCompleted: (pin) {
                      setState(() {
                        smscode = pin;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ]),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: CommonButton(
                containcolore: theamcolore,
                onPressed1: () {
                  if (otpvarable2.toString() == smscode) {
                    if (widget.otpvariable == otpvarable2) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Onmobile3Screen(),
                          ));
                    } else {
                      CustomNotification.show(
                          message: "Incorrect OTP. Please try again.".tr,
                          type: NotificationType.info);
                    }
                  } else {
                    CustomNotification.show(
                        message: "Please Enter Otp.".tr,
                        type: NotificationType.info);
                  }
                },
                context: context,
                txt1: "Continue".tr),
          )
        ],
      ),
    );
  }
}
