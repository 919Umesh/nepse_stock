import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../business_logic/portfolio/portfolio_bloc.dart';
import '../../../business_logic/portfolio/portfolio_event.dart';
import '../../../business_logic/portfolio/portfolio_state.dart';
import '../../../business_logic/stock/stock_bloc.dart';
import '../../../business_logic/stock/stock_event.dart';
import '../../../business_logic/stock/stock_state.dart';
import '../../../business_logic/auth/auth_bloc.dart';
import '../../../business_logic/auth/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/route_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data
    context.read<PortfolioBloc>().add(const LoadPortfolio());
    context.read<StockBloc>().add(const LoadMarketOverview());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEPSE Trader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push(RouteConstants.profile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PortfolioBloc>().add(const RefreshPortfolio());
          context.read<StockBloc>().add(const LoadMarketOverview());
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          _buildWelcomeHeader(),
          const Divider(height: 1),

          // Portfolio summary
          _buildPortfolioSummary(),
          const SizedBox(height: 16),

          // Market overview
          _buildMarketOverview(),
          const SizedBox(height: 16),

          // Stock list
          _buildStockList(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = 'Trader';
        if (state is Authenticated) {
          name = state.user.fullName.split(' ').first;
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 8,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'NEPSE MARKET OPEN',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortfolioSummary() {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      builder: (context, state) {
        if (state is PortfolioLoaded) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Equity',
                  style: AppTextStyles.labelText,
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.formatCurrency(
                    state.portfolio.totalValue + state.wallet.balance,
                  ),
                  style: AppTextStyles.priceDisplay,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      state.portfolio.totalProfitLoss >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 20,
                      color: state.portfolio.totalProfitLoss >= 0
                          ? AppColors.successGreen
                          : AppColors.errorRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${Formatters.formatPercentage(state.portfolio.profitLossPercent, showPlus: true)} (${Formatters.formatCurrency(state.portfolio.totalProfitLoss)})',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: state.portfolio.totalProfitLoss >= 0
                            ? AppColors.successGreen
                            : AppColors.errorRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invested',
                            style: AppTextStyles.labelText,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatCompactCurrency(
                              state.portfolio.totalInvested,
                            ),
                            style: AppTextStyles.valueText,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available',
                            style: AppTextStyles.labelText,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatCompactCurrency(
                              state.wallet.balance,
                            ),
                            style: AppTextStyles.valueText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (state is PortfolioLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 180,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMarketOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Gainers',
                style: AppTextStyles.h4,
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        BlocBuilder<StockBloc, StockState>(
          builder: (context, state) {
            final overview = state.marketOverview;
            if (overview != null) {
              final gainers = overview.topGainers.take(5).toList();
              if (gainers.isEmpty) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: Text('No top gainers today')),
                );
              }
              return SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: gainers.length,
                  itemBuilder: (context, index) {
                    final gainer = gainers[index];
                    return _buildGainerCard(gainer);
                  },
                ),
              );
            } else if (state.status == StockStatus.loading) {
              return SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  itemBuilder: (context, index) => _buildShimmerGainerCard(),
                ),
              );
            } else if (state.status == StockStatus.failure) {
              return SizedBox(
                height: 120,
                child: Center(child: Text('Error: ${state.error}')),
              );
            }
            return const SizedBox(height: 120);
          },
        ),
      ],
    );
  }

  Widget _buildShimmerGainerCard() {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildGainerCard(dynamic gainer) {
    return GestureDetector(
      onTap: () => context.push('/stock/${gainer.symbol}'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.successGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    gainer.symbol,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: AppColors.successGreen,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.formatCurrency(gainer.currentPrice),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Formatters.formatPercentage(
                    gainer.changePercent,
                    showPlus: true,
                  ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'All Stocks',
            style: AppTextStyles.h4,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<StockBloc, StockState>(
          builder: (context, state) {
            final overview = state.marketOverview;
            if (overview != null) {
              final stocks = overview.mostActive;
              if (stocks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No stocks available')),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stocks.length > 10 ? 10 : stocks.length,
                itemBuilder: (context, index) {
                  final company = stocks[index];
                  return ListTile(
                    onTap: () => context.push('/stock/${company.symbol}'),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                      child: Text(
                        company.symbol.substring(0, company.symbol.length > 2 ? 2 : company.symbol.length),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(company.symbol, style: AppTextStyles.stockSymbol),
                    subtitle: Text(company.name, style: AppTextStyles.companyName),
                    trailing: const Icon(Icons.chevron_right),
                  );
                },
              );
            } else if (state.status == StockStatus.loading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state.status == StockStatus.failure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('Failed to load stocks: ${state.error}'),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
