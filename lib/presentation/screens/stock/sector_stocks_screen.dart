import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../business_logic/stock/stock_bloc.dart';
import '../../../business_logic/stock/stock_event.dart';
import '../../../business_logic/stock/stock_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SectorStocksScreen extends StatefulWidget {
  final String sector;
  const SectorStocksScreen({super.key, required this.sector});

  @override
  State<SectorStocksScreen> createState() => _SectorStocksScreenState();
}

class _SectorStocksScreenState extends State<SectorStocksScreen> {
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
    context.read<StockBloc>().add(LoadCompaniesBySector(sector: widget.sector, isRefresh: true));
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<StockBloc>().add(LoadCompaniesBySector(sector: widget.sector));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.sector} Stocks'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialData();
        },
        child: BlocBuilder<StockBloc, StockState>(
          builder: (context, state) {
            final sectorCompanies = state.sectorCompanies[widget.sector] ?? [];
            final hasReachedMax = state.sectorHasReachedMax[widget.sector] ?? false;

            if (sectorCompanies.isNotEmpty) {
              return ListView.builder(
                controller: _scrollController,
                itemCount: sectorCompanies.length + 1,
                itemBuilder: (context, index) {
                  if (index >= sectorCompanies.length) {
                    return hasReachedMax
                        ? const SizedBox.shrink()
                        : const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          );
                  }
                  final company = sectorCompanies[index];
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
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                  );
                },
              );
            } else if (state.status == StockStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == StockStatus.failure) {
              return Center(
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
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
