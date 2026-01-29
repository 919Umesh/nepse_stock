import 'package:equatable/equatable.dart';

/// Company Model
class CompanyModel extends Equatable {
  final int id;
  final String symbol;
  final String name;
  final String sector;
  final double marketCap;
  final String description;
  final int? foundedYear;
  final int? employees;
  final bool isActive;

  const CompanyModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.sector,
    required this.marketCap,
    required this.description,
    this.foundedYear,
    this.employees,
    this.isActive = true,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      sector: json['sector'] as String,
      marketCap: (json['market_cap'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      foundedYear: json['founded_year'] as int?,
      employees: json['employees'] as int?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'sector': sector,
      'market_cap': marketCap,
      'description': description,
      'founded_year': foundedYear,
      'employees': employees,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        symbol,
        name,
        sector,
        marketCap,
        description,
        foundedYear,
        employees,
        isActive,
      ];
}
