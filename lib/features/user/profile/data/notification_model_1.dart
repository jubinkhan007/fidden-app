// // To parse this JSON data, do
// //
// //     final getMyNotificationModel = getMyNotificationModelFromJson(jsonString);

// import 'dart:convert';

// GetMyNotificationModel getMyNotificationModelFromJson(String str) => GetMyNotificationModel.fromJson(json.decode(str));

// String getMyNotificationModelToJson(GetMyNotificationModel data) => json.encode(data.toJson());

// class GetMyNotificationModel {
//   bool? success;
//   int? statusCode;
//   String? message;
//   List<NotificationDatum>? data;

//   GetMyNotificationModel({
//     this.success,
//     this.statusCode,
//     this.message,
//     this.data,
//   });

//   factory GetMyNotificationModel.fromJson(Map<String, dynamic> json) => GetMyNotificationModel(
//     success: json["success"],
//     statusCode: json["statusCode"],
//     message: json["message"],
//     data: json["data"] == null ? [] : List<NotificationDatum>.from(json["data"]!.map((x) => NotificationDatum.fromJson(x))),
//   );

//   Map<String, dynamic> toJson() => {
//     "success": success,
//     "statusCode": statusCode,
//     "message": message,
//     "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
//   };
// }

// class NotificationDatum {
//   String? id;
//   String? senderId;
//   String? receiverId;
//   String? title;
//   String? body;
//   bool? read;
//   DateTime? createdAt;
//   DateTime? updatedAt;

//   NotificationDatum({
//     this.id,
//     this.senderId,
//     this.receiverId,
//     this.title,
//     this.body,
//     this.read,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory NotificationDatum.fromJson(Map<String, dynamic> json) => NotificationDatum(
//     id: json["id"],
//     senderId: json["senderId"],
//     receiverId: json["receiverId"],
//     title: json["title"],
//     body: json["body"],
//     read: json["read"],
//     createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
//     updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
//   );

//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "senderId": senderId,
//     "receiverId": receiverId,
//     "title": title,
//     "body": body,
//     "read": read,
//     "createdAt": createdAt?.toIso8601String(),
//     "updatedAt": updatedAt?.toIso8601String(),
//   };
// }
