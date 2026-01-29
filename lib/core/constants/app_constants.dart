/// Application-wide Constants
class AppConstants {
  // App Info
  static const String appName = 'NEPSE Trader';
  static const String appVersion = '1.0.0';
  
  // Local Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyIsLoggedIn = 'is_logged_in';
  
  // Default Values
  static const double initialVirtualBalance = 1000000.0; // NPR 10 lakh
  
  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;
  
  // Market Hours (Nepal Time)
  static const int marketOpenHour = 11;
  static const int marketCloseHour = 15;
  
  // Refresh Intervals
  static const Duration priceRefreshInterval = Duration(seconds: 30);
  static const Duration portfolioRefreshInterval = Duration(minutes: 1);
  
  // Chart Timeframes
  static const List<String> chartTimeframes = ['1D', '1W', '1M', '1Y', 'ALL'];
  
  // Sectors
  static const List<String> sectors = [
    'Banking',
    'Hydropower',
    'Insurance',
    'Manufacturing',
    'Hotels',
    'Finance',
  ];
}
