// To parse this JSON data, do
//
//     final referAndEarnApiModel = referAndEarnApiModelFromJson(jsonString);

import 'dart:convert';

ReferAndEarnApiModel referAndEarnApiModelFromJson(String str) => ReferAndEarnApiModel.fromJson(json.decode(str));

String referAndEarnApiModelToJson(ReferAndEarnApiModel data) => json.encode(data.toJson());

class ReferAndEarnApiModel {
  int? responseCode;
  bool? result;
  String? message;
  ReferData? referData;

  ReferAndEarnApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.referData,
  });

  factory ReferAndEarnApiModel.fromJson(Map<String, dynamic> json) => ReferAndEarnApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    referData: json["refer_data"] == null ? null : ReferData.fromJson(json["refer_data"]),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "refer_data": referData?.toJson(),
  };
}

class ReferData {
  String? referralCode;
  String? referCredit;
  String? signupCredit;

  ReferData({
    this.referralCode,
    this.referCredit,
    this.signupCredit,
  });

  factory ReferData.fromJson(Map<String, dynamic> json) => ReferData(
    referralCode: json["referral_code"],
    referCredit: json["refer_credit"],
    signupCredit: json["signup_credit"],
  );

  Map<String, dynamic> toJson() => {
    "referral_code": referralCode,
    "refer_credit": referCredit,
    "signup_credit": signupCredit,
  };
}
