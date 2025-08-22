// To parse this JSON data, do
//
//     final msgApiModel = msgApiModelFromJson(jsonString);

import 'dart:convert';

MsgApiModel msgApiModelFromJson(String str) => MsgApiModel.fromJson(json.decode(str));

String msgApiModelToJson(MsgApiModel data) => json.encode(data.toJson());

class MsgApiModel {
  int? responseCode;
  bool? result;
  String? message;
  String? otp;

  MsgApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.otp,
  });

  factory MsgApiModel.fromJson(Map<String, dynamic> json) => MsgApiModel(
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
