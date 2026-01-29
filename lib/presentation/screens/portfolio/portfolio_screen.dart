import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../business_logic/portfolio/portfolio_bloc.dart';
import '../../../business_logic/portfolio/portfolio_event.dart';
import '../../../business_logic/portfolio/portfolio_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PortfolioBloc>().add(const LoadPortfolio());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PortfolioBloc>().add(const RefreshPortfolio());
            },
          ),
        ],
      ),
      body: BlocBuilder<PortfolioBloc, PortfolioState>(
        builder: (context, state) {
          if (state is PortfolioLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PortfolioBloc>().add(const RefreshPortfolio());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Portfolio summary
                    _buildPortfolioSummary(state),
                    const SizedBox(height: 16),

                    // Sector allocation
                    if (state.portfolio.holdings.isNotEmpty) ...[
                      _buildSectorAllocation(state),
                      const SizedBox(height: 16),
                    ],

                    // Holdings list
                    _buildHoldingsList(state),
                  ],
                ),
              ),
            );
          } else if (state is PortfolioLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PortfolioError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPortfolioSummary(PortfolioLoaded state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Value', style: AppTextStyles.labelText),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(state.portfolio.totalValue),
            style: AppTextStyles.priceDisplay,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                state.portfolio.totalProfitLoss >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: state.portfolio.totalProfitLoss >= 0
                    ? AppColors.successGreen
                    : AppColors.errorRed,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${Formatters.formatPercentage(state.portfolio.profitLossPercent, showPlus: true)} (${Formatters.formatCurrency(state.portfolio.totalProfitLoss)})',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: state.portfolio.totalProfitLoss >= 0
                      ? AppColors.successGreen
                      : AppColors.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Investment', style: AppTextStyles.labelText),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatCompactCurrency(state.portfolio.totalInvested),
                      style: AppTextStyles.valueText,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Cash', style: AppTextStyles.labelText),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatCompactCurrency(state.wallet.balance),
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
  }

  Widget _buildSectorAllocation(PortfolioLoaded state) {
    // Group holdings by sector
    Map<String, double> sectorMap = {};
    for (var holding in state.portfolio.holdings) {
      // This is simplified - in reality you'd need to fetch sector from company model
      final sector = 'Other'; // Placeholder
      sectorMap[sector] = (sectorMap[sector] ?? 0) + holding.currentValue;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sector Allocation', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _buildPieSections(sectorMap),
                centerSpaceRadius: 60,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> sectors) {
    final colors = [
      AppColors.sectorBanking,
      AppColors.sectorHydropower,
      AppColors.sectorInsurance,
      AppColors.sectorManufacturing,
      AppColors.sectorHotels,
      AppColors.sectorFinance,
    ];

    int index = 0;
    return sectors.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        value: entry.value,
        title: '',
        color: color,
        radius: 50,
      );
    }).toList();
  }

  Widget _buildHoldingsList(PortfolioLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current Holdings', style: AppTextStyles.h4),
              TextButton(
                onPressed: () {},
                child: const Text('Sort'),
              ),
            ],
          ),
        ),
        if (state.portfolio.holdings.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No holdings yet',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start buying stocks to build your portfolio',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.portfolio.holdings.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final holding = state.portfolio.holdings[index];
              return ListTile(
                onTap: () => context.push('/stock/${holding.companySymbol}'),
                leading: CircleAvatar(
                  backgroundColor: holding.profitLoss >= 0
                      ? AppColors.successGreen.withOpacity(0.2)
                      : AppColors.errorRed.withOpacity(0.2),
                  child: Text(
                    holding.companySymbol.substring(0, 2),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: holding.profitLoss >= 0
                          ? AppColors.successGreen
                          : AppColors.errorRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(holding.companySymbol, style: AppTextStyles.stockSymbol),
                subtitle: Text(
                  '${holding.quantity} units @ ${Formatters.formatCurrency(holding.avgBuyPrice, showSymbol: false)}',
                  style: AppTextStyles.bodySmall,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.formatCurrency(holding.currentValue),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${Formatters.formatPercentage(holding.profitLossPercent, showPlus: true)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: holding.profitLoss >= 0
                            ? AppColors.successGreen
                            : AppColors.errorRed,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
