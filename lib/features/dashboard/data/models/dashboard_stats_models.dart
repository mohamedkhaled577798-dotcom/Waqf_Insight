import 'package:waqf_insight/core/utils/json_parse_helpers.dart';
import 'package:waqf_insight/features/filters/data/models/applied_geo_filter_model.dart';

class DistributionSliceModel {
  const DistributionSliceModel({
    required this.label,
    required this.value,
    required this.percent,
  });

  final String label;
  final int value;
  final double percent;

  factory DistributionSliceModel.fromJson(Map<String, dynamic> json) {
    return DistributionSliceModel(
      label: json['label'] as String? ?? '',
      value: parseJsonInt(json['value']),
      percent: parseJsonDouble(json['percent']),
    );
  }

  double effectivePercent(int total) {
    if (percent > 0) return percent;
    if (total <= 0) return 0;
    return (value / total) * 100;
  }
}

class OverdueBucketModel {
  const OverdueBucketModel({
    required this.bucketName,
    required this.installmentsCount,
    required this.totalAmount,
  });

  final String bucketName;
  final int installmentsCount;
  final double totalAmount;

  factory OverdueBucketModel.fromJson(Map<String, dynamic> json) {
    return OverdueBucketModel(
      bucketName: json['bucketName'] as String? ?? '',
      installmentsCount: parseJsonInt(json['installmentsCount']),
      totalAmount: parseJsonDouble(json['totalAmount']),
    );
  }
}

class RevenueByGovernorateModel {
  const RevenueByGovernorateModel({
    required this.governorateId,
    required this.governorateName,
    required this.rentalCollected,
    required this.investorCollected,
    required this.totalCollected,
  });

  final String? governorateId;
  final String governorateName;
  final double rentalCollected;
  final double investorCollected;
  final double totalCollected;

  factory RevenueByGovernorateModel.fromJson(Map<String, dynamic> json) {
    return RevenueByGovernorateModel(
      governorateId: json['governorateId'] as String?,
      governorateName: json['governorateName'] as String? ?? '',
      rentalCollected: parseJsonDouble(json['rentalCollected']),
      investorCollected: parseJsonDouble(json['investorCollected']),
      totalCollected: parseJsonDouble(json['totalCollected']),
    );
  }
}

class RevenueSourceModel {
  const RevenueSourceModel({required this.label, required this.amount});

  final String label;
  final double amount;

  factory RevenueSourceModel.fromJson(Map<String, dynamic> json) {
    return RevenueSourceModel(
      label: json['label'] as String? ?? '',
      amount: parseJsonDouble(json['amount']),
    );
  }
}

class MutawalliLeaderModel {
  const MutawalliLeaderModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.propertiesCount,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final int propertiesCount;

  factory MutawalliLeaderModel.fromJson(Map<String, dynamic> json) {
    return MutawalliLeaderModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      propertiesCount: parseJsonInt(json['propertiesCount']),
    );
  }
}

List<DistributionSliceModel> _parseSlices(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map((e) => DistributionSliceModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

class PropertyStatsModel {
  const PropertyStatsModel({
    required this.totalProperties,
    required this.totalUnits,
    required this.gpsCoveragePercent,
    required this.totalEstimatedValue,
    required this.rentedCount,
    required this.vacantCount,
    required this.withGps,
    required this.withoutGps,
    required this.disputedCount,
    required this.byType,
    required this.byGovernorate,
    required this.byDistrict,
    required this.byLegalStatus,
    required this.byUsageStatus,
  });

  final int totalProperties;
  final int totalUnits;
  final double gpsCoveragePercent;
  final double totalEstimatedValue;
  final int rentedCount;
  final int vacantCount;
  final int withGps;
  final int withoutGps;
  final int disputedCount;
  final List<DistributionSliceModel> byType;
  final List<DistributionSliceModel> byGovernorate;
  final List<DistributionSliceModel> byDistrict;
  final List<DistributionSliceModel> byLegalStatus;
  final List<DistributionSliceModel> byUsageStatus;

  factory PropertyStatsModel.fromJson(Map<String, dynamic> json) {
    return PropertyStatsModel(
      totalProperties: parseJsonInt(json['totalProperties']),
      totalUnits: parseJsonInt(json['totalUnits']),
      gpsCoveragePercent: parseJsonDouble(json['gpsCoveragePercent']),
      totalEstimatedValue: parseJsonDouble(json['totalEstimatedValue']),
      rentedCount: parseJsonInt(json['rentedCount']),
      vacantCount: parseJsonInt(json['vacantCount']),
      withGps: parseJsonInt(json['withGps']),
      withoutGps: parseJsonInt(json['withoutGps']),
      disputedCount: parseJsonInt(json['disputedCount']),
      byType: _parseSlices(json['byType']),
      byGovernorate: _parseSlices(json['byGovernorate']),
      byDistrict: _parseSlices(json['byDistrict']),
      byLegalStatus: _parseSlices(json['byLegalStatus']),
      byUsageStatus: _parseSlices(json['byUsageStatus']),
    );
  }

  factory PropertyStatsModel.empty() => const PropertyStatsModel(
        totalProperties: 0,
        totalUnits: 0,
        gpsCoveragePercent: 0,
        totalEstimatedValue: 0,
        rentedCount: 0,
        vacantCount: 0,
        withGps: 0,
        withoutGps: 0,
        disputedCount: 0,
        byType: [],
        byGovernorate: [],
        byDistrict: [],
        byLegalStatus: [],
        byUsageStatus: [],
      );
}

class ContractStatsModel {
  const ContractStatsModel({
    required this.collectedThisYear,
    required this.expectedThisYear,
    required this.totalUnits,
    required this.rentedUnits,
    required this.occupancyRatePercent,
    required this.activeContracts,
    required this.expiringSoonContracts,
    required this.totalOverdueAmount,
    required this.overdueBuckets,
  });

  final double collectedThisYear;
  final double expectedThisYear;
  final int totalUnits;
  final int rentedUnits;
  final double occupancyRatePercent;
  final int activeContracts;
  final int expiringSoonContracts;
  final double totalOverdueAmount;
  final List<OverdueBucketModel> overdueBuckets;

  factory ContractStatsModel.fromJson(Map<String, dynamic> json) {
    final buckets = json['overdueBuckets'] as List<dynamic>? ?? [];
    return ContractStatsModel(
      collectedThisYear: parseJsonDouble(json['collectedThisYear']),
      expectedThisYear: parseJsonDouble(json['expectedThisYear']),
      totalUnits: parseJsonInt(json['totalUnits']),
      rentedUnits: parseJsonInt(json['rentedUnits']),
      occupancyRatePercent: parseJsonDouble(json['occupancyRatePercent']),
      activeContracts: parseJsonInt(json['activeContracts']),
      expiringSoonContracts: parseJsonInt(json['expiringSoonContracts']),
      totalOverdueAmount: parseJsonDouble(json['totalOverdueAmount']),
      overdueBuckets: buckets
          .map((e) => OverdueBucketModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory ContractStatsModel.empty() => const ContractStatsModel(
        collectedThisYear: 0,
        expectedThisYear: 0,
        totalUnits: 0,
        rentedUnits: 0,
        occupancyRatePercent: 0,
        activeContracts: 0,
        expiringSoonContracts: 0,
        totalOverdueAmount: 0,
        overdueBuckets: [],
      );
}

class RevenueStatsModel {
  const RevenueStatsModel({
    required this.rentalCollectionRatePercent,
    required this.totalGrossRevenue,
    required this.totalOverdueAmount,
    required this.bySource,
    required this.byGovernorate,
  });

  final double rentalCollectionRatePercent;
  final double totalGrossRevenue;
  final double totalOverdueAmount;
  final List<RevenueSourceModel> bySource;
  final List<RevenueByGovernorateModel> byGovernorate;

  factory RevenueStatsModel.fromJson(Map<String, dynamic> json) {
    final sources = json['bySource'] as List<dynamic>? ?? [];
    final gov = json['byGovernorate'] as List<dynamic>? ?? [];
    return RevenueStatsModel(
      rentalCollectionRatePercent:
          parseJsonDouble(json['rentalCollectionRatePercent']),
      totalGrossRevenue: parseJsonDouble(json['totalGrossRevenue']),
      totalOverdueAmount: parseJsonDouble(json['totalOverdueAmount']),
      bySource: sources
          .map((e) => RevenueSourceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      byGovernorate: gov
          .map(
            (e) => RevenueByGovernorateModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  factory RevenueStatsModel.empty() => const RevenueStatsModel(
        rentalCollectionRatePercent: 0,
        totalGrossRevenue: 0,
        totalOverdueAmount: 0,
        bySource: [],
        byGovernorate: [],
      );
}

class TenantStatsModel {
  const TenantStatsModel({
    required this.totalTenants,
    required this.activeTenants,
    required this.withOverduePayments,
    required this.totalOutstandingBalance,
  });

  final int totalTenants;
  final int activeTenants;
  final int withOverduePayments;
  final double totalOutstandingBalance;

  factory TenantStatsModel.fromJson(Map<String, dynamic> json) {
    return TenantStatsModel(
      totalTenants: parseJsonInt(json['totalTenants']),
      activeTenants: parseJsonInt(json['activeTenants']),
      withOverduePayments: parseJsonInt(json['withOverduePayments']),
      totalOutstandingBalance: parseJsonDouble(json['totalOutstandingBalance']),
    );
  }

  factory TenantStatsModel.empty() => const TenantStatsModel(
        totalTenants: 0,
        activeTenants: 0,
        withOverduePayments: 0,
        totalOutstandingBalance: 0,
      );
}

class InvestorStatsModel {
  const InvestorStatsModel({
    required this.totalInvestors,
    required this.activeInvestors,
    required this.collectedThisYear,
    required this.pendingApprovals,
  });

  final int totalInvestors;
  final int activeInvestors;
  final double collectedThisYear;
  final int pendingApprovals;

  factory InvestorStatsModel.fromJson(Map<String, dynamic> json) {
    return InvestorStatsModel(
      totalInvestors: parseJsonInt(json['totalInvestors']),
      activeInvestors: parseJsonInt(json['activeInvestors']),
      collectedThisYear: parseJsonDouble(json['collectedThisYear']),
      pendingApprovals: parseJsonInt(json['pendingApprovals']),
    );
  }

  factory InvestorStatsModel.empty() => const InvestorStatsModel(
        totalInvestors: 0,
        activeInvestors: 0,
        collectedThisYear: 0,
        pendingApprovals: 0,
      );
}

class PartnerStatsModel {
  const PartnerStatsModel({
    required this.totalPartners,
    required this.activePartners,
    required this.assignedPropertiesCount,
  });

  final int totalPartners;
  final int activePartners;
  final int assignedPropertiesCount;

  factory PartnerStatsModel.fromJson(Map<String, dynamic> json) {
    return PartnerStatsModel(
      totalPartners: parseJsonInt(json['totalPartners']),
      activePartners: parseJsonInt(json['activePartners']),
      assignedPropertiesCount: parseJsonInt(json['assignedPropertiesCount']),
    );
  }

  factory PartnerStatsModel.empty() => const PartnerStatsModel(
        totalPartners: 0,
        activePartners: 0,
        assignedPropertiesCount: 0,
      );
}

class MutawalliStatsModel {
  const MutawalliStatsModel({
    required this.totalMutawallis,
    required this.assignedPropertiesCount,
    required this.topByProperties,
  });

  final int totalMutawallis;
  final int assignedPropertiesCount;
  final List<MutawalliLeaderModel> topByProperties;

  factory MutawalliStatsModel.fromJson(Map<String, dynamic> json) {
    final top = json['topByProperties'] as List<dynamic>? ?? [];
    return MutawalliStatsModel(
      totalMutawallis: parseJsonInt(json['totalMutawallis']),
      assignedPropertiesCount: parseJsonInt(json['assignedPropertiesCount']),
      topByProperties: top
          .map((e) => MutawalliLeaderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory MutawalliStatsModel.empty() => const MutawalliStatsModel(
        totalMutawallis: 0,
        assignedPropertiesCount: 0,
        topByProperties: [],
      );
}

class ModuleStatsModel {
  const ModuleStatsModel({
    required this.activeCases,
    required this.upcomingSessions,
    required this.activeProjects,
    required this.pendingMaintenanceRequests,
    required this.pendingInspectionTasks,
    required this.pendingApprovals,
  });

  final int activeCases;
  final int upcomingSessions;
  final int activeProjects;
  final int pendingMaintenanceRequests;
  final int pendingInspectionTasks;
  final int pendingApprovals;

  factory ModuleStatsModel.fromJson(Map<String, dynamic> json) {
    return ModuleStatsModel(
      activeCases: parseJsonInt(json['activeCases']),
      upcomingSessions: parseJsonInt(json['upcomingSessions']),
      activeProjects: parseJsonInt(json['activeProjects']),
      pendingMaintenanceRequests: parseJsonInt(json['pendingMaintenanceRequests']),
      pendingInspectionTasks: parseJsonInt(json['pendingInspectionTasks']),
      pendingApprovals: parseJsonInt(json['pendingApprovals']),
    );
  }

  factory ModuleStatsModel.empty() => const ModuleStatsModel(
        activeCases: 0,
        upcomingSessions: 0,
        activeProjects: 0,
        pendingMaintenanceRequests: 0,
        pendingInspectionTasks: 0,
        pendingApprovals: 0,
      );
}

class StaffOverviewModel {
  const StaffOverviewModel({
    required this.totalUsers,
    required this.totalEmployees,
    required this.totalInspectors,
    required this.activeUsers,
  });

  final int totalUsers;
  final int totalEmployees;
  final int totalInspectors;
  final int activeUsers;

  factory StaffOverviewModel.fromJson(Map<String, dynamic> json) {
    return StaffOverviewModel(
      totalUsers: parseJsonInt(json['totalUsers']),
      totalEmployees: parseJsonInt(json['totalEmployees']),
      totalInspectors: parseJsonInt(json['totalInspectors']),
      activeUsers: parseJsonInt(json['activeUsers']),
    );
  }

  factory StaffOverviewModel.empty() => const StaffOverviewModel(
        totalUsers: 0,
        totalEmployees: 0,
        totalInspectors: 0,
        activeUsers: 0,
      );
}

class DashboardSummaryModel {
  const DashboardSummaryModel({
    required this.appliedFilter,
    required this.properties,
    required this.contracts,
    required this.revenue,
    required this.tenants,
    required this.investors,
    required this.partners,
    required this.mutawallis,
    required this.modules,
    required this.staff,
    this.generatedAt,
  });

  final AppliedGeoFilterModel appliedFilter;
  final PropertyStatsModel properties;
  final ContractStatsModel contracts;
  final RevenueStatsModel revenue;
  final TenantStatsModel tenants;
  final InvestorStatsModel investors;
  final PartnerStatsModel partners;
  final MutawalliStatsModel mutawallis;
  final ModuleStatsModel modules;
  final StaffOverviewModel staff;
  final DateTime? generatedAt;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> section(String key) =>
        json[key] as Map<String, dynamic>? ?? {};

    return DashboardSummaryModel(
      appliedFilter: json['appliedFilter'] != null
          ? AppliedGeoFilterModel.fromJson(
              json['appliedFilter'] as Map<String, dynamic>,
            )
          : const AppliedGeoFilterModel(hasAnyFilter: false),
      properties: PropertyStatsModel.fromJson(section('properties')),
      contracts: ContractStatsModel.fromJson(section('contracts')),
      revenue: RevenueStatsModel.fromJson(section('revenue')),
      tenants: TenantStatsModel.fromJson(section('tenants')),
      investors: InvestorStatsModel.fromJson(section('investors')),
      partners: PartnerStatsModel.fromJson(section('partners')),
      mutawallis: MutawalliStatsModel.fromJson(section('mutawallis')),
      modules: ModuleStatsModel.fromJson(section('modules')),
      staff: StaffOverviewModel.fromJson(section('staff')),
      generatedAt: parseJsonDateTime(json['generatedAt']),
    );
  }
}

class DashboardResult<T> {
  const DashboardResult({
    required this.data,
    this.filter,
    this.message,
  });

  final T data;
  final AppliedGeoFilterModel? filter;
  final String? message;
}
