// ===== Flutter 3.35.x =====
// Events for BusinessBookingBloc
// Each event represents a user action or lifecycle trigger.

import 'package:equatable/equatable.dart';

abstract class BusinessBookingEvent extends Equatable {
  const BusinessBookingEvent();

  @override
  List<Object?> get props => [];
}

// Bootstrap: fetch all bookings when screen loads
class BusinessBookingBootstrap extends BusinessBookingEvent {}

// Filter bookings by status (all, pending, completed, rejected, canceled)
class BusinessBookingFilterChanged extends BusinessBookingEvent {
  final String filter;
  const BusinessBookingFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

// Reject a booking by ID
class RejectBooking extends BusinessBookingEvent {
  final int bookingId;
  const RejectBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

// Unreject (move rejected back to pending)
class UnrejectBooking extends BusinessBookingEvent {
  final int bookingId;
  const UnrejectBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

// Mark a booking as paid
class MarkPaidBooking extends BusinessBookingEvent {
  final int bookingId;
  const MarkPaidBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}
