import 'dart:convert';

BusinessOwnerBookingModel businessOwnerBookingModelFromJson(String str) =>
    BusinessOwnerBookingModel.fromJson(json.decode(str));

String businessOwnerBookingModelToJson(BusinessOwnerBookingModel data) =>
    json.encode(data.toJson());

class BusinessOwnerBookingModel {
  bool? success;
  int? statusCode;
  String? message;
  List<Datum>? data;

  BusinessOwnerBookingModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory BusinessOwnerBookingModel.fromJson(Map<String, dynamic> json) =>
      BusinessOwnerBookingModel(
        success: json["success"],
        statusCode: json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "statusCode": statusCode,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? bookingTime;
  DateTime? bookingDate;
  String? serviceName;
  String? serviceImage;
  List<CustomerForm>? customerForm;

  Datum({
    this.id,
    this.bookingTime,
    this.bookingDate,
    this.serviceName,
    this.serviceImage,
    this.customerForm,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    bookingTime: json["booking_time"],
    bookingDate: json["booking_date"] == null
        ? null
        : DateTime.parse(json["booking_date"]),
    serviceName: json["service_name"],
    serviceImage: json["service_image"],
    customerForm: json["customer_form"] == null
        ? []
        : List<CustomerForm>.from(
            json["customer_form"]!.map((x) => CustomerForm.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_time": bookingTime,
    "booking_date":
        "${bookingDate!.year.toString().padLeft(4, '0')}-${bookingDate!.month.toString().padLeft(2, '0')}-${bookingDate!.day.toString().padLeft(2, '0')}",
    "service_name": serviceName,
    "service_image": serviceImage,
    "customer_form": customerForm == null
        ? []
        : List<dynamic>.from(customerForm!.map((x) => x.toJson())),
  };
}

class CustomerForm {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? address;
  String? city;
  String? state;
  String? postalCode;
  String? userId;
  String? bookingId;
  DateTime? createdAt;
  DateTime? updatedAt;

  CustomerForm({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.userId,
    this.bookingId,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerForm.fromJson(Map<String, dynamic> json) => CustomerForm(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    postalCode: json["postal_code"],
    userId: json["userId"],
    bookingId: json["bookingId"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "address": address,
    "city": city,
    "state": state,
    "postal_code": postalCode,
    "userId": userId,
    "bookingId": bookingId,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
