import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/core/utils/format_helpers.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_section_bloc.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_section_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_section_state.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/dashboard_charts.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/responsive_dashboard_widgets.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/presentation/widgets/geo_filter_sheet.dart';

class AssetsTabPage extends StatelessWidget {
  const AssetsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardSectionBloc>(),
      child: const _AssetsTabContent(),
    );
  }
}

class _AssetsTabContent extends StatefulWidget {
  const _AssetsTabContent();

  @override
  State<_AssetsTabContent> createState() => _AssetsTabContentState();
}

class _AssetsTabContentState extends State<_AssetsTabContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromFilters());
  }

  void _loadFromFilters() {
    final filters = context.read<FiltersBloc>().state;
    if (filters is FiltersLoaded) {
      context.read<DashboardSectionBloc>().add(
            DashboardSectionLoadRequested(
              section: DashboardSectionType.properties,
              selection: filters.selection,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<FiltersBloc, FiltersState>(
      listener: (context, state) {
        if (state is FiltersLoaded && !state.isRefreshingLevel) {
          context.read<DashboardSectionBloc>().add(
                DashboardSectionLoadRequested(
                  section: DashboardSectionType.properties,
                  selection: state.selection,
                ),
              );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'الأملاك',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              tooltip: 'بحث الأملاك',
              icon: const Icon(Icons.search_rounded),
              onPressed: () => Navigator.pushNamed(context, AppRouter.propertySearch),
            ),
            IconButton(
              tooltip: 'الخريطة',
              icon: const Icon(Icons.map_rounded),
              onPressed: () {
                final filters = context.read<FiltersBloc>().state;
                final selection =
                    filters is FiltersLoaded ? filters.selection : null;
                Navigator.pushNamed(
                  context,
                  AppRouter.geoMap,
                  arguments: GeoMapArgs(
                    selection: selection ?? const GeoSelection(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: GeoFilterBar(
                padding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: BlocBuilder<DashboardSectionBloc, DashboardSectionState>(
                builder: (context, state) {
                  if (state is DashboardSectionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is DashboardSectionError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message, style: GoogleFonts.cairo()),
                          FilledButton(
                            onPressed: _loadFromFilters,
                            child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is! DashboardSectionLoaded ||
                      state.data is! PropertyStatsModel) {
                    return const SizedBox.shrink();
                  }

                  final stats = state.data as PropertyStatsModel;

                  return RefreshIndicator(
                    onRefresh: () async => _loadFromFilters(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      children: [
                        ResponsiveMetricRow(
                          children: [
                            MetricHighlightCard(
                              label: 'إجمالي الأملاك',
                              value: '${stats.totalProperties}',
                              icon: Icons.domain_rounded,
                              color: colorScheme.primary,
                            ),
                            MetricHighlightCard(
                              label: 'القيمة التقديرية',
                              value: formatIraqiCurrency(stats.totalEstimatedValue),
                              subtitle: 'د.ع',
                              icon: Icons.payments_rounded,
                              color: const Color(0xFFD5A069),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ResponsiveStatGrid(
                          children: [
                            _MiniStat(
                              label: 'مؤجرة',
                              value: '${stats.rentedCount}',
                              icon: Icons.key_rounded,
                              color: colorScheme.tertiary,
                            ),
                            _MiniStat(
                              label: 'شاغرة',
                              value: '${stats.vacantCount}',
                              icon: Icons.meeting_room_outlined,
                              color: Colors.orange,
                            ),
                            _MiniStat(
                              label: 'متنازع',
                              value: '${stats.disputedCount}',
                              icon: Icons.gavel_rounded,
                              color: colorScheme.error,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GpsGaugeChart(percent: stats.gpsCoveragePercent),
                        const SizedBox(height: 16),
                        DistributionPieChart(
                          title: 'توزيع حسب النوع',
                          slices: stats.byType,
                        ),
                        const SizedBox(height: 16),
                        DistributionPieChart(
                          title: 'حالة الاستخدام',
                          slices: stats.byUsageStatus,
                        ),
                        const SizedBox(height: 16),
                        DistributionBarChart(
                          title: 'حسب المحافظة',
                          slices: stats.byGovernorate,
                        ),
                        const SizedBox(height: 16),
                        DistributionBarChart(
                          title: 'حسب القضاء',
                          slices: stats.byDistrict,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRouter.propertySearch,
                          ),
                          icon: const Icon(Icons.search_rounded),
                          label: Text(
                            'بحث واستعراض الأملاك',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.geoMap,
                              arguments: GeoMapArgs(selection: state.selection),
                            );
                          },
                          icon: const Icon(Icons.map_rounded),
                          label: Text(
                            'عرض التوزيع على الخريطة',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
