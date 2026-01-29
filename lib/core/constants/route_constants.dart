/// Route name constants
class RouteConstants {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String stockDetail = '/stock/:symbol';
  static const String buyStock = '/buy/:symbol';
  static const String sellStock = '/sell/:symbol';
  static const String portfolio = '/portfolio';
  static const String markets = '/markets';
  static const String sectorStocks = '/sector/:sector';
  static const String analytics = '/analytics/:symbol';
  static const String profile = '/profile';
  static const String transactions = '/transactions';
  
  // Route parameter keys
  static const String paramSymbol = 'symbol';
}
