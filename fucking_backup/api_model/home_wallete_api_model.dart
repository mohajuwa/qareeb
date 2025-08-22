// To parse this JSON data, do
//
//     final homeWalleteApiModel = homeWalleteApiModelFromJson(jsonString);

import 'dart:convert';

HomeWalleteApiModel homeWalleteApiModelFromJson(String str) => HomeWalleteApiModel.fromJson(json.decode(str));

String homeWalleteApiModelToJson(HomeWalleteApiModel data) => json.encode(data.toJson());

class HomeWalleteApiModel {
  int? responseCode;
  bool? result;
  String? message;
  String? walletAmount;

  HomeWalleteApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.walletAmount,
  });

  factory HomeWalleteApiModel.fromJson(Map<String, dynamic> json) => HomeWalleteApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    walletAmount: json["wallet_amount"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "wallet_amount": walletAmount,
  };
}
