import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/features/activity/data/models/activity_model.dart';
import 'package:waqf_insight/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:waqf_insight/features/activity/presentation/bloc/activity_event.dart';
import 'package:waqf_insight/features/activity/presentation/bloc/activity_state.dart';
import 'package:waqf_insight/features/activity/presentation/utils/activity_ui_utils.dart';

class RecentActivityPage extends StatelessWidget {
  const RecentActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ActivityBloc>()..add(const ActivityLoadRequested()),
      child: const _RecentActivityView(),
    );
  }
}

class _RecentActivityView extends StatelessWidget {
  const _RecentActivityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سجل العمليات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, state) {
          if (state is ActivityLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ActivityError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: GoogleFonts.cairo()),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<ActivityBloc>().add(
                          const ActivityLoadRequested(),
                        ),
                    child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            );
          }

          if (state is! ActivityLoaded) return const SizedBox.shrink();

          final modules = state.allItems
              .map((e) => e.moduleLabel)
              .toSet()
              .toList()
            ..sort();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ActivityBloc>().add(const ActivityRefreshRequested());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _ActivitySummaryBanner(count: state.allItems.length),
                  ),
                ),
                if (modules.length > 1)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: FilterChip(
                                selected: state.selectedModule == null,
                                label: Text('الكل', style: GoogleFonts.cairo(fontSize: 12)),
                                onSelected: (_) => context.read<ActivityBloc>().add(
                                      const ActivityModuleFilterChanged(null),
                                    ),
                              ),
                            ),
                            for (final module in modules)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(end: 8),
                                child: FilterChip(
                                  selected: state.selectedModule == module,
                                  label: Text(module, style: GoogleFonts.cairo(fontSize: 12)),
                                  onSelected: (_) => context.read<ActivityBloc>().add(
                                        ActivityModuleFilterChanged(module),
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (state.filteredItems.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'لا توجد عمليات مسجّلة',
                        style: GoogleFonts.cairo(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: state.filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _ActivityTile(item: state.filteredItems[index]);
                      },
                    ),
                  ),
                if (state.hasMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: state.isLoadingMore
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () => context.read<ActivityBloc>().add(
                                    const ActivityLoadMoreRequested(),
                                  ),
                              icon: const Icon(Icons.expand_more_rounded),
                              label: Text(
                                'تحميل 20 عملية أخرى',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActivitySummaryBanner extends StatelessWidget {
  const _ActivitySummaryBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4527A0), Color(0xFF6A1B9A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.history_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'آخر العمليات في النظام',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$count عملية محمّلة',
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
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});

  final ActivityModel item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = activityActionColor(item.action, colorScheme);

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                activityActionIcon(item.action),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.displayText,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        formatRelativeTimeAr(item.performedAt),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _Tag(label: item.actionLabel, color: color),
                      _Tag(
                        label: item.moduleLabel,
                        color: colorScheme.primary,
                      ),
                      if (item.entityTypeLabel != '—')
                        _Tag(
                          label: item.entityTypeLabel,
                          color: colorScheme.secondary,
                        ),
                    ],
                  ),
                  if (item.userName != null && item.userName!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.userName!,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: colorScheme.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
