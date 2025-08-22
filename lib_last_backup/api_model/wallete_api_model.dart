// To parse this JSON data, do
//
//     final walletAddApiModel = walletAddApiModelFromJson(jsonString);

import 'dart:convert';

WalletAddApiModel walletAddApiModelFromJson(String str) => WalletAddApiModel.fromJson(json.decode(str));

String walletAddApiModelToJson(WalletAddApiModel data) => json.encode(data.toJson());

class WalletAddApiModel {
  int? responseCode;
  bool? result;
  String? message;

  WalletAddApiModel({
    this.responseCode,
    this.result,
    this.message,
  });

  factory WalletAddApiModel.fromJson(Map<String, dynamic> json) => WalletAddApiModel(
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
