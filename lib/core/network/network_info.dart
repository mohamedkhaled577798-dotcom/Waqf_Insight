/// Abstraction for checking network connectivity.
///
/// Used by repositories to determine whether to fetch from remote
/// or fall back to cached data.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  // TODO: Inject InternetConnectionChecker or connectivity_plus here.
  // For now, defaults to true.
  //
  // Example with internet_connection_checker:
  // final InternetConnectionChecker connectionChecker;
  // NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async => true;
}
