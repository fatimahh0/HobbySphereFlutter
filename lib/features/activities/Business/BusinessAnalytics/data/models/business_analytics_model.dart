import '../../domain/entities/business_analytics.dart';

class BusinessAnalyticsModel extends BusinessAnalytics {
  const BusinessAnalyticsModel({
    required double totalRevenue,
    required String topActivity,
    required double bookingGrowth,
    required String peakHours,
    required double customerRetention,
    required String analyticsDate,
  }) : super(
         totalRevenue: totalRevenue,
         topActivity: topActivity,
         bookingGrowth: bookingGrowth,
         peakHours: peakHours,
         customerRetention: customerRetention,
         analyticsDate: analyticsDate,
       );

  factory BusinessAnalyticsModel.fromJson(Map<String, dynamic> json) {
    print("🔍 Backend Analytics JSON: $json"); // 👈 Debug log

    return BusinessAnalyticsModel(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      topActivity: (json['topActivity'] ?? 'N/A').toString(),
      bookingGrowth: (json['bookingGrowth'] ?? 0).toDouble(),
      peakHours: (json['peakHours'] ?? 'N/A').toString(),
      customerRetention: (json['customerRetention'] ?? 0).toDouble(),
      analyticsDate: (json['analyticsDate'] ?? '').toString(),
    );
  }
}
