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
    final booking = (json['booking'] as Map?) ?? const {};

    String _status(dynamic v) {
      final s = (v ?? '')
          .toString()
          .trim()
          .toUpperCase(); // PENDING/COMPLETED/...
      if (s.isEmpty) return '';
      // Title-case to match UI filters: Pending/Completed/Canceled/CancelRequested
      final map = {
        'PENDING': 'Pending',
        'COMPLETED': 'Completed',
        'CANCELED': 'Canceled',
        'CANCEL_REQUESTED': 'CancelRequested',
      };
      return map[s] ?? s[0] + s.substring(1).toLowerCase();
    }

    int _int(dynamic v, [int d = 0]) {
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? d;
    }

    return BookingModel(
      id: _int(json['id'] ?? json['bookingId']),
      bookingStatus: _status(
        // prefer nested booking.status, fallback to flat
        booking['status'] ?? json['bookingStatus'] ?? json['status'],
      ),
      numberOfParticipants: _int(
        json['quantity'] ?? json['numberOfParticipants'] ?? 1,
        1,
      ),
      startDatetime: item['startDatetime'] != null
          ? DateTime.tryParse('${item['startDatetime']}')
          : null,
      itemName: '${item['itemName'] ?? json['itemName'] ?? ''}',
      location: '${item['location'] ?? json['location'] ?? ''}',
      imageUrl: item['imageUrl']?.toString(),
      // backend doesn't send "wasPaid" on ItemBooking; default false
      wasPaid: json['wasPaid'] == true,
    );
  }

  static List<BookingModel> listFromJson(List data) => data
      .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
      .toList();
}
