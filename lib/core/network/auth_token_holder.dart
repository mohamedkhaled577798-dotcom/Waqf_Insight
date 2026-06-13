/// In-memory holder for the current JWT, synced with local storage.
class AuthTokenHolder {
  String? _token;

  String? get token => _token;

  void setToken(String? token) => _token = token;

  void clear() => _token = null;
}
