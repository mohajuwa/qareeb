// To parse this JSON data, do
//
//     final vihicalRideCompleteApiModel = vihicalRideCompleteApiModelFromJson(jsonString);

import 'dart:convert';

VihicalRideCompleteApiModel vihicalRideCompleteApiModelFromJson(String str) => VihicalRideCompleteApiModel.fromJson(json.decode(str));

String vihicalRideCompleteApiModelToJson(VihicalRideCompleteApiModel data) => json.encode(data.toJson());

class VihicalRideCompleteApiModel {
  int? responseCode;
  bool? result;
  String? message;
  int? requestId;
  List<ReviewList>? reviewList;

  VihicalRideCompleteApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.requestId,
    this.reviewList,
  });

  factory VihicalRideCompleteApiModel.fromJson(Map<String, dynamic> json) => VihicalRideCompleteApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    requestId: json["request_id"],
    reviewList: json["review_list"] == null ? [] : List<ReviewList>.from(json["review_list"]!.map((x) => ReviewList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "request_id": requestId,
    "review_list": reviewList == null ? [] : List<dynamic>.from(reviewList!.map((x) => x.toJson())),
  };
}

class ReviewList {
  int? id;
  String? title;
  String? status;

  ReviewList({
    this.id,
    this.title,
    this.status,
  });

  factory ReviewList.fromJson(Map<String, dynamic> json) => ReviewList(
    id: json["id"],
    title: json["title"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "status": status,
  };
}
