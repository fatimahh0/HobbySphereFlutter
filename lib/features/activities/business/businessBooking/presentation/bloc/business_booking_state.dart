import 'package:equatable/equatable.dart';
import '../../domain/entities/business_booking.dart';

class BusinessBookingState extends Equatable {
  final List<BusinessBooking> bookings;
  final bool loading;
  final String filter;
  final String? error; // one-shot
  final String? success; // one-shot
  final Set<int> busyIds;

  const BusinessBookingState({
    this.bookings = const [],
    this.loading = false,
    this.filter = 'all',
    this.error,
    this.success,
    this.busyIds = const {},
  });

  BusinessBookingState copyWith({
    List<BusinessBooking>? bookings,
    bool? loading,
    String? filter,
    String? error,
    String? success,
    Set<int>? busyIds,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BusinessBookingState(
      bookings: bookings ?? this.bookings,
      loading: loading ?? this.loading,
      filter: filter ?? this.filter,
      error: clearError ? null : (error ?? this.error),
      success: clearSuccess ? null : (success ?? this.success),
      busyIds: busyIds ?? this.busyIds,
    );
  }

  @override
  List<Object?> get props => [
    bookings,
    loading,
    filter,
    error,
    success,
    busyIds,
  ];
}
