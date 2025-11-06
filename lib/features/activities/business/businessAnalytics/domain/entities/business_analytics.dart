// ===== Flutter 3.35.x =====
// Domain entity: BusinessAnalytics

import 'package:equatable/equatable.dart';

class BusinessAnalytics extends Equatable {
  final double totalRevenue;
  final String topActivity;
  final double bookingGrowth;
  final String peakHours;
  final double customerRetention;
  final String analyticsDate;

  const BusinessAnalytics({
    required this.totalRevenue,
    required this.topActivity,
    required this.bookingGrowth,
    required this.peakHours,
    required this.customerRetention,
    required this.analyticsDate,
  });

  @override
  List<Object?> get props => [
    totalRevenue,
    topActivity,
    bookingGrowth,
    peakHours,
    customerRetention,
    analyticsDate,
  ];
}
