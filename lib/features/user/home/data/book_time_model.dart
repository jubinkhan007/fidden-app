import 'dart:convert';

GetBookTimeModel getBookTimeModelFromJson(String str) =>
    GetBookTimeModel.fromJson(json.decode(str));

String getBookTimeModelToJson(GetBookTimeModel data) =>
    json.encode(data.toJson());

class GetBookTimeModel {
  bool? success;
  int? statusCode;
  String? message;
  List<Datum>? data;

  GetBookTimeModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetBookTimeModel.fromJson(Map<String, dynamic> json) => GetBookTimeModel(
    success: json["success"],
    statusCode: json["statusCode"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "statusCode": statusCode,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? time;
  bool? booked;

  Datum({this.time, this.booked});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    time: json["time"],
    booked: json["booked"],
  );

  Map<String, dynamic> toJson() => {
    "time": time,
    "booked": booked,
  };
}
