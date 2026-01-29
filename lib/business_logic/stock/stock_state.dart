import 'package:equatable/equatable.dart';
import '../../data/models/stock/company_model.dart';
import '../../data/models/stock/stock_price_model.dart';
import '../../data/models/stock/market_overview_model.dart';
import '../../data/models/stock/price_history_model.dart';
import '../../data/models/stock/stock_event_model.dart';

enum StockStatus { initial, loading, success, failure }

/// Unified Stock State
class StockState extends Equatable {
  final StockStatus status;
  final String? error;

  // Market Overview (Home)
  final MarketOverviewModel? marketOverview;
  
  // All Companies (Markets)
  final List<CompanyModel> companies;
  final bool hasReachedMax;
  final int offset;

  // Sector Companies (Dynamic per sector)
  final Map<String, List<CompanyModel>> sectorCompanies;
  final Map<String, bool> sectorHasReachedMax;
  final Map<String, int> sectorOffsets;

  // Search
  final List<CompanyModel> searchResults;

  // Stock Detail
  final CompanyModel? selectedCompany;
  final StockPriceModel? currentPrice;
  final PriceHistoryModel? priceHistory;
  final List<StockEventModel>? events;
  final bool isHistoryLoading;

  const StockState({
    this.status = StockStatus.initial,
    this.error,
    this.marketOverview,
    this.companies = const [],
    this.hasReachedMax = false,
    this.offset = 0,
    this.sectorCompanies = const {},
    this.sectorHasReachedMax = const {},
    this.sectorOffsets = const {},
    this.searchResults = const [],
    this.selectedCompany,
    this.currentPrice,
    this.priceHistory,
    this.events,
    this.isHistoryLoading = false,
  });

  StockState copyWith({
    StockStatus? status,
    String? error,
    MarketOverviewModel? marketOverview,
    List<CompanyModel>? companies,
    bool? hasReachedMax,
    int? offset,
    Map<String, List<CompanyModel>>? sectorCompanies,
    Map<String, bool>? sectorHasReachedMax,
    Map<String, int>? sectorOffsets,
    List<CompanyModel>? searchResults,
    CompanyModel? selectedCompany,
    StockPriceModel? currentPrice,
    PriceHistoryModel? priceHistory,
    List<StockEventModel>? events,
    bool? isHistoryLoading,
  }) {
    return StockState(
      status: status ?? this.status,
      error: error ?? this.error,
      marketOverview: marketOverview ?? this.marketOverview,
      companies: companies ?? this.companies,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      offset: offset ?? this.offset,
      sectorCompanies: sectorCompanies ?? this.sectorCompanies,
      sectorHasReachedMax: sectorHasReachedMax ?? this.sectorHasReachedMax,
      sectorOffsets: sectorOffsets ?? this.sectorOffsets,
      searchResults: searchResults ?? this.searchResults,
      selectedCompany: selectedCompany ?? this.selectedCompany,
      currentPrice: currentPrice ?? this.currentPrice,
      priceHistory: priceHistory ?? this.priceHistory,
      events: events ?? this.events,
      isHistoryLoading: isHistoryLoading ?? this.isHistoryLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        marketOverview,
        companies,
        hasReachedMax,
        offset,
        sectorCompanies,
        sectorHasReachedMax,
        sectorOffsets,
        searchResults,
        selectedCompany,
        currentPrice,
        priceHistory,
        events,
        isHistoryLoading,
      ];
}
