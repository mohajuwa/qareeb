// To parse this JSON data, do
//
//     final walletReportApiModel = walletReportApiModelFromJson(jsonString);

import 'dart:convert';

WalletReportApiModel walletReportApiModelFromJson(String str) => WalletReportApiModel.fromJson(json.decode(str));

String walletReportApiModelToJson(WalletReportApiModel data) => json.encode(data.toJson());

class WalletReportApiModel {
  int? responseCode;
  bool? result;
  String? message;
  String? walletAmount;
  List<WalletDatum>? walletData;

  WalletReportApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.walletAmount,
    this.walletData,
  });

  factory WalletReportApiModel.fromJson(Map<String, dynamic> json) => WalletReportApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    walletAmount: json["wallet_amount"],
    walletData: json["wallet_data"] == null ? [] : List<WalletDatum>.from(json["wallet_data"]!.map((x) => WalletDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "wallet_amount": walletAmount,
    "wallet_data": walletData == null ? [] : List<dynamic>.from(walletData!.map((x) => x.toJson())),
  };
}

class WalletDatum {
  int? id;
  String? cId;
  String? paymentId;
  String? amount;
  String? date;
  String? status;
  String? type;
  String? pname;

  WalletDatum({
    this.id,
    this.cId,
    this.paymentId,
    this.amount,
    this.date,
    this.status,
    this.type,
    this.pname,
  });

  factory WalletDatum.fromJson(Map<String, dynamic> json) => WalletDatum(
    id: json["id"],
    cId: json["c_id"],
    paymentId: json["payment_id"],
    amount: json["amount"],
    date: json["date"],
    status: json["status"],
    type: json["type"],
    pname: json["pname"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "c_id": cId,
    "payment_id": paymentId,
    "amount": amount,
    "date": date,
    "status": status,
    "type": type,
    "pname": pname,
  };
}
