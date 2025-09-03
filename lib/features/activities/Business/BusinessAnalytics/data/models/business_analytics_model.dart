import '../../domain/entities/business_analytics.dart';

class BusinessAnalyticsModel extends BusinessAnalytics {
  const BusinessAnalyticsModel({
    required int totalBookings,
    required double totalRevenue,
    required int activeItems,
    required int completedBookings,
    required int canceledBookings,
  }) : super(
         totalBookings: totalBookings,
         totalRevenue: totalRevenue,
         activeItems: activeItems,
         completedBookings: completedBookings,
         canceledBookings: canceledBookings,
       );

  factory BusinessAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return BusinessAnalyticsModel(
      totalBookings: (json['totalBookings'] ?? 0) as int,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      activeItems: (json['activeItems'] ?? 0) as int,
      completedBookings: (json['completedBookings'] ?? 0) as int,
      canceledBookings: (json['canceledBookings'] ?? 0) as int,
    );
  }
}
