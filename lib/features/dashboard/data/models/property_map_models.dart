import 'package:waqf_insight/core/utils/json_parse_helpers.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';

class PropertyMapPointModel {
  const PropertyMapPointModel({
    required this.id,
    required this.name,
    required this.wsiCode,
    required this.latitude,
    required this.longitude,
    required this.governorate,
    required this.district,
    required this.subdistrict,
    required this.neighborhood,
    this.legalStatus,
    this.usageStatus,
    this.propertyType,
  });

  final String id;
  final String name;
  final String wsiCode;
  final double latitude;
  final double longitude;
  final String governorate;
  final String district;
  final String subdistrict;
  final String neighborhood;
  final String? legalStatus;
  final String? usageStatus;
  final String? propertyType;

  factory PropertyMapPointModel.fromJson(Map<String, dynamic> json) {
    return PropertyMapPointModel(
      id: '${json['id']}',
      name: json['name'] as String? ?? '',
      wsiCode: json['wsiCode'] as String? ?? '',
      latitude: parseJsonDouble(json['latitude']),
      longitude: parseJsonDouble(json['longitude']),
      governorate: json['governorate'] as String? ?? '',
      district: json['district'] as String? ?? '',
      subdistrict: json['subdistrict'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      legalStatus: json['legalStatus'] as String?,
      usageStatus: json['usageStatus'] as String?,
      propertyType: json['propertyType'] as String?,
    );
  }

  String get locationLabel {
    final parts = [governorate, district, subdistrict, neighborhood]
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.join(' › ');
  }
}

class MapFocusModel {
  const MapFocusModel({
    required this.centerLat,
    required this.centerLng,
    required this.zoom,
    this.south,
    this.west,
    this.north,
    this.east,
    this.focusLabel,
  });

  final double centerLat;
  final double centerLng;
  final int zoom;
  final double? south;
  final double? west;
  final double? north;
  final double? east;
  final String? focusLabel;

  factory MapFocusModel.fromJson(Map<String, dynamic> json) {
    return MapFocusModel(
      centerLat: parseJsonDouble(json['centerLat']),
      centerLng: parseJsonDouble(json['centerLng']),
      zoom: parseJsonInt(json['zoom']),
      south: json['south'] != null ? parseJsonDouble(json['south']) : null,
      west: json['west'] != null ? parseJsonDouble(json['west']) : null,
      north: json['north'] != null ? parseJsonDouble(json['north']) : null,
      east: json['east'] != null ? parseJsonDouble(json['east']) : null,
      focusLabel: json['focusLabel'] as String?,
    );
  }

  factory MapFocusModel.iraqDefault() => const MapFocusModel(
        centerLat: 33.3152,
        centerLng: 44.3661,
        zoom: 6,
        focusLabel: 'كل العراق',
      );
}

class PropertyDistributionModel {
  const PropertyDistributionModel({
    required this.stats,
    required this.mapPoints,
    required this.mapFocus,
  });

  final PropertyStatsModel stats;
  final List<PropertyMapPointModel> mapPoints;
  final MapFocusModel mapFocus;

  factory PropertyDistributionModel.fromJson(Map<String, dynamic> json) {
    return PropertyDistributionModel(
      stats: PropertyStatsModel.fromJson(
        json['stats'] as Map<String, dynamic>? ?? {},
      ),
      mapPoints: (json['mapPoints'] as List<dynamic>? ?? [])
          .map((e) => PropertyMapPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      mapFocus: json['mapFocus'] != null
          ? MapFocusModel.fromJson(json['mapFocus'] as Map<String, dynamic>)
          : MapFocusModel.iraqDefault(),
    );
  }
}

class PropertyListItemModel {
  const PropertyListItemModel({
    required this.id,
    required this.wsiCode,
    required this.name,
    this.fullAddress,
    required this.governorate,
    required this.district,
    required this.subdistrict,
    required this.neighborhood,
    this.propertyType,
    this.legalStatus,
    this.usageStatus,
    this.estimatedValue,
    required this.hasDeed,
    required this.hasGps,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String wsiCode;
  final String name;
  final String? fullAddress;
  final String governorate;
  final String district;
  final String subdistrict;
  final String neighborhood;
  final String? propertyType;
  final String? legalStatus;
  final String? usageStatus;
  final double? estimatedValue;
  final bool hasDeed;
  final bool hasGps;
  final double? latitude;
  final double? longitude;

  factory PropertyListItemModel.fromJson(Map<String, dynamic> json) {
    return PropertyListItemModel(
      id: '${json['id']}',
      wsiCode: json['wsiCode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fullAddress: json['fullAddress'] as String?,
      governorate: json['governorate'] as String? ?? '',
      district: json['district'] as String? ?? '',
      subdistrict: json['subdistrict'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      propertyType: json['propertyType'] as String?,
      legalStatus: json['legalStatus'] as String?,
      usageStatus: json['usageStatus'] as String?,
      estimatedValue: json['estimatedValue'] != null
          ? parseJsonDouble(json['estimatedValue'])
          : null,
      hasDeed: json['hasDeed'] as bool? ?? false,
      hasGps: json['hasGps'] as bool? ?? false,
      latitude: json['latitude'] != null ? parseJsonDouble(json['latitude']) : null,
      longitude: json['longitude'] != null ? parseJsonDouble(json['longitude']) : null,
    );
  }

  String get locationLabel {
    final parts = [governorate, district, subdistrict, neighborhood]
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.join(' › ');
  }
}

class PagedPropertyListModel {
  const PagedPropertyListModel({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  final List<PropertyListItemModel> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  bool get hasMore => pageNumber * pageSize < totalCount;

  factory PagedPropertyListModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return PagedPropertyListModel(
      items: itemsJson
          .map((e) => PropertyListItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: parseJsonInt(json['totalCount']),
      pageNumber: parseJsonInt(json['pageNumber']),
      pageSize: parseJsonInt(json['pageSize']),
    );
  }
}

class PropertyDetailModel {
  const PropertyDetailModel({
    required this.id,
    required this.wsiCode,
    required this.name,
    this.fullAddress,
    this.latitude,
    this.longitude,
    required this.governorate,
    required this.district,
    required this.subdistrict,
    required this.neighborhood,
    this.propertyType,
    this.legalStatus,
    this.usageStatus,
    this.estimatedValue,
    this.landArea,
    required this.assetCount,
    required this.hasDeed,
    required this.hasGps,
  });

  final String id;
  final String wsiCode;
  final String name;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;
  final String governorate;
  final String district;
  final String subdistrict;
  final String neighborhood;
  final String? propertyType;
  final String? legalStatus;
  final String? usageStatus;
  final double? estimatedValue;
  final double? landArea;
  final int assetCount;
  final bool hasDeed;
  final bool hasGps;

  factory PropertyDetailModel.fromJson(Map<String, dynamic> json) {
    return PropertyDetailModel(
      id: '${json['id']}',
      wsiCode: json['wsiCode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fullAddress: json['fullAddress'] as String?,
      latitude: json['latitude'] != null ? parseJsonDouble(json['latitude']) : null,
      longitude: json['longitude'] != null ? parseJsonDouble(json['longitude']) : null,
      governorate: json['governorate'] as String? ?? '',
      district: json['district'] as String? ?? '',
      subdistrict: json['subdistrict'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      propertyType: json['propertyType'] as String?,
      legalStatus: json['legalStatus'] as String?,
      usageStatus: json['usageStatus'] as String?,
      estimatedValue: json['estimatedValue'] != null
          ? parseJsonDouble(json['estimatedValue'])
          : null,
      landArea: json['landArea'] != null ? parseJsonDouble(json['landArea']) : null,
      assetCount: parseJsonInt(json['assetCount']),
      hasDeed: json['hasDeed'] as bool? ?? false,
      hasGps: json['hasGps'] as bool? ?? false,
    );
  }

  String get locationLabel {
    final parts = [governorate, district, subdistrict, neighborhood]
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.join(' › ');
  }
}
