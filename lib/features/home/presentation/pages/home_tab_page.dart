import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/constants/org_branding.dart';
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
    return BlocListener<FiltersBloc, FiltersState>(
      listener: (context, state) {
        if (state is FiltersLoaded) {
          _reloadDashboard(context, state);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            OrgBranding.authoritySubtitle,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.3,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'الفلتر الجغرافي',
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => showGeoFilterSheet(context),
            ),
            IconButton(
              tooltip: 'الخريطة',
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const GeoFilterBar(),
                const SizedBox(height: 14),
                const DashboardKpiSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
