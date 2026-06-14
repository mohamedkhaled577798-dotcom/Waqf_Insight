import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/core/utils/format_helpers.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardKpiSection extends StatelessWidget {
  const DashboardKpiSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const _DashboardLoading();
        }

        if (state is DashboardError) {
          return _DashboardError(
            message: state.message,
            onRetry: () => context.read<DashboardBloc>().add(
              DashboardSummaryRequested(state.selection),
            ),
          );
        }

        if (state is DashboardLoaded) {
          return _DashboardContent(
            summary: state.summary,
            generatedAt: state.generatedAt,
            selection: state.selection,
          );
        }

        return const _DashboardLoading();
      },
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(child: _ShimmerCard(colorScheme: colorScheme)),
              const SizedBox(width: 12),
              Expanded(child: _ShimmerCard(colorScheme: colorScheme)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(color: colorScheme.error),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final p = summary.properties;
    final c = summary.contracts;
    final r = summary.revenue;
    final t = summary.tenants;
    final i = summary.investors;
    final pt = summary.partners;
    final m = summary.mutawallis;
    final mod = summary.modules;
    final s = summary.staff;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (generatedAt != null) ...[
          Text(
            'آخر تحديث: ${_formatGeneratedAt(generatedAt!)}',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 12),
        ],
        _SectionTitle(
          title: 'الأملاك',
          colorScheme: colorScheme,
          onTap: () => _openSection(context, DashboardSectionType.properties),
        ),
        const SizedBox(height: 8),
        _KpiRow(
          cards: [
            _KpiCardData(
              icon: Icons.home_work_rounded,
              label: 'إجمالي الأملاك',
              value: '${p.totalProperties}',
              color: colorScheme.primary,
            ),
            _KpiCardData(
              icon: Icons.gps_fixed_rounded,
              label: 'تغطية GPS',
              value: formatPercent(p.gpsCoveragePercent),
              color: colorScheme.tertiary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _KpiRow(
          cards: [
            _KpiCardData(
              icon: Icons.payments_rounded,
              label: 'القيمة التقديرية',
              value: formatIraqiCurrency(p.totalEstimatedValue),
              subtitle: 'د.ع',
              color: colorScheme.secondary,
            ),
            _KpiCardData(
              icon: Icons.key_rounded,
              label: 'مؤجرة / شاغرة',
              value: '${p.rentedCount} / ${p.vacantCount}',
              color: colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle(
          title: 'العقود والتحصيل',
          colorScheme: colorScheme,
          onTap: () => _openSection(context, DashboardSectionType.contracts),
        ),
        const SizedBox(height: 8),
        _KpiRow(
          cards: [
            _KpiCardData(
              icon: Icons.description_rounded,
              label: 'عقود نشطة',
              value: '${c.activeContracts}',
              color: colorScheme.primary,
            ),
            _KpiCardData(
              icon: Icons.hotel_rounded,
              label: 'نسبة الإشغال',
              value: formatPercent(c.occupancyRatePercent),
              color: colorScheme.tertiary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _KpiRow(
          cards: [
            _KpiCardData(
              icon: Icons.calendar_today_rounded,
              label: 'تنتهي قريباً',
              value: '${c.expiringSoonContracts}',
              color: Colors.orange,
            ),
            _KpiCardData(
              icon: Icons.warning_amber_rounded,
              label: 'متأخرات',
              value: formatIraqiCurrency(c.totalOverdueAmount),
              subtitle: 'د.ع',
              color: colorScheme.error,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle(
          title: 'الإيرادات',
          colorScheme: colorScheme,
          onTap: () => _openSection(context, DashboardSectionType.revenue),
        ),
        const SizedBox(height: 8),
        _KpiRow(
          cards: [
            _KpiCardData(
              icon: Icons.account_balance_wallet_rounded,
              label: 'إجمالي الإيراد',
              value: formatIraqiCurrency(r.totalGrossRevenue),
              subtitle: 'د.ع',
              color: colorScheme.secondary,
            ),
            _KpiCardData(
              icon: Icons.percent_rounded,
              label: 'تحصيل الإيجار',
              value: formatPercent(r.rentalCollectionRatePercent),
              color: colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle(
          title: 'المستأجرون',
          colorScheme: colorScheme,
          onTap: () => _openSection(context, DashboardSectionType.tenants),
        ),
        const SizedBox(height: 8),
        _KpiRow(
          cards: [
            _KpiCardData(
              icon: Icons.people_rounded,
              label: 'المستأجرون',
              value: '${t.totalTenants}',
              color: colorScheme.primary,
            ),
            _KpiCardData(
              icon: Icons.business_center_rounded,
              label: 'المستثمرون',
              value: '${i.totalInvestors}',
              color: colorScheme.secondary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _SectionTitle(
          title: 'المستثمرون',
          colorScheme: colorScheme,
          onTap: () => _openSection(context, DashboardSectionType.investors),
        ),
        const SizedBox(height: 8),
        _KpiRow(
          cards: [
            _KpiCardData(
              icon: Icons.handshake_rounded,
              label: 'الشركاء',
              value: '${pt.totalPartners}',
              color: colorScheme.tertiary,
            ),
            _KpiCardData(
              icon: Icons.manage_accounts_rounded,
              label: 'المتولون',
              value: '${m.totalMutawallis}',
              color: colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _SectionTitle(
          title: 'الشركاء',
          colorScheme: colorScheme,
          onTap: () => _openSection(context, DashboardSectionType.partners),
        ),
        const SizedBox(height: 8),
        _SectionTitle(
          title: 'المتولون',
          colorScheme: colorScheme,
          onTap: () => _openSection(context, DashboardSectionType.mutawallis),
        ),
        const SizedBox(height: 20),
        _SectionTitle(
          title: 'التشغيل',
          colorScheme: colorScheme,
          onTap: () => _openSection(context, DashboardSectionType.modules),
        ),
        const SizedBox(height: 8),
        _KpiRow(
          cards: [
            _KpiCardData(
              icon: Icons.gavel_rounded,
              label: 'قضايا نشطة',
              value: '${mod.activeCases}',
              color: colorScheme.primary,
            ),
            _KpiCardData(
              icon: Icons.build_rounded,
              label: 'صيانة معلّقة',
              value: '${mod.pendingMaintenanceRequests}',
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _KpiRow(
          cards: [
            _KpiCardData(
              icon: Icons.apartment_rounded,
              label: 'مشاريع نشطة',
              value: '${mod.activeProjects}',
              color: colorScheme.secondary,
            ),
            _KpiCardData(
              icon: Icons.pending_actions_rounded,
              label: 'موافقات معلّقة',
              value: '${mod.pendingApprovals}',
              color: colorScheme.error,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle(
          title: 'الموظفون',
          colorScheme: colorScheme,
          onTap: () => _openSection(context, DashboardSectionType.staff),
        ),
        const SizedBox(height: 8),
        _KpiRow(
          cards: [
            _KpiCardData(
              icon: Icons.badge_rounded,
              label: 'الموظفون',
              value: '${s.totalEmployees}',
              color: colorScheme.primary,
            ),
            _KpiCardData(
              icon: Icons.person_rounded,
              label: 'مستخدمون نشطون',
              value: '${s.activeUsers}',
              color: colorScheme.tertiary,
            ),
          ],
        ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.colorScheme,
    this.onTap,
  });

  final String title;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.chevron_left_rounded,
            color: colorScheme.primary,
          ),
      ],
    );

    if (onTap == null) return child;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: child,
      ),
    );
  }
}

class _KpiCardData {
  const _KpiCardData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.cards});

  final List<_KpiCardData> cards;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(child: _KpiCard(data: cards[index])),
        ],
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});

  final _KpiCardData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            data.color.withValues(alpha: 0.08),
            colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: data.color, size: 24),
          const SizedBox(height: 10),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          if (data.subtitle != null)
            Text(
              data.subtitle!,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          Text(
            data.label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
