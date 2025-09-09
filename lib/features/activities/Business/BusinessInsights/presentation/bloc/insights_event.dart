part of 'insights_bloc.dart';

abstract class InsightsEvent {}

class LoadInsights extends InsightsEvent {
  final String token;
  final int itemId; 

  LoadInsights(this.token, {required this.itemId});
}

class MarkAsPaid extends InsightsEvent {
  final String token;
  final int bookingId;
  final int itemId; 

  MarkAsPaid(this.token, this.bookingId, {required this.itemId});
}
