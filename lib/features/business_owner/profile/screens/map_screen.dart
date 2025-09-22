import 'dart:math';
import 'package:fidden/features/business_owner/profile/services/places_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';

// TODO: move to env/secure storage
const kGoogleApiKey = 'AIzaSyC8Rj8qqv9kn2FGTtALwhwpe_GPmhJfP8s';

class MapScreenProfile extends StatefulWidget {
  final LatLng? initialPosition;
  final String?
  initialAddress; // ← optional, if you have a saved address string

  const MapScreenProfile({
    super.key,
    this.initialPosition,
    this.initialAddress,
  });

  @override
  State<MapScreenProfile> createState() => _MapScreenProfileState();
}

class _MapScreenProfileState extends State<MapScreenProfile> {
  GoogleMapController? _map;
  late final PlacesService _places = PlacesService(kGoogleApiKey);

  final _markers = <Marker>{};
  Marker? _currentMarker;
  LatLng? _selected;
  bool _hasLocationPermission = false;

  late LatLng _initialCenter;

  String? _address; // nice human-readable address for UI
  bool _resolvingAddress = false;

  // session token for a single autocomplete flow
  String? _sessionToken;

  @override
  void initState() {
    super.initState();
    _initialCenter = widget.initialPosition ?? const LatLng(23.8041, 90.4152);

    // Priority:
    // 1) If a saved address string is provided, attempt to geocode & center on it
    // 2) Else if initialPosition is provided, use that and resolve address
    // 3) Else use current user location and resolve address
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapDefaultView();
    });
  }

  @override
  void dispose() {
    _places.close();
    super.dispose();
  }

  Future<void> _bootstrapDefaultView() async {
    if (widget.initialAddress != null &&
        widget.initialAddress!.trim().isNotEmpty) {
      // Try geocoding the provided address first
      try {
        final locs = await locationFromAddress(widget.initialAddress!.trim());
        if (locs.isNotEmpty) {
          final p = LatLng(locs.first.latitude, locs.first.longitude);
          _setSelected(p, animate: true);
          await _updateAddressFor(p); // confirm/refresh address formatting
          return;
        }
      } catch (_) {
        /* fall through */
      }
    }

    if (widget.initialPosition != null) {
      _setSelected(widget.initialPosition!, animate: true);
      await _updateAddressFor(widget.initialPosition!);
      return;
    }
    final ok = await _ensureLocationPermission(context);
    _hasLocationPermission = ok;
    if (!ok) {
      if (mounted) setState(() {});   // so myLocationEnabled reflects it
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    final here = LatLng(pos.latitude, pos.longitude);

    _initialCenter = here;
    _setCurrentMarker(here);
    _setSelected(here, animate: true);
    await _updateAddressFor(here);
  }

  Future<void> _goMyLocation() async {
    try {
      final ok = await _ensureLocationPermission(context);
      _hasLocationPermission = ok;
      if (!ok) {
        if (mounted) setState(() {});
        return; // don’t proceed
      }

      final pos = await Geolocator.getCurrentPosition();
      final here = LatLng(pos.latitude, pos.longitude);
      _setCurrentMarker(here);
      _setSelected(here, animate: true);
      if (mounted) setState(() {});
    } catch (_) {
      Get.snackbar('Location', 'Unable to fetch your current location.');
    }

    // fallback: current location
    await _ensureLocationPermissionThenCenter();
  }

  Future<bool> _ensureLocationPermission(BuildContext context) async {
    final servicesOn = await Geolocator.isLocationServiceEnabled();
    if (!servicesOn) {
      if (!mounted) return false;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Turn On Location'),
          content: const Text('Location services are off. Turn them on to find nearby places.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return false;
    }

    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied) return false;
    }

    if (p == LocationPermission.deniedForever) {
      if (!mounted) return false;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Enable Location'),
          content: const Text(
            'Location permission was denied previously. Enable it in Settings to use your current location.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
            TextButton(
              onPressed: () async {
                await openAppSettings(); // from permission_handler
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _ensureLocationPermissionThenCenter() async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied ||
        p == LocationPermission.deniedForever) {
      // p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever)
      return;

    final pos = await Geolocator.getCurrentPosition();
    final here = LatLng(pos.latitude, pos.longitude);

    _initialCenter = here;
    _setCurrentMarker(here);
    _setSelected(here, animate: true);
    await _updateAddressFor(here);
  }

  void _onMapCreated(GoogleMapController c) => _map = c;

  void _onTap(LatLng p) => _setSelected(p, animate: true);

  void _setSelected(LatLng p, {bool animate = false}) {
    _selected = p;
    _rebuildMarkers();
    if (animate) {
      _map?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: p, zoom: 16)),
      );
    }
    _updateAddressFor(p); // fire & forget (awaited in callers where needed)
  }

  void _setCurrentMarker(LatLng p) {
    _currentMarker = Marker(
      markerId: const MarkerId('current'),
      position: p,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    _rebuildMarkers();
  }

  void _rebuildMarkers() {
    _markers
      ..clear()
      ..addAll([
        if (_currentMarker != null) _currentMarker!,
        if (_selected != null)
          Marker(markerId: const MarkerId('selected'), position: _selected!),
      ]);
    if (mounted) setState(() {});
  }


  // ---------- Reverse geocode nicely ----------
  Future<void> _updateAddressFor(LatLng p) async {
    setState(() => _resolvingAddress = true);
    try {
      final list = await placemarkFromCoordinates(p.latitude, p.longitude);
      if (list.isNotEmpty) {
        final a = list.first;
        final parts = [
          a.name,
          a.street,
          a.subLocality,
          a.locality,
          a.administrativeArea,
          a.country,
          a.postalCode,
        ].where((e) => (e ?? '').toString().trim().isNotEmpty).toList();
        _address = parts.join(', ');
      } else {
        _address =
            '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}';
      }
    } catch (_) {
      _address =
          '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}';
    } finally {
      if (mounted) setState(() => _resolvingAddress = false);
    }
  }

  // ---------- SEARCH (Places Autocomplete) ----------
  Future<void> _openSearch() async {
    _sessionToken ??= _randToken();

    final p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: Mode.overlay,
      language: 'en',
      sessionToken: _sessionToken,
      hint: 'Search location',
    );

    if (p == null || p.placeId == null) return;

    try {
      final res = await _places.details(
        p.placeId!,
        sessionToken: _sessionToken,
      );
      _sessionToken = null;

      if (res.status != 'OK' || res.result.geometry == null) {
        Get.snackbar(
          'Places',
          res.errorMessage ?? 'Could not get place details.',
        );
        return;
      }

      final g = res.result.geometry!;
      final target = LatLng(g.location.lat, g.location.lng);

      _setSelected(target, animate: true);
    } catch (e) {
      _sessionToken = null;
      Get.snackbar('Places', 'Failed to fetch place details.');
    }
  }

  // ---------- Open in Google Maps ----------
  Future<void> _openInMaps() async {
    final p = _selected ?? _currentMarker?.position;
    if (p == null) {
      Get.snackbar('No location', 'Pick a location first.');
      return;
    }
    final app = Uri.parse(
      'geo:${p.latitude},${p.longitude}?q=${p.latitude},${p.longitude}',
    );
    final web = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${p.latitude},${p.longitude}',
    );
    if (await canLaunchUrl(app)) {
      await launchUrl(app);
    } else {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  // ---------- Directions ----------
  Future<void> _openDirections() async {
    final p = _selected ?? _currentMarker?.position;
    if (p == null) {
      Get.snackbar('No location', 'Pick a location first.');
      return;
    }
    final nav = Uri.parse(
      'google.navigation:q=${p.latitude},${p.longitude}&mode=d',
    );
    final web = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${p.latitude},${p.longitude}&travelmode=driving',
    );
    if (await canLaunchUrl(nav)) {
      await launchUrl(nav, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  // simple random token for the autocomplete session
  String _randToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random.secure();
    return List.generate(24, (_) => chars[r.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Select Location'),
        centerTitle: true,
        elevation: 0.5,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _openSearch),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialCenter,
              zoom: 14,
            ),
            myLocationEnabled: _hasLocationPermission,
            myLocationButtonEnabled: false,
            onTap: _onTap,
            markers: _markers,
          ),
          if (!_hasLocationPermission)
            Positioned(
              left: 12, right: 12, bottom: 110,
              child: Material(
                elevation: 8, color: Colors.white, borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Location is off', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      const Text('Enable location to center the map on you and find nearby places.'),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: () async {
                          final ok = await _ensureLocationPermission(context);
                          if (mounted) setState(() {});
                          if (ok) _goMyLocation();
                        },
                        child: const Text('Enable location'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating search pill (tap to open autocomplete)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: _openSearch,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.black87),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search location',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right-side vertical action buttons
          Positioned(
            right: 12,
            bottom: 180,
            child: Column(
              children: [
                _RoundFab(icon: Icons.my_location, onTap: _goMyLocation),
                const SizedBox(height: 10),
                _RoundFab(icon: Icons.map_outlined, onTap: _openInMaps),
                const SizedBox(height: 10),
                _RoundFab(
                  icon: Icons.turn_right_outlined,
                  onTap: _openDirections,
                ),
              ],
            ),
          ),

          // Bottom address card + confirm CTA
          Positioned(
            left: 12,
            right: 12,
            bottom: 24,
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF1F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.place_outlined),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _resolvingAddress
                                ? Row(
                                    key: const ValueKey('loading'),
                                    children: const [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Resolving address...'),
                                    ],
                                  )
                                : Text(
                                    _address ??
                                        'Tap on map to choose a location',
                                    key: const ValueKey('addr'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      height: 1.35,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: (_selected != null)
                            ? () => Get.back(result: _selected)
                            : null,
                        child: const Text('Use this location'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _goMyLocation,
      //   child: const Icon(Icons.my_location),
      // ),
    );
  }
}

class _RoundFab extends StatelessWidget {
  const _RoundFab({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          // use the icon parameter (no `const` here)
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}
