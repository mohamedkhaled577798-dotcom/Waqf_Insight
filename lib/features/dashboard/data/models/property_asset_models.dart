import 'package:equatable/equatable.dart';
import 'package:waqf_insight/core/utils/json_parse_helpers.dart';

class PropertyAssetSummaryModel {
  const PropertyAssetSummaryModel({
    required this.totalCount,
    required this.linkedCount,
    required this.unlinkedCount,
    required this.missingPropertyCount,
  });

  final int totalCount;
  final int linkedCount;
  final int unlinkedCount;
  final int missingPropertyCount;

  factory PropertyAssetSummaryModel.fromJson(Map<String, dynamic> json) {
    return PropertyAssetSummaryModel(
      totalCount: parseJsonInt(json['totalCount']),
      linkedCount: parseJsonInt(json['linkedCount']),
      unlinkedCount: parseJsonInt(json['unlinkedCount']),
      missingPropertyCount: parseJsonInt(json['missingPropertyCount']),
    );
  }

  factory PropertyAssetSummaryModel.empty() => const PropertyAssetSummaryModel(
        totalCount: 0,
        linkedCount: 0,
        unlinkedCount: 0,
        missingPropertyCount: 0,
      );
}

class PropertyAssetListItemModel {
  const PropertyAssetListItemModel({
    required this.id,
    required this.assetCode,
    this.commercialName,
    this.propertyId,
    this.propertyName,
    this.propertyAqarId,
    this.pendingAqarId,
    this.displayAqarId,
    this.usageTypeName,
    this.rentedArea,
    required this.occupancyStatus,
    required this.isLinked,
    required this.propertyMissing,
    required this.linkLabel,
  });

  final String id;
  final String assetCode;
  final String? commercialName;
  final String? propertyId;
  final String? propertyName;
  final String? propertyAqarId;
  final String? pendingAqarId;
  final String? displayAqarId;
  final String? usageTypeName;
  final double? rentedArea;
  final String occupancyStatus;
  final bool isLinked;
  final bool propertyMissing;
  final String linkLabel;

  factory PropertyAssetListItemModel.fromJson(Map<String, dynamic> json) {
    return PropertyAssetListItemModel(
      id: '${json['id']}',
      assetCode: json['assetCode'] as String? ?? '',
      commercialName: json['commercialName'] as String?,
      propertyId: json['propertyId']?.toString(),
      propertyName: json['propertyName'] as String?,
      propertyAqarId: json['propertyAqarId'] as String?,
      pendingAqarId: json['pendingAqarId'] as String?,
      displayAqarId: json['displayAqarId'] as String?,
      usageTypeName: json['usageTypeName'] as String?,
      rentedArea: json['rentedArea'] != null ? parseJsonDouble(json['rentedArea']) : null,
      occupancyStatus: json['occupancyStatus'] as String? ?? '',
      isLinked: json['isLinked'] as bool? ?? false,
      propertyMissing: json['propertyMissing'] as bool? ?? false,
      linkLabel: json['linkLabel'] as String? ?? '',
    );
  }
}

class PropertyAssetRegistryModel {
  const PropertyAssetRegistryModel({
    required this.summary,
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final PropertyAssetSummaryModel summary;
  final List<PropertyAssetListItemModel> items;
  final int page;
  final int pageSize;
  final int totalCount;

  bool get hasMore => page * pageSize < totalCount;

  factory PropertyAssetRegistryModel.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    return PropertyAssetRegistryModel(
      summary: json['summary'] is Map<String, dynamic>
          ? PropertyAssetSummaryModel.fromJson(json['summary'] as Map<String, dynamic>)
          : PropertyAssetSummaryModel.empty(),
      items: itemsRaw is List
          ? itemsRaw
              .map((e) => PropertyAssetListItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      page: parseJsonInt(json['page']) == 0 ? 1 : parseJsonInt(json['page']),
      pageSize: parseJsonInt(json['pageSize']) == 0 ? 20 : parseJsonInt(json['pageSize']),
      totalCount: parseJsonInt(json['totalCount']),
    );
  }
}

class PropertyAssetContractModel {
  const PropertyAssetContractModel({
    required this.id,
    required this.label,
    this.partyName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.baseRent,
    required this.outstandingAmount,
    required this.isActive,
  });

  final String id;
  final String label;
  final String? partyName;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final double baseRent;
  final double outstandingAmount;
  final bool isActive;

  factory PropertyAssetContractModel.fromJson(Map<String, dynamic> json) {
    return PropertyAssetContractModel(
      id: '${json['id']}',
      label: json['label'] as String? ?? '',
      partyName: json['partyName'] as String?,
      status: json['status'] as String? ?? '',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime(2000),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime(2000),
      baseRent: parseJsonDouble(json['baseRent']),
      outstandingAmount: parseJsonDouble(json['outstandingAmount']),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}

class PropertyAssetDetailModel {
  const PropertyAssetDetailModel({
    required this.id,
    required this.assetCode,
    this.commercialName,
    this.location,
    this.rentedArea,
    this.annualRent,
    required this.occupancyStatus,
    this.usageTypeName,
    this.ownershipTypeName,
    required this.isAvailableForRental,
    required this.isAvailableForInvestment,
    required this.collectRevenue,
    required this.propertyMissing,
    this.propertyId,
    this.pendingAqarId,
    this.propertyName,
    this.propertyAqarId,
    this.waqfName,
    this.waqfNameId,
    required this.totalRevenue,
    required this.totalDebt,
    required this.tenantContracts,
    required this.collectionContracts,
    required this.investorContracts,
    required this.tenants,
    required this.mutawallis,
    required this.propertyPartners,
    required this.waqfPartners,
    required this.revenues,
    required this.debts,
  });

  final String id;
  final String assetCode;
  final String? commercialName;
  final String? location;
  final double? rentedArea;
  final double? annualRent;
  final String occupancyStatus;
  final String? usageTypeName;
  final String? ownershipTypeName;
  final bool isAvailableForRental;
  final bool isAvailableForInvestment;
  final bool collectRevenue;
  final bool propertyMissing;
  final String? propertyId;
  final String? pendingAqarId;
  final String? propertyName;
  final String? propertyAqarId;
  final String? waqfName;
  final String? waqfNameId;
  final double totalRevenue;
  final double totalDebt;
  final List<PropertyAssetContractModel> tenantContracts;
  final List<PropertyAssetContractModel> collectionContracts;
  final List<PropertyAssetContractModel> investorContracts;
  final List<Map<String, dynamic>> tenants;
  final List<Map<String, dynamic>> mutawallis;
  final List<Map<String, dynamic>> propertyPartners;
  final List<Map<String, dynamic>> waqfPartners;
  final List<Map<String, dynamic>> revenues;
  final List<Map<String, dynamic>> debts;

  factory PropertyAssetDetailModel.fromJson(Map<String, dynamic> json) {
    List<T> mapList<T>(String key, T Function(Map<String, dynamic>) mapper) {
      final raw = json[key];
      if (raw is! List) return const [];
      return raw.map((e) => mapper(e as Map<String, dynamic>)).toList();
    }

    return PropertyAssetDetailModel(
      id: '${json['id']}',
      assetCode: json['assetCode'] as String? ?? '',
      commercialName: json['commercialName'] as String?,
      location: json['location'] as String?,
      rentedArea: json['rentedArea'] != null ? parseJsonDouble(json['rentedArea']) : null,
      annualRent: json['annualRent'] != null ? parseJsonDouble(json['annualRent']) : null,
      occupancyStatus: json['occupancyStatus'] as String? ?? '',
      usageTypeName: json['usageTypeName'] as String?,
      ownershipTypeName: json['ownershipTypeName'] as String?,
      isAvailableForRental: json['isAvailableForRental'] as bool? ?? false,
      isAvailableForInvestment: json['isAvailableForInvestment'] as bool? ?? false,
      collectRevenue: json['collectRevenue'] as bool? ?? false,
      propertyMissing: json['propertyMissing'] as bool? ?? false,
      propertyId: json['propertyId']?.toString(),
      pendingAqarId: json['pendingAqarId'] as String?,
      propertyName: json['propertyName'] as String?,
      propertyAqarId: json['propertyAqarId'] as String?,
      waqfName: json['waqfName'] as String?,
      waqfNameId: json['waqfNameId']?.toString(),
      totalRevenue: parseJsonDouble(json['totalRevenue']),
      totalDebt: parseJsonDouble(json['totalDebt']),
      tenantContracts: mapList('tenantContracts', PropertyAssetContractModel.fromJson),
      collectionContracts: mapList('collectionContracts', PropertyAssetContractModel.fromJson),
      investorContracts: mapList('investorContracts', (m) => PropertyAssetContractModel(
            id: '${m['id']}',
            label: m['investorName'] as String? ?? 'استثمار',
            partyName: m['investorName'] as String?,
            status: m['status'] as String? ?? '',
            startDate: DateTime.tryParse(m['startDate']?.toString() ?? '') ?? DateTime(2000),
            endDate: DateTime.tryParse(m['endDate']?.toString() ?? '') ?? DateTime(2000),
            baseRent: 0,
            outstandingAmount: parseJsonDouble(m['outstandingAmount']),
            isActive: m['isActive'] as bool? ?? false,
          )),
      tenants: (json['tenants'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
      mutawallis: (json['mutawallis'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
      propertyPartners: (json['propertyPartners'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
      waqfPartners: (json['waqfPartners'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
      revenues: (json['revenues'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
      debts: (json['debts'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
    );
  }
}

class PropertyAssetDetailArgs extends Equatable {
  const PropertyAssetDetailArgs({required this.assetId, this.title});

  final String assetId;
  final String? title;

  @override
  List<Object?> get props => [assetId, title];
}
