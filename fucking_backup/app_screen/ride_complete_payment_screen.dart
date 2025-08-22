// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/notifier.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_code/vihical_ride_complete_order_api_controller.dart';
import 'home_screen.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../api_code/coupon_payment_api_contoller.dart';
import '../api_code/review_data_api_controller.dart';
import '../common_code/common_flow_screen.dart';
import '../common_code/config.dart';
import '../payment_screen/razorpay.dart';
import 'map_screen.dart';

num finaltotalsecounde = 0.00;

class RideCompletePaymentScreen extends StatefulWidget {
  const RideCompletePaymentScreen({super.key});

  @override
  State<RideCompletePaymentScreen> createState() =>
      _RideCompletePaymentScreenState();
}

class _RideCompletePaymentScreenState extends State<RideCompletePaymentScreen> {
  // late IO.Socket socket;
  var decodeUid;

  var currencyy;
  var userid;
  num walleteelse = 0.00;

  dataget() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("userLogin");
    var currency = preferences.getString("currenci");

    decodeUid = jsonDecode(uid!);
    currencyy = jsonDecode(currency!);

    userid = decodeUid['id'];

    print("!!!!!!:-- $userid");
    print("!!!!!!:-- $currencyy");

    setState(() {
      print("77777777777777777777777777777777:--- (${walleteamount})");
      // print("77778888888888883464567457373734:--- (${finaltotal})");
      walleteelse = walleteamount;
      // finaltotalsecounde = finaltotal;
      walleteamountcondition = walleteamount;
      print("*******{{{{:-- ${walleteelse}");
      print("*****finaltotalsecounde**{{{{:-- ${finaltotalsecounde}");
    });
  }

  late IO.Socket socket;

  socketConnect() async {
    print("*****qqqq****:--- ($userid)");
    print("*****pppp****:--- ($currencyy)");

    socket = IO.io(Config.imageurl, <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });
    socket.connect();

    socket.onConnect((_) {
      print('Connected');
      socket.emit('message', 'Hello from Flutter');
    });

    _connectSocket();
  }

  _connectSocket() async {
    setState(() {});
    socket.onConnect(
        (data) => print('Connection established Connected driverdetail'));
    socket.onConnectError((data) => print('Connect Error driverdetail: $data'));
    socket.onDisconnect(
        (data) => print('Socket.IO server disconnected driverdetail'));
  }

  socateempt() {
    socket.emit('Vehicle_P_Change', {
      'userid': userid,
      'd_id': driver_id,
      'payment_id': payment,
    });
  }

  socateemptvihicalridecomplete() {
    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
    socket.emit('Vehicle_Ride_Complete', {
      'd_id': driver_id,
      'request_id': ridecompleterequestid,
    });
  }

  num walleteamountcondition = 0.00;

  @override
  void initState() {
    super.initState();
    setState(() {});

    dataget();

    socketConnect();

    paymentGetApiController.paymentlistApi(context).then(
      (value) {
        setState(() {});
        for (int i = 1;
            i < paymentGetApiController.paymentgetwayapi!.paymentList!.length;
            i++) {
          if (int.parse(paymentGetApiController.paymentgetwayapi!.defaultPayment
                  .toString()) ==
              paymentGetApiController.paymentgetwayapi!.paymentList![i].id) {
            setState(() {
              paymentindex = i;
              payment =
                  paymentGetApiController.paymentgetwayapi!.paymentList![i].id!;
              // print("+++++$payment");
              // print("-----$i");
              print("++++paymentindex++++:--$paymentindex");
              print("----paymentid----:-$payment");
            });
          }
        }
      },
    );

    razorPayClass.initiateRazorPay(
        handlePaymentSuccess: handlePaymentSuccess,
        handlePaymentError: handlePaymentError,
        handleExternalWallet: handleExternalWallet);

    // socketConnect();
    print("done123");
  }

  bool switchValue = false;
  int payment = 0;
  int paymentindex = 0;
  String selectedOption = "";
  String selectBoring = "";
  double walletValue = 0;
  double walletMain = 0;

  PaymentGetApiController paymentGetApiController =
      Get.put(PaymentGetApiController());
  VihicalRideCompleteOrderApiController vihicalRideCompleteOrderApiController =
      Get.put(VihicalRideCompleteOrderApiController());

  RazorPayClass razorPayClass = RazorPayClass();

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    vihicalRideCompleteOrderApiController
        .vihicalridecomplete(
            payment_id: payment.toString(),
            context: context,
            payment_img: "",
            uid: "${userid}",
            d_id: "${driver_id}",
            request_id: "${request_id}",
            wallet: "${walletValue}")
        .then(
      (value) {
        print(
            "ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssshh ${value}");
        rateBottomSheet();
        socateemptvihicalridecomplete();
      },
    );
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Notifier.info(response.error.toString());
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Notifier.info(response.walletName.toString());
  }

  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  File? _selectedImage1;

  Future<void> _pickImage1() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage1 = File(pickedFile.path);
      });
    }
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return WillPopScope(
      onWillPop: () {
        return Future(
          () => false,
        );
      },
      child: Scaffold(
        // backgroundColor: Colors.grey.shade100,
        backgroundColor: notifier.languagecontainercolore,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: notifier.containercolore,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: notifier.languagecontainercolore,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.help_outline,
                        size: 21, color: notifier.textColor),
                    const SizedBox(width: 3),
                    Text(
                      "Help".tr,
                      style: TextStyle(
                        //
                        fontSize: 14,
                        color: notifier.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
            color: notifier.containercolore,
            padding: const EdgeInsets.all(10),
            child: finaltotal == 0
                ? CommonButton(
                    containcolore: theamcolore,
                    onPressed1: () {
                      // print("++${payment}");
                      // print("--${paymentindex}");
                      // socateempt();
                      vihicalRideCompleteOrderApiController
                          .vihicalridecomplete(
                              payment_id: "",
                              context: context,
                              payment_img: "",
                              uid: "${userid}",
                              d_id: "${driver_id}",
                              request_id: "${request_id}",
                              wallet: "${walletValue}")
                          .then(
                        (value) {
                          print(
                              "ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssshh ${value}");
                          rateBottomSheet();
                          socateemptvihicalridecomplete();
                        },
                      );
                    },
                    context: context,
                    txt1: "Wallet".tr)
                : CommonButton(
                    containcolore: theamcolore,
                    onPressed1: () {
                      // print("++${payment}");
                      // print("--${paymentindex}");
                      socateempt();
                      if (paymentGetApiController.paymentgetwayapi!
                              .paymentList![paymentindex].id ==
                          1) {
                        razorPayClass.openCheckout(
                            key: paymentGetApiController.paymentgetwayapi!
                                .paymentList![paymentindex].attribute
                                .toString(),
                            amount: '$finaltotal',
                            number: '${decodeUid['phone']}',
                            name: '${decodeUid['name']}');
                        // Get.back();
                        print("+++++++++++if+++++++++++");
                      } else if (paymentGetApiController.paymentgetwayapi!
                              .paymentList![paymentindex].id ==
                          2) {
                        print("paypal");
                      } else if (paymentGetApiController.paymentgetwayapi!
                              .paymentList![paymentindex].id ==
                          3) {
                        print("Stripe");
                      } else if (paymentGetApiController.paymentgetwayapi!
                              .paymentList![paymentindex].id ==
                          4) {
                        print("PayStack");
                      } else if (paymentGetApiController.paymentgetwayapi!
                              .paymentList![paymentindex].id ==
                          5) {
                        print("FlutterWave");
                      } else if (paymentGetApiController.paymentgetwayapi!
                              .paymentList![paymentindex].id ==
                          6) {
                        print("SenangPay");
                      } else if (paymentGetApiController.paymentgetwayapi!
                              .paymentList![paymentindex].id ==
                          7) {
                        print("Payfast");
                      } else if (paymentGetApiController.paymentgetwayapi!
                              .paymentList![paymentindex].id ==
                          8) {
                        print("Midtrans");
                      } else if (paymentGetApiController.paymentgetwayapi!
                              .paymentList![paymentindex].id ==
                          9) {
                        vihicalRideCompleteOrderApiController
                            .vihicalridecomplete(
                                payment_id: payment.toString(),
                                context: context,
                                payment_img: "",
                                uid: "${userid}",
                                d_id: "${driver_id}",
                                request_id: "${request_id}",
                                wallet: "${walletValue}")
                            .then(
                          (value) {
                            print(
                                "ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssshh ${value}");
                            rateBottomSheet();
                            socateemptvihicalridecomplete();
                          },
                        );
                        print("Cash");
                      } else if (paymentGetApiController.paymentgetwayapi!
                              .paymentList![paymentindex].id ==
                          10) {
                        print("Pay with QR Code");
                        Get.bottomSheet(
                            clipBehavior: Clip.none,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10))),
                            StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              height: 300,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Pay with QR Code",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 150,
                                            width: 150,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        "${Config.imageurl}${paymentGetApiController.paymentgetwayapi!.paymentList![paymentindex].attribute}"),
                                                    fit: BoxFit.cover)),
                                            // child: Image.network("${Config.imageurl}${paymentGetApiController.paymentgetwayapi!.paymentList![paymentindex].attribute}",height: 150,width: 150,fit: BoxFit.cover,)
                                          ),
                                          const Spacer(),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _pickImage().then(
                                                  (value) {
                                                    setState(() {});
                                                  },
                                                );
                                              });
                                            },
                                            child: Container(
                                              width: 150,
                                              height: 150,
                                              decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: _selectedImage != null
                                                  ? Image.file(
                                                      _selectedImage!,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : const Center(
                                                      child:
                                                          Text("Select Image")),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    _selectedImage != null
                                        ? CommonButton(
                                            containcolore: theamcolore,
                                            onPressed1: () {
                                              Get.back();
                                              vihicalRideCompleteOrderApiController
                                                  .vihicalridecomplete(
                                                      payment_id:
                                                          payment.toString(),
                                                      context: context,
                                                      payment_img:
                                                          _selectedImage!.path,
                                                      uid: "${userid}",
                                                      d_id: "${driver_id}",
                                                      request_id:
                                                          "${request_id}",
                                                      wallet: "${walletValue}")
                                                  .then(
                                                (value) {
                                                  rateBottomSheet();
                                                  socateemptvihicalridecomplete();
                                                },
                                              );
                                            },
                                            context: context,
                                            txt1: "Next")
                                        : CommonButton(
                                            containcolore:
                                                theamcolore.withOpacity(0.1),
                                            onPressed1: () {
                                              Notifier.info(
                                                  'Please Select Image'.tr);
                                            },
                                            context: context,
                                            txt1: "Next"),
                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ));
                      } else if (paymentGetApiController.paymentgetwayapi!
                              .paymentList![paymentindex].id ==
                          11) {
                        print("Bank Account");
                        Get.bottomSheet(
                            clipBehavior: Clip.none,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10))),
                            StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              height: 420,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Bank Details",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Text("Bank Name")
                                    //   ],
                                    // ),
                                    // ListView.builder(
                                    //   shrinkWrap: true,
                                    //   clipBehavior: Clip.none,
                                    //   itemCount: paymentGetApiController.paymentgetwayapi!.bankData!.length,
                                    //   itemBuilder: (context, index) {
                                    //   return Text("${paymentGetApiController.paymentgetwayapi!.bankData![index].bankName}");
                                    // },),
                                    // SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        const Text(
                                          "bank Name",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const Spacer(),
                                        Text(
                                            "${paymentGetApiController.paymentgetwayapi!.bankData![0].bankName}",
                                            style:
                                                const TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "holder Name",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "${paymentGetApiController.paymentgetwayapi!.bankData![1].holderName}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "account No",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "${paymentGetApiController.paymentgetwayapi!.bankData![2].accountNo}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "iafc Code",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "${paymentGetApiController.paymentgetwayapi!.bankData![3].iafcCode}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "swift Code",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "${paymentGetApiController.paymentgetwayapi!.bankData![4].swiftCode}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _pickImage1().then(
                                              (value) {
                                                setState(() {});
                                              },
                                            );
                                          });
                                        },
                                        child: Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: _selectedImage1 != null
                                              ? Image.file(
                                                  _selectedImage1!,
                                                  fit: BoxFit.cover,
                                                )
                                              : const Center(
                                                  child: Text("Select Image")),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    _selectedImage1 != null
                                        ? CommonButton(
                                            containcolore: theamcolore,
                                            onPressed1: () {
                                              Get.back();
                                              vihicalRideCompleteOrderApiController
                                                  .vihicalridecomplete(
                                                      payment_id:
                                                          payment.toString(),
                                                      context: context,
                                                      payment_img:
                                                          _selectedImage1!.path,
                                                      uid: "${userid}",
                                                      d_id: "${driver_id}",
                                                      request_id:
                                                          "${request_id}",
                                                      wallet: "${walletValue}")
                                                  .then(
                                                (value) {
                                                  rateBottomSheet();
                                                  socateemptvihicalridecomplete();
                                                },
                                              );
                                            },
                                            context: context,
                                            txt1: "Next")
                                        : CommonButton(
                                            containcolore:
                                                theamcolore.withOpacity(0.1),
                                            onPressed1: () {
                                              Notifier.info(
                                                  'Please Select Image');
                                            },
                                            context: context,
                                            txt1: "Next"),
                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ));
                      } else {
                        // Get.back();
                        print("+++++++++++else+++++++++++");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Not Valid'.tr),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        );
                      }
                    },
                    context: context,
                    txt1: "Next".tr)),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: notifier.containercolore,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        alignment: Alignment.center,
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: theamcolore,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "${decodeUid['name'][0] ?? ""}".tr,
                          style: TextStyle(
                            fontSize: 23,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.green)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            "assets/svgpicture/check-circle.svg",
                            color: Colors.green,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "RIDE COMPLETED".tr,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      "Select a payment method to pay".tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: notifier.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // const SizedBox(height: 6),
                    // const Text(
                    //  " completePriceController.completePriceModel!.priceList.cusName,",
                    //   style: TextStyle(
                    //
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.w500,
                    //     color: Colors.black,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                    // const SizedBox(height: 6),
                    // const Text(
                    //   "200",
                    //   style: TextStyle(
                    //
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.w500,
                    //     color: Colors.black,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                    const SizedBox(height: 15),
                    ExpansionTile(
                      onExpansionChanged: (bool expanded) {
                        setState(() {});
                      },
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      childrenPadding: EdgeInsets.zero,
                      initiallyExpanded: true,
                      title: Text(
                        "Total trip fare".tr,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w500,
                          color: notifier.textColor,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$currencyy ${finaltotal.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w500,
                              color: notifier.textColor,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_outlined,
                              size: 23, color: Colors.grey),
                        ],
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 17),
                          child: Row(
                            children: [
                              Text(
                                "Ride Charges".tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "$currencyy ${total.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: notifier.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            coupontotal == 0
                                ? const SizedBox()
                                : const SizedBox(height: 5),
                            coupontotal == 0
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 17),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Discount".tr,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "- $currencyy ${coupontotal.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: notifier.textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                        coupontotal == 0
                            ? const SizedBox()
                            : const SizedBox(height: 5),
                        additionaltotal == 0
                            ? const SizedBox()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 17),
                                child: Row(
                                  children: [
                                    Text(
                                      "Additional time(${additionaltime.toStringAsFixed(2)} mint)",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "$currencyy ${additionaltotal.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: notifier.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(height: 5),
                        whthercharge == 0
                            ? const SizedBox()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 17),
                                child: Row(
                                  children: [
                                    Text(
                                      "Whether Charge".tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "$currencyy ${whthercharge.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: notifier.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(height: 5),
                        platformfee == 0
                            ? const SizedBox()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 17),
                                child: Row(
                                  children: [
                                    Text(
                                      "Platform fee".tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "$currencyy ${platformfee.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: notifier.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(height: 5),
                      ],
                    ),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 17),
                      dense: true,
                      minVerticalPadding: 0,
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        "AMOUNT TO BE PAID".tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: notifier.textColor,
                        ),
                      ),
                      trailing: Text(
                        "$currencyy ${finaltotal.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: notifier.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Container(
                  // height: 450,
                  decoration: BoxDecoration(
                    color: notifier.containercolore,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                  ),
                  child: paymentGetApiController.isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: theamcolore))
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(
                                height: 13,
                              ),
                              Text('Payment Gateway Method'.tr,
                                  style: TextStyle(
                                      fontFamily: "SofiaProBold",
                                      fontSize: 18,
                                      color: notifier.textColor)),
                              const SizedBox(
                                height: 10,
                              ),
                              walleteamountcondition == 0
                                  ? const SizedBox()
                                  : Row(
                                      children: [
                                        SvgPicture.asset(
                                            "assets/svgpicture/wallet.svg",
                                            height: 30,
                                            color: theamcolore),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "My Wallet ($currencyy${walleteamount.toStringAsFixed(2)})"
                                              .tr,
                                          style: TextStyle(
                                              color: notifier.textColor),
                                        ),
                                        const Spacer(),
                                        Transform.scale(
                                          scale: 0.8,
                                          child: CupertinoSwitch(
                                            value: switchValue,
                                            activeColor: theamcolore,
                                            onChanged: (bool value) {
                                              setState(() {
                                                switchValue = value;
                                                walletMain = double.parse(
                                                    "$walleteelse");
                                              });

                                              if (switchValue) {
                                                // print("hello if$walletMain");

                                                if (finaltotal >
                                                    walleteamount) {
                                                  walletValue = double.parse(
                                                      "${walleteamount}");
                                                  finaltotal -= walletValue;
                                                  walleteamount = 0;
                                                  print(
                                                      "////walletValue///// $walletValue");
                                                } else {
                                                  walletValue = double.parse(
                                                      "$finaltotal");
                                                  finaltotal -= finaltotal;
                                                  double good = walletMain;
                                                  walleteamount =
                                                      (good - walletValue);
                                                  print(
                                                      "++++++ walleteamount +++++ : --   $walleteamount");
                                                  print(
                                                      "++++++ walletValue +++++ : --   $walletValue");
                                                  print(
                                                      "++++++ finaltotal +++++ : --   $finaltotal");
                                                  print(
                                                      "++++++ good +++++ : --   $good");
                                                }
                                              } else {
                                                print("hello else");
                                                walleteamount = walleteelse;
                                                finaltotal = finaltotalsecounde;
                                                walletValue = 0;
                                                setState(() {});
                                                print(
                                                    "++++++ walletMain +++++ : --   $walletMain");
                                                print(
                                                    "++++++ walletValue +++++ : --   $walletValue");
                                                print(
                                                    "++++++ walleteamount +++++ : --   $walleteamount");
                                                print(
                                                    "++++++ walleteamount +++++ : --   $walleteelse");
                                                print(
                                                    "++++++ finaltotalsecounde +++++ : --   $finaltotalsecounde");
                                                // walletMain = walletMain;
                                              }
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                              const SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: ListView.separated(
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(width: 0);
                                    },
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: paymentGetApiController
                                        .paymentgetwayapi!.paymentList!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return InkWell(
                                        onTap: finaltotal == 0
                                            ? () {
                                                print("dgvbdjbjksbg");
                                              }
                                            : () {
                                                setState(() {
                                                  paymentindex = index;
                                                  payment =
                                                      paymentGetApiController
                                                          .paymentgetwayapi!
                                                          .paymentList![index]
                                                          .id!;
                                                  print(
                                                      "++++++++:--$paymentindex");
                                                  print("--------:-$payment");
                                                  // paymentmethodId = paymentGetApiController.paymentgetwayapi!.paymentdata[index].id;
                                                });
                                              },
                                        child: paymentGetApiController
                                                    .paymentgetwayapi!
                                                    .paymentList![index]
                                                    .status ==
                                                "0"
                                            ? const SizedBox()
                                            : Container(
                                                height: 90,
                                                margin: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 6,
                                                    bottom: 0),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  // color: Colors.yellowAccent,
                                                  border: Border.all(
                                                      color: payment ==
                                                              paymentGetApiController
                                                                  .paymentgetwayapi!
                                                                  .paymentList![
                                                                      index]
                                                                  .id!
                                                          ? theamcolore
                                                          : Colors.grey
                                                              .withOpacity(
                                                                  0.4)),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Center(
                                                  child: ListTile(
                                                    leading:
                                                        Transform.translate(
                                                      offset:
                                                          const Offset(-5, 0),
                                                      child: Container(
                                                        height: 100,
                                                        width: 60,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.4)),
                                                            image: DecorationImage(
                                                                image: NetworkImage(
                                                                    '${Config.imageurl}${paymentGetApiController.paymentgetwayapi!.paymentList![index].image}'))),
                                                      ),
                                                    ),
                                                    title: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 4),
                                                      child: Text(
                                                        paymentGetApiController
                                                            .paymentgetwayapi!
                                                            .paymentList![index]
                                                            .name
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontFamily:
                                                                "SofiaProBold",
                                                            color: notifier
                                                                .textColor),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                    subtitle: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 4),
                                                      child: Text(
                                                        paymentGetApiController
                                                            .paymentgetwayapi!
                                                            .paymentList![index]
                                                            .subTitle
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "SofiaProBold",
                                                            color: notifier
                                                                .textColor),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                    trailing: Radio(
                                                      value: payment ==
                                                              paymentGetApiController
                                                                  .paymentgetwayapi!
                                                                  .paymentList![
                                                                      index]
                                                                  .id!
                                                          ? true
                                                          : false,
                                                      fillColor:
                                                          MaterialStatePropertyAll(
                                                              theamcolore),
                                                      groupValue: true,
                                                      onChanged: (value) {
                                                        print(value);
                                                        setState(() {
                                                          selectedOption =
                                                              value.toString();
                                                          selectBoring =
                                                              paymentGetApiController
                                                                  .paymentgetwayapi!
                                                                  .paymentList![
                                                                      index]
                                                                  .image
                                                                  .toString();
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
