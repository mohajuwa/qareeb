// To parse this JSON data, do
//
//     final paymentgetwayapi = paymentgetwayapiFromJson(jsonString);

import 'dart:convert';

Paymentgetwayapi paymentgetwayapiFromJson(String str) => Paymentgetwayapi.fromJson(json.decode(str));

String paymentgetwayapiToJson(Paymentgetwayapi data) => json.encode(data.toJson());

class Paymentgetwayapi {
  int? responseCode;
  bool? result;
  String? message;
  String? defaultPayment;
  List<CouponList>? couponList;
  List<PaymentList>? paymentList;
  List<BankDatum>? bankData;

  Paymentgetwayapi({
    this.responseCode,
    this.result,
    this.message,
    this.defaultPayment,
    this.couponList,
    this.paymentList,
    this.bankData,
  });

  factory Paymentgetwayapi.fromJson(Map<String, dynamic> json) => Paymentgetwayapi(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    defaultPayment: json["default_payment"],
    couponList: json["coupon_list"] == null ? [] : List<CouponList>.from(json["coupon_list"]!.map((x) => CouponList.fromJson(x))),
    paymentList: json["payment_list"] == null ? [] : List<PaymentList>.from(json["payment_list"]!.map((x) => PaymentList.fromJson(x))),
    bankData: json["bank_data"] == null ? [] : List<BankDatum>.from(json["bank_data"]!.map((x) => BankDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "default_payment": defaultPayment,
    "coupon_list": couponList == null ? [] : List<dynamic>.from(couponList!.map((x) => x.toJson())),
    "payment_list": paymentList == null ? [] : List<dynamic>.from(paymentList!.map((x) => x.toJson())),
    "bank_data": bankData == null ? [] : List<dynamic>.from(bankData!.map((x) => x.toJson())),
  };
}

class BankDatum {
  String? bankName;
  String? holderName;
  String? accountNo;
  String? iafcCode;
  String? swiftCode;

  BankDatum({
    this.bankName,
    this.holderName,
    this.accountNo,
    this.iafcCode,
    this.swiftCode,
  });

  factory BankDatum.fromJson(Map<String, dynamic> json) => BankDatum(
    bankName: json["bank_name"],
    holderName: json["holder_name"],
    accountNo: json["account_no"],
    iafcCode: json["iafc_code"],
    swiftCode: json["swift_code"],
  );

  Map<String, dynamic> toJson() => {
    "bank_name": bankName,
    "holder_name": holderName,
    "account_no": accountNo,
    "iafc_code": iafcCode,
    "swift_code": swiftCode,
  };
}

class CouponList {
  int? id;
  String? title;
  String? subTitle;
  String? code;
  DateTime? startDate;
  DateTime? endDate;
  String? minAmount;
  String? discountAmount;

  CouponList({
    this.id,
    this.title,
    this.subTitle,
    this.code,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.discountAmount,
  });

  factory CouponList.fromJson(Map<String, dynamic> json) => CouponList(
    id: json["id"],
    title: json["title"],
    subTitle: json["sub_title"],
    code: json["code"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    minAmount: json["min_amount"],
    discountAmount: json["discount_amount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "sub_title": subTitle,
    "code": code,
    "start_date": startDate?.toIso8601String(),
    "end_date": endDate?.toIso8601String(),
    "min_amount": minAmount,
    "discount_amount": discountAmount,
  };
}

class PaymentList {
  int? id;
  String? image;
  String? name;
  String? subTitle;
  String? attribute;
  String? status;
  String? walletStatus;

  PaymentList({
    this.id,
    this.image,
    this.name,
    this.subTitle,
    this.attribute,
    this.status,
    this.walletStatus,
  });

  factory PaymentList.fromJson(Map<String, dynamic> json) => PaymentList(
    id: json["id"],
    image: json["image"],
    name: json["name"],
    subTitle: json["sub_title"],
    attribute: json["attribute"],
    status: json["status"],
    walletStatus: json["wallet_status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "name": name,
    "sub_title": subTitle,
    "attribute": attribute,
    "status": status,
    "wallet_status": walletStatus,
  };
}
