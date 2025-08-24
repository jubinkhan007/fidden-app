class Service {
  final String name;
  final String image;
  final String serviceDetails;

  Service({required this.name, required this.image, required this.serviceDetails});
}

class Booking {
  final String image;
  final String shopName;
  final String location;
  final double rating;
  final int reviews;
  final String dateTime;
  final List<Service> services;

  Booking({
    required this.image,
    required this.shopName,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.dateTime,
    required this.services,
  });
}
