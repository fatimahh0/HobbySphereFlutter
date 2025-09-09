part of 'insights_bloc.dart';

abstract class InsightsEvent {}

class LoadInsights extends InsightsEvent {
  final String token;
  LoadInsights(this.token);
}

class MarkAsPaid extends InsightsEvent {
  final String token;
  final int bookingId;
  MarkAsPaid(this.token, this.bookingId);
}
