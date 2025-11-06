// lib/features/activities/business/businessBooking/domain/entities/business_booking.dart
//// Flutter 3.35.x
//// BusinessBooking entity with a normalized statusKey

// import app server root for images
import 'package:hobby_sphere/core/network/globals.dart' as g; // appServerRoot()

// import currency entity
import '../../../../common/domain/entities/currency.dart'; // Currency model

class BusinessBooking {
  // unique id
  final int id; // booking id

  // raw status as sent by backend (e.g., "CancelRequested")
  final String status; // original status text

  // flag paid or not
  final bool wasPaid; // true if booking is paid

  // activity info
  final String? itemName; // activity name
  final String? itemImage; // activity image (full url)
  final String? itemLocation; // activity location string
  final DateTime? eventStart; // activity start datetime

  // user info
  final String? bookedBy; // who booked (name/username)
  final String? bookedByAvatar; // avatar url

  // booking details
  final int participants; // number of participants
  final double price; // total price
  final String paymentMethod; // payment method text
  final DateTime? bookingDatetime; // booking created at
  final Currency? currency; // currency object (symbol/code)

  // constructor with defaults
  BusinessBooking({
    required this.id, // required id
    required this.status, // required status
    required this.wasPaid, // required paid flag
    this.itemName, // optional name
    this.itemImage, // optional image
    this.itemLocation, // optional location
    this.eventStart, // optional event date
    this.bookedBy, // optional booked by
    this.bookedByAvatar, // optional avatar
    this.participants = 1, // default 1
    this.price = 0.0, // default 0
    this.paymentMethod = "N/A", // default N/A
    this.bookingDatetime, // optional created at
    this.currency, // optional currency
  });

  // 👉 normalized status used everywhere in UI
  // lowercased, keep only letters (a-z), removes spaces/underscore/dash
  String get statusKey {
    final low = status.toLowerCase(); // to lower
    return low.replaceAll(RegExp(r'[^a-z]'), ''); // only letters
  }

  // full formatted price with currency (e.g., $12.50)
  String get totalFormatted {
    final sym = currency?.symbol?.isNotEmpty == true
        ? currency!.symbol
        : currency?.code ?? ''; // prefer symbol then code
    final numStr = price.toStringAsFixed(2); // 2 decimals
    return (sym != null && sym!.isNotEmpty) ? "$sym$numStr" : numStr; // join
  }

  // formatted event date if present
  String? get eventDateFormatted {
    if (eventStart == null) return null; // no date
    final m = eventStart!; // non-null
    final mm = m.minute.toString().padLeft(2, '0'); // pad minute
    return "${m.day}/${m.month}/${m.year} ${m.hour}:$mm"; // dd/mm/yyyy hh:mm
  }

  // formatted booking date if present
  String get dateFormatted {
    if (bookingDatetime == null) return ""; // empty if null
    final d = bookingDatetime!; // non-null
    final mm = d.minute.toString().padLeft(2, '0'); // pad minute
    return "${d.day}/${d.month}/${d.year} ${d.hour}:$mm"; // dd/mm/yyyy hh:mm
  }

  // getter alias for clarity
  String? get imageUrl => itemImage; // image url

  // factory to create from backend json
  factory BusinessBooking.fromJson(Map<String, dynamic> json) {
    // handle image path → full url
    String? raw = json['item']?['imageUrl']; // raw path or http
    String? fullUrl; // result
    if (raw != null && raw.isNotEmpty) {
      fullUrl = raw.startsWith("http")
          ? raw
          : "${g.appServerRoot}$raw"; // make full
    }

    // booked by name + avatar (user or businessUser or fallback)
    String? bookedBy; // name
    String? avatar; // avatar
    if (json['user'] != null) {
      // prefer username else first+last
      bookedBy =
          json['user']?['username'] ??
          "${json['user']?['firstName'] ?? ''} ${json['user']?['lastName'] ?? ''}"
              .trim();
      avatar = json['user']?['profilePictureUrl']; // avatar
    } else if (json['businessUser'] != null) {
      // business user case
      bookedBy =
          "${json['businessUser']?['firstName'] ?? ''} ${json['businessUser']?['lastName'] ?? ''}"
              .trim();
      avatar = json['businessUser']?['profilePictureUrl']; // avatar
    } else if (json['bookedByName'] != null) {
      // fallback name
      bookedBy = json['bookedByName']; // text
    }

    // currency parse
    Currency? parsedCurrency; // currency
    if (json['currency'] != null) {
      parsedCurrency = Currency(
        code: json['currency']['code'] ?? '', // code
        symbol: json['currency']['symbol'] ?? '', // symbol
      );
    }

    // event location and start datetime
    final String? itemLocation = json['item']?['location']; // location
    final DateTime? eventStart = json['item']?['startDatetime'] != null
        ? DateTime.tryParse(json['item']['startDatetime'].toString())
        : null; // parse date

    // number of participants safe parse
    final int participants = json['numberOfParticipants'] is int
        ? json['numberOfParticipants'] as int
        : int.tryParse(json['numberOfParticipants']?.toString() ?? '') ?? 1;

    // price safe parse
    final double totalPrice = json['totalPrice'] is num
        ? (json['totalPrice'] as num).toDouble()
        : 0.0; // to double

    // build object
    return BusinessBooking(
      id: json['id'] as int, // id
      status: json['bookingStatus']?.toString() ?? 'Pending', // raw status
      wasPaid: json['wasPaid'] == true, // paid flag
      itemName: json['item']?['itemName'], // name
      itemImage: fullUrl, // image
      itemLocation: itemLocation, // location
      eventStart: eventStart, // start
      bookedBy: bookedBy, // name
      bookedByAvatar: avatar, // avatar
      participants: participants, // count
      currency: parsedCurrency, // currency
      price: totalPrice, // price
      paymentMethod: json['paymentMethod']?.toString() ?? "N/A", // method
      bookingDatetime: json['bookingDatetime'] != null
          ? DateTime.tryParse(json['bookingDatetime'].toString())
          : null, // created at
    );
  }
}
