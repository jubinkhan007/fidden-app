import 'dart:convert';

GetUserBookingModel getUserBookingModelFromJson(String str) => GetUserBookingModel.fromJson(json.decode(str));

String getUserBookingModelToJson(GetUserBookingModel data) => json.encode(data.toJson());

class GetUserBookingModel {
  bool? success;
  int? statusCode;
  String? message;
  List<UserBookingDatum>? data;

  GetUserBookingModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetUserBookingModel.fromJson(Map<String, dynamic> json) => GetUserBookingModel(
    success: json["success"],
    statusCode: json["statusCode"],
    message: json["message"],
    data: json["data"] == null ? [] : List<UserBookingDatum>.from(json["data"].map((x) => UserBookingDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "statusCode": statusCode,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class UserBookingDatum {
  String? id;
  DateTime? bookingDate;
  String? bookingTime;
  bool? paid;
  String? status;
  String? serviceId;
  String? serviceName;
  double? servicePrice;
  String? serviceImage;
  String? providerId;
  String? businessName;
  String? businessAddress;
  String? businessImage;
  double? review;

  UserBookingDatum({
    this.id,
    this.bookingDate,
    this.bookingTime,
    this.paid,
    this.status,
    this.serviceId,
    this.serviceName,
    this.servicePrice,
    this.serviceImage,
    this.providerId,
    this.businessName,
    this.businessAddress,
    this.businessImage,
    this.review,
  });

  factory UserBookingDatum.fromJson(Map<String, dynamic> json) => UserBookingDatum(
    id: json["id"],
    bookingDate: json["bookingDate"] == null ? null : DateTime.parse(json["bookingDate"]),
    bookingTime: json["bookingTime"],
    paid: json["paid"],
    status: json["status"],
    serviceId: json["serviceId"],
    serviceName: json["serviceName"],
    servicePrice: json["servicePrice"]?.toDouble(),
    serviceImage: json["serviceImage"],
    providerId: json["providerId"],
    businessName: json["businessName"],
    businessAddress: json["businessAddress"],
    businessImage: json["businessImage"],
    review: json["review"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "bookingDate": bookingDate == null
        ? null
        : "${bookingDate!.year.toString().padLeft(4, '0')}-${bookingDate!.month.toString().padLeft(2, '0')}-${bookingDate!.day.toString().padLeft(2, '0')}",
    "bookingTime": bookingTime,
    "paid": paid,
    "status": status,
    "serviceId": serviceId,
    "serviceName": serviceName,
    "servicePrice": servicePrice,
    "serviceImage": serviceImage,
    "providerId": providerId,
    "businessName": businessName,
    "businessAddress": businessAddress,
    "businessImage": businessImage,
    "review": review,
  };
}
