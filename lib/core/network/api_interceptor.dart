import 'package:dio/dio.dart';
import '../storage/local_storage.dart';
import '../errors/exceptions.dart';

/// API Interceptor for handling auth tokens and errors
class ApiInterceptor extends Interceptor {
  final LocalStorage _localStorage = LocalStorage();
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token if available
    final token = await _localStorage.getAuthToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please try again.';
        break;
        
      case DioExceptionType.badResponse:
        message = _handleStatusCode(err.response?.statusCode, err.response?.data);
        break;
        
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
        
      case DioExceptionType.unknown:
        message = 'No internet connection';
        break;
        
      default:
        message = 'Something went wrong';
    }
    
    final exception = ServerException(
      message: message,
      statusCode: err.response?.statusCode,
    );
    
    handler.next(err.copyWith(
      error: exception,
    ));
  }
  
  String _handleStatusCode(int? statusCode, dynamic responseData) {
    switch (statusCode) {
      case 400:
        // Try to extract message from response
        if (responseData is Map && responseData['message'] != null) {
          return responseData['message'];
        }
        return 'Bad request';
        
      case 401:
        return 'Unauthorized. Please login again.';
        
      case 403:
        return 'Access forbidden';
        
      case 404:
        return 'Resource not found';
        
      case 409:
        if (responseData is Map && responseData['message'] != null) {
          return responseData['message'];
        }
        return 'Conflict';
        
      case 500:
        return 'Server error. Please try again later.';
        
      default:
        return 'Something went wrong';
    }
  }
}
