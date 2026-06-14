import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/dashboard_charts.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/responsive_dashboard_widgets.dart';
import 'package:waqf_insight/features/splash/presentation/widgets/splash_colors.dart';

class ModulesSectionBody extends StatelessWidget {
  const ModulesSectionBody({super.key, required this.stats});

  final ModuleStatsModel stats;

  int get _pendingTotal =>
      stats.pendingMaintenanceRequests +
      stats.pendingInspectionTasks +
      stats.pendingApprovals;

  int get _activeTotal => stats.activeCases + stats.activeProjects;

  double get _activityPercent {
    final total = _activeTotal + _pendingTotal;
    if (total <= 0) return 0;
    return (_activeTotal / total) * 100;
  }

  List<DistributionSliceModel> get _pendingSlices {
    final items = [
      ('صيانة', stats.pendingMaintenanceRequests),
      ('تفتيش', stats.pendingInspectionTasks),
      ('موافقات', stats.pendingApprovals),
    ].where((e) => e.$2 > 0).toList();

    final total = items.fold<int>(0, (sum, e) => sum + e.$2);
    return [
      for (final item in items)
        DistributionSliceModel(
          label: item.$1,
          value: item.$2,
          percent: total > 0 ? (item.$2 / total) * 100 : 0,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OperationsHeroBanner(
          activeTotal: _activeTotal,
          pendingTotal: _pendingTotal,
          upcomingSessions: stats.upcomingSessions,
        ),
        const SizedBox(height: 16),
        ResponsiveMetricRow(
          children: [
            MetricHighlightCard(
              label: 'مشاريع نشطة',
              value: '${stats.activeProjects}',
              icon: Icons.apartment_rounded,
              color: const Color(0xFF1565C0),
            ),
            MetricHighlightCard(
              label: 'قضايا نشطة',
              value: '${stats.activeCases}',
              icon: Icons.gavel_rounded,
              color: colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        GpsGaugeChart(
          percent: _activityPercent,
          title: 'نشاط التشغيل',
          subtitle: 'نسبة الأعمال النشطة من إجمالي المتابعة',
          centerLabel: 'نشط',
        ),
        const SizedBox(height: 20),
        _SectionLabel(title: 'القضايا والجلسات', icon: Icons.balance_rounded),
        const SizedBox(height: 10),
        ResponsiveStatGrid(
          children: [
            _OperationCard(
              label: 'قضايا نشطة',
              value: stats.activeCases,
              icon: Icons.gavel_rounded,
              color: colorScheme.primary,
            ),
            _OperationCard(
              label: 'جلسات قادمة',
              value: stats.upcomingSessions,
              icon: Icons.event_rounded,
              color: const Color(0xFF6A1B9A),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionLabel(title: 'المشاريع والصيانة', icon: Icons.engineering_rounded),
        const SizedBox(height: 10),
        ResponsiveStatGrid(
          children: [
            _OperationCard(
              label: 'مشاريع نشطة',
              value: stats.activeProjects,
              icon: Icons.apartment_rounded,
              color: const Color(0xFF1565C0),
            ),
            _OperationCard(
              label: 'صيانة معلّقة',
              value: stats.pendingMaintenanceRequests,
              icon: Icons.build_circle_rounded,
              color: Colors.orange.shade800,
              highlight: stats.pendingMaintenanceRequests > 0,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionLabel(title: 'متابعة وموافقات', icon: Icons.fact_check_rounded),
        const SizedBox(height: 10),
        ResponsiveStatGrid(
          children: [
            _OperationCard(
              label: 'تفتيش معلّق',
              value: stats.pendingInspectionTasks,
              icon: Icons.fact_check_outlined,
              color: colorScheme.tertiary,
              highlight: stats.pendingInspectionTasks > 0,
            ),
            _OperationCard(
              label: 'موافقات معلّقة',
              value: stats.pendingApprovals,
              icon: Icons.pending_actions_rounded,
              color: colorScheme.error,
              highlight: stats.pendingApprovals > 0,
            ),
          ],
        ),
        if (_pendingSlices.isNotEmpty) ...[
          const SizedBox(height: 20),
          DistributionPieChart(
            title: 'توزيع المهام المعلّقة',
            slices: _pendingSlices,
          ),
        ],
        if (_pendingTotal == 0 && _activeTotal == 0) ...[
          const SizedBox(height: 16),
          _EmptyOperationsHint(colorScheme: colorScheme),
        ],
      ],
    );
  }
}

class _OperationsHeroBanner extends StatelessWidget {
  const _OperationsHeroBanner({
    required this.activeTotal,
    required this.pendingTotal,
    required this.upcomingSessions,
  });

  final int activeTotal;
  final int pendingTotal;
  final int upcomingSessions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings_suggest_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لوحة التشغيل',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'متابعة القضايا والمشاريع والمهام',
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroStatChip(
                  label: 'نشط',
                  value: '$activeTotal',
                  icon: Icons.play_circle_fill_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroStatChip(
                  label: 'معلّق',
                  value: '$pendingTotal',
                  icon: Icons.hourglass_top_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroStatChip(
                  label: 'جلسات',
                  value: '$upcomingSessions',
                  icon: Icons.event_available_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(icon, color: SplashColors.goldLight, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _OperationCard extends StatelessWidget {
  const _OperationCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      padding: EdgeInsets.all(width < 360 ? 12 : 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? color.withValues(alpha: 0.45)
              : color.withValues(alpha: 0.2),
          width: highlight ? 1.5 : 1,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.72)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: GoogleFonts.cairo(
                    fontSize: width < 360 ? 20 : 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'متابعة',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyOperationsHint extends StatelessWidget {
  const _EmptyOperationsHint({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'لا توجد مهام تشغيل مسجّلة حالياً ضمن نطاق الفلتر المختار',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
