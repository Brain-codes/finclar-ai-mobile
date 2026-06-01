class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ApiException extends AppException {
  final int? statusCode;
  const ApiException(super.message, {this.statusCode});
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(super.message) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message) : super(statusCode: 404);
}

class ValidationException extends ApiException {
  const ValidationException(super.message) : super(statusCode: 422);
}

class ServerException extends ApiException {
  const ServerException(super.message) : super(statusCode: 500);
}

class ConflictException extends ApiException {
  const ConflictException(super.message) : super(statusCode: 409);
}

class CacheException extends AppException {
  const CacheException(super.message);
}
