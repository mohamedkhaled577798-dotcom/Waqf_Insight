import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/dashboard/data/models/executive_models.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_asset_models.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_map_models.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardResult<DashboardSummaryModel>>> getSummary(
    GeoSelection selection,
  );

  Future<Either<Failure, DashboardResult<PropertyStatsModel>>> getProperties(
    GeoSelection selection,
  );

  Future<Either<Failure, DashboardResult<ContractStatsModel>>> getContracts(
    GeoSelection selection,
  );

  Future<Either<Failure, DashboardResult<RevenueStatsModel>>> getRevenue(
    GeoSelection selection,
  );

  Future<Either<Failure, DashboardResult<TenantStatsModel>>> getTenants(
    GeoSelection selection,
  );

  Future<Either<Failure, DashboardResult<InvestorStatsModel>>> getInvestors(
    GeoSelection selection,
  );

  Future<Either<Failure, DashboardResult<PartnerStatsModel>>> getPartners(
    GeoSelection selection,
  );

  Future<Either<Failure, DashboardResult<MutawalliStatsModel>>> getMutawallis(
    GeoSelection selection,
  );

  Future<Either<Failure, DashboardResult<ModuleStatsModel>>> getModules(
    GeoSelection selection,
  );

  Future<Either<Failure, DashboardResult<StaffOverviewModel>>> getStaffOverview();

  Future<Either<Failure, DashboardResult<PropertyDistributionModel>>>
      getPropertyDistribution(GeoSelection selection);

  Future<Either<Failure, DashboardResult<MapFocusModel>>> getMapFocus(
    GeoSelection selection,
  );

  Future<Either<Failure, DashboardResult<PropertyDetailModel>>> getPropertyDetail(
    String id,
  );

  Future<Either<Failure, DashboardResult<PagedPropertyListModel>>> getPropertyList({
    required GeoSelection selection,
    String? search,
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, DashboardResult<PropertyAssetRegistryModel>>> getPropertyAssetRegistry({
    required GeoSelection selection,
    String? search,
    String linkStatus = 'all',
    String? aqarId,
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, DashboardResult<PropertyAssetDetailModel>>> getPropertyAssetDetail(
    String id,
  );

  Future<Either<Failure, DashboardResult<List<PropertyAssetListItemModel>>>>
      getPropertyAssetsForProperty(String propertyId);

  Future<Either<Failure, DashboardResult<ExecutiveOverviewModel>>> getExecutiveOverview(
    GeoSelection selection,
  );

  Future<Either<Failure, DashboardResult<ChairmanAlertsModel>>> getExecutiveAlerts(
    GeoSelection selection,
  );

  Future<Either<Failure, DashboardResult<ChairmanCalendarModel>>> getExecutiveCalendar({
    required GeoSelection selection,
    required int year,
    required int month,
  });
}
