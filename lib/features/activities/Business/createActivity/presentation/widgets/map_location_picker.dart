import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

class MapLocationPicker extends StatefulWidget {
  final String hintText;
  final String? initialAddress;
  final LatLng? initialLatLng; // 👈 NEW
  final void Function(String address, double lat, double lng) onPicked;

  const MapLocationPicker({
    super.key,
    required this.hintText,
    this.initialAddress,
    this.initialLatLng, // 👈 NEW
    required this.onPicked,
  });

  // ---- helpers ----
  static Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  static Future<String> _reverse(double lat, double lng) async {
    try {
      final ps = await geo.placemarkFromCoordinates(lat, lng);
      if (ps.isEmpty) return 'Dropped pin';
      final p = ps.first;
      return [
        if (p.street != null && p.street!.isNotEmpty) p.street,
        if (p.locality != null && p.locality!.isNotEmpty) p.locality,
        if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
          p.administrativeArea,
        if (p.country != null && p.country!.isNotEmpty) p.country,
      ].whereType<String>().join(', ');
    } catch (_) {
      return 'Dropped pin';
    }
  }

  /// External quick action (e.g., from a button above the map)
  static Future<void> locateMeAndPick({
    required BuildContext context,
    required void Function(String address, double lat, double lng) onPicked,
  }) async {
    final ok = await _ensurePermission();
    if (!ok) return;

    final pos = await Geolocator.getCurrentPosition();
    final address = await _reverse(pos.latitude, pos.longitude);
    onPicked(address, pos.latitude, pos.longitude);

    final state = context.findAncestorStateOfType<_MapLocationPickerState>();
    state?._moveCamera(LatLng(pos.latitude, pos.longitude), address: address);
  }

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}



class _MapLocationPickerState extends State<MapLocationPicker> {
  final _searchCtrl = TextEditingController();
  GoogleMapController? _map;

  LatLng _cameraTarget = const LatLng(45.5019, -73.5674); // default center
  Marker? _marker;
  String _address = '';
  bool _busy = false;
  bool _suppressFirstIdle =
      true; // 👈 prevent first onCameraIdle from firing onPicked


  @override
  void initState() {
    super.initState();

    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _searchCtrl.text = widget.initialAddress!;
      _address = widget.initialAddress!;
    }

    if (widget.initialLatLng != null) {
      // Pre-place the marker & camera on the provided position
      _cameraTarget = widget.initialLatLng!;
      _marker = Marker(
        markerId: const MarkerId('picked'),
        position: _cameraTarget,
        infoWindow: InfoWindow(
          title: _address.isNotEmpty ? _address : 'Picked location',
        ),
      );

      // Fire onPicked once after first frame so parent state is aligned
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final addr = _address.isNotEmpty
            ? _address
            : await MapLocationPicker._reverse(
                _cameraTarget.latitude,
                _cameraTarget.longitude,
              );
        widget.onPicked(addr, _cameraTarget.latitude, _cameraTarget.longitude);
        if (mounted && _address.isEmpty) {
          setState(() {
            _address = addr;
            _searchCtrl.text = addr;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSearchSubmit() async {
    final text = _searchCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _busy = true);
    try {
      final list = await geo.locationFromAddress(text);
      if (list.isNotEmpty) {
        final lat = list.first.latitude;
        final lng = list.first.longitude;
        final addr = await MapLocationPicker._reverse(lat, lng);
        await _moveCamera(LatLng(lat, lng), address: addr);
        widget.onPicked(addr, lat, lng);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _moveCamera(LatLng target, {String? address}) async {
    _cameraTarget = target;
    await _map?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 15)),
    );
    setState(() {
      _marker = Marker(
        markerId: const MarkerId('picked'),
        position: target,
        infoWindow: InfoWindow(title: address ?? 'Picked location'),
      );
      if (address != null) {
        _address = address;
        _searchCtrl.text = address;
      }
    });
  }

  Future<void> _locateMe() async {
    final ok = await MapLocationPicker._ensurePermission();
    if (!ok) return;
    final pos = await Geolocator.getCurrentPosition();
    final addr = await MapLocationPicker._reverse(pos.latitude, pos.longitude);
    await _moveCamera(LatLng(pos.latitude, pos.longitude), address: addr);
    widget.onPicked(addr, pos.latitude, pos.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    print(
      "DEBUG Map init => initialLatLng=${widget.initialLatLng}, initialAddress=${widget.initialAddress}",
    );

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _cameraTarget,
              zoom: widget.initialLatLng != null ? 15 : 12,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (c) {
              _map = c;
              // After map is created, we let onCameraIdle work as usual
              // but skip the very first idle that happens immediately.
              Future.delayed(const Duration(milliseconds: 300), () {
                _suppressFirstIdle = false;
              });
            },
            markers: {if (_marker != null) _marker!},
            onCameraMove: (CameraPosition pos) {
              _cameraTarget = pos.target;
            },
            onCameraIdle: () async {
              if (_suppressFirstIdle) return; // 👈 skip first idle
              setState(() => _busy = true);
              final addr = await MapLocationPicker._reverse(
                _cameraTarget.latitude,
                _cameraTarget.longitude,
              );
              if (!mounted) return;
              setState(() => _busy = false);

              _address = addr;
              _searchCtrl.text = addr;
              setState(() {
                _marker = Marker(
                  markerId: const MarkerId('picked'),
                  position: _cameraTarget,
                  infoWindow: InfoWindow(title: addr),
                );
              });
              widget.onPicked(
                addr,
                _cameraTarget.latitude,
                _cameraTarget.longitude,
              );
            },
          ),

          // Search bar
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Material(
              color: cs.surface,
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _onSearchSubmit(),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  prefixIcon: Icon(Icons.search, color: cs.primary),
                  suffixIcon: _busy
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.primary,
                            ),
                          ),
                        )
                      : IconButton(
                          tooltip: 'My location',
                          icon: Icon(Icons.my_location, color: cs.primary),
                          onPressed: _locateMe,
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Address chip
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _address.isEmpty ? 'Pick a place on the map' : _address,
                      style: tt.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant MapLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialLatLng != null &&
        widget.initialLatLng != oldWidget.initialLatLng) {
      _moveCamera(widget.initialLatLng!, address: widget.initialAddress);
    }
  }
  
}
