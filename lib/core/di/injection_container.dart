import 'package:get_it/get_it.dart';
import 'package:waqf_insight/core/network/api_client.dart';
import 'package:waqf_insight/core/network/network_info.dart';

import 'package:waqf_insight/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:waqf_insight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:waqf_insight/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:waqf_insight/features/auth/domain/repositories/auth_repository.dart';
import 'package:waqf_insight/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:waqf_insight/features/auth/domain/usecases/login_usecase.dart';
import 'package:waqf_insight/features/auth/domain/usecases/logout_usecase.dart';
import 'package:waqf_insight/features/auth/domain/usecases/register_usecase.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_bloc.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes all dependencies for the application.
///
/// Call this once in [main()] before [runApp()].
/// Dependencies are registered in order: external → core → features.
///
/// Usage:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initDependencies();
///   runApp(const App());
/// }
/// ```
Future<void> initDependencies() async {
  // ── Core ────────────────────────────────────────────────

  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // ── Features ────────────────────────────────────────────

  // Auth Feature
  _initAuthFeature();
}

void _initAuthFeature() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      getCurrentUserUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );
}

// ── Feature Initializers ──────────────────────────────────
//
// Keep each feature's DI registration in its own method for clarity.
//
// void _initWaqfFeature() {
//   // Data sources
//   sl.registerLazySingleton<WaqfRemoteDataSource>(
//     () => WaqfRemoteDataSourceImpl(apiClient: sl()),
//   );
//
//   // Repository
//   sl.registerLazySingleton<WaqfRepository>(
//     () => WaqfRepositoryImpl(
//       remoteDataSource: sl(),
//       networkInfo: sl(),
//     ),
//   );
//
//   // Use cases
//   sl.registerLazySingleton(() => GetWaqfDetails(sl()));
//
//   // BLoC
//   sl.registerFactory(() => WaqfBloc(getWaqfDetails: sl()));
// }
