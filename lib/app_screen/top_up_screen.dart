// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../services/notifier.dart';
import '../widgets/loading_overlay.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../common_code/config.dart';

import '../api_code/coupon_payment_api_contoller.dart';
import '../api_code/wallet_report_controller.dart';
import '../api_code/wallete_api_controller.dart';
import '../common_code/colore_screen.dart';
import '../payment_screen/razorpay.dart';
import '../payment_screen/webview.dart';

TextEditingController walletController = TextEditingController();
String currencybol = "";

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  WalletApiController walletApiController = Get.put(WalletApiController());

  WalletReportApiController walletReportApiController =
      Get.put(WalletReportApiController());
  PaymentGetApiController paymentGetApiController =
      Get.put(PaymentGetApiController());
  // PayStackPayMentApiController payStackPayMentApiController = Get.put(PayStackPayMentApiController());

  @override
  void initState() {
    getPackage();
    datagetfunction();
    razorPayClass.initiateRazorPay(
        handlePaymentSuccess: handlePaymentSuccess,
        handlePaymentError: handlePaymentError,
        handleExternalWallet: handleExternalWallet);
    // TODO: implement initState
    super.initState();
  }

  PackageInfo? packageInfo;
  String? appName;
  String? packageName;

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo!.appName;

    packageName = packageInfo!.packageName;

    setState(() {});
  }

  int payment = -1;
  String selectedOption = '';
  String selectBoring = "";

  var decodeUid;
  var userid;
  var currencyy;

  datagetfunction() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("userLogin");
    var currency = preferences.getString("currenci");

    decodeUid = jsonDecode(uid!);
    userid = decodeUid['id'];

    currencyy = jsonDecode(currency!);
    currencybol = currencyy;

    print("++ userid ++:---  ${userid}");
    print("++ currencyy ++:---  ${currencyy}");

    walletReportApiController.walletreportApi(uid: userid.toString());
    paymentGetApiController.paymentlistApi(context);
    // currencybol = currency1;
    // print("******hello cureency++++:--- ${currencybol}");
  }

  @override
  void dispose() {
    walletReportApiController.isLoading = true;
    // TODO: implement dispose
    super.dispose();
  }

  RazorPayClass razorPayClass = RazorPayClass();
  // HomeApiController homeApiController = Get.put(HomeApiController());

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    walletApiController
        .walletaddapi(
            amount: walletController.text,
            uid: userid.toString(),
            payment_id: "${selectpaymentid}",
            context: context)
        .then((value) {
      walletReportApiController.walletreportApi(uid: userid.toString());
      // homeApiController.homeApi(uid: userdata['id'],latitude: lathome.toString(),logitude: longhome.toString());
    });

    Notifier.info('');
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Notifier.info('');
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Notifier.info('');
  }

  String amountvarable = "";
  int selectpaymentid = 0;

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: notifier.background,
        title: Text("Wallet".tr,
            style: TextStyle(fontSize: 18, color: notifier.textColor)),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(Icons.arrow_back, color: notifier.textColor),
        ),
      ),
      body: GetBuilder<WalletReportApiController>(
        builder: (walletReportApiController) {
          return walletReportApiController.isLoading
              ?LoadingOverlay()
              : Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Balance".tr,
                                style: TextStyle(color: notifier.textColor),
                              ),
                              walletReportApiController
                                          .walletReportApiModel?.walletAmount ==
                                      null
                                  ? Text(
                                      "${currencyy}0",
                                      style: TextStyle(
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                          color: notifier.textColor),
                                    )
                                  : Text(
                                      "${currencyy}${walletReportApiController.walletReportApiModel?.walletAmount}",
                                      style: TextStyle(
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                          color: notifier.textColor),
                                    ),
                            ],
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              selectedOption = '';
                              selectBoring = "";
                              walletController.clear();
                              Get.bottomSheet(
                                isScrollControlled: true,
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 150),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: notifier.containercolore,
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              topLeft: Radius.circular(15)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10, top: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6, right: 6),
                                                child: Text(
                                                    'Add Wallet Amount'.tr,
                                                    style: TextStyle(
                                                        color: theamcolore,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: SizedBox(
                                                  height: 45,
                                                  child: TextFormField(
                                                    controller:
                                                        walletController,
                                                    cursorColor: Colors.black,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        amountvarable = value;
                                                      });
                                                      print(
                                                          "*****::--(${amountvarable})");
                                                    },
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            notifier.textColor),
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          const EdgeInsets.only(
                                                              top: 15),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                          color: Colors.grey
                                                              .withOpacity(0.4),
                                                        ),
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                          color: Colors.grey
                                                              .withOpacity(0.4),
                                                        ),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                          color: Colors.grey
                                                              .withOpacity(0.4),
                                                        ),
                                                      ),
                                                      prefixIcon: SizedBox(
                                                        height: 20,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 14),
                                                          child:
                                                              SvgPicture.asset(
                                                            "assets/svgpicture/wallet.svg",
                                                            width: 20,
                                                            color: notifier
                                                                .textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      hintText:
                                                          "Enter Amount".tr,
                                                      hintStyle:
                                                          const TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6, right: 6),
                                                child: Text(
                                                    'Select Payment Method'.tr,
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12)),
                                              ),
                                              const SizedBox(
                                                height: 0,
                                              ),
                                              Expanded(
                                                child: ListView.separated(
                                                    separatorBuilder:
                                                        (context, index) {
                                                      return const SizedBox(
                                                        width: 0,
                                                      );
                                                    },
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    itemCount:
                                                        paymentGetApiController
                                                            .paymentgetwayapi!
                                                            .paymentList!
                                                            .length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return InkWell(
                                                        onTap:
                                                            walletController
                                                                    .text
                                                                    .isEmpty
                                                                ? () {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                      msg: "Enter Amount!!!"
                                                                          .tr,
                                                                    );
                                                                  }
                                                                : () {
                                                                    setState(
                                                                        () {
                                                                      payment =
                                                                          index;
                                                                      selectpaymentid = paymentGetApiController
                                                                          .paymentgetwayapi!
                                                                          .paymentList![
                                                                              payment]
                                                                          .id!;
                                                                      print(
                                                                          "+++selectpaymentid+++:--${selectpaymentid}");
                                                                    });
                                                                    if (paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![
                                                                                payment]
                                                                            .id ==
                                                                        1) {
                                                                      razorPayClass.openCheckout(
                                                                          key: paymentGetApiController
                                                                              .paymentgetwayapi!
                                                                              .paymentList![
                                                                                  0]
                                                                              .attribute
                                                                              .toString(),
                                                                          amount:
                                                                              '${double.parse(walletController.text)}',
                                                                          number:
                                                                              '${decodeUid['phone']}',
                                                                          name:
                                                                              '${decodeUid['email']}');
                                                                      Get.back();
                                                                    } else if (paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![
                                                                                payment]
                                                                            .id ==
                                                                        2) {
                                                                      print(
                                                                          "paypal");
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                PaymentWebVIew(
                                                                              initialUrl: "${Config.imageurl}payment/paypal-payment?amount=100&uid=20&request_id=158",
                                                                              navigationDelegate: (request) async {
                                                                                final uri = Uri.parse(request.url);
                                                                                print("Navigating to URL: ${request.url}");
                                                                                print("Parsed URI: $uri");

                                                                                // Check the status parameter instead of Result
                                                                                final status = uri.queryParameters["status"];
                                                                                print("Hello Status:---- $status");

                                                                                if (status == null) {
                                                                                  print("No status parameter found.");
                                                                                } else {
                                                                                  print("Status parameter: $status");
                                                                                  if (status == "success") {
                                                                                    print("Purchase successful.");
                                                                                    // walletApiController.walletaddapi(wallet: walletController.text, uid: userdata['id'],context: context).then((value) {
                                                                                    //   walletReportApiController.walletreportApi(uid: userdata['id']);
                                                                                    // });
                                                                                    return NavigationDecision.prevent;
                                                                                  } else {
                                                                                    print("Purchase failed with status: $status.");
                                                                                    Navigator.pop(context);
                                                                                    Notifier.info('');
                                                                                    return NavigationDecision.prevent;
                                                                                  }
                                                                                }
                                                                                return NavigationDecision.navigate;
                                                                              },
                                                                            ),
                                                                          ));
                                                                    } else if (paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![
                                                                                payment]
                                                                            .id ==
                                                                        3) {
                                                                      print(
                                                                          "Stripe");
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                PaymentWebVIew(
                                                                              initialUrl: "${Config.imageurl}payment/strip-payment?amount=100&uid=20&request_id=158",
                                                                              navigationDelegate: (request) async {
                                                                                final uri = Uri.parse(request.url);
                                                                                print("Navigating to URL: ${request.url}");
                                                                                print("Parsed URI: $uri");

                                                                                // Check the status parameter instead of Result
                                                                                final status = uri.queryParameters["status"];
                                                                                print("Hello Status:---- $status");

                                                                                if (status == null) {
                                                                                  print("No status parameter found.");
                                                                                } else {
                                                                                  print("Status parameter: $status");
                                                                                  if (status == "success") {
                                                                                    print("Purchase successful.");
                                                                                    // walletApiController.walletaddapi(wallet: walletController.text, uid: userdata['id'],context: context).then((value) {
                                                                                    //   walletReportApiController.walletreportApi(uid: userdata['id']);
                                                                                    // });
                                                                                    return NavigationDecision.prevent;
                                                                                  } else {
                                                                                    print("Purchase failed with status: $status.");
                                                                                    Navigator.pop(context);
                                                                                    Notifier.info('');
                                                                                    return NavigationDecision.prevent;
                                                                                  }
                                                                                }
                                                                                return NavigationDecision.navigate;
                                                                              },
                                                                            ),
                                                                          ));
                                                                    } else if (paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![
                                                                                payment]
                                                                            .id ==
                                                                        4) {
                                                                      print(
                                                                          "PayStack");
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                PaymentWebVIew(
                                                                              initialUrl: "${Config.imageurl}payment/paystack-payment?amount=100&uid=20&request_id=158",
                                                                              navigationDelegate: (request) async {
                                                                                final uri = Uri.parse(request.url);
                                                                                print("Navigating to URL: ${request.url}");
                                                                                print("Parsed URI: $uri");

                                                                                // Check the status parameter instead of Result
                                                                                final status = uri.queryParameters["status"];
                                                                                print("Hello Status:---- $status");

                                                                                if (status == null) {
                                                                                  print("No status parameter found.");
                                                                                } else {
                                                                                  print("Status parameter: $status");
                                                                                  if (status == "success") {
                                                                                    print("Purchase successful.");
                                                                                    // walletApiController.walletaddapi(wallet: walletController.text, uid: userdata['id'],context: context).then((value) {
                                                                                    //   walletReportApiController.walletreportApi(uid: userdata['id']);
                                                                                    // });
                                                                                    return NavigationDecision.prevent;
                                                                                  } else {
                                                                                    print("Purchase failed with status: $status.");
                                                                                    Navigator.pop(context);
                                                                                    Notifier.info('');
                                                                                    return NavigationDecision.prevent;
                                                                                  }
                                                                                }
                                                                                return NavigationDecision.navigate;
                                                                              },
                                                                            ),
                                                                          ));
                                                                    } else if (paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![
                                                                                payment]
                                                                            .id ==
                                                                        5) {
                                                                      print(
                                                                          "FlutterWave");
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                PaymentWebVIew(
                                                                              initialUrl: "${Config.imageurl}payment/flutterwave-payment?amount=100&uid=20&request_id=158",
                                                                              navigationDelegate: (request) async {
                                                                                final uri = Uri.parse(request.url);
                                                                                print("Navigating to URL: ${request.url}");
                                                                                print("Parsed URI: $uri");

                                                                                // Check the status parameter instead of Result
                                                                                final status = uri.queryParameters["status"];
                                                                                print("Hello Status:---- $status");

                                                                                if (status == null) {
                                                                                  print("No status parameter found.");
                                                                                } else {
                                                                                  print("Status parameter: $status");
                                                                                  if (status == "success") {
                                                                                    print("Purchase successful.");
                                                                                    // walletApiController.walletaddapi(wallet: walletController.text, uid: userdata['id'],context: context).then((value) {
                                                                                    //   walletReportApiController.walletreportApi(uid: userdata['id']);
                                                                                    // });
                                                                                    return NavigationDecision.prevent;
                                                                                  } else {
                                                                                    print("Purchase failed with status: $status.");
                                                                                    Navigator.pop(context);
                                                                                    Notifier.info('');
                                                                                    return NavigationDecision.prevent;
                                                                                  }
                                                                                }
                                                                                return NavigationDecision.navigate;
                                                                              },
                                                                            ),
                                                                          ));
                                                                    } else if (paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![
                                                                                payment]
                                                                            .id ==
                                                                        6) {
                                                                      print(
                                                                          "SenangPay");
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                PaymentWebVIew(
                                                                              initialUrl: "${Config.imageurl}payment/senangpay-payment?amount=100&uid=20&request_id=158",
                                                                              navigationDelegate: (request) async {
                                                                                final uri = Uri.parse(request.url);
                                                                                print("Navigating to URL: ${request.url}");
                                                                                print("Parsed URI: $uri");

                                                                                // Check the status parameter instead of Result
                                                                                final status = uri.queryParameters["status"];
                                                                                print("Hello Status:---- $status");

                                                                                if (status == null) {
                                                                                  print("No status parameter found.");
                                                                                } else {
                                                                                  print("Status parameter: $status");
                                                                                  if (status == "success") {
                                                                                    print("Purchase successful.");
                                                                                    // walletApiController.walletaddapi(wallet: walletController.text, uid: userdata['id'],context: context).then((value) {
                                                                                    //   walletReportApiController.walletreportApi(uid: userdata['id']);
                                                                                    // });
                                                                                    return NavigationDecision.prevent;
                                                                                  } else {
                                                                                    print("Purchase failed with status: $status.");
                                                                                    Navigator.pop(context);
                                                                                    Notifier.info('');
                                                                                    return NavigationDecision.prevent;
                                                                                  }
                                                                                }
                                                                                return NavigationDecision.navigate;
                                                                              },
                                                                            ),
                                                                          ));
                                                                    } else if (paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![
                                                                                payment]
                                                                            .id ==
                                                                        7) {
                                                                      print(
                                                                          "Payfast");
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                PaymentWebVIew(
                                                                              initialUrl: "${Config.imageurl}payment/payfast-payment?amount=100&uid=20&request_id=158",
                                                                              navigationDelegate: (request) async {
                                                                                final uri = Uri.parse(request.url);
                                                                                print("Navigating to URL: ${request.url}");
                                                                                print("Parsed URI: $uri");

                                                                                // Check the status parameter instead of Result
                                                                                final status = uri.queryParameters["status"];
                                                                                print("Hello Status:---- $status");

                                                                                if (status == null) {
                                                                                  print("No status parameter found.");
                                                                                } else {
                                                                                  print("Status parameter: $status");
                                                                                  if (status == "success") {
                                                                                    print("Purchase successful.");
                                                                                    // walletApiController.walletaddapi(wallet: walletController.text, uid: userdata['id'],context: context).then((value) {
                                                                                    //   walletReportApiController.walletreportApi(uid: userdata['id']);
                                                                                    // });
                                                                                    return NavigationDecision.prevent;
                                                                                  } else {
                                                                                    print("Purchase failed with status: $status.");
                                                                                    Navigator.pop(context);
                                                                                    Notifier.info('');
                                                                                    return NavigationDecision.prevent;
                                                                                  }
                                                                                }
                                                                                return NavigationDecision.navigate;
                                                                              },
                                                                            ),
                                                                          ));
                                                                    } else if (paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![
                                                                                payment]
                                                                            .id ==
                                                                        8) {
                                                                      print(
                                                                          "Midtrans");
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                PaymentWebVIew(
                                                                              initialUrl: "${Config.imageurl}payment/midtrans-payment?amount=100&uid=20&request_id=158",
                                                                              navigationDelegate: (request) async {
                                                                                final uri = Uri.parse(request.url);
                                                                                print("Navigating to URL: ${request.url}");
                                                                                print("Parsed URI: $uri");

                                                                                // Check the status parameter instead of Result
                                                                                final status = uri.queryParameters["status"];
                                                                                print("Hello Status:---- $status");

                                                                                if (status == null) {
                                                                                  print("No status parameter found.");
                                                                                } else {
                                                                                  print("Status parameter: $status");
                                                                                  if (status == "success") {
                                                                                    print("Purchase successful.");
                                                                                    // walletApiController.walletaddapi(wallet: walletController.text, uid: userdata['id'],context: context).then((value) {
                                                                                    //   walletReportApiController.walletreportApi(uid: userdata['id']);
                                                                                    // });
                                                                                    return NavigationDecision.prevent;
                                                                                  } else {
                                                                                    print("Purchase failed with status: $status.");
                                                                                    Navigator.pop(context);
                                                                                    Notifier.info('');
                                                                                    return NavigationDecision.prevent;
                                                                                  }
                                                                                }
                                                                                return NavigationDecision.navigate;
                                                                              },
                                                                            ),
                                                                          ));
                                                                    } else if (paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![
                                                                                payment]
                                                                            .id ==
                                                                        9) {
                                                                      print(
                                                                          "Cash");
                                                                    } else if (paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![
                                                                                payment]
                                                                            .id ==
                                                                        10) {
                                                                      print(
                                                                          "Pay with QR Code");
                                                                    } else if (paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![payment]
                                                                            .id ==
                                                                        11) {
                                                                      print(
                                                                          "Bank Account");
                                                                    } else {
                                                                      // Get.back();
                                                                      print(
                                                                          "+++++++++++else+++++++++++");
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                            content:
                                                                                Text('Not Valid'.tr),
                                                                            behavior: SnackBarBehavior.floating,
                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                                                      );
                                                                    }
                                                                  },
                                                        child: paymentGetApiController
                                                                    .paymentgetwayapi!
                                                                    .paymentList![
                                                                        index]
                                                                    .status ==
                                                                "0"
                                                            ? const SizedBox()
                                                            : Container(
                                                                height: 90,
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        top: 6,
                                                                        bottom:
                                                                            6),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  // color: Colors.yellowAccent,
                                                                  border: Border.all(
                                                                      color: payment ==
                                                                              index
                                                                          ? theamcolore
                                                                          : Colors
                                                                              .grey
                                                                              .withOpacity(0.4)),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      ListTile(
                                                                    leading:
                                                                        Transform
                                                                            .translate(
                                                                      offset:
                                                                          const Offset(
                                                                              -5,
                                                                              0),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            100,
                                                                        width:
                                                                            60,
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15),
                                                                            border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                                                            image: DecorationImage(image: NetworkImage('${Config.imageurl}${paymentGetApiController.paymentgetwayapi!.paymentList![index].image}'))),
                                                                      ),
                                                                    ),
                                                                    title:
                                                                        Padding(
                                                                      padding: EdgeInsets.only(
                                                                          bottom:
                                                                              4),
                                                                      child:
                                                                          Text(
                                                                        paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![index]
                                                                            .name
                                                                            .toString(),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: notifier.textColor),
                                                                        maxLines:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                    subtitle:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              4),
                                                                      child:
                                                                          Text(
                                                                        paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![index]
                                                                            .subTitle
                                                                            .toString(),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: notifier.textColor),
                                                                        maxLines:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                    trailing:
                                                                        Radio(
                                                                      value: payment ==
                                                                              index
                                                                          ? true
                                                                          : false,
                                                                      fillColor:
                                                                          MaterialStatePropertyAll(
                                                                              theamcolore),
                                                                      groupValue:
                                                                          true,
                                                                      onChanged:
                                                                          (value) {
                                                                        print(
                                                                            value);
                                                                        setState(
                                                                            () {
                                                                          selectedOption =
                                                                              value.toString();
                                                                          selectBoring = paymentGetApiController
                                                                              .paymentgetwayapi!
                                                                              .paymentList![index]
                                                                              .image!;
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              width: 130,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theamcolore,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Image(
                                        image:
                                            AssetImage("assets/arrow-up.png"),
                                        height: 18,
                                        width: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text("Top-up".tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Share.share(
                            "You can download ${appName} and it just takes a few moments to get started. Your support would mean a lot to us and to the causes we’re working towards:${Platform.isAndroid ? 'https://play.google.com/store/apps/details?id=${packageName}' : Platform.isIOS ? 'https://apps.apple.com/us/app/${appName}/id${packageName}' : ""}",
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: theamcolore,
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Invite a friend, and".tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "start the adventure ".tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text("together with our ".tr,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text("app today!".tr,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            Text("Invite friend".tr,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Colors.yellow,
                                                        fontSize: 14)),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Icon(
                                                Icons.arrow_right_alt_sharp,
                                                color: Colors.yellow),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Lottie.asset('assets/lottie/wallet2.json',
                                        height: 120),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, right: 0),
                        child: Column(
                          children: [
                            walletReportApiController
                                    .walletReportApiModel!.walletData!.isEmpty
                                ? const SizedBox()
                                : Row(
                                    children: [
                                      Text(
                                        'Transaction History'.tr,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: notifier.textColor),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Expanded(
                        child: ListView.separated(
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                width: 0,
                              );
                            },
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: walletReportApiController
                                .walletReportApiModel!.walletData!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: walletReportApiController
                                            .walletReportApiModel!
                                            .walletData![index]
                                            .status ==
                                        '2'
                                    ? const Image(
                                        image: AssetImage('assets/Debit.png'),
                                        height: 40)
                                    : const Image(
                                        image: AssetImage('assets/Creadit.png'),
                                        height: 40),
                                title: Transform.translate(
                                    offset: Offset(-6, 0),
                                    child: Text(
                                        walletReportApiController
                                            .walletReportApiModel!
                                            .walletData![index]
                                            .pname
                                            .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: notifier.textColor))),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Transform.translate(
                                        offset: const Offset(-6, 0),
                                        child: walletReportApiController
                                                    .walletReportApiModel!
                                                    .walletData![index]
                                                    .status ==
                                                '2'
                                            ? Text("Debit".tr,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey))
                                            : Text("Credit".tr,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey))),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    walletReportApiController
                                                .walletReportApiModel!
                                                .walletData![index]
                                                .status ==
                                            '2'
                                        ? Transform.translate(
                                            offset: const Offset(-6, 0),
                                            child: Text(
                                                "Ride Id: ${walletReportApiController.walletReportApiModel!.walletData![index].type}"
                                                    .tr,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey)))
                                        : const SizedBox(),
                                  ],
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // SizedBox(height: 3,),
                                    Text(
                                      "${walletReportApiController.walletReportApiModel!.walletData![index].date}",
                                      style:
                                          TextStyle(color: notifier.textColor),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                        '${walletReportApiController.walletReportApiModel!.walletData![index].status == '2' ? '-' : "+"} $currencyy${walletReportApiController.walletReportApiModel!.walletData![index].amount}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: walletReportApiController
                                                        .walletReportApiModel!
                                                        .walletData![index]
                                                        .status ==
                                                    "2"
                                                ? Colors.red
                                                : Colors.green)),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
