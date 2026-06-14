import 'package:dartz/dartz.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/errors/failures.dart';
import 'package:waqf_insight/core/network/network_info.dart';
import 'package:waqf_insight/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:waqf_insight/features/dashboard/data/models/dashboard_stats_models.dart';
import 'package:waqf_insight/features/dashboard/data/models/property_map_models.dart';
import 'package:waqf_insight/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:waqf_insight/features/filters/domain/entities/geo_selection.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final DashboardRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }

    try {
      return Right(await call());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, DashboardResult<DashboardSummaryModel>>> getSummary(
    GeoSelection selection,
  ) {
    return _guard(() => remoteDataSource.getSummary(selection));
  }

  @override
  Future<Either<Failure, DashboardResult<PropertyStatsModel>>> getProperties(
    GeoSelection selection,
  ) {
    return _guard(() => remoteDataSource.getProperties(selection));
  }

  @override
  Future<Either<Failure, DashboardResult<ContractStatsModel>>> getContracts(
    GeoSelection selection,
  ) {
    return _guard(() => remoteDataSource.getContracts(selection));
  }

  @override
  Future<Either<Failure, DashboardResult<RevenueStatsModel>>> getRevenue(
    GeoSelection selection,
  ) {
    return _guard(() => remoteDataSource.getRevenue(selection));
  }

  @override
  Future<Either<Failure, DashboardResult<TenantStatsModel>>> getTenants(
    GeoSelection selection,
  ) {
    return _guard(() => remoteDataSource.getTenants(selection));
  }

  @override
  Future<Either<Failure, DashboardResult<InvestorStatsModel>>> getInvestors(
    GeoSelection selection,
  ) {
    return _guard(() => remoteDataSource.getInvestors(selection));
  }

  @override
  Future<Either<Failure, DashboardResult<PartnerStatsModel>>> getPartners(
    GeoSelection selection,
  ) {
    return _guard(() => remoteDataSource.getPartners(selection));
  }

  @override
  Future<Either<Failure, DashboardResult<MutawalliStatsModel>>> getMutawallis(
    GeoSelection selection,
  ) {
    return _guard(() => remoteDataSource.getMutawallis(selection));
  }

  @override
  Future<Either<Failure, DashboardResult<ModuleStatsModel>>> getModules(
    GeoSelection selection,
  ) {
    return _guard(() => remoteDataSource.getModules(selection));
  }

  @override
  Future<Either<Failure, DashboardResult<StaffOverviewModel>>> getStaffOverview() {
    return _guard(remoteDataSource.getStaffOverview);
  }

  @override
  Future<Either<Failure, DashboardResult<PropertyDistributionModel>>>
      getPropertyDistribution(GeoSelection selection) {
    return _guard(() => remoteDataSource.getPropertyDistribution(selection));
  }

  @override
  Future<Either<Failure, DashboardResult<MapFocusModel>>> getMapFocus(
    GeoSelection selection,
  ) {
    return _guard(() => remoteDataSource.getMapFocus(selection));
  }

  @override
  Future<Either<Failure, DashboardResult<PropertyDetailModel>>> getPropertyDetail(
    String id,
  ) {
    return _guard(() => remoteDataSource.getPropertyDetail(id));
  }

  @override
  Future<Either<Failure, DashboardResult<PagedPropertyListModel>>> getPropertyList({
    required GeoSelection selection,
    String? search,
    required int page,
    required int pageSize,
  }) {
    return _guard(
      () => remoteDataSource.getPropertyList(
        selection: selection,
        search: search,
        page: page,
        pageSize: pageSize,
      ),
    );
  }
}
