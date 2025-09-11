// import '../../../../../../core/network/globals.dart' as g;
import 'package:hobby_sphere/core/network/globals.dart' as g;

import '../../../../common/domain/entities/currency.dart';

class BusinessBooking {
  final int id;
  final String status;
  final bool wasPaid;

  // Activity info
  final String? itemName;
  final String? itemImage;
  final String? itemLocation; // NEW: parsed from item.location
  final DateTime? eventStart; // NEW: parsed from item.startDatetime

  // User info
  final String? bookedBy;
  final String? bookedByAvatar;

  // Booking details
  final int participants;
  final double price; // total price
  final String paymentMethod;
  final DateTime? bookingDatetime; // when the booking was made
  final Currency? currency;

  BusinessBooking({
    required this.id,
    required this.status,
    required this.wasPaid,
    this.itemName,
    this.itemImage,
    this.itemLocation,
    this.eventStart,
    this.bookedBy,
    this.bookedByAvatar,
    this.participants = 1,
    this.price = 0.0,
    this.paymentMethod = "N/A",
    this.bookingDatetime,
    this.currency,
  });

  factory BusinessBooking.fromJson(Map<String, dynamic> json) {
    // Image
    String? raw = json['item']?['imageUrl'];
    String? fullUrl;
    if (raw != null && raw.isNotEmpty) {
      fullUrl = raw.startsWith("http") ? raw : "${g.appServerRoot}$raw";
    }

    // Booked by
    String? bookedBy;
    String? avatar;
    if (json['user'] != null) {
      bookedBy =
          json['user']?['username'] ??
          "${json['user']?['firstName'] ?? ''} ${json['user']?['lastName'] ?? ''}"
              .trim();
      avatar = json['user']?['profilePictureUrl'];
    } else if (json['businessUser'] != null) {
      bookedBy =
          "${json['businessUser']?['firstName'] ?? ''} ${json['businessUser']?['lastName'] ?? ''}"
              .trim();
      avatar = json['businessUser']?['profilePictureUrl'];
    } else if (json['bookedByName'] != null) {
      bookedBy = json['bookedByName'];
    }

    // Currency
    Currency? parsedCurrency;
    if (json['currency'] != null) {
      parsedCurrency = Currency(
        code: json['currency']['code'] ?? '',
        symbol: json['currency']['symbol'] ?? '',
      );
    }

    // NEW: location + event start
    final String? itemLocation = json['item']?['location'];
    final DateTime? eventStart = json['item']?['startDatetime'] != null
        ? DateTime.tryParse(json['item']['startDatetime'].toString())
        : null;

    return BusinessBooking(
      id: json['id'] as int,
      status: json['bookingStatus']?.toString() ?? 'Pending',
      wasPaid: json['wasPaid'] == true,
      itemName: json['item']?['itemName'],
      itemImage: fullUrl,
      itemLocation: itemLocation,
      eventStart: eventStart,
      bookedBy: bookedBy,
      bookedByAvatar: avatar,
      participants: json['numberOfParticipants'] is int
          ? json['numberOfParticipants']
          : int.tryParse(json['numberOfParticipants']?.toString() ?? '') ?? 1,
      currency: parsedCurrency,
      price: json['totalPrice'] is num
          ? (json['totalPrice'] as num).toDouble()
          : 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? "N/A",
      bookingDatetime: json['bookingDatetime'] != null
          ? DateTime.tryParse(json['bookingDatetime'].toString())
          : null,
    );
  }

  // Formatted dates
  String? get eventDateFormatted {
    if (eventStart == null) return null;
    final m = eventStart!;
    return "${m.day}/${m.month}/${m.year} ${m.hour}:${m.minute.toString().padLeft(2, '0')}";
  }

  String get dateFormatted {
    if (bookingDatetime == null) return "";
    return "${bookingDatetime!.day}/${bookingDatetime!.month}/${bookingDatetime!.year} "
        "${bookingDatetime!.hour}:${bookingDatetime!.minute.toString().padLeft(2, '0')}";
  }

  // Money
  String get totalFormatted {
    final sym = currency?.symbol?.isNotEmpty == true
        ? currency!.symbol
        : currency?.code ?? '';
    final numStr = price.toStringAsFixed(2);
    return sym != null && sym!.isNotEmpty ? "$sym$numStr" : numStr;
  }

  String? get imageUrl => itemImage;
}
