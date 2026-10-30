/// Base type for every error the data layer reports to the UI.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Your session has expired. Please sign in again.',
  ]) : super(statusCode: 401);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'The requested item was not found.'])
    : super(statusCode: 404);
}

class ServerException extends ApiException {
  const ServerException([
    super.message = 'Something went wrong on the server. Please try again.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}
