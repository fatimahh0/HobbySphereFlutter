import 'package:equatable/equatable.dart';

class InsightBooking extends Equatable {
  final int id;
  final int? businessUserId; // 👈 new field
  final String clientName;
  final String itemName;
  final bool wasPaid;

  const InsightBooking({
    required this.id,
    this.businessUserId,
    required this.clientName,
    required this.itemName,
    required this.wasPaid,
  });

  @override
  List<Object?> get props => [
    id,
    businessUserId,
    clientName,
    itemName,
    wasPaid,
  ];
}
