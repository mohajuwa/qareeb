// To parse this JSON data, do
//
//     final driverReviewApiModel = driverReviewApiModelFromJson(jsonString);

import 'dart:convert';

DriverReviewApiModel driverReviewApiModelFromJson(String str) => DriverReviewApiModel.fromJson(json.decode(str));

String driverReviewApiModelToJson(DriverReviewApiModel data) => json.encode(data.toJson());

class DriverReviewApiModel {
  int? responseCode;
  bool? result;
  String? message;

  DriverReviewApiModel({
    this.responseCode,
    this.result,
    this.message,
  });

  factory DriverReviewApiModel.fromJson(Map<String, dynamic> json) => DriverReviewApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
  };
}
