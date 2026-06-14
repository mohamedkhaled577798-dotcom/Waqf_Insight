import 'package:flutter/material.dart';
import 'package:waqf_insight/features/filters/presentation/widgets/geo_filter_sheet.dart';

/// @deprecated Use [GeoFilterBar] + [showGeoFilterSheet] instead.
class GeoFilterPanel extends StatelessWidget {
  const GeoFilterPanel({super.key});

  @override
  Widget build(BuildContext context) => const GeoFilterBar();
}
