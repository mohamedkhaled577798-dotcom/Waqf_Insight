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
import 'package:waqf_insight/features/dashboard/presentation/widgets/distribution_list_widget.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/modules_section_body.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/responsive_dashboard_widgets.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';
import 'package:waqf_insight/features/filters/presentation/widgets/geo_filter_sheet.dart';

class DashboardSectionPage extends StatelessWidget {
  const DashboardSectionPage({super.key, required this.args});

  final DashboardSectionArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardSectionBloc>()
        ..add(
          DashboardSectionLoadRequested(
            section: args.section,
            selection: args.selection,
          ),
        ),
      child: _DashboardSectionView(args: args),
    );
  }
}

class _DashboardSectionView extends StatelessWidget {
  const _DashboardSectionView({required this.args});

  final DashboardSectionArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FiltersBloc, FiltersState>(
      listener: (context, state) {
        if (state is FiltersLoaded && !state.isRefreshingLevel) {
          context.read<DashboardSectionBloc>().add(
                DashboardSectionLoadRequested(
                  section: args.section,
                  selection: state.selection,
                ),
              );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            args.section.title,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          actions: [
            if (args.section == DashboardSectionType.properties)
              IconButton(
                tooltip: 'الخريطة',
                icon: const Icon(Icons.map_rounded),
                onPressed: () {
                  final filters = context.read<FiltersBloc>().state;
                  final selection = filters is FiltersLoaded
                      ? filters.selection
                      : args.selection;
                  Navigator.pushNamed(
                    context,
                    AppRouter.geoMap,
                    arguments: GeoMapArgs(selection: selection),
                  );
                },
              ),
          ],
        ),
        body: BlocBuilder<DashboardSectionBloc, DashboardSectionState>(
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
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<DashboardSectionBloc>().add(
                      const DashboardSectionRefreshRequested(),
                    ),
                    child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardSectionLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardSectionBloc>().add(
                  const DashboardSectionRefreshRequested(),
                );
              },
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.sizeOf(context).width < 360 ? 14 : 16,
                  12,
                  MediaQuery.sizeOf(context).width < 360 ? 14 : 16,
                  24,
                ),
                children: [
                  const GeoFilterBar(),
                  const SizedBox(height: 16),
                  _SectionBody(
                    section: state.section,
                    data: state.data,
                    selection: state.selection,
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({
    required this.section,
    required this.data,
    required this.selection,
  });

  final DashboardSectionType section;
  final Object data;
  final GeoSelection selection;

  @override
  Widget build(BuildContext context) {
    return switch (section) {
      DashboardSectionType.properties => _PropertiesBody(stats: data as PropertyStatsModel, selection: selection),
      DashboardSectionType.contracts => _ContractsBody(data as ContractStatsModel),
      DashboardSectionType.revenue => _RevenueBody(data as RevenueStatsModel),
      DashboardSectionType.tenants => _TenantsBody(data as TenantStatsModel),
      DashboardSectionType.investors => _InvestorsBody(data as InvestorStatsModel),
      DashboardSectionType.partners => _PartnersBody(data as PartnerStatsModel),
      DashboardSectionType.mutawallis => _MutawallisBody(data as MutawalliStatsModel),
      DashboardSectionType.modules => ModulesSectionBody(stats: data as ModuleStatsModel),
      DashboardSectionType.staff => _StaffBody(data as StaffOverviewModel),
    };
  }
}

class _PropertiesBody extends StatelessWidget {
  const _PropertiesBody({required this.stats, required this.selection});

  final PropertyStatsModel stats;
  final GeoSelection selection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveMetricRow(
          children: [
            MetricHighlightCard(
              label: 'إجمالي العقارات',
              value: '${stats.totalProperties}',
              icon: Icons.domain_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            MetricHighlightCard(
              label: 'الملوك (وحدات)',
              value: '${stats.totalUnits}',
              icon: Icons.apartment_rounded,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ResponsiveMetricRow(
          children: [
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
        GpsGaugeChart(percent: stats.gpsCoveragePercent),
        const SizedBox(height: 16),
        DistributionPieChart(title: 'حسب النوع', slices: stats.byType),
        const SizedBox(height: 16),
        DistributionPieChart(title: 'حالة الاستخدام', slices: stats.byUsageStatus),
        const SizedBox(height: 16),
        DistributionBarChart(title: 'حسب المحافظة', slices: stats.byGovernorate),
        const SizedBox(height: 16),
        DistributionListWidget(title: 'الوضع القانوني', slices: stats.byLegalStatus),
        const SizedBox(height: 16),
        StatTile(label: 'مع GPS / بدون', value: '${stats.withGps} / ${stats.withoutGps}'),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => Navigator.pushNamed(
            context,
            AppRouter.geoMap,
            arguments: GeoMapArgs(selection: selection),
          ),
          icon: const Icon(Icons.map_rounded),
          label: Text('عرض على الخريطة', style: GoogleFonts.cairo()),
        ),
      ],
    );
  }
}

class _ContractsBody extends StatelessWidget {
  const _ContractsBody(this.stats);
  final ContractStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveMetricRow(
          children: [
            MetricHighlightCard(
              label: 'عقود نشطة',
              value: '${stats.activeContracts}',
              icon: Icons.description_rounded,
              color: colorScheme.primary,
            ),
            MetricHighlightCard(
              label: 'المحصّل (سنة)',
              value: formatIraqiCurrency(stats.collectedThisYear),
              subtitle: 'د.ع',
              icon: Icons.payments_rounded,
              color: const Color(0xFFD5A069),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GpsGaugeChart(
          percent: stats.occupancyRatePercent,
          title: 'نسبة الإشغال',
          subtitle: 'نسبة الملوك المؤجرة (${stats.rentedUnits}/${stats.totalUnits})',
          centerLabel: 'إشغال',
        ),
        const SizedBox(height: 16),
        ResponsiveStatGrid(
          children: [
            StatTile(
              label: 'المتوقع (سنة)',
              value: '${formatIraqiCurrency(stats.expectedThisYear)} د.ع',
              icon: Icons.event_available_rounded,
            ),
            StatTile(
              label: 'إجمالي المتأخرات',
              value: '${formatIraqiCurrency(stats.totalOverdueAmount)} د.ع',
              icon: Icons.warning_amber_rounded,
            ),
            StatTile(
              label: 'تنتهي قريباً',
              value: '${stats.expiringSoonContracts}',
              icon: Icons.schedule_rounded,
            ),
          ],
        ),
        if (stats.overdueBuckets.isNotEmpty) ...[
          const SizedBox(height: 16),
          DistributionBarChart(
            title: 'المتأخرات حسب الفترة',
            slices: distributionFromOverdueBuckets(stats.overdueBuckets),
          ),
        ],
      ],
    );
  }
}

class _RevenueBody extends StatelessWidget {
  const _RevenueBody(this.stats);
  final RevenueStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveMetricRow(
          children: [
            MetricHighlightCard(
              label: 'إجمالي الإيراد',
              value: formatIraqiCurrency(stats.totalGrossRevenue),
              subtitle: 'د.ع',
              icon: Icons.account_balance_wallet_rounded,
              color: colorScheme.primary,
            ),
            MetricHighlightCard(
              label: 'المتأخرات',
              value: formatIraqiCurrency(stats.totalOverdueAmount),
              subtitle: 'د.ع',
              icon: Icons.warning_amber_rounded,
              color: colorScheme.error,
            ),
          ],
        ),
        const SizedBox(height: 16),
        GpsGaugeChart(
          percent: stats.rentalCollectionRatePercent,
          title: 'تحصيل الإيجار',
          subtitle: 'نسبة التحصيل من المستحق',
          centerLabel: 'تحصيل',
        ),
        if (stats.bySource.isNotEmpty) ...[
          const SizedBox(height: 16),
          DistributionPieChart(
            title: 'حسب المصدر',
            slices: distributionFromRevenueSources(stats.bySource),
          ),
        ],
        if (stats.byGovernorate.isNotEmpty) ...[
          const SizedBox(height: 16),
          DistributionBarChart(
            title: 'حسب المحافظة',
            slices: distributionFromRevenueGovernorates(stats.byGovernorate),
          ),
        ],
      ],
    );
  }
}

class _TenantsBody extends StatelessWidget {
  const _TenantsBody(this.stats);
  final TenantStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activePercent = stats.totalTenants > 0
        ? (stats.activeTenants / stats.totalTenants) * 100
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveMetricRow(
          children: [
            MetricHighlightCard(
              label: 'إجمالي المستأجرين',
              value: '${stats.totalTenants}',
              icon: Icons.people_rounded,
              color: colorScheme.primary,
            ),
            MetricHighlightCard(
              label: 'رصيد مستحق',
              value: formatIraqiCurrency(stats.totalOutstandingBalance),
              subtitle: 'د.ع',
              icon: Icons.receipt_long_rounded,
              color: const Color(0xFFD5A069),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GpsGaugeChart(
          percent: activePercent,
          title: 'المستأجرون النشطون',
          subtitle: 'نسبة النشطين من الإجمالي',
          centerLabel: 'نشط',
        ),
        const SizedBox(height: 16),
        ResponsiveStatGrid(
          children: [
            StatTile(
              label: 'نشطون',
              value: '${stats.activeTenants}',
              icon: Icons.verified_user_rounded,
            ),
            StatTile(
              label: 'متأخرات',
              value: '${stats.withOverduePayments}',
              icon: Icons.pending_actions_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _InvestorsBody extends StatelessWidget {
  const _InvestorsBody(this.stats);
  final InvestorStatsModel stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatTile(label: 'إجمالي المستثمرين', value: '${stats.totalInvestors}'),
        const SizedBox(height: 10),
        StatTile(label: 'نشطون', value: '${stats.activeInvestors}'),
        const SizedBox(height: 10),
        StatTile(label: 'محصّل (سنة)', value: '${formatIraqiCurrency(stats.collectedThisYear)} د.ع'),
        const SizedBox(height: 10),
        StatTile(label: 'موافقات معلّقة', value: '${stats.pendingApprovals}'),
      ],
    );
  }
}

class _PartnersBody extends StatelessWidget {
  const _PartnersBody(this.stats);
  final PartnerStatsModel stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatTile(label: 'إجمالي الشركاء', value: '${stats.totalPartners}'),
        const SizedBox(height: 10),
        StatTile(label: 'نشطون', value: '${stats.activePartners}'),
        const SizedBox(height: 10),
        StatTile(label: 'عقارات مسندة', value: '${stats.assignedPropertiesCount}'),
      ],
    );
  }
}

class _MutawallisBody extends StatelessWidget {
  const _MutawallisBody(this.stats);
  final MutawalliStatsModel stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatTile(label: 'إجمالي المتولين', value: '${stats.totalMutawallis}'),
        const SizedBox(height: 10),
        StatTile(label: 'عقارات مسندة', value: '${stats.assignedPropertiesCount}'),
        const SizedBox(height: 24),
        Text('أكثر المتولين (عقارات)', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 10),
        ...stats.topByProperties.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StatTile(
              label: m.phone ?? m.email ?? '',
              value: '${m.name} — ${m.propertiesCount} عقار',
              icon: Icons.person_rounded,
            ),
          ),
        ),
      ],
    );
  }
}

class _StaffBody extends StatelessWidget {
  const _StaffBody(this.stats);
  final StaffOverviewModel stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatTile(label: 'المستخدمون', value: '${stats.totalUsers}'),
        const SizedBox(height: 10),
        StatTile(label: 'الموظفون', value: '${stats.totalEmployees}'),
        const SizedBox(height: 10),
        StatTile(label: 'المفتشون', value: '${stats.totalInspectors}'),
        const SizedBox(height: 10),
        StatTile(label: 'نشطون', value: '${stats.activeUsers}'),
      ],
    );
  }
}
