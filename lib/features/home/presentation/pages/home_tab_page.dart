import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/dashboard_kpi_section.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';
import 'package:waqf_insight/features/filters/presentation/widgets/geo_filter_sheet.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardBloc>(),
      child: const _HomeTabContent(),
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  const _HomeTabContent();

  void _reloadDashboard(BuildContext context, FiltersLoaded filters) {
    if (filters.isRefreshingLevel) return;
    context.read<DashboardBloc>().add(
          DashboardSummaryRequested(filters.selection),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<FiltersBloc, FiltersState>(
      listener: (context, state) {
        if (state is FiltersLoaded) {
          _reloadDashboard(context, state);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ديوان الوقف السني',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              tooltip: 'التوزيع الجغرافي',
              icon: const Icon(Icons.map_rounded),
              onPressed: () {
                final filters = context.read<FiltersBloc>().state;
                final selection = filters is FiltersLoaded
                    ? filters.selection
                    : const GeoSelection();
                Navigator.pushNamed(
                  context,
                  AppRouter.geoMap,
                  arguments: GeoMapArgs(selection: selection),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            final filters = context.read<FiltersBloc>().state;
            if (filters is FiltersLoaded) {
              context.read<DashboardBloc>().add(
                    DashboardSummaryRequested(filters.selection),
                  );
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const GeoFilterBar(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك',
                        style: GoogleFonts.cairo(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'هيئة إدارة واستثمار\nأموال الوقف السني',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'نظرة سريعة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                const DashboardKpiSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
