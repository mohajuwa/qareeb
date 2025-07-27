// To parse this JSON data, do
//
//     final calCulateModel = calCulateModelFromJson(jsonString);

import 'dart:convert';

CalCulateModel calCulateModelFromJson(String str) => CalCulateModel.fromJson(json.decode(str));

String calCulateModelToJson(CalCulateModel data) => json.encode(data.toJson());

class CalCulateModel {
  int? responseCode;
  bool? result;
  String? message;
  int? offerExpireTime;
  List<Zoneresult>? zoneresult;
  double? totKm;
  double? dropPrice;
  int? totHour;
  int? totMinute;
  int? totSecond;
  List<int>? driverId;
  Vehicle? vehicle;

  CalCulateModel({
    this.responseCode,
    this.result,
    this.message,
    this.offerExpireTime,
    this.zoneresult,
    this.totKm,
    this.dropPrice,
    this.totHour,
    this.totMinute,
    this.totSecond,
    this.driverId,
    this.vehicle,
  });

  factory CalCulateModel.fromJson(Map<String, dynamic> json) => CalCulateModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    offerExpireTime: json["offer_expire_time"],
    zoneresult: json["zoneresult"] == null ? [] : List<Zoneresult>.from(json["zoneresult"]!.map((x) => Zoneresult.fromJson(x))),
    totKm: json["tot_km"]?.toDouble(),
    dropPrice: json["drop_price"]?.toDouble(),
    totHour: json["tot_hour"],
    totMinute: json["tot_minute"],
    totSecond: json["tot_second"],
    driverId: json["driver_id"] == null ? [] : List<int>.from(json["driver_id"]!.map((x) => x)),
    vehicle: json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "offer_expire_time": offerExpireTime,
    "zoneresult": zoneresult == null ? [] : List<dynamic>.from(zoneresult!.map((x) => x.toJson())),
    "tot_km": totKm,
    "drop_price": dropPrice,
    "tot_hour": totHour,
    "tot_minute": totMinute,
    "tot_second": totSecond,
    "driver_id": driverId == null ? [] : List<dynamic>.from(driverId!.map((x) => x)),
    "vehicle": vehicle?.toJson(),
  };
}

class Vehicle {
  int? id;
  String? image;
  String? mapImg;
  String? name;
  String? description;
  String? minKmDistance;
  String? minKmPrice;
  String? afterKmPrice;
  String? comissionRate;
  String? comissionType;
  String? extraCharge;
  String? passengerCapacity;
  String? bidding;
  String? whetherCharge;
  String? status;
  String? minimumFare;
  String? maximumFare;

  Vehicle({
    this.id,
    this.image,
    this.mapImg,
    this.name,
    this.description,
    this.minKmDistance,
    this.minKmPrice,
    this.afterKmPrice,
    this.comissionRate,
    this.comissionType,
    this.extraCharge,
    this.passengerCapacity,
    this.bidding,
    this.whetherCharge,
    this.status,
    this.minimumFare,
    this.maximumFare,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json["id"],
    image: json["image"],
    mapImg: json["map_img"],
    name: json["name"],
    description: json["description"],
    minKmDistance: json["min_km_distance"],
    minKmPrice: json["min_km_price"],
    afterKmPrice: json["after_km_price"],
    comissionRate: json["comission_rate"],
    comissionType: json["comission_type"],
    extraCharge: json["extra_charge"],
    passengerCapacity: json["passenger_capacity"],
    bidding: json["bidding"],
    whetherCharge: json["whether_charge"],
    status: json["status"],
    minimumFare: json["minimum_fare"],
    maximumFare: json["maximum_fare"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "map_img": mapImg,
    "name": name,
    "description": description,
    "min_km_distance": minKmDistance,
    "min_km_price": minKmPrice,
    "after_km_price": afterKmPrice,
    "comission_rate": comissionRate,
    "comission_type": comissionType,
    "extra_charge": extraCharge,
    "passenger_capacity": passengerCapacity,
    "bidding": bidding,
    "whether_charge": whetherCharge,
    "status": status,
    "minimum_fare": minimumFare,
    "maximum_fare": maximumFare,
  };
}

class Zoneresult {
  int? zone;
  int? status;

  Zoneresult({
    this.zone,
    this.status,
  });

  factory Zoneresult.fromJson(Map<String, dynamic> json) => Zoneresult(
    zone: json["zone"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "zone": zone,
    "status": status,
  };
}
