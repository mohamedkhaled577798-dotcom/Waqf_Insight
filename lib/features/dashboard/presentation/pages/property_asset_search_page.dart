import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waqf_insight/config/routes/app_router.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_asset_models.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/property_asset_list_bloc.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/property_asset_list_event.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/property_asset_list_state.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_state.dart';
import 'package:waqf_insight/features/filters/presentation/widgets/geo_filter_sheet.dart';

class PropertyAssetSearchPage extends StatelessWidget {
  const PropertyAssetSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = context.read<FiltersBloc>().state;
    final selection = filters is FiltersLoaded ? filters.selection : const GeoSelection();

    return BlocProvider(
      create: (_) => sl<PropertyAssetListBloc>()
        ..add(PropertyAssetListLoadRequested(selection: selection)),
      child: const _PropertyAssetSearchView(),
    );
  }
}

class _PropertyAssetSearchView extends StatefulWidget {
  const _PropertyAssetSearchView();

  @override
  State<_PropertyAssetSearchView> createState() => _PropertyAssetSearchViewState();
}

class _PropertyAssetSearchViewState extends State<_PropertyAssetSearchView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  static const _linkFilters = [
    ('all', 'الكل'),
    ('linked', 'مرتبط'),
    ('unlinked', 'غير مرتبط'),
    ('missing_property', 'عقار غير موجود'),
  ];

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<PropertyAssetListBloc>().add(const PropertyAssetListLoadMoreRequested());
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      context.read<PropertyAssetListBloc>().add(PropertyAssetListSearchSubmitted(value.trim()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FiltersBloc, FiltersState>(
      listener: (context, state) {
        if (state is FiltersLoaded && !state.isRefreshingLevel) {
          context.read<PropertyAssetListBloc>().add(
                PropertyAssetListFilterChanged(state.selection),
              );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('سجل الملوك', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'بحث برقم الملك، الاسم، عق...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: BlocBuilder<PropertyAssetListBloc, PropertyAssetListState>(
              builder: (context, state) {
                final current = state is PropertyAssetListLoaded
                    ? state.linkStatus
                    : state is PropertyAssetListLoading
                        ? state.linkStatus
                        : 'all';
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _linkFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final (value, label) = _linkFilters[index];
                    final selected = current == value;
                    return FilterChip(
                      label: Text(label, style: GoogleFonts.cairo(fontSize: 12)),
                      selected: selected,
                      onSelected: (_) => context
                          .read<PropertyAssetListBloc>()
                          .add(PropertyAssetListLinkStatusChanged(value)),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<PropertyAssetListBloc, PropertyAssetListState>(
              builder: (context, state) {
                if (state is PropertyAssetListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PropertyAssetListError) {
                  return Center(child: Text(state.message, style: GoogleFonts.cairo()));
                }
                if (state is! PropertyAssetListLoaded) {
                  return const SizedBox.shrink();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<PropertyAssetListBloc>().add(
                          PropertyAssetListLoadRequested(
                            selection: state.selection,
                            search: state.search,
                            linkStatus: state.linkStatus,
                          ),
                        );
                  },
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      _SummaryRow(summary: state.summary),
                      const SizedBox(height: 12),
                      ...state.items.map((item) => _AssetTile(item: item)),
                      if (state.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});
  final PropertyAssetSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ChipStat('النتائج', '${summary.totalCount}'),
        _ChipStat('مرتبط', '${summary.linkedCount}'),
        _ChipStat('غير مرتب', '${summary.unlinkedCount}'),
        _ChipStat('عقار ناقص', '${summary.missingPropertyCount}', warn: true),
      ],
    );
  }
}

class _ChipStat extends StatelessWidget {
  const _ChipStat(this.label, this.value, {this.warn = false});
  final String label;
  final String value;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: warn ? Colors.amber.shade50 : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$label: $value', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _AssetTile extends StatelessWidget {
  const _AssetTile({required this.item});
  final PropertyAssetListItemModel item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.propertyAssetDetail,
          arguments: PropertyAssetDetailArgs(assetId: item.id, title: item.assetCode),
        ),
        title: Text(item.assetCode, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.commercialName != null && item.commercialName!.isNotEmpty)
              Text(item.commercialName!, style: GoogleFonts.cairo(fontSize: 12)),
            Text(item.linkLabel, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey.shade700)),
            if (item.usageTypeName != null)
              Text('${item.usageTypeName} • ${item.occupancyStatus}', style: GoogleFonts.cairo(fontSize: 11)),
          ],
        ),
        trailing: item.propertyMissing
            ? const Icon(Icons.warning_amber_rounded, color: Colors.amber)
            : const Icon(Icons.chevron_left),
      ),
    );
  }
}
