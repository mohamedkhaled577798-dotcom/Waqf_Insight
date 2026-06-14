import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/constants/org_branding.dart';
import 'package:waqf_insight/core/utils/format_helpers.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';
import 'package:waqf_insight/features/activity/presentation/widgets/activity_log_access_card.dart';
import 'package:waqf_insight/features/home/presentation/widgets/main_shell_scope.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_colors.dart';

class HomeDashboardLayout extends StatelessWidget {
  const HomeDashboardLayout({
    super.key,
    required this.summary,
    this.generatedAt,
    required this.selection,
  });

  final DashboardSummaryModel summary;
  final DateTime? generatedAt;
  final GeoSelection selection;

  GeoSelection _resolveSelection(BuildContext context) {
    final filters = context.read<FiltersBloc>().state;
    if (filters is FiltersLoaded) return filters.selection;
    return selection;
  }

  void _openSection(BuildContext context, DashboardSectionType section) {
    Navigator.pushNamed(
      context,
      AppRouter.dashboardSection,
      arguments: DashboardSectionArgs(
        section: section,
        selection: _resolveSelection(context),
      ),
    );
  }

  void _openMap(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRouter.geoMap,
      arguments: GeoMapArgs(selection: _resolveSelection(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final p = summary.properties;
    final c = summary.contracts;
    final r = summary.revenue;
    final s = summary.staff;
    final mod = summary.modules;

    final metrics = [
      _MetricCardData(
        label: 'إجمالي الأملاك',
        value: '${p.totalProperties}',
        icon: Icons.domain_rounded,
        colors: [colorScheme.primary, const Color(0xFF2E7D32)],
        onTap: () => _openSection(context, DashboardSectionType.properties),
      ),
      _MetricCardData(
        label: 'القيمة التقديرية',
        value: formatIraqiCurrency(p.totalEstimatedValue),
        subtitle: 'د.ع',
        icon: Icons.payments_rounded,
        colors: [SplashColors.goldDark, SplashColors.gold],
        onTap: () => _openSection(context, DashboardSectionType.properties),
      ),
      _MetricCardData(
        label: 'عقود نشطة',
        value: '${c.activeContracts}',
        icon: Icons.description_rounded,
        colors: [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
        onTap: () => _openSection(context, DashboardSectionType.contracts),
      ),
      _MetricCardData(
        label: 'إجمالي الإيراد',
        value: formatIraqiCurrency(r.totalGrossRevenue),
        subtitle: 'د.ع',
        icon: Icons.account_balance_wallet_rounded,
        colors: [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)],
        onTap: () => _openSection(context, DashboardSectionType.revenue),
      ),
      _MetricCardData(
        label: 'الموظفون',
        value: '${s.totalEmployees}',
        icon: Icons.groups_rounded,
        colors: [const Color(0xFF00695C), colorScheme.tertiary],
        onTap: () => MainShellScope.goToTab(context, 2),
      ),
    ];

    final quickActions = [
      _QuickActionData(
        label: 'الأملاك',
        subtitle: '${p.totalProperties} عقار',
        icon: Icons.domain_rounded,
        color: colorScheme.primary,
        onTap: () => MainShellScope.goToTab(context, 1),
      ),
      _QuickActionData(
        label: 'الخريطة',
        subtitle: 'التوزيع الجغرافي',
        icon: Icons.map_rounded,
        color: const Color(0xFF0277BD),
        onTap: () => _openMap(context),
      ),
      _QuickActionData(
        label: 'بحث الأملاك',
        subtitle: 'بحث وتصفّح',
        icon: Icons.search_rounded,
        color: SplashColors.goldDark,
        onTap: () => Navigator.pushNamed(context, AppRouter.propertySearch),
      ),
      _QuickActionData(
        label: 'العقود',
        subtitle: '${c.activeContracts} نشط',
        icon: Icons.handshake_rounded,
        color: const Color(0xFF1565C0),
        onTap: () => _openSection(context, DashboardSectionType.contracts),
      ),
      _QuickActionData(
        label: 'الإيرادات',
        subtitle: formatPercent(r.rentalCollectionRatePercent),
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF6A1B9A),
        onTap: () => _openSection(context, DashboardSectionType.revenue),
      ),
      _QuickActionData(
        label: 'الموظفون',
        subtitle: '${s.activeUsers} نشط',
        icon: Icons.badge_rounded,
        color: const Color(0xFF00695C),
        onTap: () => MainShellScope.goToTab(context, 2),
      ),
      _QuickActionData(
        label: 'المستأجرون',
        subtitle: '${summary.tenants.totalTenants}',
        icon: Icons.people_rounded,
        color: colorScheme.secondary,
        onTap: () => _openSection(context, DashboardSectionType.tenants),
      ),
      _QuickActionData(
        label: 'التشغيل',
        subtitle: '${mod.activeProjects} مشروع',
        icon: Icons.settings_suggest_rounded,
        color: Colors.orange.shade800,
        onTap: () => _openSection(context, DashboardSectionType.modules),
      ),
    ];

    final sections = [
      _SectionCardData(
        title: 'الأملاك',
        icon: Icons.home_work_rounded,
        color: colorScheme.primary,
        lines: [
          'مؤجرة: ${p.rentedCount}',
          'GPS: ${formatPercent(p.gpsCoveragePercent)}',
        ],
        section: DashboardSectionType.properties,
      ),
      _SectionCardData(
        title: 'العقود',
        icon: Icons.description_rounded,
        color: const Color(0xFF1565C0),
        lines: [
          'إشغال: ${formatPercent(c.occupancyRatePercent)}',
          'متأخرات: ${formatIraqiCurrency(c.totalOverdueAmount)}',
        ],
        section: DashboardSectionType.contracts,
      ),
      _SectionCardData(
        title: 'الإيرادات',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF6A1B9A),
        lines: [
          'تحصيل: ${formatPercent(r.rentalCollectionRatePercent)}',
          'إجمالي: ${formatIraqiCurrency(r.totalGrossRevenue)}',
        ],
        section: DashboardSectionType.revenue,
      ),
      _SectionCardData(
        title: 'المستأجرون',
        icon: Icons.people_rounded,
        color: colorScheme.secondary,
        lines: [
          'المستأجرون: ${summary.tenants.totalTenants}',
          'المستثمرون: ${summary.investors.totalInvestors}',
        ],
        section: DashboardSectionType.tenants,
      ),
      _SectionCardData(
        title: 'التشغيل',
        icon: Icons.build_circle_rounded,
        color: Colors.orange.shade800,
        lines: [
          'قضايا: ${mod.activeCases}',
          'صيانة: ${mod.pendingMaintenanceRequests}',
        ],
        section: DashboardSectionType.modules,
      ),
      _SectionCardData(
        title: 'الموظفون',
        icon: Icons.groups_rounded,
        color: const Color(0xFF00695C),
        lines: [
          'موظفون: ${s.totalEmployees}',
          'مفتشون: ${s.totalInspectors}',
        ],
        section: DashboardSectionType.staff,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HomeHeroBanner(
          filterLabel: summary.appliedFilter.displayLabel,
          hasFilter: summary.appliedFilter.hasAnyFilter,
        ),
        if (generatedAt != null) ...[
          const SizedBox(height: 10),
          Text(
            'آخر تحديث: ${_formatGeneratedAt(generatedAt!)}',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
        const SizedBox(height: 18),
        _SectionHeading(title: 'أبرز المؤشرات'),
        const SizedBox(height: 10),
        _MetricsCarousel(metrics: metrics),
        const SizedBox(height: 22),
        _SectionHeading(title: 'الوصول السريع'),
        const SizedBox(height: 10),
        _QuickActionsGrid(actions: quickActions),
        const SizedBox(height: 22),
        _SectionHeading(title: 'استكشف الأقسام'),
        const SizedBox(height: 10),
        _SectionsCarousel(
          sections: sections,
          onOpen: (section) => _openSection(context, section),
        ),
        const SizedBox(height: 22),
        const ActivityLogAccessCard(),
      ],
    );
  }

  String _formatGeneratedAt(DateTime utc) {
    final local = utc.toLocal();
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

class HomeDashboardLoading extends StatelessWidget {
  const HomeDashboardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => Container(
              width: 160,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: List.generate(
            4,
            (_) => Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeHeroBanner extends StatelessWidget {
  const _HomeHeroBanner({
    required this.filterLabel,
    required this.hasFilter,
  });

  final String filterLabel;
  final bool hasFilter;


  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [SplashColors.deepGreen, SplashColors.forestGreen],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: SplashColors.deepGreen.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -10,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SplashColors.gold.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: SplashColors.gold.withValues(alpha: 0.85),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SplashColors.gold.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.account_balance_rounded,
                        size: 42,
                        color: SplashColors.deepGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك',
                        style: GoogleFonts.cairo(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        OrgBranding.diwanTitle,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasFilter
                                  ? Icons.location_on_rounded
                                  : Icons.public_rounded,
                              color: SplashColors.goldLight,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                filterLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _MetricCardData {
  const _MetricCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
    required this.onTap,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
}

class _MetricsCarousel extends StatelessWidget {
  const _MetricsCarousel({required this.metrics});

  final List<_MetricCardData> metrics;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final m = metrics[index];
          return _MetricTile(data: m);
        },
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.data});

  final _MetricCardData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 168,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: data.colors,
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: data.colors.first.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(data.icon, color: Colors.white.withValues(alpha: 0.92), size: 22),
              const Spacer(),
              Text(
                data.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              if (data.subtitle != null)
                Text(
                  data.subtitle!,
                  style: GoogleFonts.cairo(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.actions});

  final List<_QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => _QuickActionTile(data: actions[index]),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.color,
                      data.color.withValues(alpha: 0.72),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: data.color.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(data.icon, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Text(
                data.label,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Text(
                data.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCardData {
  const _SectionCardData({
    required this.title,
    required this.icon,
    required this.color,
    required this.lines,
    required this.section,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> lines;
  final DashboardSectionType section;
}

class _SectionsCarousel extends StatelessWidget {
  const _SectionsCarousel({
    required this.sections,
    required this.onOpen,
  });

  final List<_SectionCardData> sections;
  final ValueChanged<DashboardSectionType> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final s = sections[index];
          return _SectionTile(
            data: s,
            onTap: () => onOpen(s.section),
          );
        },
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.data, required this.onTap});

  final _SectionCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: data.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(data.icon, color: data.color, size: 20),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: data.color,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  data.title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                for (final line in data.lines) ...[
                  const SizedBox(height: 2),
                  Text(
                    line,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
