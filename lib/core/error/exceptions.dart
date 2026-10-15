/// Exceptions are thrown by data sources and translated into [Failure]s
/// at the repository boundary, so they never leak into the UI.
class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  const ServerException([this.message = 'Something went wrong on our side']);
  final String message;

  @override
  String toString() => 'ServerException: $message';
}
