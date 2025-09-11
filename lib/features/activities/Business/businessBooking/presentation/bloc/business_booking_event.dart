import 'package:equatable/equatable.dart';

abstract class BusinessBookingEvent extends Equatable {
  const BusinessBookingEvent();
  @override
  List<Object?> get props => [];
}

// Load all
class BusinessBookingBootstrap extends BusinessBookingEvent {}

// Change filter (all | pending | completed | rejected | canceled)
class BusinessBookingFilterChanged extends BusinessBookingEvent {
  final String filter;
  const BusinessBookingFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

// Actions
class RejectBooking extends BusinessBookingEvent {
  final int bookingId;
  const RejectBooking(this.bookingId);
}

class UnrejectBooking extends BusinessBookingEvent {
  final int bookingId;
  const UnrejectBooking(this.bookingId);
}

class MarkPaidBooking extends BusinessBookingEvent {
  final int bookingId;
  const MarkPaidBooking(this.bookingId);
}

class ApproveCancelBooking extends BusinessBookingEvent {
  final int bookingId;
  const ApproveCancelBooking(this.bookingId);
}

class RejectCancelBooking extends BusinessBookingEvent {
  final int bookingId;
  const RejectCancelBooking(this.bookingId);
}

// One-shot flash clear (to clear success/error after toast)
class BusinessBookingClearFlash extends BusinessBookingEvent {}
