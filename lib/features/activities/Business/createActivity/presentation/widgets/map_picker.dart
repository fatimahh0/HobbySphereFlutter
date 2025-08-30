// lib/features/activities/Business/presentation/create/widgets/map_picker.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPicker extends StatefulWidget {
  /// You can override height from the parent if you want.
  final double height;

  final double? initialLat;
  final double? initialLng;
  final Function(double lat, double lng) onLocationPicked;

  const MapPicker({
    super.key,
    this.height = 240, // bounded by default
    this.initialLat,
    this.initialLng,
    required this.onLocationPicked,
  });

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  final _controller = Completer<GoogleMapController>();
  LatLng? _picked;
  String? _error;

  static const _fallback = LatLng(33.8938, 35.5018); // Beirut

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _picked = LatLng(widget.initialLat!, widget.initialLng!);
    }
  }

  Future<void> _getMyLocation() async {
    try {
      final locStatus = await Permission.locationWhenInUse.request();
      if (!locStatus.isGranted) {
        setState(() => _error = 'Location permission denied.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final me = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _picked = me;
        _error = null;
      });

      widget.onLocationPicked(me.latitude, me.longitude);

      final map = await _controller.future;
      map.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: me, zoom: 16.5)),
      );
    } catch (e) {
      setState(() => _error = 'Couldn\'t get your location. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = _picked ?? _fallback;

    return SizedBox(
      height: widget.height, // ✅ bounded height
      child: ExcludeSemantics(
        // ✅ reduce semantics churn with platform views
        child: RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: start,
                    zoom: 12,
                  ),
                  onMapCreated: (g) => _controller.complete(g),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  onTap: (latLng) {
                    // async gesture → safe setState
                    setState(() {
                      _picked = latLng;
                      _error = null;
                    });
                    // ❌ DO NOT trigger parent notifyListeners() here
                    widget.onLocationPicked(latLng.latitude, latLng.longitude);
                  },
                  markers: _picked == null
                      ? const <Marker>{}
                      : {
                          Marker(
                            markerId: const MarkerId('picked'),
                            position: _picked!,
                          ),
                        },
                ),
              ),

              Positioned(
                right: 12,
                bottom: 12,
                child: FloatingActionButton.extended(
                  onPressed: _getMyLocation,
                  label: const Text('Get my location'),
                  icon: const Icon(Icons.my_location),
                ),
              ),

              if (_error != null)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
