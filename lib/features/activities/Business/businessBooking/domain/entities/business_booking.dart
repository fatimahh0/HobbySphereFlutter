// ===== Flutter 3.35.x =====
// BusinessBooking entity — supports JSON parsing

import '../../../../../../core/network/globals.dart' as g;
import '../../../../common/domain/entities/currency.dart';

class BusinessBooking {
  final int id;
  final String status;
  final bool wasPaid;

  // Activity info
  final String? itemName;
  final String? itemImage;

  // User info
  final String? bookedBy;
  final String? bookedByAvatar;

  // Booking details
  final int participants;
  final double price;
  final String paymentMethod;
  final DateTime? bookingDatetime;
  final Currency? currency;

  BusinessBooking({
    required this.id,
    required this.status,
    required this.wasPaid,
    this.itemName,
    this.itemImage,
    this.bookedBy,
    this.bookedByAvatar,
    this.participants = 1,
    this.price = 0.0,
    this.paymentMethod = "N/A",
    this.bookingDatetime,
    this.currency = const Currency(code: 'CAD', symbol: '\C\$'),
  });

  // ===== JSON Factory =====
  factory BusinessBooking.fromJson(Map<String, dynamic> json) {
    String? raw = json['item']?['imageUrl'];
    String? fullUrl;
    if (raw != null && raw.isNotEmpty) {
      if (raw.startsWith("http")) {
        fullUrl = raw; // already full
      } else {
        fullUrl = "${g.appServerRoot}$raw"; // prepend server root
      }
    }

    return BusinessBooking(
      id: json['id'] as int,
      status: json['bookingStatus']?.toString() ?? 'Pending',
      wasPaid: json['wasPaid'] == true,
      itemName: json['item']?['itemName'],
      itemImage: fullUrl, // ✅ use fixed URL
      // user
      bookedBy: json['user']?['username'] ?? json['bookedBy'],
      bookedByAvatar: json['user']?['profileImage'],

      // details
      participants: json['participants'] is int
          ? json['participants']
          : int.tryParse(json['participants']?.toString() ?? '') ?? 1,

      currency: json['currency'] != null
          ? Currency(
              code: json['currency']['code'],
              symbol: json['currency']['symbol'],
            )
          : null,

      price: json['totalPrice'] is num
          ? (json['totalPrice'] as num).toDouble()
          : 0.0,

      paymentMethod: json['paymentMethod']?.toString() ?? "N/A",

      bookingDatetime: json['bookingDatetime'] != null
          ? DateTime.tryParse(json['bookingDatetime'].toString())
          : null,
    );
  }

  // Convenience formatted date
  String get dateFormatted {
    if (bookingDatetime == null) return "";
    return "${bookingDatetime!.day}/${bookingDatetime!.month}/${bookingDatetime!.year} "
        "${bookingDatetime!.hour}:${bookingDatetime!.minute.toString().padLeft(2, '0')}";
  }

  // Convenience getter for widget
  String? get imageUrl => itemImage;
}
