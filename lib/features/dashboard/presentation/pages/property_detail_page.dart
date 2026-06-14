import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/core/utils/format_helpers.dart';
import 'package:waqf_insight/core/utils/map_launcher.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_map_models.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/maps_setup_hint.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/property_mini_map.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/property_osm_map.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';

class PropertyDetailPage extends StatefulWidget {
  const PropertyDetailPage({super.key, required this.args});

  final PropertyDetailArgs args;

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  PropertyDetailModel? _detail;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await sl<DashboardRepository>().getPropertyDetail(
      widget.args.propertyId,
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (response) => setState(() {
        _loading = false;
        _detail = response.data;
      }),
    );
  }

  void _openOnMap(PropertyDetailModel detail) {
    final filters = context.read<FiltersBloc>().state;
    final selection = filters is FiltersLoaded ? filters.selection : null;

    Navigator.pushNamed(
      context,
      AppRouter.geoMap,
      arguments: GeoMapArgs(
        selection: selection ?? const GeoSelection(),
        focusPropertyId: detail.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الملك', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: GoogleFonts.cairo()),
                      FilledButton(
                        onPressed: _load,
                        child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                      ),
                    ],
                  ),
                )
              : _detail == null
                  ? Center(child: Text('الملك غير موجود', style: GoogleFonts.cairo()))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _HeaderCard(detail: _detail!),
                        const SizedBox(height: 16),
                        if (_detail!.hasGps &&
                            _detail!.latitude != null &&
                            _detail!.longitude != null) ...[
                          if (useNativeGoogleMap) ...[
                            const MapsSetupHint(),
                            const SizedBox(height: 10),
                          ],
                          PropertyMiniMap(
                            latitude: _detail!.latitude!,
                            longitude: _detail!.longitude!,
                            label: _detail!.name,
                            showSetupHint: false,
                          ),
                          const SizedBox(height: 16),
                        ],
                        _SectionCard(
                          title: 'الموقع',
                          children: [
                            _InfoRow(label: 'المحافظة', value: _detail!.governorate),
                            _InfoRow(label: 'القضاء', value: _detail!.district),
                            _InfoRow(label: 'الناحية', value: _detail!.subdistrict),
                            _InfoRow(label: 'المحلة', value: _detail!.neighborhood),
                            if (_detail!.fullAddress != null)
                              _InfoRow(label: 'العنوان', value: _detail!.fullAddress!),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _SectionCard(
                          title: 'البيانات',
                          children: [
                            if (_detail!.propertyType != null)
                              _InfoRow(label: 'النوع', value: _detail!.propertyType!),
                            if (_detail!.legalStatus != null)
                              _InfoRow(label: 'الوضع القانوني', value: _detail!.legalStatus!),
                            if (_detail!.usageStatus != null)
                              _InfoRow(label: 'حالة الاستخدام', value: _detail!.usageStatus!),
                            if (_detail!.estimatedValue != null)
                              _InfoRow(
                                label: 'القيمة التقديرية',
                                value: '${formatIraqiCurrency(_detail!.estimatedValue!)} د.ع',
                              ),
                            if (_detail!.landArea != null)
                              _InfoRow(label: 'المساحة', value: '${_detail!.landArea}'),
                            _InfoRow(label: 'سند', value: _detail!.hasDeed ? 'نعم' : 'لا'),
                            _InfoRow(
                              label: 'GPS',
                              value: _detail!.hasGps ? 'متوفّر' : 'غير متوفّر',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_detail!.hasGps &&
                            _detail!.latitude != null &&
                            _detail!.longitude != null) ...[
                          FilledButton.icon(
                            onPressed: () => _openOnMap(_detail!),
                            icon: const Icon(Icons.map_rounded),
                            label: Text('عرض على الخريطة', style: GoogleFonts.cairo()),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () => MapLauncher.openDirections(
                              latitude: _detail!.latitude!,
                              longitude: _detail!.longitude!,
                              label: _detail!.name,
                            ),
                            icon: const Icon(Icons.directions_rounded),
                            label: Text('الاتجاهات', style: GoogleFonts.cairo()),
                          ),
                        ],
                      ],
                    ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.detail});

  final PropertyDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.78),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.domain_rounded, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  detail.name,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            detail.wsiCode,
            style: GoogleFonts.cairo(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (detail.propertyType != null)
                _HeaderChip(label: detail.propertyType!),
              if (detail.usageStatus != null)
                _HeaderChip(label: detail.usageStatus!),
              if (detail.hasGps) _HeaderChip(label: 'GPS'),
              if (detail.hasDeed) _HeaderChip(label: 'سند'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.cairo())),
        ],
      ),
    );
  }
}
