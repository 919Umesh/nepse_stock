/// Stock Event Model
class StockEventModel {
  final int id;
  final int companyId;
  final String eventType;
  final String title;
  final String description;
  final double? impactPercentage;
  final DateTime eventDate;

  StockEventModel({
    required this.id,
    required this.companyId,
    required this.eventType,
    required this.title,
    required this.description,
    this.impactPercentage,
    required this.eventDate,
  });

  factory StockEventModel.fromJson(Map<String, dynamic> json) {
    return StockEventModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      eventType: json['event_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      impactPercentage: json['impact_percentage'] != null
          ? (json['impact_percentage'] as num).toDouble()
          : null,
      eventDate: DateTime.parse(json['event_date'] as String),
    );
  }
}
