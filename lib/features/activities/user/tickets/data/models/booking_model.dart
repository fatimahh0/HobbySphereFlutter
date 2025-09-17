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

    String _status(dynamic v) => (v ?? '').toString().trim();

    int _int(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? 0;
    }

    int _intOr(dynamic v, int d) {
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? d;
    }

    return BookingModel(
      id: _int(json['id'] ?? json['bookingId']),
      bookingStatus: _status(json['bookingStatus'] ?? json['status']),
      numberOfParticipants: _intOr(json['numberOfParticipants'] ?? 1, 1),
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
