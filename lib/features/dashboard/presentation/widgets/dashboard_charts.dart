import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/core/theme/chart_colors.dart';
import 'package:waqf_insight/core/utils/format_helpers.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';

class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final padding = width < 360 ? 14.0 : 18.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class MetricHighlightCard extends StatelessWidget {
  const MetricHighlightCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final valueSize = width < 360 ? 16.0 : width < 420 ? 18.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(width < 360 ? 12 : 14),
      constraints: const BoxConstraints(minHeight: 96),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.72)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.9),
            size: width < 360 ? 22 : 24,
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: valueSize,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 10,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: width < 360 ? 11 : 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class GpsGaugeChart extends StatelessWidget {
  const GpsGaugeChart({
    super.key,
    required this.percent,
    this.title = 'تغطية GPS',
    this.subtitle = 'نسبة الأملاك ذات الإحداثيات',
    this.centerLabel = 'تغطية',
  });

  final double percent;
  final String title;
  final String subtitle;
  final String centerLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final clamped = percent.clamp(0.0, 100.0);
    final width = MediaQuery.sizeOf(context).width;
    final chartHeight = width < 360 ? 150.0 : width < 420 ? 165.0 : 180.0;
    final centerRadius = width < 360 ? 46.0 : width < 420 ? 52.0 : 58.0;
    final sectionRadius = width < 360 ? 18.0 : 22.0;
    final percentSize = width < 360 ? 22.0 : 26.0;

    return ChartCard(
      title: title,
      subtitle: subtitle,
      child: SizedBox(
        height: chartHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 0,
                centerSpaceRadius: centerRadius,
                sections: [
                  PieChartSectionData(
                    value: clamped,
                    color: colorScheme.primary,
                    radius: sectionRadius,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 100 - clamped,
                    color: colorScheme.surfaceContainerHighest,
                    radius: sectionRadius,
                    showTitle: false,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatPercent(clamped),
                    style: GoogleFonts.cairo(
                      fontSize: percentSize,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Text(
                  centerLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DistributionPieChart extends StatelessWidget {
  const DistributionPieChart({
    super.key,
    required this.title,
    required this.slices,
  });

  final String title;
  final List<DistributionSliceModel> slices;

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) return const SizedBox.shrink();

    final total = slices.fold<int>(0, (s, e) => s + e.value);
    final top = slices.take(6).toList();
    final width = MediaQuery.sizeOf(context).width;
    final chartHeight = width < 360 ? 160.0 : 190.0;
    final sectionRadius = width < 360 ? 42.0 : 52.0;
    final centerRadius = width < 360 ? 28.0 : 36.0;

    return ChartCard(
      title: title,
      subtitle: 'إجمالي $total',
      child: Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: centerRadius,
                sections: [
                  for (var i = 0; i < top.length; i++)
                    PieChartSectionData(
                      value: top[i].value.toDouble(),
                      title: '${top[i].effectivePercent(total).toStringAsFixed(0)}%',
                      titleStyle: GoogleFonts.cairo(
                        fontSize: width < 360 ? 9 : 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      color: ChartColors.at(i),
                      radius: sectionRadius,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < top.length; i++)
                _LegendChip(
                  color: ChartColors.at(i),
                  label: top[i].label,
                  value: top[i].value,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class DistributionBarChart extends StatelessWidget {
  const DistributionBarChart({
    super.key,
    required this.title,
    required this.slices,
  });

  final String title;
  final List<DistributionSliceModel> slices;

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) return const SizedBox.shrink();

    final top = slices.take(8).toList();
    final maxVal = top.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return ChartCard(
      title: title,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 400) {
            return _HorizontalBarList(slices: top, maxVal: maxVal);
          }

          return SizedBox(
            height: 36.0 * top.length + 24,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal <= 0 ? 1 : maxVal * 1.15,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= top.length) {
                          return const SizedBox.shrink();
                        }
                        final label = top[index].label;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label.length > 10 ? '${label.substring(0, 10)}…' : label,
                            style: GoogleFonts.cairo(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < top.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: top[i].value.toDouble(),
                          color: ChartColors.at(i),
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalBarList extends StatelessWidget {
  const _HorizontalBarList({
    required this.slices,
    required this.maxVal,
  });

  final List<DistributionSliceModel> slices;
  final int maxVal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (var i = 0; i < slices.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      slices[i].label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${slices[i].value}',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ChartColors.at(i),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: maxVal <= 0 ? 0 : slices[i].value / maxVal,
                  minHeight: 10,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: ChartColors.at(i),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label · $value',
            style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

List<DistributionSliceModel> distributionFromAmounts(
  Iterable<({String label, double amount})> items,
) {
  final list = items.toList();
  final total = list.fold<double>(0, (sum, e) => sum + e.amount);
  return [
    for (final item in list)
      DistributionSliceModel(
        label: item.label,
        value: item.amount.round(),
        percent: total > 0 ? (item.amount / total) * 100 : 0,
      ),
  ];
}

List<DistributionSliceModel> distributionFromOverdueBuckets(
  List<OverdueBucketModel> buckets,
) {
  return distributionFromAmounts(
    buckets.map((b) => (label: b.bucketName, amount: b.totalAmount)),
  );
}

List<DistributionSliceModel> distributionFromRevenueSources(
  List<RevenueSourceModel> sources,
) {
  return distributionFromAmounts(
    sources.map((s) => (label: s.label, amount: s.amount)),
  );
}

List<DistributionSliceModel> distributionFromRevenueGovernorates(
  List<RevenueByGovernorateModel> rows,
) {
  return distributionFromAmounts(
    rows.map((g) => (label: g.governorateName, amount: g.totalCollected)),
  );
}
