// To parse this JSON data, do
//
//     final twilioApiModel = twilioApiModelFromJson(jsonString);

import 'dart:convert';

TwilioApiModel twilioApiModelFromJson(String str) => TwilioApiModel.fromJson(json.decode(str));

String twilioApiModelToJson(TwilioApiModel data) => json.encode(data.toJson());

class TwilioApiModel {
  int? responseCode;
  bool? result;
  String? message;
  String? otp;

  TwilioApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.otp,
  });

  factory TwilioApiModel.fromJson(Map<String, dynamic> json) => TwilioApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "otp": otp,
  };
}
