// To parse this JSON data, do
//
//     final accountDeleteApiModel = accountDeleteApiModelFromJson(jsonString);

import 'dart:convert';

AccountDeleteApiModel accountDeleteApiModelFromJson(String str) => AccountDeleteApiModel.fromJson(json.decode(str));

String accountDeleteApiModelToJson(AccountDeleteApiModel data) => json.encode(data.toJson());

class AccountDeleteApiModel {
  int? responseCode;
  bool? result;
  String? message;

  AccountDeleteApiModel({
    this.responseCode,
    this.result,
    this.message,
  });

  factory AccountDeleteApiModel.fromJson(Map<String, dynamic> json) => AccountDeleteApiModel(
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
