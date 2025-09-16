// ignore_for_file: avoid_prin
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_field
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void resendOtp() {
    setState(() {
      secondsRemaining = 30;
      enableResend = false;
    });
    startTimer();

    // Resend logic based on SMS type
    if (smstypeApiController.smaApiModel?.message == "MSG91") {
      masgapiController.msgApi(
        mobilenumber: ccode + signupmobilecontroller.text,
        context: context,
      );
    } else if (smstypeApiController.smaApiModel?.message == "Twilio") {
      twilioapiController.twilioApi(
        mobilenumber: ccode + signupmobilecontroller.text,
        context: context,
      );
    }
  }

  String formatPhoneNumber(String countryCode, String phoneNumber) {
    // Force LTR direction for numbers even in RTL languages like Arabic
    return '\u202A$countryCode$phoneNumber\u202C';
  }

  // ONLY ADDITION: Paste functionality
  void pasteFromClipboard() async {
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null) {
        String clipboardText = data!.text!.replaceAll(RegExp(r'[^0-9]'), '');
        if (clipboardText.length >= 6) {
          String otpCode = clipboardText.substring(0, 6);
          setState(() {
            smscode = otpCode;
          });

          // Split digits and set them individually
          List<String> digits = otpCode.split('');
          signotpController.clear();

          // Use a small delay to ensure fields are ready
          await Future.delayed(const Duration(milliseconds: 100));

          for (int i = 0; i < digits.length; i++) {
            signotpController.setValue(digits[i], i);
          }

          CustomNotification.show(
            message: "OTP pasted successfully".tr,
            type: NotificationType.info,
          );
        } else {
          CustomNotification.show(
            message: "No valid OTP found in clipboard".tr,
            type: NotificationType.warning,
          );
        }
      }
    } catch (e) {
      CustomNotification.show(
        message: "Failed to paste from clipboard".tr,
        type: NotificationType.error,
      );
    }
  }

  ColorNotifier notifier = ColorNotifier();

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theamcolore, theamcolore.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theamcolore.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
                child: Column(
                  children: [
                    // Back Button and Progress
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SvgPicture.asset(
                              "assets/svgpicture/lestarroe.svg",
                              color: Colors.white,
                              height: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Step 1/2".tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Got an OTP?".tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "We've sent a verification code".tr,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Section - Expanded to fill remaining space
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    // Phone Number Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notifier.containercolore,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theamcolore.withOpacity(0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theamcolore.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.phone_android,
                              color: theamcolore,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Login using the OTP sent".tr,
                                  style: TextStyle(
                                    color: notifier.textColor.withOpacity(0.6),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    formatPhoneNumber(
                                        ccode, signupmobilecontroller.text),
                                    style: TextStyle(
                                      color: notifier.textColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // OTP Section with Paste and Clear Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Please Enter Otp.".tr,
                          style: TextStyle(
                            color: notifier.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Paste Button
                            TextButton.icon(
                              onPressed: pasteFromClipboard,
                              icon: Icon(
                                Icons.content_paste,
                                color: theamcolore,
                                size: 14,
                              ),
                              label: Text(
                                "Paste".tr,
                                style: TextStyle(
                                  color: theamcolore,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                              ),
                            ),
                            // Clear Button
                            TextButton.icon(
                              onPressed: () {
                                signotpController.clear();
                                setState(() {
                                  smscode = '';
                                  otpvarable2 = 0;
                                });
                              },
                              icon: Icon(
                                Icons.clear_all,
                                color: theamcolore,
                                size: 14,
                              ),
                              label: Text(
                                "Clear".tr,
                                style: TextStyle(
                                  color: theamcolore,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Enhanced OTP Field with Sequential Input
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theamcolore.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: OTPTextField(
                          otpFieldStyle: OtpFieldStyle(
                            enabledBorderColor: Colors.grey.withOpacity(0.25),
                            focusBorderColor: theamcolore,
                            borderColor: Colors.grey.withOpacity(0.15),
                            backgroundColor: notifier.containercolore,
                          ),
                          controller: signotpController,
                          length: 6,
                          width: MediaQuery.of(context).size.width,
                          textFieldAlignment: MainAxisAlignment.spaceEvenly,
                          fieldWidth: 45,
                          fieldStyle: FieldStyle.box,
                          outlineBorderRadius: 12,
                          contentPadding: const EdgeInsets.all(14),
                          keyboardType: TextInputType.number,
                          spaceBetween: 8,
                          isDense: true,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                          onChanged: (pin) {
                            setState(() {
                              if (pin.isNotEmpty && pin.length <= 6) {
                                try {
                                  // Ensure only numbers and LTR direction
                                  String cleanPin =
                                      pin.replaceAll(RegExp(r'[^0-9]'), '');
                                  if (cleanPin.isNotEmpty) {
                                    otpvarable2 = int.parse(cleanPin);
                                  }
                                  // Store current pin for real-time validation
                                  smscode = cleanPin;
                                } catch (e) {
                                  // Handle parsing error
                                }
                              }
                              print(
                                  "++++++widget.otpvariable+++++ :- ${widget.otpvariable}");
                              print("smscode ${smscode}");
                              print("++++++otpvarable2+++++ :- ${otpvarable2}");
                              print("++++++pin+++++ :- ${pin}");
                            });
                          },
                          onCompleted: (pin) {
                            setState(() {
                              // Clean and validate the pin
                              String cleanPin =
                                  pin.replaceAll(RegExp(r'[^0-9]'), '');
                              smscode = cleanPin;

                              // Auto-validate when OTP is complete
                              if (cleanPin.length == 6) {
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  if (widget.otpvariable.toString() ==
                                      cleanPin) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const Onmobile3Screen(),
                                      ),
                                    );
                                  } else {
                                    CustomNotification.show(
                                      message:
                                          "Incorrect OTP. Please try again.".tr,
                                      type: NotificationType.error,
                                    );
                                    // Clear the fields for retry
                                    signotpController.clear();
                                    setState(() {
                                      smscode = '';
                                      otpvarable2 = 0;
                                    });
                                  }
                                });
                              }
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Timer/Resend Section
                    Center(
                      child: !enableResend
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: theamcolore,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "${"Resend in".tr} $secondsRemaining ${"seconds".tr}",
                                  style: TextStyle(
                                    color: notifier.textColor.withOpacity(0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : TextButton.icon(
                              onPressed: resendOtp,
                              icon: Icon(
                                Icons.refresh,
                                color: theamcolore,
                                size: 16,
                              ),
                              label: Text(
                                "Resend code?".tr,
                                style: TextStyle(
                                  color: theamcolore,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 30),

                    // Continue Button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theamcolore, theamcolore.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: theamcolore.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            if (smscode.length < 6) {
                              CustomNotification.show(
                                message: "Please enter the complete OTP.".tr,
                                type: NotificationType.warning,
                              );
                            } else if (widget.otpvariable.toString() ==
                                smscode) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Onmobile3Screen(),
                                ),
                              );
                            } else {
                              CustomNotification.show(
                                message: "Incorrect OTP. Please try again.".tr,
                                type: NotificationType.error,
                              );
                              // Clear the fields for retry
                              signotpController.clear();
                              setState(() {
                                smscode = '';
                              });
                            }
                          },
                          child: Center(
                            child: Text(
                              "Continue".tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
