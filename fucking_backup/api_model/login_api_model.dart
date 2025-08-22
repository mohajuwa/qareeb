// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  int? responseCode;
  bool? result;
  String? message;
  General? general;
  CustomerData? customerData;

  LoginModel({
    this.responseCode,
    this.result,
    this.message,
    this.general,
    this.customerData,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    general: json["general"] == null ? null : General.fromJson(json["general"]),
    customerData: json["customer_data"] == null ? null : CustomerData.fromJson(json["customer_data"]),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "general": general?.toJson(),
    "customer_data": customerData?.toJson(),
  };
}

class CustomerData {
  int? id;
  String? name;
  String? email;
  String? countryCode;
  String? phone;
  String? password;
  String? status;
  String? referralCode;
  String? wallet;

  CustomerData({
    this.id,
    this.name,
    this.email,
    this.countryCode,
    this.phone,
    this.password,
    this.status,
    this.referralCode,
    this.wallet,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) => CustomerData(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    countryCode: json["country_code"],
    phone: json["phone"],
    password: json["password"],
    status: json["status"],
    referralCode: json["referral_code"],
    wallet: json["wallet"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "country_code": countryCode,
    "phone": phone,
    "password": password,
    "status": status,
    "referral_code": referralCode,
    "wallet": wallet,
  };
}

class General {
  String? oneAppId;
  String? oneApiKey;

  General({
    this.oneAppId,
    this.oneApiKey,
  });

  factory General.fromJson(Map<String, dynamic> json) => General(
    oneAppId: json["one_app_id"],
    oneApiKey: json["one_api_key"],
  );

  Map<String, dynamic> toJson() => {
    "one_app_id": oneAppId,
    "one_api_key": oneApiKey,
  };
}
