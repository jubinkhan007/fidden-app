import 'package:fidden/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

class MapScreenProfile extends StatefulWidget {
  final LatLng? initialPosition;
  const MapScreenProfile({super.key, this.initialPosition});

  @override
  _MapScreenProfileState createState() => _MapScreenProfileState();
}

class _MapScreenProfileState extends State<MapScreenProfile> {
  late GoogleMapController mapController;
  LatLng? _selectedLocation;

  late LatLng _initialCenter;
  Marker? _currentLocationMarker;

  @override
  void initState() {
    super.initState();
    _initialCenter =
        widget.initialPosition ??
        const LatLng(23.8041, 90.4152); // Default to Dhaka
  }
  // --- END CHANGE ---

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => Get.back(result: _selectedLocation),
            ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialCenter,
          zoom: 14.0,
        ),
        onTap: _onTap,
        // ---  MODIFIED MARKERS LOGIC ---
        markers: {
          if (_selectedLocation != null)
            Marker(
              markerId: const MarkerId("selected_location"),
              position: _selectedLocation!,
            ),
          if (_currentLocationMarker != null) _currentLocationMarker!,
        },
        // --- END MODIFICATION ---
      ),
      // ---  ADD FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCurrentUserLocation,
        child: const Icon(Icons.my_location),
      ),
      // --- END ADD ---
    );
  }

  // ---  ADD NEW METHOD TO GO TO CURRENT LOCATION ---
  Future<void> _goToCurrentUserLocation() async {
    try {
      final position = await LocationService().getCurrentPosition();
      if (position != null) {
        final currentLocation = LatLng(position.latitude, position.longitude);

        // Animate camera to the new location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentLocation, zoom: 16.0),
          ),
        );

        // Update the markers on the map
        setState(() {
          _selectedLocation =
              currentLocation; // Set this as the new selected point
          _currentLocationMarker = Marker(
            markerId: const MarkerId("current_location"),
            position: currentLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ), // Blue marker
          );
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Could not get your current location.");
    }
  }
}
