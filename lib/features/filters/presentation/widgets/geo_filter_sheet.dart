import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_option.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_event.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';

/// Opens the shared geo filter bottom sheet used across the app.
Future<void> showGeoFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => BlocProvider.value(
      value: context.read<FiltersBloc>(),
      child: const _GeoFilterSheet(),
    ),
  );
}

class GeoFilterBar extends StatelessWidget {
  const GeoFilterBar({super.key, this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiltersBloc, FiltersState>(
      builder: (context, state) {
        if (state is FiltersLoading) {
          return Padding(
            padding: padding ?? EdgeInsets.zero,
            child: const LinearProgressIndicator(minHeight: 3),
          );
        }

        if (state is FiltersError) {
          return Padding(
            padding: padding ?? const EdgeInsets.all(12),
            child: Text(state.message, style: GoogleFonts.cairo()),
          );
        }

        if (state is! FiltersLoaded) return const SizedBox.shrink();

        final colorScheme = Theme.of(context).colorScheme;
        final hasFilter = state.appliedFilter.hasAnyFilter;

        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Material(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => showGeoFilterSheet(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الفلتر الجغرافي',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: colorScheme.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                          Text(
                            state.filterChipLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasFilter)
                      IconButton(
                        tooltip: 'مسح',
                        onPressed: () => context
                            .read<FiltersBloc>()
                            .add(const FiltersReset()),
                        icon: Icon(
                          Icons.filter_alt_off_rounded,
                          color: colorScheme.error,
                          size: 22,
                        ),
                      ),
                    Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GeoFilterSheet extends StatelessWidget {
  const _GeoFilterSheet();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      margin: const EdgeInsets.only(top: 48),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'فلترة الموقع',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                BlocBuilder<FiltersBloc, FiltersState>(
                  builder: (context, state) {
                    if (state is! FiltersLoaded || !state.appliedFilter.hasAnyFilter) {
                      return const SizedBox.shrink();
                    }
                    return TextButton(
                      onPressed: () {
                        context.read<FiltersBloc>().add(const FiltersReset());
                      },
                      child: Text('مسح الكل', style: GoogleFonts.cairo()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'اختر المحافظة ثم القضاء والناحية والحي — أدق مستوى محدّد هو الذي يُطبَّق',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.5,
              ),
              child: const SingleChildScrollView(
                child: GeoFilterForm(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text('تطبيق الفلتر', style: GoogleFonts.cairo()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cascade dropdowns — used inside the filter sheet.
class GeoFilterForm extends StatelessWidget {
  const GeoFilterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiltersBloc, FiltersState>(
      builder: (context, state) {
        if (state is FiltersLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is FiltersError) {
          return Column(
            children: [
              Text(state.message, style: GoogleFonts.cairo()),
              TextButton(
                onPressed: () =>
                    context.read<FiltersBloc>().add(const FiltersInitialized()),
                child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
              ),
            ],
          );
        }

        if (state is! FiltersLoaded) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GeoDropdown(
              label: 'المحافظة',
              hint: 'كل العراق',
              value: state.selection.governorateId,
              options: state.governorates,
              enabled: !state.isRefreshingLevel,
              onChanged: (id) =>
                  context.read<FiltersBloc>().add(GovernorateSelected(id)),
            ),
            const SizedBox(height: 14),
            _GeoDropdown(
              label: 'القضاء',
              hint: 'كل المحافظة',
              value: state.selection.districtId,
              options: state.districts,
              enabled: state.selection.governorateId != null &&
                  !state.isRefreshingLevel,
              onChanged: (id) =>
                  context.read<FiltersBloc>().add(DistrictSelected(id)),
            ),
            const SizedBox(height: 14),
            _GeoDropdown(
              label: 'الناحية',
              hint: 'كل القضاء',
              value: state.selection.subdistrictId,
              options: state.subdistricts,
              enabled:
                  state.selection.districtId != null && !state.isRefreshingLevel,
              onChanged: (id) =>
                  context.read<FiltersBloc>().add(SubdistrictSelected(id)),
            ),
            const SizedBox(height: 14),
            _GeoDropdown(
              label: 'الحي',
              hint: 'كل الناحية',
              value: state.selection.neighborhoodId,
              options: state.neighborhoods,
              enabled: state.selection.subdistrictId != null &&
                  !state.isRefreshingLevel,
              onChanged: (id) =>
                  context.read<FiltersBloc>().add(NeighborhoodSelected(id)),
            ),
            if (state.isRefreshingLevel) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(minHeight: 2),
            ],
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: GoogleFonts.cairo(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _GeoDropdown extends StatelessWidget {
  const _GeoDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final List<GeoOption> options;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(),
        filled: true,
        fillColor: enabled
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: GoogleFonts.cairo()),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(hint, style: GoogleFonts.cairo()),
            ),
            ...options.map(
              (option) => DropdownMenuItem<String?>(
                value: option.id,
                child: Text(option.displayLabel, style: GoogleFonts.cairo()),
              ),
            ),
          ],
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}
