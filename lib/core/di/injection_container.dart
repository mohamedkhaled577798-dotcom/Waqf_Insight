import 'package:get_it/get_it.dart';
import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/core/network/api_client.dart';
import 'package:waqf_insight/core/network/auth_token_holder.dart';
import 'package:waqf_insight/core/network/network_info.dart';
import 'package:waqf_insight/core/storage/key_value_storage.dart';
import 'package:waqf_insight/core/storage/key_value_storage_factory.dart';
import 'package:waqf_insight/core/theme/theme_cubit.dart';

import 'package:waqf_insight/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:waqf_insight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:waqf_insight/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:waqf_insight/features/auth/domain/repositories/auth_repository.dart';
import 'package:waqf_insight/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:waqf_insight/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:waqf_insight/features/auth/domain/usecases/login_usecase.dart';
import 'package:waqf_insight/features/auth/domain/usecases/logout_usecase.dart';
import 'package:waqf_insight/features/auth/domain/usecases/register_usecase.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:waqf_insight/features/filters/data/datasources/filters_remote_data_source.dart';
import 'package:waqf_insight/features/filters/data/repositories/filters_repository_impl.dart';
import 'package:waqf_insight/features/filters/domain/repositories/filters_repository.dart';
import 'package:waqf_insight/features/filters/presentation/bloc/filters_bloc.dart';

import 'package:waqf_insight/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:waqf_insight/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:waqf_insight/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/dashboard_section_bloc.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/geo_map_bloc.dart';
import 'package:waqf_insight/features/dashboard/presentation/bloc/property_list_bloc.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes all dependencies for the application.
Future<void> initDependencies() async {
  final storage = await createKeyValueStorage();
  await storage.init();

  sl.registerLazySingleton<KeyValueStorage>(() => storage);
  sl.registerLazySingleton<AuthTokenHolder>(() => AuthTokenHolder());

  final savedToken = await storage.read(AppConstants.tokenKey);
  if (savedToken != null && savedToken.isNotEmpty) {
    sl<AuthTokenHolder>().setToken(savedToken);
  }

  // ── Core ────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(tokenHolder: sl()));
  sl.registerLazySingleton(() => ThemeCubit(sl()));

  // ── Features ────────────────────────────────────────────
  _initAuthFeature();
  _initFiltersFeature();
  _initDashboardFeature();
}

void _initDashboardFeature() {
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerFactory(() => DashboardBloc(repository: sl()));
  sl.registerFactory(() => DashboardSectionBloc(repository: sl()));
  sl.registerFactory(() => GeoMapBloc(repository: sl()));
  sl.registerFactory(() => PropertyListBloc(repository: sl()));
}

void _initFiltersFeature() {
  sl.registerLazySingleton<FiltersRemoteDataSource>(
    () => FiltersRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<FiltersRepository>(
    () => FiltersRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerFactory(() => FiltersBloc(repository: sl()));
}

void _initAuthFeature() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      storage: sl(),
      tokenHolder: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));

  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      getCurrentUserUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );
}
