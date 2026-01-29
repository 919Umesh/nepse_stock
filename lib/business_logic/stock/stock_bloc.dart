import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/stock_repository.dart';
import 'stock_event.dart';
import 'stock_state.dart';
import '../../data/models/stock/company_model.dart';

/// Stock BLoC
class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository _stockRepository;

  StockBloc({required StockRepository stockRepository})
      : _stockRepository = stockRepository,
        super(const StockState()) {
    on<LoadCompanies>(_onLoadCompanies);
    on<SearchCompanies>(_onSearchCompanies);
    on<LoadCompaniesBySector>(_onLoadCompaniesBySector);
    on<LoadCompanyDetails>(_onLoadCompanyDetails);
    on<LoadStockPrice>(_onLoadStockPrice);
    on<LoadPriceHistory>(_onLoadPriceHistory);
    on<LoadMarketOverview>(_onLoadMarketOverview);
    on<LoadTopGainers>(_onLoadTopGainers);
    on<LoadTopLosers>(_onLoadTopLosers);
  }

  Future<void> _onLoadCompanies(
    LoadCompanies event,
    Emitter<StockState> emit,
  ) async {
    final currentCompanies = event.isRefresh ? <CompanyModel>[] : state.companies;
    final currentOffset = event.isRefresh ? 0 : state.offset;

    if (!event.isRefresh && state.hasReachedMax) return;

    emit(state.copyWith(status: StockStatus.loading));

    try {
      final companies = await _stockRepository.getCompanies(
        limit: event.limit,
        offset: currentOffset,
      );
      
      emit(state.copyWith(
        status: StockStatus.success,
        companies: currentCompanies + companies,
        hasReachedMax: companies.length < event.limit,
        offset: currentOffset + companies.length,
      ));
    } catch (e) {
      emit(state.copyWith(status: StockStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onSearchCompanies(
    SearchCompanies event,
    Emitter<StockState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }
    
    emit(state.copyWith(status: StockStatus.loading));
    
    try {
      final companies = await _stockRepository.searchCompanies(event.query);
      emit(state.copyWith(status: StockStatus.success, searchResults: companies));
    } catch (e) {
      emit(state.copyWith(status: StockStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onLoadCompaniesBySector(
    LoadCompaniesBySector event,
    Emitter<StockState> emit,
  ) async {
    final sector = event.sector;
    final currentCompaniesList = event.isRefresh ? <CompanyModel>[] : (state.sectorCompanies[sector] ?? []);
    final currentOffset = event.isRefresh ? 0 : (state.sectorOffsets[sector] ?? 0);

    if (!event.isRefresh && (state.sectorHasReachedMax[sector] ?? false)) return;

    emit(state.copyWith(status: StockStatus.loading));

    try {
      final companies = await _stockRepository.getCompaniesBySector(
        sector,
        limit: event.limit,
        offset: currentOffset,
      );
      
      final updatedSectorCompanies = Map<String, List<CompanyModel>>.from(state.sectorCompanies);
      final updatedSectorHasReachedMax = Map<String, bool>.from(state.sectorHasReachedMax);
      final updatedSectorOffsets = Map<String, int>.from(state.sectorOffsets);

      updatedSectorCompanies[sector] = currentCompaniesList + companies;
      updatedSectorHasReachedMax[sector] = companies.length < event.limit;
      updatedSectorOffsets[sector] = currentOffset + companies.length;

      emit(state.copyWith(
        status: StockStatus.success,
        sectorCompanies: updatedSectorCompanies,
        sectorHasReachedMax: updatedSectorHasReachedMax,
        sectorOffsets: updatedSectorOffsets,
      ));
    } catch (e) {
      emit(state.copyWith(status: StockStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onLoadCompanyDetails(
    LoadCompanyDetails event,
    Emitter<StockState> emit,
  ) async {
    emit(state.copyWith(status: StockStatus.loading));
    
    try {
      final company = await _stockRepository.getCompanyDetails(event.symbol);
      final price = await _stockRepository.getCurrentPrice(event.symbol);
      final events = await _stockRepository.getStockEvents(event.symbol);
      
      emit(state.copyWith(
        status: StockStatus.success,
        selectedCompany: company,
        currentPrice: price,
        events: events,
      ));
    } catch (e) {
      emit(state.copyWith(status: StockStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onLoadStockPrice(
    LoadStockPrice event,
    Emitter<StockState> emit,
  ) async {
    try {
      final price = await _stockRepository.getCurrentPrice(event.symbol);
      emit(state.copyWith(currentPrice: price));
    } catch (e) {
      // Silent error for background updates
    }
  }

  Future<void> _onLoadPriceHistory(
    LoadPriceHistory event,
    Emitter<StockState> emit,
  ) async {
    emit(state.copyWith(isHistoryLoading: true));
    
    try {
      final priceHistory = await _stockRepository.getPriceHistory(
        event.symbol,
        timeframe: event.timeframe,
        days: event.days,
      );
      
      emit(state.copyWith(
        priceHistory: priceHistory,
        isHistoryLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isHistoryLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadMarketOverview(
    LoadMarketOverview event,
    Emitter<StockState> emit,
  ) async {
    emit(state.copyWith(status: StockStatus.loading));
    
    try {
      final overview = await _stockRepository.getMarketOverview();
      emit(state.copyWith(status: StockStatus.success, marketOverview: overview));
    } catch (e) {
      emit(state.copyWith(status: StockStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onLoadTopGainers(
    LoadTopGainers event,
    Emitter<StockState> emit,
  ) async {
    try {
      // Note: MarketOverview already contains top gainers. 
      // This event could be used for a dedicated "Top Gainers" screen.
      final gainers = await _stockRepository.getTopGainers(limit: event.limit);
      // For now, we'll just update the overview if it exists, or handle separately if needed.
    } catch (e) {
      emit(state.copyWith(status: StockStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onLoadTopLosers(
    LoadTopLosers event,
    Emitter<StockState> emit,
  ) async {
    try {
      final losers = await _stockRepository.getTopLosers(limit: event.limit);
    } catch (e) {
      emit(state.copyWith(status: StockStatus.failure, error: e.toString()));
    }
  }
}
