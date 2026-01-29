import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/network/dio_client.dart';
import 'core/storage/local_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/stock_repository.dart';
import 'data/repositories/trading_repository.dart';
import 'business_logic/auth/auth_bloc.dart';
import 'business_logic/stock/stock_bloc.dart';
import 'business_logic/trading/trading_bloc.dart';
import 'business_logic/portfolio/portfolio_bloc.dart';
import 'presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage
  final localStorage = LocalStorage();
  await localStorage.init();
  
  // Initialize HTTP client
  final dioClient = DioClient();
  
  // Initialize repositories
  final authRepository = AuthRepository(
    dioClient: dioClient,
    localStorage: localStorage,
  );
  final stockRepository = StockRepository(dioClient: dioClient);
  final tradingRepository = TradingRepository(dioClient: dioClient);
  
  // Initialize router
  final appRouter = AppRouter(localStorage: localStorage);
  
  runApp(
    NepseApp(
      authRepository: authRepository,
      stockRepository: stockRepository,
      tradingRepository: tradingRepository,
      appRouter: appRouter,
    ),
  );
}

class NepseApp extends StatelessWidget {
  final AuthRepository authRepository;
  final StockRepository stockRepository;
  final TradingRepository tradingRepository;
  final AppRouter appRouter;

  const NepseApp({
    super.key,
    required this.authRepository,
    required this.stockRepository,
    required this.tradingRepository,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<StockBloc>(
          create: (context) => StockBloc(stockRepository: stockRepository),
        ),
        BlocProvider<TradingBloc>(
          create: (context) => TradingBloc(tradingRepository: tradingRepository),
        ),
        BlocProvider<PortfolioBloc>(
          create: (context) => PortfolioBloc(tradingRepository: tradingRepository),
        ),
      ],
      child: MaterialApp.router(
        title: 'NEPSE Trader',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter.router,
      ),
    );
  }
}
