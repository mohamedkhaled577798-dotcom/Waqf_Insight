import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/maps_setup_hint.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/property_osm_map.dart';

/// Reusable map wrapper (Google Maps on mobile/web, OSM on Windows desktop).
class PropertyGoogleMap extends StatefulWidget {
  const PropertyGoogleMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.label,
    this.height = 220,
    this.zoom = 15,
    this.borderRadius = 16,
    this.showSetupHint = true,
  });

  final double latitude;
  final double longitude;
  final String? label;
  final double height;
  final double zoom;
  final double borderRadius;
  final bool showSetupHint;

  @override
  State<PropertyGoogleMap> createState() => _PropertyGoogleMapState();
}

class _PropertyGoogleMapState extends State<PropertyGoogleMap> {
  bool _mapReady = false;

  @override
  Widget build(BuildContext context) {
    if (useOsmMap) {
      return PropertyOsmMiniMap(
        latitude: widget.latitude,
        longitude: widget.longitude,
        height: widget.height,
      );
    }

    final position = LatLng(widget.latitude, widget.longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showSetupHint && useNativeGoogleMap) ...[
          const MapsSetupHint(compact: true),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: position,
                    zoom: widget.zoom,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('property'),
                      position: position,
                      infoWindow: InfoWindow(title: widget.label ?? ''),
                    ),
                  },
                  zoomControlsEnabled: true,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: (_) {
                    if (mounted) setState(() => _mapReady = true);
                  },
                ),
                if (!_mapReady)
                  const ColoredBox(
                    color: Color(0x11000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
