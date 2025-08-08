// MIGRATED common_flow_screen.dart with Provider State Management
// ignore_for_file: avoid_print, unnecessary_cast
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/api_code/calculate_api_controller.dart';
import 'package:qareeb/api_code/global_driver_access_api_controller.dart';
import 'package:qareeb/app_screen/home_screen.dart';

// ✅ PROVIDER IMPORTS
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/map_state.dart';
import 'package:qareeb/providers/pricing_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';
import 'package:qareeb/providers/socket_service.dart';

import '../api_code/cancel_rason_request_api_controller.dart';
import '../api_code/remove_request.dart';
import '../api_code/vihical_calculate_api_controller.dart';
import '../api_code/vihical_ride_cancel.dart';
import '../app_screen/map_screen.dart';

import 'colore_screen.dart';
import 'common_button.dart';
import 'config.dart';
import 'global_variables.dart';
import 'modern_loading_widget.dart';
import 'toastification.dart';

String request_id = "";
GlobalDriverAcceptClass globalDriverAcceptClass =
    Get.put(GlobalDriverAcceptClass());

// ✅ MIGRATED CANCEL REQUEST FLOW
Future<void> commonbottomsheetflow({required BuildContext context}) {
  return Get.bottomSheet(
    isScrollControlled: true,
    Consumer3<RideRequestState, LocationState, PricingState>(
      builder: (context, rideState, locationState, pricingState, child) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool cancelloader = false;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  width: Get.width,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notifier.containercolore,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle for dragging
                        Container(
                          height: 5,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Status indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/svgpicture/check-circle.svg",
                              color: notifier.textColor,
                              height: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Request Processing...",
                              style: TextStyle(
                                color: notifier.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Route information
                        _buildRouteInfo(context, locationState),

                        const SizedBox(height: 30),

                        // Pricing information
                        if (pricingState.dropPrice > 0)
                          _buildPricingInfo(context, pricingState),

                        const SizedBox(height: 30),

                        // Action buttons
                        Column(
                          children: [
                            // Keep searching button (if needed)
                            CommonOutLineButton(
                              bordercolore: theamcolore,
                              onPressed1: () {
                                // Keep searching logic
                                Get.back();
                              },
                              context: context,
                              txt1: "Keep Searching",
                            ),

                            const SizedBox(height: 15),

                            // Cancel request button
                            cancelloader
                                // ignore: dead_code
                                ? const Center(
                                    child: ModernLoadingWidget(
                                      message: "جاري المعالجة...",
                                    ),
                                  )
                                : CommonOutLineButton(
                                    bordercolore: theamcolore,
                                    onPressed1: () async {
                                      await _handleCancelRequest(
                                        context,
                                        setState,
                                        () => cancelloader = true,
                                        () => cancelloader = false,
                                      );
                                    },
                                    context: context,
                                    txt1: "Cancel Request",
                                  ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}

Future<void> _handleCancelRequest(
  BuildContext context,
  StateSetter setState,
  VoidCallback setLoading,
  VoidCallback clearLoading,
) async {
  try {
    setState(() {
      setLoading();
    });

    // Get remove request controller

    RemoveRequest removeRequest = Get.put(RemoveRequest());

    GlobalDriverAcceptClass globalDriverAcceptClass =
        Get.put(GlobalDriverAcceptClass());

    // Call remove API

    final result = await removeRequest.removeApi(
      uid: useridgloable.toString(),
      context: context,
    );

    if (result != null && result["Result"] == true) {
      // Emit socket event using provider

      SocketService.instance.emit('AcceRemoveOther', {
        'requestid': globalDriverAcceptClass.request_id, // FIXED

        'driverid': result["driver_list"] ?? [],
      });

      // Clear provider states

      if (context.mounted) {
        context.read<RideRequestState>().clearRideRequest();

        context.read<LocationState>().clearLocationData();

        context.read<PricingState>().clearPricingData();

        context.read<MapState>().clearMapData();
      }

      // Small delay for socket processing

      await Future.delayed(const Duration(milliseconds: 500));

      // Close bottom sheet and navigate

      Get.back();

      // Navigate to map screen

      Get.offAll(() => const ModernMapScreen(selectVehicle: false));

      // Show success message

      showToastForDuration("Request cancelled successfully", 2);
    } else {
      // Handle API failure

      showToastForDuration("Failed to cancel request. Please try again.", 3);
    }
  } catch (e) {
    if (kDebugMode) print("❌ Cancel request error: $e");

    showToastForDuration("Something went wrong. Please try again.", 3);
  } finally {
    if (context.mounted) {
      setState(() {
        clearLoading();
      });
    }
  }
}

// 5. FIX THE _processCancelRide FUNCTION:

Future<void> _processCancelRide(
  BuildContext context,
  VihicalCancelRideApiController controller,
  String cancelId,
) async {
  try {
    GlobalDriverAcceptClass globalDriverAcceptClass =
        Get.put(GlobalDriverAcceptClass());

    // Show loading

    Get.dialog(
      const Center(
        child: ModernLoadingWidget(
          message: "جاري إلغاء الرحلة...",
        ),
      ),
      barrierDismissible: false,
    );

    // Get current location from provider

    final locationState = context.read<LocationState>();

    // Call cancel API

    final result = await controller.vihicalcancelapi(
      uid: useridgloable.toString(),

      lat: locationState.latHomeCurrent?.toString() ?? "0",

      lon: locationState.longHomeCurrent?.toString() ?? "0",

      cancel_id: cancelId,

      request_id: globalDriverAcceptClass.request_id.toString(), // FIXED
    );

    // Hide loading dialog

    Get.back();

    if (result != null && result["Result"] == true) {
      // Emit socket event

      SocketService.instance.emit('Vehicle_Ride_Cancel', {
        'uid': useridgloable.toString(),
        'driverid': result["driverid"],
      });

      // Clear provider states

      if (context.mounted) {
        context.read<RideRequestState>().clearRideRequest();

        context.read<LocationState>().clearLocationData();

        context.read<PricingState>().clearPricingData();

        context.read<MapState>().clearMapData();
      }

      // Close all bottom sheets

      Get.close(2);

      // Navigate to map screen

      Get.offAll(() => const ModernMapScreen(selectVehicle: false));

      // Show success message

      showToastForDuration("Ride cancelled successfully", 2);
    } else {
      showToastForDuration("Failed to cancel ride. Please try again.", 3);
    }
  } catch (e) {
    // Hide loading dialog if still showing

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    if (kDebugMode) print("❌ Cancel ride error: $e");

    showToastForDuration("Something went wrong. Please try again.", 3);
  }
}

// ✅ MIGRATED CANCEL REASON BOTTOM SHEET
Future<void> commonbottomsheetcancelflow({required BuildContext context}) {
  return Get.bottomSheet(
    Consumer<RideRequestState>(
      builder: (context, rideState, child) {
        return StatefulBuilder(
          builder: (context, setState) {
            // API Controllers

            CancelRasonRequestApiController cancelRasonRequestApiController =
                Get.put(CancelRasonRequestApiController());
            VihicalCancelRideApiController vihicalCancelRideApiController =
                Get.put(VihicalCancelRideApiController());

            String cancel_id = "";

            // Load cancel reasons

            cancelRasonRequestApiController.cancelreasonApi(context);

            // Connect socket

            SocketService.instance.connect();

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: notifier.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),

                        // Handle for dragging

                        Center(
                          child: Container(
                            height: 5,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Title

                        Text(
                          "Cancel Ride",
                          style: TextStyle(
                            color: notifier.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Please select a reason for cancellation:",
                          style: TextStyle(
                            color: notifier.textColor,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Cancel reasons list

                        GetBuilder<CancelRasonRequestApiController>(
                          builder: (cancelController) {
                            return cancelController
                                        .cancelreasonApi(context)
                                        ?.cancelList
                                        ?.isNotEmpty ==
                                    true

                                // FIX: The Column is now structured correctly.

                                ? Column(
                                    children: [
                                      // FIX: .toList() is now correctly placed on the .map() operation.

                                      ...cancelController
                                          .cancelreasonApi(context)!
                                          .cancelList!
                                          .map(
                                            (reason) => Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    cancel_id =
                                                        reason.id.toString();
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  decoration: BoxDecoration(
                                                    color: cancel_id ==
                                                            reason.id.toString()
                                                        ? theamcolore
                                                            .withOpacity(0.1)
                                                        : notifier
                                                            .containercolore,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                      color: cancel_id ==
                                                              reason.id
                                                                  .toString()
                                                          ? theamcolore
                                                          : Colors.grey
                                                              .withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        cancel_id ==
                                                                reason.id
                                                                    .toString()
                                                            ? Icons
                                                                .radio_button_checked
                                                            : Icons
                                                                .radio_button_unchecked,
                                                        color: cancel_id ==
                                                                reason.id
                                                                    .toString()
                                                            ? theamcolore
                                                            : Colors.grey,
                                                      ),
                                                      const SizedBox(width: 15),
                                                      Expanded(
                                                        child: Text(
                                                          reason.title ?? "",
                                                          style: TextStyle(
                                                            color: notifier
                                                                .textColor,
                                                            fontSize: 16,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),

                                      const SizedBox(height: 30),

                                      // FIX: The action buttons are now direct children of the same Column.

                                      CommonOutLineButton(
                                        bordercolore: theamcolore,
                                        onPressed1: () {
                                          Get.back();
                                        },
                                        context: context,
                                        txt1: "Keep searching",
                                      ),

                                      const SizedBox(height: 15),

                                      CommonButton(
                                        containcolore: theamcolore,
                                        onPressed1: () async {
                                          if (cancel_id.isNotEmpty) {
                                            await _processCancelRide(
                                              context,
                                              vihicalCancelRideApiController,
                                              cancel_id,
                                            );
                                          } else {
                                            showToastForDuration(
                                              "Please select a cancellation reason",
                                              2,
                                            );
                                          }
                                        },
                                        txt1: "Cancel Ride",
                                      ),
                                      const SizedBox(
                                          height:
                                              20), // Added padding for the bottom
                                    ],
                                  )
                                : const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
    isScrollControlled: true,
  );
}

// ✅ HELPER WIDGET: ROUTE INFORMATION
Widget _buildRouteInfo(BuildContext context, LocationState locationState) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: notifier.containercolore,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.withOpacity(0.2)),
    ),
    child: Column(
      children: [
        // Pickup location
        Row(
          children: [
            Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 4),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pickup Location",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    locationState.pickTitle.isNotEmpty
                        ? locationState.pickTitle
                        : locationState.pickupController.text,
                    style: TextStyle(
                      color: notifier.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        // Dotted line
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 7),
              Container(
                height: 20,
                width: 2,
                child: Column(
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: Container(
                        width: 2,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Drop location
        Row(
          children: [
            Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 4),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Drop Location",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    locationState.dropTitle.isNotEmpty
                        ? locationState.dropTitle
                        : locationState.dropController.text,
                    style: TextStyle(
                      color: notifier.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ✅ HELPER WIDGET: PRICING INFORMATION
Widget _buildPricingInfo(BuildContext context, PricingState pricingState) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: theamcolore.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theamcolore.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Estimated Fare:",
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "$globalcurrency${pricingState.dropPrice.toStringAsFixed(2)}",
              style: TextStyle(
                color: theamcolore,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (pricingState.minimumfare > 0 && pricingState.maximumfare > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Range:",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  "$globalcurrency${pricingState.minimumfare.toStringAsFixed(2)} - $globalcurrency${pricingState.maximumfare.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

// ✅ PAYMENT SUCCESS FLOW (if needed)
Future<void> paymentSuccessFlow({
  required BuildContext context,
  required double totalAmount,
}) {
  return Get.bottomSheet(
    isScrollControlled: true,
    Consumer2<PricingState, RideRequestState>(
      builder: (context, pricingState, rideState, child) {
        return Container(
          decoration: BoxDecoration(
            color: notifier.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Payment Successful!",
                  style: TextStyle(
                    color: notifier.textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Paid $globalcurrency${totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: theamcolore,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 30),

                CommonButton(
                  containcolore: theamcolore,
                  onPressed1: () {
                    Get.back();
                    Get.offAll(
                        () => const ModernMapScreen(selectVehicle: false));
                  },
                  txt1: "Done",
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    ),
  );
}
