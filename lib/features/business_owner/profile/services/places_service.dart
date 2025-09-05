import 'package:flutter_google_maps_webservices/places.dart';

class PlacesService {
  PlacesService(this.apiKey) : _client = GoogleMapsPlaces(apiKey: apiKey);

  final String apiKey;
  final GoogleMapsPlaces _client;

  Future<PlacesDetailsResponse> details(
    String placeId, {
    String? sessionToken,
  }) {
    // Request only the minimal, safe fields
    return _client.getDetailsByPlaceId(
      placeId,
      sessionToken: sessionToken,
      fields: const [
        'place_id',
        'name',
        'formatted_address',
        'geometry/location',
      ],
    );
  }

  void close() => _client.dispose();
}
