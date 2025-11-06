part of 'insights_bloc.dart';

abstract class InsightsState {}

class InsightsLoading extends InsightsState {}

class InsightsLoaded extends InsightsState {
  final List<InsightBooking> bookings;
  InsightsLoaded(this.bookings);
}

class InsightsError extends InsightsState {
  final String message;
  InsightsError(this.message);
}
