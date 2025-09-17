import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final int id;
  final String bookingStatus; // Pending, Completed, Canceled, CancelRequested
  final int numberOfParticipants;
  final DateTime? startDatetime;
  final String itemName;
  final String location;
  final String? imageUrl;
  final bool wasPaid;

  const BookingEntity({
    required this.id,
    required this.bookingStatus,
    required this.numberOfParticipants,
    this.startDatetime,
    required this.itemName,
    required this.location,
    this.imageUrl,
    this.wasPaid = false,
  });

  @override
  List<Object?> get props => [
    id,
    bookingStatus,
    numberOfParticipants,
    startDatetime,
    itemName,
    location,
    imageUrl,
    wasPaid,
  ];
}
