class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}
