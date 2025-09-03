// ===== Flutter 3.35.x =====
import 'package:equatable/equatable.dart';

// clean representation of backend DTO
class BusinessAnalytics extends Equatable {
  final int totalBookings;
  final double totalRevenue;
  final int activeItems;
  final int completedBookings;
  final int canceledBookings;

  const BusinessAnalytics({
    required this.totalBookings,
    required this.totalRevenue,
    required this.activeItems,
    required this.completedBookings,
    required this.canceledBookings,
  });

  @override
  List<Object?> get props => [
    totalBookings,
    totalRevenue,
    activeItems,
    completedBookings,
    canceledBookings,
  ];
}
