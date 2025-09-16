import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.bookingStatus,
    required super.numberOfParticipants,
    super.startDatetime,
    required super.itemName,
    required super.location,
    super.imageUrl,
    super.wasPaid,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final item = (json['item'] as Map?) ?? const {};
    return BookingModel(
      id: (json['id'] ?? json['bookingId']) is num
          ? (json['id'] ?? json['bookingId']).toInt()
          : int.tryParse('${json['id'] ?? json['bookingId']}') ?? 0,
      bookingStatus: '${json['bookingStatus'] ?? json['status'] ?? ''}',
      numberOfParticipants: (json['numberOfParticipants'] ?? 1) is num
          ? (json['numberOfParticipants'] ?? 1).toInt()
          : int.tryParse('${json['numberOfParticipants'] ?? 1}') ?? 1,
      startDatetime: item['startDatetime'] != null
          ? DateTime.tryParse('${item['startDatetime']}')
          : null,
      itemName: '${item['itemName'] ?? json['itemName'] ?? ''}',
      location: '${item['location'] ?? json['location'] ?? ''}',
      imageUrl: item['imageUrl']?.toString(),
      wasPaid: json['wasPaid'] == true,
    );
  }

  static List<BookingModel> listFromJson(List data) => data
      .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
      .toList();
}
