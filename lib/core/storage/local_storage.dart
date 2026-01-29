import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Local Storage Service
class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();
  
  SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  /// Initialize storage
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  /// Auth Token (Secure Storage)
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: AppConstants.keyAuthToken, value: token);
  }
  
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConstants.keyAuthToken);
  }
  
  Future<void> deleteAuthToken() async {
    await _secureStorage.delete(key: AppConstants.keyAuthToken);
  }
  
  /// User ID
  Future<void> saveUserId(int userId) async {
    await _prefs?.setInt(AppConstants.keyUserId, userId);
  }
  
  int? getUserId() {
    return _prefs?.getInt(AppConstants.keyUserId);
  }
  
  /// User Email
  Future<void> saveUserEmail(String email) async {
    await _prefs?.setString(AppConstants.keyUserEmail, email);
  }
  
  String? getUserEmail() {
    return _prefs?.getString(AppConstants.keyUserEmail);
  }
  
  /// User Name
  Future<void> saveUserName(String name) async {
    await _prefs?.setString(AppConstants.keyUserName, name);
  }
  
  String? getUserName() {
    return _prefs?.getString(AppConstants.keyUserName);
  }
  
  /// Is Logged In
  Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool(AppConstants.keyIsLoggedIn, value);
  }
  
  bool isLoggedIn() {
    return _prefs?.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }
  
  /// Clear all data (on logout)
  Future<void> clearAll() async {
    await _prefs?.clear();
    await _secureStorage.deleteAll();
  }
}
