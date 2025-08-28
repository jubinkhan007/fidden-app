class Appointment {
  final String? name;
  final String? service;
  final String time;
  final String? date;
  final String? imageUrl;
  final String? imageUrl2;

  Appointment({
     this.name,
     this.service,
    required this.time,
     this.date,
    this.imageUrl,
    this.imageUrl2,
  });
}