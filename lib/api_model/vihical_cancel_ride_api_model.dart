// To parse this JSON data, do
//
//     final vihicalRideCancelModel = vihicalRideCancelModelFromJson(jsonString);

import 'dart:convert';

VihicalRideCancelModel vihicalRideCancelModelFromJson(String str) => VihicalRideCancelModel.fromJson(json.decode(str));

String vihicalRideCancelModelToJson(VihicalRideCancelModel data) => json.encode(data.toJson());

class VihicalRideCancelModel {
  int? responseCode;
  bool? result;
  String? message;
  List<int>? driverid;

  VihicalRideCancelModel({
    this.responseCode,
    this.result,
    this.message,
    this.driverid,
  });

  factory VihicalRideCancelModel.fromJson(Map<String, dynamic> json) => VihicalRideCancelModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    driverid: json["driverid"] == null ? [] : List<int>.from(json["driverid"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "driverid": driverid == null ? [] : List<dynamic>.from(driverid!.map((x) => x)),
  };
}
