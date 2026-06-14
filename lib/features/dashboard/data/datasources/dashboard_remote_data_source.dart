import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/network/api_client.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/filters/data/models/chairman_filter_response.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_map_models.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardResult<DashboardSummaryModel>> getSummary(GeoSelection selection);
  Future<DashboardResult<PropertyStatsModel>> getProperties(GeoSelection selection);
  Future<DashboardResult<ContractStatsModel>> getContracts(GeoSelection selection);
  Future<DashboardResult<RevenueStatsModel>> getRevenue(GeoSelection selection);
  Future<DashboardResult<TenantStatsModel>> getTenants(GeoSelection selection);
  Future<DashboardResult<InvestorStatsModel>> getInvestors(GeoSelection selection);
  Future<DashboardResult<PartnerStatsModel>> getPartners(GeoSelection selection);
  Future<DashboardResult<MutawalliStatsModel>> getMutawallis(GeoSelection selection);
  Future<DashboardResult<ModuleStatsModel>> getModules(GeoSelection selection);
  Future<DashboardResult<StaffOverviewModel>> getStaffOverview();
  Future<DashboardResult<PropertyDistributionModel>> getPropertyDistribution(
    GeoSelection selection,
  );
  Future<DashboardResult<MapFocusModel>> getMapFocus(GeoSelection selection);
  Future<DashboardResult<PropertyDetailModel>> getPropertyDetail(String id);
  Future<DashboardResult<PagedPropertyListModel>> getPropertyList({
    required GeoSelection selection,
    String? search,
    required int page,
    required int pageSize,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  DashboardResult<T> _unwrap<T>(
    dynamic raw,
    T Function(Object? json) fromJsonT,
  ) {
    if (raw is! Map<String, dynamic>) {
      throw const ServerException(message: 'استجابة غير متوقعة من الخادم');
    }

    final wrapper = ChairmanFilterResponse<T>.fromJson(raw, fromJsonT);
    if (!wrapper.success) {
      throw ServerException(
        message: wrapper.message ?? 'فشل تحميل لوحة المعلومات',
      );
    }

    if (wrapper.data == null) {
      throw const ServerException(message: 'لا توجد بيانات في الاستجابة');
    }

    return DashboardResult(
      data: wrapper.data as T,
      filter: wrapper.filter,
      message: wrapper.message,
    );
  }

  Future<DashboardResult<T>> _get<T>(
    String path,
    GeoSelection selection,
    T Function(Object? json) fromJsonT,
  ) async {
    final response = await apiClient.get(
      path,
      queryParameters: selection.toQueryParams(),
    );
    return _unwrap(response.data, fromJsonT);
  }

  @override
  Future<DashboardResult<DashboardSummaryModel>> getSummary(
    GeoSelection selection,
  ) {
    return _get(
      AppConstants.dashboardSummaryPath,
      selection,
      (data) => DashboardSummaryModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<PropertyStatsModel>> getProperties(
    GeoSelection selection,
  ) {
    return _get(
      AppConstants.dashboardPropertiesPath,
      selection,
      (data) => PropertyStatsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<ContractStatsModel>> getContracts(
    GeoSelection selection,
  ) {
    return _get(
      AppConstants.dashboardContractsPath,
      selection,
      (data) => ContractStatsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<RevenueStatsModel>> getRevenue(GeoSelection selection) {
    return _get(
      AppConstants.dashboardRevenuePath,
      selection,
      (data) => RevenueStatsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<TenantStatsModel>> getTenants(GeoSelection selection) {
    return _get(
      AppConstants.dashboardTenantsPath,
      selection,
      (data) => TenantStatsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<InvestorStatsModel>> getInvestors(
    GeoSelection selection,
  ) {
    return _get(
      AppConstants.dashboardInvestorsPath,
      selection,
      (data) => InvestorStatsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<PartnerStatsModel>> getPartners(GeoSelection selection) {
    return _get(
      AppConstants.dashboardPartnersPath,
      selection,
      (data) => PartnerStatsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<MutawalliStatsModel>> getMutawallis(
    GeoSelection selection,
  ) {
    return _get(
      AppConstants.dashboardMutawallisPath,
      selection,
      (data) => MutawalliStatsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<ModuleStatsModel>> getModules(GeoSelection selection) {
    return _get(
      AppConstants.dashboardModulesPath,
      selection,
      (data) => ModuleStatsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<StaffOverviewModel>> getStaffOverview() async {
    final response = await apiClient.get(AppConstants.dashboardStaffOverviewPath);
    return _unwrap(
      response.data,
      (data) => StaffOverviewModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<PropertyDistributionModel>> getPropertyDistribution(
    GeoSelection selection,
  ) {
    return _get(
      AppConstants.propertiesDistributionPath,
      selection,
      (data) => PropertyDistributionModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<MapFocusModel>> getMapFocus(GeoSelection selection) {
    return _get(
      AppConstants.propertiesMapFocusPath,
      selection,
      (data) => MapFocusModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<PropertyDetailModel>> getPropertyDetail(String id) async {
    final response = await apiClient.get(AppConstants.propertyDetailPath(id));
    return _unwrap(
      response.data,
      (data) => PropertyDetailModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<DashboardResult<PagedPropertyListModel>> getPropertyList({
    required GeoSelection selection,
    String? search,
    required int page,
    required int pageSize,
  }) async {
    final params = {
      ...selection.toQueryParams(),
      'page': '$page',
      'pageSize': '$pageSize',
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };
    final response = await apiClient.get(
      AppConstants.propertiesListPath,
      queryParameters: params,
    );
    return _unwrap(
      response.data,
      (data) => PagedPropertyListModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
