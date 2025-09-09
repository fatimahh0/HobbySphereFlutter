import 'package:equatable/equatable.dart';

class InsightBooking extends Equatable {
  final int id;
  final String clientName;
  final String itemName;
  final bool wasPaid;

  const InsightBooking({
    required this.id,
    required this.clientName,
    required this.itemName,
    required this.wasPaid,
  });

  @override
  List<Object?> get props => [id, clientName, itemName, wasPaid];
}
