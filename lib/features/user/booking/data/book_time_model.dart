import 'dart:convert';

// Function to parse the JSON string into a BookTimeModel object
BookTimeModel bookTimeModelFromJson(String str) =>
    BookTimeModel.fromJson(json.decode(str));

// Function to convert a BookTimeModel object into a JSON string
String bookTimeModelToJson(BookTimeModel data) => json.encode(data.toJson());

class BookTimeModel {
  final List<TimeSlot>? morning;
  final List<TimeSlot>? afternoon;
  final List<TimeSlot>? evening;

  BookTimeModel({this.morning, this.afternoon, this.evening});

  factory BookTimeModel.fromJson(Map<String, dynamic> json) => BookTimeModel(
    morning: json["morning"] == null
        ? []
        : List<TimeSlot>.from(
            json["morning"]!.map((x) => TimeSlot.fromJson(x)),
          ),
    afternoon: json["afternoon"] == null
        ? []
        : List<TimeSlot>.from(
            json["afternoon"]!.map((x) => TimeSlot.fromJson(x)),
          ),
    evening: json["evening"] == null
        ? []
        : List<TimeSlot>.from(
            json["evening"]!.map((x) => TimeSlot.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "morning": morning == null
        ? []
        : List<dynamic>.from(morning!.map((x) => x.toJson())),
    "afternoon": afternoon == null
        ? []
        : List<dynamic>.from(afternoon!.map((x) => x.toJson())),
    "evening": evening == null
        ? []
        : List<dynamic>.from(evening!.map((x) => x.toJson())),
  };
}

class TimeSlot {
  final int? id;
  final String? startTime;
  final String? endTime;
  final bool? isBooked;

  TimeSlot({this.id, this.startTime, this.endTime, this.isBooked});

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
    id: json["id"],
    startTime: json["start_time"],
    endTime: json["end_time"],
    isBooked: json["is_booked"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "start_time": startTime,
    "end_time": endTime,
    "is_booked": isBooked,
  };
}
