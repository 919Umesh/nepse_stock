import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/local_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/auth/user_model.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/auth/auth_response.dart';

/// Authentication Repository
class AuthRepository {
  final DioClient _dioClient;
  final LocalStorage _localStorage;

  AuthRepository({
    required DioClient dioClient,
    required LocalStorage localStorage,
  })  : _dioClient = dioClient,
        _localStorage = localStorage;

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      
      // Save auth data
      await _saveAuthData(authResponse);
      
      return authResponse;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Registration failed');
    }
  }

  /// Login user
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      
      // Save auth data
      await _saveAuthData(authResponse);
      
      return authResponse;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Login failed');
    }
  }

  /// Get user profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _dioClient.get(ApiConstants.profile);
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to load profile');
    }
  }

  /// Update profile
  Future<UserModel> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    try {
      final response = await _dioClient.put(
        ApiConstants.updateProfile,
        data: {
          'full_name': fullName,
          'phone': phone,
        },
      );
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: 'Failed to update profile');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _localStorage.clearAll();
    _dioClient.removeAuthToken();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _localStorage.getAuthToken();
    return token != null;
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    final isUserLoggedIn = await isLoggedIn();
    if (!isUserLoggedIn) return null;
    
    try {
      return await getProfile();
    } catch (e) {
      return null;
    }
  }

  /// Save auth data to local storage
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _localStorage.saveAuthToken(authResponse.token);
    await _localStorage.saveUserId(authResponse.user.id);
    await _localStorage.saveUserEmail(authResponse.user.email);
    await _localStorage.saveUserName(authResponse.user.fullName);
    await _localStorage.setLoggedIn(true);
    _dioClient.setAuthToken(authResponse.token);
  }
}
