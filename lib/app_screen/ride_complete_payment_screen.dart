// ✅ MIGRATED - Ride Complete Payment Screen with Provider State Management
// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qareeb/common_code/modern_loading_widget.dart';
import 'package:qareeb/common_code/rate_bottom_sheet.dart';
import 'package:qareeb/common_code/socket_service.dart';
import 'package:qareeb/common_code/toastification.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qareeb/api_code/vihical_ride_complete_order_api_controller.dart';
import 'package:qareeb/api_code/global_driver_access_api_controller.dart';
import 'package:qareeb/app_screen/home_screen.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import 'package:qareeb/common_code/common_button.dart';

// ✅ PROVIDER IMPORTS
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/map_state.dart';
import 'package:qareeb/providers/pricing_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';

import '../api_code/coupon_payment_api_contoller.dart';
import '../api_code/review_data_api_controller.dart';
import '../common_code/common_flow_screen.dart';
import '../common_code/config.dart';
import '../payment_screen/razorpay.dart';
import 'map_screen.dart';

class RideCompletePaymentScreen extends StatefulWidget {
  const RideCompletePaymentScreen({super.key});

  @override
  State<RideCompletePaymentScreen> createState() =>
      _RideCompletePaymentScreenState();
}

class _RideCompletePaymentScreenState extends State<RideCompletePaymentScreen> {
  // ✅ MIGRATED - Remove direct socket, use SocketService
  var decodeUid;
  var currencyy;
  var userid;

  // ✅ MIGRATED - Local state variables
  num walleteelse = 0.00;
  num walleteamountcondition = 0.00;
  int paymentindex = 0;
  int payment = 0;
  num platformfee = 0.0;
  // ✅ MIGRATED - GetX controllers for API calls
  PaymentGetApiController paymentGetApiController =
      Get.put(PaymentGetApiController());
  VihicalRideCompleteOrderApiController vihicalRideCompleteOrderApiController =
      Get.put(VihicalRideCompleteOrderApiController());
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());

  // ✅ MIGRATED - Provider for UI theming
  ColorNotifier notifier = ColorNotifier();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeSocket();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    SocketService.instance.disconnect();
    super.dispose();
  }

  // ✅ MIGRATED - Initialize user data
  Future<void> _initializeData() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var uid = preferences.getString("userLogin");
      var currency = preferences.getString("currenci");

      if (uid != null && currency != null) {
        decodeUid = jsonDecode(uid);
        currencyy = jsonDecode(currency);
        userid = decodeUid['id'];

        if (kDebugMode) {
          print("✅ User data initialized:");
          print("User ID: $userid");
          print("Currency: $currencyy");
        }

        setState(() {
          walleteelse = walleteamount;
          walleteamountcondition = walleteamount;
          if (kDebugMode) {
            print("💰 Wallet amount: $walleteelse");
          }
        });
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error initializing data: $e");
    }
  }

  // ✅ MIGRATED - Socket initialization using SocketService
  void _initializeSocket() {
    try {
      if (!SocketService.instance.isConnected) {
        SocketService.instance.connect();
      }
      _setupSocketListeners();
    } catch (e) {
      if (kDebugMode) print("❌ Socket initialization error: $e");
    }
  }

  // ✅ MIGRATED - Socket event listeners for payment updates
  void _setupSocketListeners() {
    final socketService = SocketService.instance;

    // Listen for payment status updates
    socketService.on('payment_status_update$userid', (data) {
      _handlePaymentStatusUpdate(data);
    });

    // Listen for ride completion confirmations
    socketService.on('ride_complete_confirmed$userid', (data) {
      _handleRideCompleteConfirmed(data);
    });

    if (kDebugMode)
      print("✅ Socket listeners setup for RideCompletePaymentScreen");
  }

  // ✅ NEW - Socket event handlers
  void _handlePaymentStatusUpdate(dynamic data) {
    if (!mounted) return;

    try {
      if (kDebugMode) print("💳 Payment status update received: $data");

      if (data['status'] == 'success') {
        _showPaymentSuccessAndNavigateToRating();
      } else if (data['status'] == 'failed') {
        _showPaymentFailedMessage();
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error handling payment status update: $e");
    }
  }

  void _handleRideCompleteConfirmed(dynamic data) {
    if (!mounted) return;

    try {
      if (kDebugMode) print("✅ Ride complete confirmed: $data");

      // Navigate to rating screen
      _showPaymentSuccessAndNavigateToRating();
    } catch (e) {
      if (kDebugMode) print("❌ Error handling ride complete confirmation: $e");
    }
  }

  // ✅ MIGRATED - Load payment methods
  Future<void> _loadPaymentMethods() async {
    try {
      await paymentGetApiController.paymentlistApi(context);

      if (paymentGetApiController.paymentgetwayapi?.paymentList != null) {
        setState(() {
          // Set default payment method
          for (int i = 1;
              i < paymentGetApiController.paymentgetwayapi!.paymentList!.length;
              i++) {
            if (int.parse(paymentGetApiController
                    .paymentgetwayapi!.defaultPayment
                    .toString()) ==
                paymentGetApiController.paymentgetwayapi!.paymentList![i].id) {
              paymentindex = i;
              payment =
                  paymentGetApiController.paymentgetwayapi!.paymentList![i].id!;
              break;
            }
          }
        });
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error loading payment methods: $e");
    }
  }

  // ✅ MIGRATED - Socket emission using SocketService
  void _emitPaymentChange() {
    final socketService = SocketService.instance;

    socketService.emit('Vehicle_P_Change', {
      'userid': userid,
      'd_id': globalDriverAcceptClass.driver_id.isNotEmpty
          ? globalDriverAcceptClass.driver_id
          : driver_id,
      'payment_id': payment,
    });

    if (kDebugMode) print("📤 Payment change emitted");
  }

  void _emitRideComplete() {
    final socketService = SocketService.instance;

    socketService.emit('Vehicle_Ride_Complete', {
      'd_id': globalDriverAcceptClass.driver_id.isNotEmpty
          ? globalDriverAcceptClass.driver_id
          : driver_id,
      'request_id': context.read<RideRequestState>().requestId.isNotEmpty
          ? context.read<RideRequestState>().requestId
          : request_id,
    });

    if (kDebugMode) print("📤 Ride complete emitted");
  }

  // ✅ NEW - Handle payment completion
  void _handlePaymentCompletion(String paymentMethod) {
    if (kDebugMode) print("💳 Processing payment with method: $paymentMethod");

    // Process different payment methods
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        _processCashPayment();
        break;
      case 'wallet':
        _processWalletPayment();
        break;
      case 'razorpay':
        _processRazorpayPayment();
        break;
      case 'stripe':
        _processStripePayment();
        break;
      case 'paypal':
        _processPaypalPayment();
        break;
      default:
        _processDefaultPayment();
        break;
    }
  }

  void _processCashPayment() {
    vihicalRideCompleteOrderApiController
        .vihicalridecomplete(
      payment_id: payment.toString(),
      context: context,
      payment_img: "",
      uid: "$userid",
      d_id: globalDriverAcceptClass.driver_id.isNotEmpty
          ? globalDriverAcceptClass.driver_id
          : driver_id,
      request_id: context.read<RideRequestState>().requestId.isNotEmpty
          ? context.read<RideRequestState>().requestId
          : request_id,
      wallet: "${walleteelse}",
    )
        .then((value) {
      if (kDebugMode) print("✅ Cash payment completed: $value");
      _emitRideComplete();
      _showPaymentSuccessAndNavigateToRating();
    });
  }

  void _processWalletPayment() {
    // Implement wallet payment logic
    if (kDebugMode) print("💰 Processing wallet payment");
    _processCashPayment(); // For now, use same flow as cash
  }

  void _processRazorpayPayment() {
    // Implement Razorpay payment logic
    if (kDebugMode) print("💳 Processing Razorpay payment");
    // Navigate to Razorpay screen or handle Razorpay logic
  }

  void _processStripePayment() {
    // Implement Stripe payment logic
    if (kDebugMode) print("💳 Processing Stripe payment");
  }

  void _processPaypalPayment() {
    // Implement PayPal payment logic
    if (kDebugMode) print("💳 Processing PayPal payment");
  }

  void _processDefaultPayment() {
    // Default payment processing
    if (kDebugMode) print("💳 Processing default payment");
    _processCashPayment();
  }

  void _showPaymentSuccessAndNavigateToRating() {
    // Show success message
    Get.snackbar(
      "Payment Successful".tr,
      "Your payment has been processed successfully!".tr,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );

    // Navigate to rating screen
    Future.delayed(const Duration(seconds: 1), () {
      rateBottomSheet(context);
    });
  }

  void _showPaymentFailedMessage() {
    Get.snackbar(
      "Payment Failed".tr,
      "Payment processing failed. Please try again.".tr,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    // ✅ MIGRATED - Wrap with Consumer for provider state management
    return Consumer4<PricingState, LocationState, RideRequestState, MapState>(
      builder: (context, pricingState, locationState, rideRequestState,
          mapState, child) {
        return Scaffold(
          backgroundColor: notifier.background,
          appBar: AppBar(
            backgroundColor: notifier.background,
            elevation: 0,
            centerTitle: true,
            leading: InkWell(
              onTap: () => Get.back(),
              child: Icon(
                Icons.arrow_back_ios,
                color: notifier.textColor,
              ),
            ),
            title: Text(
              "Payment".tr,
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Column(
            children: [
              // ✅ MIGRATED - Payment summary using provider state
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Trip details
                    Row(
                      children: [
                        Text(
                          "Trip fare".tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "$currencyy ${pricingState.dropPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 14,
                            color: notifier.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Platform fee (if applicable)
                    if (platformfee > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
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

                    // Total amount
                    ListTile(
                      contentPadding: EdgeInsets.zero,
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
                        "$currencyy ${pricingState.amountresponse.isNotEmpty ? pricingState.amountresponse : '0.00'}",
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

              // ✅ MIGRATED - Payment methods list
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: notifier.containercolore,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: GetBuilder<PaymentGetApiController>(
                    builder: (paymentController) {
                      return paymentController.isLoading
                          ? const Center(
                              child: ModernLoadingWidget(
                                message: "جاري تحميل طرق الدفع...",
                              ),
                            )
                          : paymentController.paymentgetwayapi?.paymentList ==
                                  null
                              ? Center(
                                  child: Text(
                                    "No payment methods available".tr,
                                    style: TextStyle(
                                      color: notifier.textColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      "Select Payment Method".tr,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: notifier.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Payment methods list
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        itemCount: paymentController
                                            .paymentgetwayapi!
                                            .paymentList!
                                            .length,
                                        itemBuilder: (context, index) {
                                          final paymentMethod =
                                              paymentController
                                                  .paymentgetwayapi!
                                                  .paymentList![index];

                                          // Skip disabled payment methods
                                          if (paymentMethod.status == "0") {
                                            return const SizedBox();
                                          }

                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: payment == index
                                                    ? theamcolore
                                                    : Colors.grey.shade300,
                                                width: payment == index ? 2 : 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ListTile(
                                              onTap: () {
                                                setState(() {
                                                  paymentindex = index;
                                                  payment = paymentMethod.id!;
                                                });
                                                _emitPaymentChange();
                                              },
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  "${Config.imageurl}${paymentMethod.image}",
                                                  height: 40,
                                                  width: 40,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      height: 40,
                                                      width: 40,
                                                      color:
                                                          Colors.grey.shade200,
                                                      child: Icon(
                                                        Icons.payment,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              title: Text(
                                                paymentMethod.name ??
                                                    "Payment Method",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: notifier.textColor,
                                                ),
                                              ),
                                              trailing: Radio(
                                                value: index,
                                                groupValue: paymentindex,
                                                onChanged: (value) {
                                                  setState(() {
                                                    paymentindex = value!;
                                                    payment = paymentMethod.id!;
                                                  });
                                                  _emitPaymentChange();
                                                },
                                                activeColor: theamcolore,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // ✅ MIGRATED - Pay button
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: CommonButton(
                                        txt1:
                                            "Pay ${pricingState.amountresponse.isNotEmpty ? pricingState.amountresponse : '0.00'} $currencyy",
                                        onPressed1: () {
                                          if (paymentController.paymentgetwayapi
                                                      ?.paymentList !=
                                                  null &&
                                              paymentindex <
                                                  paymentController
                                                      .paymentgetwayapi!
                                                      .paymentList!
                                                      .length) {
                                            final selectedMethod =
                                                paymentController
                                                    .paymentgetwayapi!
                                                    .paymentList![paymentindex];
                                            _handlePaymentCompletion(
                                                selectedMethod.name ?? "");
                                          }
                                        },
                                        containcolore: theamcolore,
                                        context: context,
                                      ),
                                    ),
                                  ],
                                );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
