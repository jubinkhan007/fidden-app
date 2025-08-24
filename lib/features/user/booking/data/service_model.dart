class ServiceModel {
  final String name;
  final String description;
  final String image; // Add this field for the image

  ServiceModel({
    required this.name,
    required this.description,
    required this.image,
  });
}

class BookingModel1 {
  final String shopName;
  final String location;
  final double rating;
  final int reviews;
  final DateTime dateTime;
  final List<ServiceModel> services; // Update this to use the Service model

  BookingModel1({
    required this.shopName,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.dateTime,
    required this.services,
  });
}