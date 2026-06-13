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
