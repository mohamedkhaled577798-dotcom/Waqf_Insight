import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/constants/org_branding.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/executive_bloc.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/executive_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/dashboard_kpi_section.dart';
import 'package:waqf_insight/features/dashboard/presentation/widgets/executive_overview_widgets.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';
import 'package:waqf_insight/features/filters/presentation/widgets/geo_filter_sheet.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DashboardBloc>()),
        BlocProvider(create: (_) => sl<ExecutiveBloc>()),
      ],
      child: const _HomeTabContent(),
    );
  }
}

class _HomeTabContent extends StatefulWidget {
  const _HomeTabContent();

  @override
  State<_HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<_HomeTabContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadAll());
  }

  void _reloadAll() {
    final filters = context.read<FiltersBloc>().state;
    if (filters is! FiltersLoaded || filters.isRefreshingLevel) return;

    context.read<DashboardBloc>().add(DashboardSummaryRequested(filters.selection));
    context.read<ExecutiveBloc>().add(ExecutiveOverviewRequested(filters.selection));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FiltersBloc, FiltersState>(
      listener: (context, state) {
        if (state is FiltersLoaded) {
          _reloadAll();
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
              tooltip: 'تنبيهات الرئيس',
              icon: const Icon(Icons.notifications_active_outlined),
              onPressed: () => Navigator.pushNamed(context, AppRouter.chairmanAlerts),
            ),
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
          onRefresh: () async => _reloadAll(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const GeoFilterBar(),
                const SizedBox(height: 14),
                const ExecutiveOverviewSection(),
                const SizedBox(height: 18),
                const DashboardKpiSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
