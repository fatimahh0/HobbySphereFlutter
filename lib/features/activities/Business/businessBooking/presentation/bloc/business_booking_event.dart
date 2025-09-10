import 'package:equatable/equatable.dart';

abstract class BusinessBookingEvent extends Equatable {
  const BusinessBookingEvent();

  @override
  List<Object?> get props => [];
}

// Bootstrap: fetch all bookings
class BusinessBookingBootstrap extends BusinessBookingEvent {}

// Filter bookings
class BusinessBookingFilterChanged extends BusinessBookingEvent {
  final String filter;
  const BusinessBookingFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

// Reject a booking
class RejectBooking extends BusinessBookingEvent {
  final int bookingId;
  const RejectBooking(this.bookingId);
}

// Unreject (back to pending)
class UnrejectBooking extends BusinessBookingEvent {
  final int bookingId;
  const UnrejectBooking(this.bookingId);
}

// Mark as paid
class MarkPaidBooking extends BusinessBookingEvent {
  final int bookingId;
  const MarkPaidBooking(this.bookingId);
}

// Approve cancel
class ApproveCancelBooking extends BusinessBookingEvent {
  final int bookingId;
  const ApproveCancelBooking(this.bookingId);
}

// Reject cancel
class RejectCancelBooking extends BusinessBookingEvent {
  final int bookingId;
  const RejectCancelBooking(this.bookingId);
}
