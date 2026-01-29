/// Custom exceptions for error handling
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  ServerException({required this.message, this.statusCode});
  
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException({this.message = 'No internet connection'});
  
  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  
  CacheException({this.message = 'Cache error'});
  
  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  
  AuthException({this.message = 'Authentication failed'});
  
  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  
  ValidationException({required this.message});
  
  @override
  String toString() => message;
}
