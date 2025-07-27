// To parse this JSON data, do
//
//     final timeOutRequest = timeOutRequestFromJson(jsonString);

import 'dart:convert';

TimeOutRequest timeOutRequestFromJson(String str) => TimeOutRequest.fromJson(json.decode(str));

String timeOutRequestToJson(TimeOutRequest data) => json.encode(data.toJson());

class TimeOutRequest {
  int? responseCode;
  bool? result;
  String? message;
  int? id;
  List<int>? driverid;

  TimeOutRequest({
    this.responseCode,
    this.result,
    this.message,
    this.id,
    this.driverid,
  });

  factory TimeOutRequest.fromJson(Map<String, dynamic> json) => TimeOutRequest(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    id: json["id"],
    driverid: json["driverid"] == null ? [] : List<int>.from(json["driverid"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "id": id,
    "driverid": driverid == null ? [] : List<dynamic>.from(driverid!.map((x) => x)),
  };
}
