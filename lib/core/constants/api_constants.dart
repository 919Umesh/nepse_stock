/// API Configuration Constants
class ApiConstants {
  // Base URL - Update this for your environment
 // static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String baseUrl = 'https://gold-go-app.onrender.com/api/v1';
  
  
  // For production, use:
  // static const String baseUrl = 'https://your-app.onrender.com/api/v1';
  
  // Endpoints
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile/update';
  
  // Stocks
  static const String stocks = '/stocks';
  static String stockDetail(String symbol) => '/stocks/$symbol';
  static String stockPrice(String symbol) => '/stocks/$symbol/price';
  static String stockHistory(String symbol) => '/stocks/$symbol/history';
  static String stockEvents(String symbol) => '/stocks/$symbol/events';
  static const String searchStocks = '/stocks/search';
  static String sectorStocks(String sector) => '/stocks/sector/$sector';
  static const String marketOverview = '/stocks/market-overview';
  static const String topGainers = '/stocks/top-gainers';
  static const String topLosers = '/stocks/top-losers';
  static const String mostActive = '/stocks/most-active';
  
  // Trading
  static const String virtualWallet = '/trading/wallet';
  static const String portfolio = '/trading/portfolio';
  static const String buyStock = '/trading/buy';
  static const String sellStock = '/trading/sell';
  static const String transactions = '/trading/transactions';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
