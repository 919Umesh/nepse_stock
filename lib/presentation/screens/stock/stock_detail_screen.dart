import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../business_logic/stock/stock_bloc.dart';
import '../../../business_logic/stock/stock_event.dart';
import '../../../business_logic/stock/stock_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/stock/price_history_model.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;

  const StockDetailScreen({super.key, required this.symbol});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  String _selectedTimeframe = '1D';
  final List<String> _timeframes = ['1D', '1W', '1M', '1Y', 'ALL'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<StockBloc>().add(LoadCompanyDetails(symbol: widget.symbol));
    _loadPriceHistory();
  }

  void _loadPriceHistory() {
    String timeframe = '1d';
    int days = 7;

    switch (_selectedTimeframe) {
      case '1W':
        timeframe = '1d';
        days = 7;
        break;
      case '1M':
        timeframe = '1d';
        days = 30;
        break;
      case '1Y':
        timeframe = '1d';
        days = 365;
        break;
      case 'ALL':
        timeframe = '1d';
        days = 365;
        break;
      default:
        timeframe = '1d';
        days = 1;
    }

    context.read<StockBloc>().add(LoadPriceHistory(
          symbol: widget.symbol,
          timeframe: timeframe,
          days: days,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          final company = state.selectedCompany;
          final price = state.currentPrice;

          if (company != null) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company info and price
                  _buildPriceHeader(company, price),
                  const SizedBox(height: 16),

                  // Timeframe selector
                  _buildTimeframeSelector(),
                  const SizedBox(height: 16),

                  // Chart
                  _buildChart(state),
                  const SizedBox(height: 16),

                  // Action buttons
                  _buildActionButtons(),
                  const SizedBox(height: 16),

                  // Description
                  _buildAboutCompany(company),

                  // Fundamentals
                  _buildFundamentals(company),
                  
                  // Recent Events
                  _buildRecentEvents(state),
                  const SizedBox(height: 32),
                ],
              ),
            );
          } else if (state.status == StockStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == StockStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPriceHeader(dynamic company, dynamic price) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(company.name, style: AppTextStyles.companyName),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price != null
                    ? Formatters.formatCurrency(price.closePrice, showSymbol: false)
                    : '...',
                style: AppTextStyles.priceDisplay,
              ),
              const SizedBox(width: 12),
              if (price != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: price.change >= 0
                        ? AppColors.successGreen.withOpacity(0.2)
                        : AppColors.errorRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        price.change >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 14,
                        color: price.change >= 0
                            ? AppColors.successGreen
                            : AppColors.errorRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.formatPercentage(price.changePercent),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: price.change >= 0
                              ? AppColors.successGreen
                              : AppColors.errorRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (price != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPriceInfo('High', Formatters.formatCurrency(price.highPrice, showSymbol: false)),
                ),
                Expanded(
                  child: _buildPriceInfo('Low', Formatters.formatCurrency(price.lowPrice, showSymbol: false)),
                ),
                Expanded(
                  child: _buildPriceInfo('Volume', Formatters.formatCompactCurrency(price.volume.toDouble())),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelText),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCompany(dynamic company) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About ${company.symbol}', style: AppTextStyles.h4),
          const SizedBox(height: 12),
          Text(
            company.description ?? 'No description available for this company.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFundamentals(dynamic company) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fundamentals', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _buildFundamentalRow('Sector', company.sector),
          _buildFundamentalRow(
            'Market Cap',
            Formatters.formatCompactCurrency(company.marketCap),
          ),
          if (company.foundedYear != null)
            _buildFundamentalRow('Founded', company.foundedYear.toString()),
          if (company.employees != null)
            _buildFundamentalRow('Employees', company.employees.toString()),
        ],
      ),
    );
  }

  Widget _buildRecentEvents(StockState state) {
    final events = state.events;
    if (events == null || events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Events', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            const Text('No recent events for this company.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Events', style: AppTextStyles.h4),
          const SizedBox(height: 12),
          ...events.map((event) => _buildEventTile(event)),
        ],
      ),
    );
  }

  Widget _buildEventTile(dynamic event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                Formatters.formatDate(event.eventDate),
                style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            event.description,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          if (event.impactPercentage != 0) ...[
            const SizedBox(height: 8),
            Text(
              'Impact: ${event.impactPercentage > 0 ? '+' : ''}${event.impactPercentage}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: event.impactPercentage > 0 ? AppColors.successGreen : AppColors.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChart(StockState state) {
    if (state.isHistoryLoading && state.priceHistory == null) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final history = state.priceHistory;
    if (history == null || history.prices.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('No history data available')),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: DateTimeAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
            ),
            primaryYAxis: NumericAxis(
              majorGridLines: const MajorGridLines(
                width: 0.5,
                color: AppColors.surfaceColor,
              ),
              axisLine: const AxisLine(width: 0),
            ),
            series: <CartesianSeries<PriceDataPoint, DateTime>>[
              AreaSeries<PriceDataPoint, DateTime>(
                dataSource: history.prices,
                xValueMapper: (PriceDataPoint price, _) => price.timestamp,
                yValueMapper: (PriceDataPoint price, _) => price.closePrice,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.3),
                    AppColors.primaryGreen.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderColor: AppColors.primaryGreen,
                borderWidth: 2,
              ),
            ],
          ),
          if (state.isHistoryLoading)
            const Positioned(
              top: 8,
              right: 8,
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _timeframes.length,
        itemBuilder: (context, index) {
          final tf = _timeframes[index];
          final isSelected = _selectedTimeframe == tf;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tf),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedTimeframe = tf;
                  });
                  _loadPriceHistory();
                }
              },
              backgroundColor: AppColors.cardBackground,
              selectedColor: AppColors.primaryGreen,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.push('/buy/${widget.symbol}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('BUY'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.push('/sell/${widget.symbol}'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.errorRed,
                side: const BorderSide(color: AppColors.errorRed),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('SELL'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundamentalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          )),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}
