import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

class MapScreenProfile extends StatefulWidget {
  @override
  _MapScreenProfileState createState() => _MapScreenProfileState();
}

class _MapScreenProfileState extends State<MapScreenProfile> {
  LatLng? selectedLocation;
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Location")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 14),
        onMapCreated: (controller) => _mapController = controller,
        onTap: (LatLng latLng) {
          setState(() => selectedLocation = latLng);
        },
        markers: selectedLocation != null
            ? {
          Marker(markerId: MarkerId("selected"), position: selectedLocation!)
        }
            : {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedLocation != null) {
            Get.back(result: selectedLocation);
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
