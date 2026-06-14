import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_map_models.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/map_density_utils.dart';

/// Interactive map for Web & desktop using OpenStreetMap tiles.
class PropertyOsmMap extends StatefulWidget {
  const PropertyOsmMap({
    super.key,
    required this.points,
    required this.focus,
    this.selected,
    required this.onPointSelected,
    this.onFocusRegion,
    this.showControls = true,
  });

  final List<PropertyMapPointModel> points;
  final MapFocusModel focus;
  final PropertyMapPointModel? selected;
  final ValueChanged<PropertyMapPointModel> onPointSelected;
  final VoidCallback? onFocusRegion;
  final bool showControls;

  @override
  State<PropertyOsmMap> createState() => _PropertyOsmMapState();
}

class _PropertyOsmMapState extends State<PropertyOsmMap> {
  final MapController _controller = MapController();
  PropertyMapViewMode _viewMode = PropertyMapViewMode.density;
  double _zoom = 6;

  @override
  void initState() {
    super.initState();
    _viewMode = defaultViewModeForCount(widget.points.length);
    _zoom = widget.focus.zoom.toDouble();
    WidgetsBinding.instance.addPostFrameCallback((_) => _moveToFocus());
  }

  @override
  void didUpdateWidget(covariant PropertyOsmMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focus != widget.focus ||
        oldWidget.points.length != widget.points.length) {
      _viewMode = defaultViewModeForCount(widget.points.length);
      WidgetsBinding.instance.addPostFrameCallback((_) => _moveToFocus());
    }
  }

  void _moveToFocus() {
    final focus = widget.focus;
    if (widget.points.isNotEmpty &&
        focus.north != null &&
        focus.south != null &&
        focus.east != null &&
        focus.west != null) {
      _controller.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(
            LatLng(focus.south!, focus.west!),
            LatLng(focus.north!, focus.east!),
          ),
          padding: const EdgeInsets.all(48),
        ),
      );
      return;
    }

    _controller.move(
      LatLng(focus.centerLat, focus.centerLng),
      focus.zoom.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final points = widget.points;

    final markers = _buildMarkers();
    final circles = _viewMode == PropertyMapViewMode.density
        ? _buildDensityCircles(colorScheme)
        : <CircleMarker>[];

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: LatLng(widget.focus.centerLat, widget.focus.centerLng),
            initialZoom: widget.focus.zoom.toDouble(),
            onPositionChanged: (position, _) => _zoom = position.zoom,
            onTap: (_, __) {},
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.waqf_insight',
            ),
            if (circles.isNotEmpty) CircleLayer(circles: circles),
            MarkerLayer(markers: markers),
          ],
        ),
        if (widget.showControls) ...[
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surface.withValues(alpha: 0.95),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.focus.focusLabel ?? 'كل العراق',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${points.length} على الخريطة',
                            style: GoogleFonts.cairo(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (widget.onFocusRegion != null)
                      IconButton(
                        tooltip: 'تركيز',
                        icon: const Icon(Icons.center_focus_strong_rounded),
                        onPressed: () {
                          _moveToFocus();
                          widget.onFocusRegion?.call();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 78,
            left: 12,
            right: 12,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surface.withValues(alpha: 0.95),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    for (final mode in PropertyMapViewMode.values)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: FilterChip(
                            selected: _viewMode == mode,
                            showCheckmark: false,
                            label: Text(
                              viewModeLabel(mode),
                              style: GoogleFonts.cairo(fontSize: 11),
                            ),
                            onSelected: (_) => setState(() => _viewMode = mode),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (points.isEmpty)
          Center(
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surface.withValues(alpha: 0.92),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'لا توجد أملاك بإحداثيات GPS',
                  style: GoogleFonts.cairo(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    if (_viewMode == PropertyMapViewMode.density) {
      if (widget.selected == null) return const [];
      final p = widget.selected!;
      return [_pointMarker(p, highlighted: true)];
    }

    if (_viewMode == PropertyMapViewMode.cluster) {
      final clusters = clusterPropertyPoints(widget.points, zoom: _zoom);
      return clusters.map((cluster) {
        final single = cluster.singlePoint;
        if (single != null) {
          return _pointMarker(
            single,
            highlighted: widget.selected?.id == single.id,
          );
        }
        return Marker(
          point: LatLng(cluster.center.latitude, cluster.center.longitude),
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () {
              _controller.move(
                LatLng(cluster.center.latitude, cluster.center.longitude),
                zoomInFromCluster(cluster, _zoom),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '${cluster.count}',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList();
    }

    return widget.points
        .map(
          (p) => _pointMarker(
            p,
            highlighted: widget.selected?.id == p.id,
          ),
        )
        .toList();
  }

  Marker _pointMarker(PropertyMapPointModel p, {required bool highlighted}) {
    return Marker(
      point: LatLng(p.latitude, p.longitude),
      width: 36,
      height: 36,
      child: GestureDetector(
        onTap: () => widget.onPointSelected(p),
        child: Icon(
          Icons.location_on,
          color: highlighted ? Colors.blue : Colors.red,
          size: 36,
        ),
      ),
    );
  }

  List<CircleMarker> _buildDensityCircles(ColorScheme colorScheme) {
    return widget.points
        .map(
          (p) => CircleMarker(
            point: LatLng(p.latitude, p.longitude),
            radius: 28,
            useRadiusInMeter: false,
            color: colorScheme.primary.withValues(alpha: 0.22),
            borderColor: colorScheme.primary.withValues(alpha: 0.45),
            borderStrokeWidth: 1,
          ),
        )
        .toList();
  }
}

/// Single-property preview map (Web / desktop).
class PropertyOsmMiniMap extends StatelessWidget {
  const PropertyOsmMiniMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 220,
  });

  final double latitude;
  final double longitude;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(latitude, longitude),
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.waqf_insight',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(latitude, longitude),
                  width: 36,
                  height: 36,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Use OpenStreetMap on platforms where Google Maps native/JS SDK is unavailable
/// or not yet loaded (Web, Windows, Linux, macOS desktop).
bool get useOsmMap => !useNativeGoogleMap;

bool get useNativeGoogleMap {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
