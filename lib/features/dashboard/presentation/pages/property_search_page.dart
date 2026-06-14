import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/core/utils/format_helpers.dart';
import 'package:waqf_insight/core/utils/map_launcher.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_map_models.dart';
import 'package:waqf_insight/features/dashboard/domain/entities/dashboard_section.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/property_list_bloc.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/property_list_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/property_list_state.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';
import 'package:waqf_insight/features/filters/presentation/widgets/geo_filter_sheet.dart';

class PropertySearchPage extends StatelessWidget {
  const PropertySearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = context.read<FiltersBloc>().state;
    final selection =
        filters is FiltersLoaded ? filters.selection : const GeoSelection();

    return BlocProvider(
      create: (_) => sl<PropertyListBloc>()
        ..add(PropertyListLoadRequested(selection: selection)),
      child: const _PropertySearchView(),
    );
  }
}

class _PropertySearchView extends StatefulWidget {
  const _PropertySearchView();

  @override
  State<_PropertySearchView> createState() => _PropertySearchViewState();
}

class _PropertySearchViewState extends State<_PropertySearchView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PropertyListBloc>().add(const PropertyListLoadMoreRequested());
    }
  }

  void _submitSearch(String value) {
    context.read<PropertyListBloc>().add(PropertyListSearchSubmitted(value.trim()));
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () => _submitSearch(value));
  }

  GeoSelection _currentSelection() {
    final filters = context.read<FiltersBloc>().state;
    if (filters is FiltersLoaded) return filters.selection;
    return const GeoSelection();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<FiltersBloc, FiltersState>(
      listener: (context, state) {
        if (state is FiltersLoaded && !state.isRefreshingLevel) {
          context.read<PropertyListBloc>().add(
                PropertyListFilterChanged(state.selection),
              );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'بحث الأملاك',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: GeoFilterBar(padding: EdgeInsets.zero),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SearchBar(
                controller: _searchController,
                hintText: 'ابحث بالاسم أو رمز WSI أو العنوان...',
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _submitSearch('');
                      },
                    ),
                ],
                onChanged: _onSearchChanged,
                onSubmitted: _submitSearch,
              ),
            ),
            Expanded(
              child: BlocBuilder<PropertyListBloc, PropertyListState>(
                builder: (context, state) {
                  if (state is PropertyListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PropertyListError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message, style: GoogleFonts.cairo()),
                          FilledButton(
                            onPressed: () => context.read<PropertyListBloc>().add(
                                  PropertyListLoadRequested(
                                    selection: state.selection,
                                    search: state.search,
                                  ),
                                ),
                            child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is! PropertyListLoaded) {
                    return const SizedBox.shrink();
                  }

                  if (state.items.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد نتائج',
                        style: GoogleFonts.cairo(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PropertyListBloc>().add(
                            PropertyListLoadRequested(
                              selection: _currentSelection(),
                              search: state.search,
                            ),
                          );
                    },
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: state.items.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index == state.items.length) {
                          if (state.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (!state.hasMore) {
                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                'عرض ${state.items.length} من ${state.totalCount}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                                ),
                              ),
                            );
                          }
                          return const SizedBox(height: 8);
                        }

                        return _PropertyListTile(
                          item: state.items[index],
                          selection: state.selection,
                        );
                      },
                    ),
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

class _PropertyListTile extends StatelessWidget {
  const _PropertyListTile({
    required this.item,
    required this.selection,
  });

  final PropertyListItemModel item;
  final GeoSelection selection;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.propertyDetail,
          arguments: PropertyDetailArgs(propertyId: item.id),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.domain_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          item.wsiCode,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.locationLabel,
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (item.propertyType != null)
                    _Badge(label: item.propertyType!, color: colorScheme.primary),
                  if (item.usageStatus != null)
                    _Badge(label: item.usageStatus!, color: colorScheme.tertiary),
                  if (item.hasGps)
                    _Badge(label: 'GPS', color: Colors.green.shade700),
                  if (item.hasDeed) _Badge(label: 'سند', color: const Color(0xFFD5A069)),
                  if (item.estimatedValue != null)
                    _Badge(
                      label: '${formatIraqiCurrency(item.estimatedValue!)} د.ع',
                      color: colorScheme.secondary,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRouter.propertyDetail,
                      arguments: PropertyDetailArgs(propertyId: item.id),
                    ),
                    icon: const Icon(Icons.info_outline_rounded, size: 18),
                    label: Text('التفاصيل', style: GoogleFonts.cairo()),
                  ),
                  if (item.hasGps && item.latitude != null && item.longitude != null) ...[
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRouter.geoMap,
                        arguments: GeoMapArgs(
                          selection: selection,
                          focusPropertyId: item.id,
                        ),
                      ),
                      icon: const Icon(Icons.map_rounded, size: 18),
                      label: Text('الخريطة', style: GoogleFonts.cairo()),
                    ),
                    TextButton.icon(
                      onPressed: () => MapLauncher.openDirections(
                        latitude: item.latitude!,
                        longitude: item.longitude!,
                        label: item.name,
                      ),
                      icon: const Icon(Icons.directions_rounded, size: 18),
                      label: Text('الاتجاهات', style: GoogleFonts.cairo()),
                    ),
                  ],
                ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
