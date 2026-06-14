import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_map_models.dart';

enum PropertyMapViewMode { density, cluster, points }

class PropertyMapCluster {
  const PropertyMapCluster({
    required this.id,
    required this.center,
    required this.points,
  });

  final String id;
  final LatLng center;
  final List<PropertyMapPointModel> points;

  int get count => points.length;

  PropertyMapPointModel? get singlePoint => count == 1 ? points.first : null;
}

/// Builds a heatmap layer highlighting areas with more properties.
Heatmap buildPropertyDensityHeatmap(List<PropertyMapPointModel> points) {
  return Heatmap(
    heatmapId: const HeatmapId('property_density'),
    data: [
      for (final p in points)
        WeightedLatLng(LatLng(p.latitude, p.longitude), weight: 1),
    ],
    radius: HeatmapRadius.fromPixels(32),
    opacity: 0.78,
    gradient: HeatmapGradient(
      const [
        HeatmapGradientColor(Color(0x0000FF00), 0.0),
        HeatmapGradientColor(Color(0xFF00E676), 0.25),
        HeatmapGradientColor(Color(0xFFFFEB3B), 0.5),
        HeatmapGradientColor(Color(0xFFFF9800), 0.75),
        HeatmapGradientColor(Color(0xFFF44336), 1.0),
      ],
    ),
  );
}

/// Grid-based clustering; cell size shrinks as zoom increases.
List<PropertyMapCluster> clusterPropertyPoints(
  List<PropertyMapPointModel> points, {
  required double zoom,
}) {
  if (points.isEmpty) return const [];

  final cellSize = _cellSizeForZoom(zoom);
  final buckets = <String, List<PropertyMapPointModel>>{};

  for (final point in points) {
    final latCell = (point.latitude / cellSize).floor();
    final lngCell = (point.longitude / cellSize).floor();
    final key = '${latCell}_$lngCell';
    buckets.putIfAbsent(key, () => []).add(point);
  }

  return buckets.entries.map((entry) {
    final clusterPoints = entry.value;
    final lat =
        clusterPoints.map((p) => p.latitude).reduce((a, b) => a + b) / clusterPoints.length;
    final lng =
        clusterPoints.map((p) => p.longitude).reduce((a, b) => a + b) / clusterPoints.length;

    return PropertyMapCluster(
      id: entry.key,
      center: LatLng(lat, lng),
      points: clusterPoints,
    );
  }).toList();
}

double _cellSizeForZoom(double zoom) {
  if (zoom >= 15) return 0.002;
  if (zoom >= 13) return 0.008;
  if (zoom >= 11) return 0.025;
  if (zoom >= 9) return 0.06;
  return 0.15;
}

Set<Marker> buildClusterMarkers({
  required List<PropertyMapCluster> clusters,
  required PropertyMapPointModel? selected,
  required void Function(PropertyMapPointModel point) onPointSelected,
  required void Function(PropertyMapCluster cluster) onClusterTap,
}) {
  return clusters.map((cluster) {
    final single = cluster.singlePoint;
    if (single != null) {
      final isSelected = selected?.id == single.id;
      return Marker(
        markerId: MarkerId(single.id),
        position: LatLng(single.latitude, single.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRose,
        ),
        infoWindow: InfoWindow(title: single.name, snippet: single.wsiCode),
        onTap: () => onPointSelected(single),
      );
    }

    return Marker(
      markerId: MarkerId('cluster_${cluster.id}'),
      position: cluster.center,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(
        title: '${cluster.count} أملاك',
        snippet: 'اضغط للتكبير',
      ),
      onTap: () => onClusterTap(cluster),
    );
  }).toSet();
}

Set<Marker> buildPointMarkers({
  required List<PropertyMapPointModel> points,
  required PropertyMapPointModel? selected,
  required void Function(PropertyMapPointModel point) onPointSelected,
}) {
  return points
      .map(
        (p) => Marker(
          markerId: MarkerId(p.id),
          position: LatLng(p.latitude, p.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            selected?.id == p.id
                ? BitmapDescriptor.hueAzure
                : BitmapDescriptor.hueRose,
          ),
          infoWindow: InfoWindow(title: p.name, snippet: p.wsiCode),
          onTap: () => onPointSelected(p),
        ),
      )
      .toSet();
}

String viewModeLabel(PropertyMapViewMode mode) {
  return switch (mode) {
    PropertyMapViewMode.density => 'كثافة',
    PropertyMapViewMode.cluster => 'تجميع',
    PropertyMapViewMode.points => 'نقاط',
  };
}

IconData viewModeIcon(PropertyMapViewMode mode) {
  return switch (mode) {
    PropertyMapViewMode.density => Icons.blur_on_rounded,
    PropertyMapViewMode.cluster => Icons.bubble_chart_rounded,
    PropertyMapViewMode.points => Icons.location_on_rounded,
  };
}

PropertyMapViewMode defaultViewModeForCount(int count) {
  if (count > 40) return PropertyMapViewMode.density;
  if (count > 8) return PropertyMapViewMode.cluster;
  return PropertyMapViewMode.points;
}

double zoomInFromCluster(PropertyMapCluster cluster, double currentZoom) {
  return math.min(currentZoom + 2.5, 18);
}
