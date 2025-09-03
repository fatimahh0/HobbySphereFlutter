// ===== Flutter 3.35.x =====
// BusinessBookingState — immutable state for business bookings

import 'package:equatable/equatable.dart';
import '../../domain/entities/business_booking.dart';

class BusinessBookingState extends Equatable {
  final List<BusinessBooking> bookings; // all bookings
  final bool loading; // show loader
  final String filter; // current filter (all, pending...)
  final String? error; // optional error message

  const BusinessBookingState({
    this.bookings = const [],
    this.loading = false,
    this.filter = 'all',
    this.error,
  });

  BusinessBookingState copyWith({
    List<BusinessBooking>? bookings,
    bool? loading,
    String? filter,
    String? error,
  }) {
    return BusinessBookingState(
      bookings: bookings ?? this.bookings,
      loading: loading ?? this.loading,
      filter: filter ?? this.filter,
      error: error,
    );
  }

  @override
  List<Object?> get props => [bookings, loading, filter, error];
}
