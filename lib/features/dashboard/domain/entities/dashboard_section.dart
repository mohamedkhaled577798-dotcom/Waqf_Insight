import 'package:equatable/equatable.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

enum DashboardSectionType {
  properties('الأملاك', 'properties'),
  contracts('العقود والتحصيل', 'contracts'),
  revenue('الإيرادات', 'revenue'),
  tenants('المستأجرون', 'tenants'),
  investors('المستثمرون', 'investors'),
  partners('الشركاء', 'partners'),
  mutawallis('المتولون', 'mutawallis'),
  modules('التشغيل', 'modules'),
  staff('الموظفون', 'staff');

  const DashboardSectionType(this.title, this.apiKey);
  final String title;
  final String apiKey;

  static DashboardSectionType? fromTitle(String title) {
    for (final section in values) {
      if (section.title == title) return section;
    }
    return null;
  }
}

class DashboardSectionArgs extends Equatable {
  const DashboardSectionArgs({
    required this.section,
    this.selection = const GeoSelection(),
  });

  final DashboardSectionType section;
  final GeoSelection selection;

  @override
  List<Object?> get props => [section, selection];
}

class GeoMapArgs extends Equatable {
  const GeoMapArgs({
    this.selection = const GeoSelection(),
    this.focusPropertyId,
  });

  final GeoSelection selection;
  final String? focusPropertyId;

  @override
  List<Object?> get props => [selection, focusPropertyId];
}

class PropertyDetailArgs extends Equatable {
  const PropertyDetailArgs({required this.propertyId});

  final String propertyId;

  @override
  List<Object?> get props => [propertyId];
}
