// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../common_code/colore_screen.dart';
import '../common_code/language_toggle_button.dart';
import '../api_code/forgot_api_controller.dart';
import '../api_code/login_controller.dart';
import '../api_code/mobile_check_controller.dart';
import '../api_code/msg91_api_controller.dart';
import '../api_code/sms_type_controller.dart';
import '../api_code/twilyo_api_controoler.dart';
import '../common_code/common_button.dart';
import 'onmobile2_screen.dart';
import 'onmobile3_screen.dart';

// Global variables for compatibility with other files
TextEditingController signupmobilecontroller = TextEditingController();
String ccode = "";
String smscode = '';

class OnbordingScreen extends StatefulWidget {
  const OnbordingScreen({super.key});

  @override
  State<OnbordingScreen> createState() => _OnbordingScreenState();
}

class _OnbordingScreenState extends State<OnbordingScreen> {
  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final PageController _pageController = PageController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotPhoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final OtpFieldController _otpController = OtpFieldController();

  // API Controllers
  final SmstypeApiController _smstypeController =
      Get.put(SmstypeApiController());
  final MobilCheckController _mobileCheckController =
      Get.put(MobilCheckController());
  final MasgapiController _msgController = Get.put(MasgapiController());
  final TwilioapiController _twilioController = Get.put(TwilioapiController());
  final LoginController _loginController = Get.put(LoginController());
  final ForgotController _forgotController = Get.put(ForgotController());

  // State variables
  int _currentPage = 0;
  String _countryCode = "";
  String _forgotCountryCode = "";
  String _smsCode = '';
  String? _otpVariableForgot;
  bool _isLoginMode = false;
  bool _isLoading = false;

  // Validation error messages
  String? _phoneError;
  String? _passwordError;

  // Slides data
  late List<OnboardingSlide> _slides;

  @override
  void initState() {
    super.initState();
    _initializeSlides();
    _smstypeController.smsApi(context);

    // Sync with global variables for compatibility
    _phoneController.addListener(() {
      signupmobilecontroller.text = _phoneController.text;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _forgotPhoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _initializeSlides() {
    _slides = [
      OnboardingSlide(
        animation: "assets/lottie/1st.json",
        title: "Welcome to Your Qareeb Ride!",
        subtitle:
            "Book a ride in just a few taps and reach your destination comfortably",
      ),
      OnboardingSlide(
        animation: "assets/lottie/2nd.json",
        title: "Your Journey, Just a Tap Away",
        subtitle: "Experience fast, reliable, and safe rides with ease.",
      ),
      OnboardingSlide(
        animation: "assets/lottie/3rd.json",
        title: "Wherever You Go, We're Here",
        subtitle: "Find a ride quickly and enjoy your journey hassle-free",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColorNotifier>(context, listen: true);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildSlidesSection(),
          _buildLanguageToggle(),
          _buildMainContent(notifier),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildSlidesSection() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: Get.height * 0.5,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentPage = page),
        physics: const BouncingScrollPhysics(),
        itemCount: _slides.length,
        itemBuilder: (context, index) => _buildSlide(_slides[index]),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return Scaffold(
      backgroundColor: theamcolore,
      body: Container(
        height: 300,
        width: Get.width,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        child: Lottie.asset(slide.animation, fit: BoxFit.cover, height: 250),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return const Positioned(
      top: 50,
      right: 20,
      child: LanguageToggleButton(),
    );
  }

  Widget _buildMainContent(ColorNotifier notifier) {
    return Center(
      child: Container(
        width: Get.width * 0.9,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          color: notifier.containergreaycolore,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSlideText(notifier),
            const SizedBox(height: 30),
            _buildPhoneField(notifier),
            if (_isLoginMode) ...[
              const SizedBox(height: 20),
              _buildPasswordField(notifier),
            ],
            const SizedBox(height: 20),
            _buildTermsText(notifier),
            const SizedBox(height: 20),
            _buildContinueButton(),
            const SizedBox(height: 15),
            _buildForgotPasswordLink(notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideText(ColorNotifier notifier) {
    final slide = _slides[_currentPage];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            slide.title.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              color: notifier.textColor,
              fontFamily: 'Khebrat',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slide.subtitle.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(ColorNotifier notifier) {
    return SizedBox(
      height: 60,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: IntlPhoneField(
          searchText: 'بحث',
          controller: _phoneController,
          decoration: InputDecoration(
            counterText: "",
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(15),
            ),
            labelText: 'Phone Number'.tr,
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theamcolore),
              borderRadius: BorderRadius.circular(15),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: TextStyle(color: notifier.textColor),
          flagsButtonPadding: EdgeInsets.zero,
          showCountryFlag: false,
          showDropdownIcon: false,
          initialCountryCode: 'YE',
          languageCode: "ar",
          dropdownTextStyle: TextStyle(color: notifier.textColor, fontSize: 15),
          onCountryChanged: (value) => setState(() {}),
          onChanged: (number) {
            setState(() {
              _countryCode = number.countryCode;
              ccode = number.countryCode; // Sync with global variable
            });
          },
        ),
      ),
    );
  }

  Widget _buildPasswordField(ColorNotifier notifier) {
    return TextFormField(
      obscureText: true,
      controller: _passwordController,
      style: TextStyle(color: notifier.textColor),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.red),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
        ),
        labelText: "Password".tr,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: theamcolore),
        ),
      ),
    );
  }

  Widget _buildTermsText(ColorNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "By clicking Continue.you agree tp our ".tr,
          style: TextStyle(color: notifier.textColor, fontSize: 12),
        ),
        Text(
          "T&Cs".tr,
          style: TextStyle(
            color: theamcolore,
            decoration: TextDecoration.underline,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return CommonButton(
      containcolore: theamcolore,
      onPressed1: _handleContinue,
      context: context,
      txt1: "Continue".tr,
    );
  }

  Widget _buildForgotPasswordLink(ColorNotifier notifier) {
    return InkWell(
      onTap: () => Get.bottomSheet(_buildForgotPasswordBottomSheet()),
      child: Text(
        'Forgot Password ?'.tr,
        style: TextStyle(
          color: notifier.textColor,
          fontFamily: "Khebrat",
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
        height: Get.height,
        width: Get.width,
        alignment: Alignment.center,
        child: CircularProgressIndicator(color: theamcolore),
      ),
    );
  }

  // Event Handlers
  void _handleContinue() {
    if (_phoneController.text.isEmpty) {
      _showSnackbar("All fields are required".tr);
      return;
    }

    setState(() => _isLoginMode = false);

    _mobileCheckController.MobileCheckApi(
      phone: _phoneController.text,
      ccode: _countryCode,
      context: context,
    ).then(_handleMobileCheckResponse);
  }

  void _handleMobileCheckResponse(dynamic value) {
    if (value['Result'] == true) {
      _handleNewUser();
    } else {
      _handleExistingUser();
    }
  }

  void _handleNewUser() {
    final smsType = _smstypeController.smaApiModel?.message;

    switch (smsType) {
      case "MSG91":
        _sendMsg91Otp();
        break;
      case "Twilio":
        _sendTwilioOtp();
        break;
      case "No Auth":
        _navigateToOnboarding3();
        break;
      default:
        Fluttertoast.showToast(msg: "No Service".tr);
    }
  }

  void _handleExistingUser() {
    setState(() => _isLoginMode = true);

    if (_phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      setState(() => _isLoading = true);

      _loginController
          .loginApi(
        context: context,
        phone: _phoneController.text,
        password: _passwordController.text,
        ccode: _countryCode,
      )
          .then((value) {
        setState(() => _isLoading = false);
        // Handle login response
      });
    } else {
      _showSnackbar(_passwordController.text.isEmpty
          ? "Enter Password".tr
          : "All fields are required.".tr);
    }
  }

  void _sendMsg91Otp() {
    _msgController
        .msgApi(
      mobilenumber: _countryCode + _phoneController.text,
      context: context,
    )
        .then((_) {
      final otp = _msgController.msgApiModel?.otp;
      if (otp != null) {
        _navigateToOnboarding2(int.parse(otp.toString()));
      }
    });
  }

  void _sendTwilioOtp() {
    _twilioController
        .twilioApi(
      mobilenumber: _countryCode + _phoneController.text,
      context: context,
    )
        .then((_) {
      final otp = _twilioController.twilioApiModel?.otp;
      if (otp != null) {
        _navigateToOnboarding2(int.parse(otp.toString()));
      }
    });
  }

  void _navigateToOnboarding2(int otp) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Onmobile2Screen(otpvariable: otp),
      ),
    );
  }

  void _navigateToOnboarding3() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Onmobile3Screen()),
    );
  }

  // Forgot Password Bottom Sheets
  Widget _buildForgotPasswordBottomSheet() {
    return Consumer<ColorNotifier>(
      builder: (context, notifier, child) {
        return Container(
          height: 220,
          decoration: BoxDecoration(
            color: notifier.containercolore,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Forget Password ?".tr,
                  style: TextStyle(
                    color: notifier.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildForgotPhoneField(notifier),
                const SizedBox(height: 20),
                CommonButton(
                  txt1: 'Continue'.tr,
                  containcolore: theamcolore,
                  context: context,
                  onPressed1: _handleForgotPassword,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForgotPhoneField(ColorNotifier notifier) {
    return SizedBox(
      height: 60,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: IntlPhoneField(
          // ignore: deprecated_member_use
          searchText: 'بحث',
          controller: _forgotPhoneController,
          decoration: InputDecoration(
            counterText: "",
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(15),
            ),
            labelText: 'Phone Number'.tr,
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theamcolore),
              borderRadius: BorderRadius.circular(15),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: TextStyle(color: notifier.textColor),
          flagsButtonPadding: EdgeInsets.zero,
          showCountryFlag: false,
          showDropdownIcon: false,
          initialCountryCode: 'YE',
          dropdownTextStyle: TextStyle(color: notifier.textColor, fontSize: 15),
          onCountryChanged: (value) {},
          onChanged: (number) =>
              setState(() => _forgotCountryCode = number.countryCode),
        ),
      ),
    );
  }

  void _handleForgotPassword() {
    if (_forgotPhoneController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter Mobile Number...!!!'.tr);
      return;
    }

    _mobileCheckController.MobileCheckApi(
      phone: _forgotPhoneController.text,
      ccode: _forgotCountryCode,
      context: context,
    ).then(_handleForgotPasswordResponse);
  }

  void _handleForgotPasswordResponse(dynamic value) {
    if (value['Result'] == false) {
      final smsType = _smstypeController.smaApiModel?.message;

      switch (smsType) {
        case "MSG91":
          _handleMsg91ForgotPassword();
          break;
        case "Twilio":
          _handleTwilioForgotPassword();
          break;
        case "No Auth":
          _showCreatePasswordBottomSheet();
          break;
        default:
          Fluttertoast.showToast(msg: "No Service".tr);
      }
    } else {
      Fluttertoast.showToast(msg: "${value['message']}");
    }
  }

  void _handleMsg91ForgotPassword() {
    _msgController
        .msgApi(
          mobilenumber: _forgotCountryCode + _forgotPhoneController.text,
          context: context,
        )
        .then((_) =>
            Get.bottomSheet(_buildOtpVerificationBottomSheet(isMsg91: true)));
  }

  void _handleTwilioForgotPassword() {
    _twilioController
        .twilioApi(
          mobilenumber: _forgotCountryCode + _forgotPhoneController.text,
          context: context,
        )
        .then((_) =>
            Get.bottomSheet(_buildOtpVerificationBottomSheet(isMsg91: false)));
  }

  Widget _buildOtpVerificationBottomSheet({required bool isMsg91}) {
    return Consumer<ColorNotifier>(
      builder: (context, notifier, child) {
        return Container(
          height: 230,
          decoration: BoxDecoration(
            color: notifier.containercolore,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15),
              topLeft: Radius.circular(15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Awesome'.tr,
                  style: TextStyle(
                    color: notifier.textColor,
                    fontFamily: 'Khebrat',
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'We have sent the OTP to $_countryCode${_forgotPhoneController.text}'
                      .tr,
                  style: TextStyle(
                    color: notifier.textColor,
                    fontFamily: "Khebrat",
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: OTPTextField(
                    otpFieldStyle: OtpFieldStyle(
                      enabledBorderColor: Colors.grey.withOpacity(0.4),
                    ),
                    controller: _otpController,
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
                      fontFamily: "Khebrat",
                    ),
                    onChanged: (pin) =>
                        setState(() => _otpVariableForgot = _smsCode),
                    onCompleted: (pin) {
                      setState(() {
                        _smsCode = pin;
                        smscode = pin; // Sync with global variable
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                CommonButton(
                  txt1: 'VERIFY OTP'.tr,
                  containcolore: theamcolore,
                  context: context,
                  onPressed1: () =>
                      _verifyOtpForForgotPassword(isMsg91: isMsg91),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verifyOtpForForgotPassword({required bool isMsg91}) {
    final expectedOtp = isMsg91
        ? _msgController.msgApiModel?.otp?.toString()
        : _twilioController.twilioApiModel?.otp?.toString();

    if (expectedOtp == _otpVariableForgot) {
      _showCreatePasswordBottomSheet();
    } else {
      Fluttertoast.showToast(msg: "Incorrect OTP. Please try again.".tr);
    }
  }

  void _showCreatePasswordBottomSheet() {
    Get.bottomSheet(
      Container(
        height: 250,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              Text(
                'Create A New Password'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: "Khebrat",
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              CommonTextfiled2(
                txt: 'New Password'.tr,
                controller: _newPasswordController,
                context: context,
              ),
              const SizedBox(height: 15),
              CommonTextfiled2(
                txt: 'Confirm Password'.tr,
                controller: _confirmPasswordController,
                context: context,
              ),
              const SizedBox(height: 15),
              CommonButton(
                containcolore: theamcolore,
                txt1: 'Confirm'.tr,
                context: context,
                onPressed1: _handlePasswordReset,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePasswordReset() {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(msg: "Please enter current password".tr);
      return;
    }

    _forgotController
        .forgotApi(
      context: context,
      phone: _forgotPhoneController.text,
      password: _confirmPasswordController.text,
      ccode: _forgotCountryCode,
    )
        .then((value) {
      if (value["ResponseCode"] == "200") {
        Get.back();
      }
      Fluttertoast.showToast(msg: value["message"]);
    });
  }

  void _showSnackbar(String message) {
    snackbar(context: context, text: message);
  }
}

// Data Models
class OnboardingSlide {
  final String animation;
  final String title;
  final String subtitle;

  OnboardingSlide({
    required this.animation,
    required this.title,
    required this.subtitle,
  });
}
