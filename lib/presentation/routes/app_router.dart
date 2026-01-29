import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import '../../core/storage/local_storage.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/stock/stock_detail_screen.dart';
import '../screens/trading/buy_screen.dart';
import '../screens/trading/sell_screen.dart';
import '../screens/portfolio/portfolio_screen.dart';
import '../screens/profile/profile_screen.dart';

import '../screens/main_wrapper.dart';
import '../screens/stock/markets_screen.dart';
import '../screens/stock/sector_stocks_screen.dart';

/// App Router Configuration
class AppRouter {
  final LocalStorage _localStorage;
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  AppRouter({required LocalStorage localStorage})
      : _localStorage = localStorage;

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConstants.splash,
    redirect: (context, state) async {
      final isLoggedIn = _localStorage.isLoggedIn();
      final isGoingToAuth = state.matchedLocation == RouteConstants.login ||
          state.matchedLocation == RouteConstants.register;
      final isGoingToSplash = state.matchedLocation == RouteConstants.splash;

      if (!isLoggedIn && !isGoingToAuth && !isGoingToSplash) {
        return RouteConstants.login;
      }

      if (isLoggedIn && isGoingToAuth) {
        return RouteConstants.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main Shell Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Portfolio Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.portfolio,
                builder: (context, state) => const PortfolioScreen(),
              ),
            ],
          ),
          // Markets Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.markets,
                builder: (context, state) => const MarketsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Stock Detail (Global route to be on top of bottom nav)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteConstants.stockDetail,
        builder: (context, state) {
          final symbol = state.pathParameters[RouteConstants.paramSymbol]!;
          return StockDetailScreen(symbol: symbol);
        },
      ),

      // Sector Stocks
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteConstants.sectorStocks,
        builder: (context, state) {
          final sector = state.pathParameters['sector']!;
          return SectorStocksScreen(sector: sector);
        },
      ),

      // Buy/Sell
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteConstants.buyStock,
        builder: (context, state) {
          final symbol = state.pathParameters[RouteConstants.paramSymbol]!;
          return BuyScreen(symbol: symbol);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteConstants.sellStock,
        builder: (context, state) {
          final symbol = state.pathParameters[RouteConstants.paramSymbol]!;
          return SellScreen(symbol: symbol);
        },
      ),

      // Profile
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteConstants.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
