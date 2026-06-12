import 'package:get_it/get_it.dart';
import 'package:waqf_insight/core/network/api_client.dart';
import 'package:waqf_insight/core/network/network_info.dart';

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

  // Register feature dependencies here.
  // Example:
  // _initWaqfFeature();
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
