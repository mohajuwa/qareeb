// To parse this JSON data, do
//
//     final reviewDataApiModel = reviewDataApiModelFromJson(jsonString);

import 'dart:convert';

ReviewDataApiModel reviewDataApiModelFromJson(String str) => ReviewDataApiModel.fromJson(json.decode(str));

String reviewDataApiModelToJson(ReviewDataApiModel data) => json.encode(data.toJson());

class ReviewDataApiModel {
  int? responseCode;
  bool? result;
  String? message;
  List<ReviewList>? reviewList;

  ReviewDataApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.reviewList,
  });

  factory ReviewDataApiModel.fromJson(Map<String, dynamic> json) => ReviewDataApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    reviewList: json["review_list"] == null ? [] : List<ReviewList>.from(json["review_list"]!.map((x) => ReviewList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
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
