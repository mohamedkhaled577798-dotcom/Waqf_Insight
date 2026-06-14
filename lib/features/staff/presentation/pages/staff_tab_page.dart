import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/core/utils/contact_launcher.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/staff/data/models/staff_models.dart';
import 'package:waqf_insight/features/staff/domain/entities/staff_detail_args.dart';
import 'package:waqf_insight/features/staff/presentation/bloc/staff_list_bloc.dart';
import 'package:waqf_insight/features/staff/presentation/bloc/staff_list_event.dart';
import 'package:waqf_insight/features/staff/presentation/bloc/staff_list_state.dart';

Future<void> _runContactAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$e', style: GoogleFonts.cairo())),
    );
  }
}

class StaffTabPage extends StatelessWidget {
  const StaffTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StaffListBloc>()..add(const StaffListLoadRequested()),
      child: const _StaffTabContent(),
    );
  }
}

class _StaffTabContent extends StatefulWidget {
  const _StaffTabContent();

  @override
  State<_StaffTabContent> createState() => _StaffTabContentState();
}

class _StaffTabContentState extends State<_StaffTabContent> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => context.read<StaffListBloc>().add(StaffListSearchSubmitted(value.trim())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('الموظفون', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<StaffListBloc, StaffListState>(
        builder: (context, state) {
          if (state is StaffListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StaffListError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: GoogleFonts.cairo()),
                  FilledButton(
                    onPressed: () => context.read<StaffListBloc>().add(
                          const StaffListLoadRequested(),
                        ),
                    child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            );
          }

          if (state is! StaffListLoaded) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<StaffListBloc>().add(
                    StaffListLoadRequested(search: state.search),
                  );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _OverviewStrip(overview: state.overview),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: SearchBar(
                      constraints: const BoxConstraints(minHeight: 48, maxHeight: 48),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 12),
                      ),
                      controller: _searchController,
                      hintText: 'ابحث بالاسم، القسم، الوظيفة، الهاتف...',
                      hintStyle: WidgetStatePropertyAll(
                        GoogleFonts.cairo(fontSize: 13),
                      ),
                      textStyle: WidgetStatePropertyAll(
                        GoogleFonts.cairo(fontSize: 14),
                      ),
                      leading: const Icon(Icons.search_rounded, size: 22),
                      trailing: _searchController.text.isNotEmpty
                          ? [
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<StaffListBloc>().add(
                                        const StaffListSearchSubmitted(''),
                                      );
                                },
                              ),
                            ]
                          : null,
                      onChanged: _onSearchChanged,
                      onSubmitted: (v) => context.read<StaffListBloc>().add(
                            StaffListSearchSubmitted(v.trim()),
                          ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: _StaffTypeFilters(
                      typeFilter: state.typeFilter,
                      activeOnly: state.activeOnly,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  sliver: state.filteredMembers.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'لا يوجد موظفون',
                              style: GoogleFonts.cairo(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        )
                      : SliverList.separated(
                          itemCount: state.filteredMembers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _StaffCard(member: state.filteredMembers[index]);
                          },
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

class _OverviewStrip extends StatelessWidget {
  const _OverviewStrip({required this.overview});

  final StaffOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatChip(
              label: 'الموظفون',
              value: '${overview.totalEmployees}',
              icon: Icons.groups_rounded,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              label: 'المفتشون',
              value: '${overview.totalInspectors}',
              icon: Icons.fact_check_rounded,
              color: colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              label: 'نشطون',
              value: '${overview.activeUsers}',
              icon: Icons.verified_user_rounded,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffTypeFilters extends StatelessWidget {
  const _StaffTypeFilters({
    required this.typeFilter,
    required this.activeOnly,
  });

  final String? typeFilter;
  final bool activeOnly;

  static const _typeFilters = ['', 'موظف', 'مفتش', 'مقاول'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < _typeFilters.length; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(start: i == 0 ? 0 : 8),
              child: _StaffFilterChip(
                label: _typeFilters[i].isEmpty ? 'الكل' : _typeFilters[i],
                selected: (typeFilter ?? '') == _typeFilters[i],
                onSelected: () {
                  context.read<StaffListBloc>().add(
                        StaffListTypeFilterChanged(
                          _typeFilters[i].isEmpty ? null : _typeFilters[i],
                        ),
                      );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: _StaffFilterChip(
              label: 'نشط فقط',
              selected: activeOnly,
              icon: Icons.check_circle_outline,
              onSelected: () {
                context.read<StaffListBloc>().add(
                      StaffListActiveFilterChanged(!activeOnly),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffFilterChip extends StatelessWidget {
  const _StaffFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      avatar: icon != null
          ? Icon(
              icon,
              size: 15,
              color: selected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
            )
          : null,
      label: Text(
        label,
        style: GoogleFonts.cairo(fontSize: 12, height: 1.1),
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.75)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              height: 1.1,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 10,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.member});

  final StaffMemberModel member;

  Color _typeColor(String type, ColorScheme scheme) {
    return switch (type) {
      'مفتش' => scheme.tertiary,
      'مقاول' => const Color(0xFFD5A069),
      _ => scheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = _typeColor(member.staffType, colorScheme);

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (member.userId.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تعذّر فتح التفاصيل — معرّف الموظف غير متوفر',
                  style: GoogleFonts.cairo(),
                ),
              ),
            );
            return;
          }
          Navigator.pushNamed(
            context,
            AppRouter.staffDetail,
            arguments: StaffDetailArgs(
              userId: member.userId,
              preview: member,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: typeColor.withValues(alpha: 0.15),
                child: Text(
                  member.initials,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w800,
                    color: typeColor,
                    fontSize: 18,
                  ),
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
                            member.fullName,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        _Badge(label: member.staffType, color: typeColor),
                        if (!member.isActive) ...[
                          const SizedBox(width: 6),
                          _Badge(label: 'غير نشط', color: colorScheme.error),
                        ],
                      ],
                    ),
                    if (member.jobTitle != null)
                      Text(
                        member.jobTitle!,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    if (member.department != null)
                      Text(
                        member.department!,
                        style: GoogleFonts.cairo(fontSize: 11),
                      ),
                    if (member.responsibilities.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: member.responsibilities.take(3).map(
                          (r) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              r,
                              style: GoogleFonts.cairo(fontSize: 10),
                            ),
                          ),
                        ).toList(),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (member.phone != null && member.phone!.isNotEmpty)
                          _ContactIcon(
                            icon: Icons.chat_rounded,
                            color: const Color(0xFF25D366),
                            tooltip: 'واتساب',
                            onTap: () => _runContactAction(
                              context,
                              () => ContactLauncher.openWhatsApp(
                                member.phone!,
                                message: 'السلام عليكم ${member.fullName}',
                              ),
                            ),
                          ),
                        if (member.email != null && member.email!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _ContactIcon(
                            icon: Icons.email_outlined,
                            color: colorScheme.primary,
                            tooltip: 'بريد',
                            onTap: () => _runContactAction(
                              context,
                              () => ContactLauncher.openEmail(member.email!),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          'التفاصيل',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _ContactIcon extends StatelessWidget {
  const _ContactIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
