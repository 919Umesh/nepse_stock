import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../business_logic/stock/stock_bloc.dart';
import '../../../business_logic/stock/stock_event.dart';
import '../../../business_logic/stock/stock_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/route_constants.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    context.read<StockBloc>().add(const LoadCompanies(isRefresh: true));
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<StockBloc>().add(const LoadCompanies());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  final List<Map<String, dynamic>> _sectors = [
    {'name': 'Banking', 'icon': Icons.account_balance, 'color': AppColors.sectorBanking},
    {'name': 'Hydropower', 'icon': Icons.water_drop, 'color': AppColors.sectorHydropower},
    {'name': 'Insurance', 'icon': Icons.security, 'color': AppColors.sectorInsurance},
    {'name': 'Manufacturing', 'icon': Icons.factory, 'color': AppColors.sectorManufacturing},
    {'name': 'Hotels', 'icon': Icons.hotel, 'color': AppColors.sectorHotels},
    {'name': 'Finance', 'icon': Icons.monetization_on, 'color': AppColors.sectorFinance},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: StockSearchDelegate(stockBloc: context.read<StockBloc>()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialData();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Sectors Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Sectors', style: AppTextStyles.h4),
              ),
            ),

            // Sectors Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final sector = _sectors[index];
                    return _buildSectorCard(sector);
                  },
                  childCount: _sectors.length,
                ),
              ),
            ),

            // All Stocks Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text('All Companies', style: AppTextStyles.h4),
              ),
            ),

            // Stocks List
            BlocBuilder<StockBloc, StockState>(
              builder: (context, state) {
                if (state.companies.isNotEmpty) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= state.companies.length) {
                          return state.hasReachedMax
                              ? const SizedBox.shrink()
                              : const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                        }
                        final company = state.companies[index];
                        return _buildStockTile(company);
                      },
                      childCount: state.companies.length + 1,
                    ),
                  );
                } else if (state.status == StockStatus.loading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state.status == StockStatus.failure) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${state.error}'),
                          TextButton(
                            onPressed: _loadInitialData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorCard(Map<String, dynamic> sector) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.sectorStocks.replaceFirst(':sector', sector['name'])),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sector['icon'], color: sector['color'], size: 32),
            const SizedBox(height: 8),
            Text(
              sector['name'],
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockTile(dynamic company) {
    return ListTile(
      onTap: () => context.push('/stock/${company.symbol}'),
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
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
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          Text(
            company.sector,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class StockSearchDelegate extends SearchDelegate {
  final StockBloc stockBloc;

  StockSearchDelegate({required this.stockBloc});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    stockBloc.add(SearchCompanies(query: query));

    return BlocBuilder<StockBloc, StockState>(
      bloc: stockBloc,
      builder: (context, state) {
        if (state.searchResults.isNotEmpty) {
          return ListView.builder(
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final company = state.searchResults[index];
              return ListTile(
                onTap: () {
                  close(context, null);
                  context.push('/stock/${company.symbol}');
                },
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  child: Text(company.symbol.substring(0, 2)),
                ),
                title: Text(company.symbol),
                subtitle: Text(company.name),
              );
            },
          );
        } else if (state.status == StockStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.status == StockStatus.failure) {
          return Center(child: Text('Error: ${state.error}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 2) {
      return const Center(child: Text('Type at least 2 characters to search'));
    }

    stockBloc.add(SearchCompanies(query: query));

    return BlocBuilder<StockBloc, StockState>(
      bloc: stockBloc,
      builder: (context, state) {
        if (state.searchResults.isNotEmpty) {
          return ListView.builder(
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final company = state.searchResults[index];
              return ListTile(
                onTap: () {
                  close(context, null);
                  context.push('/stock/${company.symbol}');
                },
                title: Text(company.symbol),
                subtitle: Text(company.name),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
