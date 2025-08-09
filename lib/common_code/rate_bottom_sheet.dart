// ✅ MIGRATED - Rate Bottom Sheet with Provider State Management
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/api_code/global_driver_access_api_controller.dart';
import 'package:qareeb/api_code/review_api_controller.dart';
import 'package:qareeb/api_code/review_data_api_controller.dart';
import 'package:qareeb/api_code/vihical_ride_complete_order_api_controller.dart';
import 'package:qareeb/app_screen/map_screen.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import 'package:qareeb/common_code/common_button.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/pricing_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';

// ✅ MIGRATED - Rate Bottom Sheet with Provider State Management
Future rateBottomSheet(BuildContext context) {
  // ✅ MIGRATED - GetX controllers remain as they handle API calls
  DriverReviewDetailApiController driverReviewDetailApiController =
      Get.put(DriverReviewDetailApiController());
  ReviewDataApiController reviewDataApiController =
      Get.put(ReviewDataApiController());

  // ✅ MIGRATED - Local state variables
  TextEditingController reviewtextcontroller = TextEditingController();
  List reviewid = [];
  String reviewtitle = '';
  double currentRating = 1.0; // ✅ ADDED LOCAL RATING VARIABLE

  // ✅ MIGRATED - Provider for UI theming
  ColorNotifier notifier = ColorNotifier();

  // ✅ MIGRATED - Get global driver access controller for driver data
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());

  // ✅ KEEP - API call for review data
  reviewDataApiController.reviewdataApi().then((value) {
    if (kDebugMode) print("✅ Review data loaded: $value");
  });

  return Get.bottomSheet(
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,

    // ✅ MIGRATED - Wrap with Provider Consumer for state management
    Consumer3<PricingState, LocationState, RideRequestState>(
      builder: (context, pricingState, locationState, rideRequestState, child) {
        return GetBuilder<ReviewDataApiController>(
          builder: (reviewDataApiController) {
            return reviewDataApiController.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: theamcolore),
                  )
                : StatefulBuilder(
                    builder: (context, setState) {
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
                                  // ✅ MIGRATED - Use provider state for payment amount
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/svgpicture/check-circle.svg",
                                        color: notifier.textColor,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "Paid $globalcurrency${pricingState.amountresponse.isNotEmpty ? pricingState.amountresponse : '0.00'}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: notifier.textColor,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              notifier.languagecontainercolore,
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.help_outline,
                                              size: 21,
                                              color: notifier.textColor,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              "Help",
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
                                  const SizedBox(height: 15),

                                  // ✅ MIGRATED - Driver image and info using global driver controller
                                  Center(
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              globalDriverAcceptClass
                                                      .driver_image.isNotEmpty
                                                  ? globalDriverAcceptClass
                                                      .driver_image
                                                  : "https://via.placeholder.com/80"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                    "How was your ride with ${globalDriverAcceptClass.driver_name.isNotEmpty ? globalDriverAcceptClass.driver_name : 'Driver'}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: notifier.textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),

                                  // ✅ KEEP - Rating bar functionality
                                  RatingBar(
                                    initialRating: 1,
                                    direction: Axis.horizontal,
                                    itemCount: 5,
                                    allowHalfRating: true,
                                    ratingWidget: RatingWidget(
                                      full: Image.asset(
                                        'assets/starBold.png',
                                        color: theamcolore,
                                      ),
                                      half: Image.asset(
                                        'assets/star-half.png',
                                        color: theamcolore,
                                      ),
                                      empty: Image.asset(
                                        'assets/star.png',
                                        color: theamcolore,
                                      ),
                                    ),
                                    itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    onRatingUpdate: (rating) {
                                      setState(() {
                                        // ✅ FIXED - Use local rating variable
                                        currentRating = rating;
                                        if (kDebugMode) {
                                          print("⭐ Rating: $rating");
                                          print(
                                              "⭐ Current Rating: $currentRating");
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  const Text(
                                    "Great, what did you like the most? 😍",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),

                                  // ✅ KEEP - Review options selection
                                  Wrap(
                                    spacing: 13,
                                    runSpacing: 13,
                                    alignment: WrapAlignment.start,
                                    clipBehavior: Clip.none,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    runAlignment: WrapAlignment.start,
                                    children: [
                                      if (reviewDataApiController
                                              .reviewDataApiModel?.reviewList !=
                                          null)
                                        for (int a = 0;
                                            a <
                                                reviewDataApiController
                                                    .reviewDataApiModel!
                                                    .reviewList!
                                                    .length;
                                            a++)
                                          Builder(
                                            builder: (context) {
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    reviewtitle =
                                                        reviewDataApiController
                                                            .reviewDataApiModel!
                                                            .reviewList![a]
                                                            .title
                                                            .toString();

                                                    if (reviewid.contains(
                                                        reviewDataApiController
                                                            .reviewDataApiModel!
                                                            .reviewList![a]
                                                            .id)) {
                                                      reviewid.remove(
                                                          reviewDataApiController
                                                              .reviewDataApiModel!
                                                              .reviewList![a]
                                                              .id);
                                                      if (kDebugMode)
                                                        print(
                                                            "➖ Removed review: $reviewid");
                                                    } else {
                                                      reviewid.add(
                                                          reviewDataApiController
                                                              .reviewDataApiModel!
                                                              .reviewList![a]
                                                              .id);
                                                      if (kDebugMode)
                                                        print(
                                                            "➕ Added review: $reviewid");
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  height: 40,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 15,
                                                    vertical: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: reviewid.contains(
                                                            reviewDataApiController
                                                                .reviewDataApiModel!
                                                                .reviewList![a]
                                                                .id)
                                                        ? theamcolore
                                                        : notifier
                                                            .containercolore,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18),
                                                    border: Border.all(
                                                      color: Colors.grey
                                                          .withOpacity(0.4),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        reviewDataApiController
                                                            .reviewDataApiModel!
                                                            .reviewList![a]
                                                            .title
                                                            .toString(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                              fontSize: 15,
                                                              color: reviewid.contains(
                                                                      reviewDataApiController
                                                                          .reviewDataApiModel!
                                                                          .reviewList![
                                                                              a]
                                                                          .id)
                                                                  ? Colors.white
                                                                  : notifier
                                                                      .textColor,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // ✅ KEEP - Text input for additional comments
                                  CommonTextfiled200(
                                    txt: "Tell us more...",
                                    context: context,
                                    controller: reviewtextcontroller,
                                  ),
                                  const SizedBox(height: 20),

                                  // ✅ MIGRATED - Submit review with provider state
                                  CommonButton(
                                    txt1: "Done",
                                    onPressed1: () {
                                      if (kDebugMode) {
                                        print("📝 Review submission:");
                                        print("userid: $useridgloable");
                                        print(
                                            "driver_id: ${globalDriverAcceptClass.driver_id}");
                                        print(
                                            "review text: ${reviewtextcontroller.text}");
                                        print("rating: $currentRating");
                                        print(
                                            "request_id: ${rideRequestState.requestId}");
                                        print("selected reviews: $reviewid");
                                      }

                                      driverReviewDetailApiController.reviewapi(
                                        def_review: reviewid,
                                        uid: useridgloable.toString(),
                                        d_id: globalDriverAcceptClass
                                                .driver_id.isNotEmpty
                                            ? globalDriverAcceptClass.driver_id
                                            : driver_id,
                                        review: reviewtextcontroller.text,
                                        tot_star: "$currentRating",
                                        request_id: rideRequestState
                                                .requestId.isNotEmpty
                                            ? rideRequestState.requestId
                                            : request_id,
                                        context: context,
                                      );
                                    },
                                    containcolore: theamcolore,
                                    context: context,
                                  ),
                                  const SizedBox(height: 10),

                                  // ✅ MIGRATED - Skip review and return to map
                                  CommonOutLineButton(
                                    bordercolore: theamcolore,
                                    onPressed1: () {
                                      Get.offAll(const ModernMapScreen(
                                          selectVehicle: false));
                                    },
                                    txt1: "Skip",
                                    context: context,
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
        );
      },
    ),
  );
}
