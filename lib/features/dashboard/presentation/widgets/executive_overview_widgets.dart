import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/utils/format_helpers.dart';
import 'package:waqf_insight/features/dashboard/data/models/executive_models.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/executive_bloc.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/executive_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/executive_state.dart';

class ChairmanBriefingCard extends StatelessWidget {
  const ChairmanBriefingCard({
    super.key,
    required this.briefing,
    required this.alertCount,
  });

  final ChairmanBriefingModel briefing;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    final hasAlerts = briefing.lines.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.82),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.pushNamed(context, AppRouter.chairmanAlerts),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.wb_sunny_rounded, color: Colors.white.withValues(alpha: 0.9)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ملخص اليوم',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    if (alertCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$alertCount',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_left, color: Colors.white.withValues(alpha: 0.85)),
                  ],
                ),
                const SizedBox(height: 12),
                if (!hasAlerts)
                  Text(
                    'لا توجد تنبيهات حرجة — الوضع مستقر',
                    style: GoogleFonts.cairo(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  )
                else
                  ...briefing.lines.take(4).map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SeverityDot(severity: line.severity),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  line.text,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChairmanTrendsSection extends StatelessWidget {
  const ChairmanTrendsSection({super.key, required this.trends});

  final ChairmanTrendsModel trends;

  @override
  Widget build(BuildContext context) {
    if (trends.metrics.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'مقارنة زمنية',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ...trends.metrics.map(
          (m) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.label,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.isCurrency
                            ? '${formatIraqiCurrency(m.currentValue)} د.ع'
                            : m.key == 'occupancy_rate'
                                ? '${m.currentValue.toStringAsFixed(1)}%'
                                : m.currentValue.toStringAsFixed(0),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (m.key != 'occupancy_rate' && m.key != 'active_contracts')
                  _TrendBadge(metric: m),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ExecutiveQuickActions extends StatelessWidget {
  const ExecutiveQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRouter.chairmanAlerts),
            icon: const Icon(Icons.notifications_active_outlined, size: 18),
            label: Text('التنبيهات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRouter.executiveCalendar),
            icon: const Icon(Icons.calendar_month_rounded, size: 18),
            label: Text('التقويم', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(backgroundColor: colorScheme.tertiary),
          ),
        ),
      ],
    );
  }
}

class ExecutiveOverviewSection extends StatelessWidget {
  const ExecutiveOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExecutiveBloc, ExecutiveState>(
      builder: (context, state) {
        if (state is ExecutiveLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ExecutiveError) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(state.message, style: GoogleFonts.cairo()),
                TextButton(
                  onPressed: () => context.read<ExecutiveBloc>().add(
                        ExecutiveOverviewRequested(state.selection),
                      ),
                  child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                ),
              ],
            ),
          );
        }

        if (state is! ExecutiveLoaded) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChairmanBriefingCard(
              briefing: state.overview.briefing,
              alertCount: state.overview.briefing.totalAlertCount,
            ),
            const SizedBox(height: 14),
            const ExecutiveQuickActions(),
            const SizedBox(height: 18),
            ChairmanTrendsSection(trends: state.overview.trends),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.metric});

  final ChairmanTrendMetricModel metric;

  @override
  Widget build(BuildContext context) {
    if (metric.previousValue == 0 && metric.currentValue == 0) {
      return const SizedBox.shrink();
    }

    final positive = metric.isPositiveTrend;
    final color = positive ? Colors.green.shade700 : Colors.red.shade700;
    final icon = metric.changePercent >= 0
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${metric.changePercent.abs().toStringAsFixed(1)}%',
            style: GoogleFonts.cairo(color: color, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SeverityDot extends StatelessWidget {
  const _SeverityDot({required this.severity});

  final String severity;

  @override
  Widget build(BuildContext context) {
    final color = switch (severity) {
      'critical' => Colors.red.shade300,
      'warning' => Colors.amber.shade200,
      _ => Colors.white.withValues(alpha: 0.7),
    };

    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
