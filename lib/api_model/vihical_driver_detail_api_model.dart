// To parse this JSON data, do
//
//     final vihicalDriverDetailModel = vihicalDriverDetailModelFromJson(jsonString);

import 'dart:convert';

VihicalDriverDetailModel vihicalDriverDetailModelFromJson(String str) => VihicalDriverDetailModel.fromJson(json.decode(str));

String vihicalDriverDetailModelToJson(VihicalDriverDetailModel data) => json.encode(data.toJson());

class VihicalDriverDetailModel {
  int? responseCode;
  bool? result;
  String? message;
  AcceptedDDetail? acceptedDDetail;

  VihicalDriverDetailModel({
    this.responseCode,
    this.result,
    this.message,
    this.acceptedDDetail,
  });

  factory VihicalDriverDetailModel.fromJson(Map<String, dynamic> json) => VihicalDriverDetailModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    acceptedDDetail: json["accepted_d_detail"] == null ? null : AcceptedDDetail.fromJson(json["accepted_d_detail"]),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "accepted_d_detail": acceptedDDetail?.toJson(),
  };
}

class AcceptedDDetail {
  int? id;
  String? cId;
  String? dId;
  num? price;
  String? totKm;
  String? status;
  String? otp;
  num? totHour;
  num? totMinute;
  String? profileImage;
  String? vehicleImage;
  String? firstName;
  String? lastName;
  String? primaryCcode;
  String? primaryPhoneNo;
  String? language;
  String? vehicleNumber;
  String? carColor;
  String? passengerCapacity;
  String? prefrenceName;
  DateTime? joinDate;
  String? carName;
  int? totReview;
  int? totCompleteOrder;
  num? rating;

  AcceptedDDetail({
    this.id,
    this.cId,
    this.dId,
    this.price,
    this.totKm,
    this.status,
    this.otp,
    this.totHour,
    this.totMinute,
    this.profileImage,
    this.vehicleImage,
    this.firstName,
    this.lastName,
    this.primaryCcode,
    this.primaryPhoneNo,
    this.language,
    this.vehicleNumber,
    this.carColor,
    this.passengerCapacity,
    this.prefrenceName,
    this.joinDate,
    this.carName,
    this.totReview,
    this.totCompleteOrder,
    this.rating,
  });

  factory AcceptedDDetail.fromJson(Map<String, dynamic> json) => AcceptedDDetail(
    id: json["id"],
    cId: json["c_id"],
    dId: json["d_id"],
    price: json["price"],
    totKm: json["tot_km"],
    status: json["status"],
    otp: json["otp"],
    totHour: json["tot_hour"],
    totMinute: json["tot_minute"],
    profileImage: json["profile_image"],
    vehicleImage: json["vehicle_image"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    primaryCcode: json["primary_ccode"],
    primaryPhoneNo: json["primary_phoneNo"],
    language: json["language"],
    vehicleNumber: json["vehicle_number"],
    carColor: json["car_color"],
    passengerCapacity: json["passenger_capacity"],
    prefrenceName: json["prefrence_name"],
    joinDate: json["join_date"] == null ? null : DateTime.parse(json["join_date"]),
    carName: json["car_name"],
    totReview: json["tot_review"],
    totCompleteOrder: json["tot_complete_order"],
    rating: json["rating"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "c_id": cId,
    "d_id": dId,
    "price": price,
    "tot_km": totKm,
    "status": status,
    "otp": otp,
    "tot_hour": totHour,
    "tot_minute": totMinute,
    "profile_image": profileImage,
    "vehicle_image": vehicleImage,
    "first_name": firstName,
    "last_name": lastName,
    "primary_ccode": primaryCcode,
    "primary_phoneNo": primaryPhoneNo,
    "language": language,
    "vehicle_number": vehicleNumber,
    "car_color": carColor,
    "passenger_capacity": passengerCapacity,
    "prefrence_name": prefrenceName,
    "join_date": "${joinDate!.year.toString().padLeft(4, '0')}-${joinDate!.month.toString().padLeft(2, '0')}-${joinDate!.day.toString().padLeft(2, '0')}",
    "car_name": carName,
    "tot_review": totReview,
    "tot_complete_order": totCompleteOrder,
    "rating": rating,
  };
}
