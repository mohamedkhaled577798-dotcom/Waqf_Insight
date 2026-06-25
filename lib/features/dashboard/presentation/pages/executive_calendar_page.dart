import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/features/dashboard/data/models/executive_models.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/executive_bloc.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/executive_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/executive_state.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';
import 'package:waqf_insight/features/filters/presentation/widgets/geo_filter_sheet.dart';

class ExecutiveCalendarPage extends StatelessWidget {
  const ExecutiveCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = context.read<FiltersBloc>().state;
    final selection = filters is FiltersLoaded ? filters.selection : const GeoSelection();
    final now = DateTime.now();

    return BlocProvider(
      create: (_) => sl<ExecutiveBloc>()
        ..add(
          ExecutiveCalendarRequested(
            selection: selection,
            year: now.year,
            month: now.month,
          ),
        ),
      child: const _ExecutiveCalendarView(),
    );
  }
}

class _ExecutiveCalendarView extends StatefulWidget {
  const _ExecutiveCalendarView();

  @override
  State<_ExecutiveCalendarView> createState() => _ExecutiveCalendarViewState();
}

class _ExecutiveCalendarViewState extends State<_ExecutiveCalendarView> {
  late DateTime _focusedMonth;

  static const _monthNames = [
    '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  GeoSelection _selection() {
    final filters = context.read<FiltersBloc>().state;
    return filters is FiltersLoaded ? filters.selection : const GeoSelection();
  }

  void _loadMonth() {
    context.read<ExecutiveBloc>().add(
          ExecutiveCalendarRequested(
            selection: _selection(),
            year: _focusedMonth.year,
            month: _focusedMonth.month,
          ),
        );
  }

  void _shiftMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
    _loadMonth();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FiltersBloc, FiltersState>(
      listener: (_, state) {
        if (state is FiltersLoaded && !state.isRefreshingLevel) _loadMonth();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('التقويم التنفيذي', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              onPressed: () => showGeoFilterSheet(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _shiftMonth(-1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                  Text(
                    '${_monthNames[_focusedMonth.month]} ${_focusedMonth.year}',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () => _shiftMonth(1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ExecutiveBloc, ExecutiveState>(
                builder: (context, state) {
                  if (state is ExecutiveCalendarLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ExecutiveCalendarError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message, style: GoogleFonts.cairo()),
                          FilledButton(
                            onPressed: _loadMonth,
                            child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is! ExecutiveCalendarLoaded) {
                    return const SizedBox.shrink();
                  }

                  final events = state.calendar.events;
                  if (events.isEmpty) {
                    return Center(
                      child: Text('لا توجد أحداث في هذا الشهر', style: GoogleFonts.cairo()),
                    );
                  }

                  final grouped = <String, List<ChairmanCalendarEventModel>>{};
                  for (final e in events) {
                    final key = e.date.toString().substring(0, 10);
                    grouped.putIfAbsent(key, () => []).add(e);
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Text(
                              entry.key,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          ...entry.value.map((e) => _EventTile(event: e)),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final ChairmanCalendarEventModel event;

  IconData get _icon => switch (event.eventType) {
        'contract_end' => Icons.description_rounded,
        'court_session' => Icons.gavel_rounded,
        'installment_due' => Icons.payments_rounded,
        'inspection' => Icons.fact_check_outlined,
        'maintenance' => Icons.build_rounded,
        _ => Icons.event_rounded,
      };

  Color _color(BuildContext context) => switch (event.severity) {
        'critical' => Colors.red.shade700,
        'warning' => Colors.orange.shade800,
        _ => Theme.of(context).colorScheme.primary,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(_icon, color: color, size: 20),
        ),
        title: Text(event.title, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13)),
        subtitle: event.subtitle != null
            ? Text(event.subtitle!, style: GoogleFonts.cairo(fontSize: 12))
            : null,
      ),
    );
  }
}
