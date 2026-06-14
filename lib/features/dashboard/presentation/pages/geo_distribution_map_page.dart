import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/core/utils/map_launcher.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_map_models.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/geo_map_bloc.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/geo_map_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/geo_map_state.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/map_density_utils.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/property_osm_map.dart';
import 'package:waqf_insight/features/filters/presentation/widgets/geo_filter_sheet.dart';

class GeoDistributionMapPage extends StatelessWidget {
  const GeoDistributionMapPage({super.key, required this.args});

  final GeoMapArgs args;

  @override
  Widget build(BuildContext context) {
    final filters = context.read<FiltersBloc>().state;
    final selection = filters is FiltersLoaded ? filters.selection : args.selection;

    return BlocProvider(
      create: (_) => sl<GeoMapBloc>()..add(GeoMapLoadRequested(selection)),
      child: _GeoMapView(args: args),
    );
  }
}

class _GeoMapView extends StatefulWidget {
  const _GeoMapView({required this.args});

  final GeoMapArgs args;

  @override
  State<_GeoMapView> createState() => _GeoMapViewState();
}

class _GeoMapViewState extends State<_GeoMapView> {
  GoogleMapController? _mapController;
  PropertyMapPointModel? _selected;
  PropertyDistributionModel? _pendingFocus;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FiltersBloc, FiltersState>(
      listener: (context, state) {
        if (state is FiltersLoaded && !state.isRefreshingLevel) {
          context.read<GeoMapBloc>().add(GeoMapFilterChanged(state.selection));
        }
      },
      child: BlocListener<GeoMapBloc, GeoMapState>(
        listener: (context, state) {
          if (state is GeoMapLoaded) {
            _pendingFocus = state.distribution;
            _applyPendingFocus();
            _selectFocusProperty(state.distribution);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'التوزيع الجغرافي',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                tooltip: 'بحث الأملاك',
                icon: const Icon(Icons.search_rounded),
                onPressed: () => Navigator.pushNamed(context, AppRouter.propertySearch),
              ),
            ],
          ),
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: GeoFilterBar(),
              ),
              Expanded(
                child: BlocBuilder<GeoMapBloc, GeoMapState>(
                  builder: (context, state) {
                    if (state is GeoMapLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is GeoMapError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.message, style: GoogleFonts.cairo()),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => context.read<GeoMapBloc>().add(
                                    GeoMapLoadRequested(state.selection),
                                  ),
                              child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is GeoMapLoaded) {
                      return _MapBody(
                        distribution: state.distribution,
                        selected: _selected,
                        onPointSelected: (point) {
                          setState(() => _selected = point);
                          _focusProperty(point);
                        },
                        onMapCreated: _onMapCreated,
                        onFocusRegion: () => _focusRegion(state.distribution.mapFocus),
                        onClusterZoom: (target, zoom) async {
                          await _mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(target: target, zoom: zoom),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
              if (_selected != null) _PropertyPreviewSheet(point: _selected!),
            ],
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _applyPendingFocus();
  }

  void _applyPendingFocus() {
    final distribution = _pendingFocus;
    if (distribution == null || _mapController == null) return;

    final focusId = widget.args.focusPropertyId;
    if (focusId != null) {
      final point = distribution.mapPoints.where((p) => p.id == focusId).firstOrNull;
      if (point != null) {
        _focusProperty(point);
        return;
      }
    }

    _focusRegion(distribution.mapFocus);
  }

  void _selectFocusProperty(PropertyDistributionModel distribution) {
    final focusId = widget.args.focusPropertyId;
    if (focusId == null) return;

    final point = distribution.mapPoints.where((p) => p.id == focusId).firstOrNull;
    if (point != null) {
      setState(() => _selected = point);
    }
  }

  Future<void> _focusRegion(MapFocusModel focus) async {
    final controller = _mapController;
    if (controller == null) return;

    if (focus.north != null &&
        focus.south != null &&
        focus.east != null &&
        focus.west != null) {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(focus.south!, focus.west!),
            northeast: LatLng(focus.north!, focus.east!),
          ),
          48,
        ),
      );
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(focus.centerLat, focus.centerLng),
          zoom: focus.zoom.toDouble(),
        ),
      ),
    );
  }

  Future<void> _focusProperty(PropertyMapPointModel point) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(point.latitude, point.longitude),
          zoom: 16,
        ),
      ),
    );
  }
}

class _MapBody extends StatefulWidget {
  const _MapBody({
    required this.distribution,
    required this.selected,
    required this.onPointSelected,
    required this.onMapCreated,
    required this.onFocusRegion,
    required this.onClusterZoom,
  });

  final PropertyDistributionModel distribution;
  final PropertyMapPointModel? selected;
  final ValueChanged<PropertyMapPointModel> onPointSelected;
  final ValueChanged<GoogleMapController> onMapCreated;
  final VoidCallback onFocusRegion;
  final Future<void> Function(LatLng target, double zoom) onClusterZoom;

  @override
  State<_MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<_MapBody> {
  PropertyMapViewMode _viewMode = PropertyMapViewMode.density;
  double _zoom = 6;

  @override
  void initState() {
    super.initState();
    _viewMode = defaultViewModeForCount(widget.distribution.mapPoints.length);
    _zoom = widget.distribution.mapFocus.zoom.toDouble();
  }

  @override
  void didUpdateWidget(covariant _MapBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.distribution.mapPoints.length !=
        widget.distribution.mapPoints.length) {
      _viewMode = defaultViewModeForCount(widget.distribution.mapPoints.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final focus = widget.distribution.mapFocus;
    final points = widget.distribution.mapPoints;
    final colorScheme = Theme.of(context).colorScheme;
    final totalWithGps = widget.distribution.stats.withGps;

    if (useOsmMap) {
      return PropertyOsmMap(
        points: points,
        focus: focus,
        selected: widget.selected,
        onPointSelected: widget.onPointSelected,
        onFocusRegion: widget.onFocusRegion,
      );
    }

    final heatmaps = _viewMode == PropertyMapViewMode.density && points.isNotEmpty
        ? {buildPropertyDensityHeatmap(points)}
        : <Heatmap>{};

    Set<Marker> markers = {};
    if (_viewMode == PropertyMapViewMode.points) {
      markers = buildPointMarkers(
        points: points,
        selected: widget.selected,
        onPointSelected: widget.onPointSelected,
      );
    } else if (_viewMode == PropertyMapViewMode.cluster) {
      final clusters = clusterPropertyPoints(points, zoom: _zoom);
      markers = buildClusterMarkers(
        clusters: clusters,
        selected: widget.selected,
        onPointSelected: widget.onPointSelected,
        onClusterTap: (cluster) {
          final single = cluster.singlePoint;
          if (single != null) {
            widget.onPointSelected(single);
            return;
          }
          widget.onClusterZoom(
            cluster.center,
            zoomInFromCluster(cluster, _zoom),
          );
        },
      );
    } else if (widget.selected != null) {
      final p = widget.selected!;
      markers = {
        Marker(
          markerId: MarkerId(p.id),
          position: LatLng(p.latitude, p.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: p.name, snippet: p.wsiCode),
          onTap: () => widget.onPointSelected(p),
        ),
      };
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(focus.centerLat, focus.centerLng),
            zoom: focus.zoom.toDouble(),
          ),
          markers: markers,
          heatmaps: heatmaps,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: widget.onMapCreated,
          onCameraMove: (position) => _zoom = position.zoom,
        ),
        Positioned(
          top: 12,
          right: 12,
          left: 12,
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
                          focus.focusLabel ?? 'كل العراق',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${points.length} على الخريطة · $totalWithGps بإحداثيات',
                          style: GoogleFonts.cairo(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'تركيز على المنطقة',
                    icon: const Icon(Icons.center_focus_strong_rounded),
                    onPressed: widget.onFocusRegion,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 78,
          right: 12,
          left: 12,
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
                          avatar: Icon(
                            viewModeIcon(mode),
                            size: 16,
                            color: _viewMode == mode
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                          ),
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
        if (_viewMode == PropertyMapViewMode.density)
          Positioned(
            bottom: 16,
            left: 12,
            right: 12,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              color: colorScheme.surface.withValues(alpha: 0.92),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'أقل',
                      style: GoogleFonts.cairo(fontSize: 10),
                    ),
                    Expanded(
                      child: Container(
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF00E676),
                              Color(0xFFFFEB3B),
                              Color(0xFFFF9800),
                              Color(0xFFF44336),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'تزاحم أكثر',
                      style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (points.isEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.surface.withValues(alpha: 0.92),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'لا توجد أملاك بإحداثيات GPS في ${focus.focusLabel ?? "هذه المنطقة"}',
                      style: GoogleFonts.cairo(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PropertyPreviewSheet extends StatelessWidget {
  const _PropertyPreviewSheet({required this.point});

  final PropertyMapPointModel point;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 8,
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                point.name,
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                point.wsiCode,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(point.locationLabel, style: GoogleFonts.cairo(fontSize: 13)),
              if (point.propertyType != null)
                Text('النوع: ${point.propertyType}', style: GoogleFonts.cairo(fontSize: 12)),
              if (point.usageStatus != null)
                Text('الاستخدام: ${point.usageStatus}', style: GoogleFonts.cairo(fontSize: 12)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRouter.propertyDetail,
                        arguments: PropertyDetailArgs(propertyId: point.id),
                      ),
                      icon: const Icon(Icons.info_outline_rounded),
                      label: Text('التفاصيل', style: GoogleFonts.cairo()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => MapLauncher.openDirections(
                        latitude: point.latitude,
                        longitude: point.longitude,
                        label: point.name,
                      ),
                      icon: const Icon(Icons.directions_rounded),
                      label: Text('الاتجاهات', style: GoogleFonts.cairo()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
