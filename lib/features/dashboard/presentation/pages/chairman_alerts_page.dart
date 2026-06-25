import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/core/utils/format_helpers.dart';
import 'package:waqf_insight/features/dashboard/data/models/executive_models.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';
import 'package:waqf_insight/features/filters/presentation/widgets/geo_filter_sheet.dart';

class ChairmanAlertsPage extends StatefulWidget {
  const ChairmanAlertsPage({super.key});

  @override
  State<ChairmanAlertsPage> createState() => _ChairmanAlertsPageState();
}

class _ChairmanAlertsPageState extends State<ChairmanAlertsPage> {
  ChairmanAlertsModel? _alerts;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  GeoSelection _selection() {
    final filters = context.read<FiltersBloc>().state;
    return filters is FiltersLoaded ? filters.selection : const GeoSelection();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await sl<DashboardRepository>().getExecutiveAlerts(_selection());

    if (!mounted) return;

    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
      }),
      (r) => setState(() {
        _loading = false;
        _alerts = r.data;
      }),
    );
  }

  void _navigateForTarget(String? target) {
    switch (target) {
      case 'property_assets':
        Navigator.pushNamed(context, AppRouter.propertyAssetSearch);
      case 'properties':
        Navigator.pushNamed(context, AppRouter.propertySearch);
      case 'contracts':
        Navigator.pushNamed(
          context,
          AppRouter.dashboardSection,
          arguments: DashboardSectionArgs(
            section: DashboardSectionType.contracts,
            selection: _selection(),
          ),
        );
      case 'modules':
        Navigator.pushNamed(
          context,
          AppRouter.dashboardSection,
          arguments: DashboardSectionArgs(
            section: DashboardSectionType.modules,
            selection: _selection(),
          ),
        );
      case 'calendar':
        Navigator.pushNamed(context, AppRouter.executiveCalendar);
      case 'investors':
        Navigator.pushNamed(
          context,
          AppRouter.dashboardSection,
          arguments: DashboardSectionArgs(
            section: DashboardSectionType.investors,
            selection: _selection(),
          ),
        );
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FiltersBloc, FiltersState>(
      listener: (_, state) {
        if (state is FiltersLoaded && !state.isRefreshingLevel) _load();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('تنبيهات الرئيس', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              onPressed: () => showGeoFilterSheet(context),
            ),
          ],
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
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_alerts != null)
                          ..._alerts!.items.map((item) => _AlertCard(
                                item: item,
                                onTap: () => _navigateForTarget(item.actionTarget),
                              )),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.item, required this.onTap});

  final ChairmanAlertItemModel item;
  final VoidCallback onTap;

  Color _severityColor(BuildContext context) {
    return switch (item.severity) {
      'critical' => Colors.red.shade700,
      'warning' => Colors.orange.shade800,
      _ => Theme.of(context).colorScheme.primary,
    };
  }

  IconData _iconForCategory() {
    return switch (item.category) {
      'contracts' => Icons.description_rounded,
      'revenue' => Icons.payments_rounded,
      'assets' => Icons.apartment_rounded,
      'properties' => Icons.domain_rounded,
      'operations' => Icons.build_circle_outlined,
      'legal' => Icons.gavel_rounded,
      'investors' => Icons.trending_up_rounded,
      _ => Icons.info_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: item.hasIssue ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_iconForCategory(), color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                        Text(
                          item.description,
                          style: GoogleFonts.cairo(fontSize: 12, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  if (item.count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item.count}',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: color),
                      ),
                    ),
                ],
              ),
              if (item.amount != null && item.amount! > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'المبلغ: ${formatIraqiCurrency(item.amount!)} د.ع',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
              if (item.samples.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...item.samples.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.label, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600)),
                              if (s.subLabel != null)
                                Text(s.subLabel!, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey.shade700)),
                            ],
                          ),
                        ),
                        if (s.date != null)
                          Text(
                            s.date!.toString().substring(0, 10),
                            style: GoogleFonts.cairo(fontSize: 11),
                          ),
                        if (s.amount != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            formatIraqiCurrency(s.amount!),
                            style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
