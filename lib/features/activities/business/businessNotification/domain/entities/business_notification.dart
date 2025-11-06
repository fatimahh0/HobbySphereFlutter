// ===== Flutter 3.35.x =====
// Entity: BusinessNotification (pure Dart, no Flutter)

class BusinessNotification {
  final int id; // notification id
  final String message; // notification text
  final String typeCode; // e.g., BOOKING_CREATED
  final String typeDescription; // human readable
  final DateTime createdAt; // timestamp
  final bool read; // read/unread status

  const BusinessNotification({
    required this.id,
    required this.message,
    required this.typeCode,
    required this.typeDescription,
    required this.createdAt,
    required this.read,
  });


  BusinessNotification copyWith({
    int? id,
    String? message,
    String? typeCode,
    String? typeDescription,
    bool? read,
    DateTime? createdAt,
  }) {
    return BusinessNotification(
      id: id ?? this.id,
      message: message ?? this.message,
      typeCode: typeCode ?? this.typeCode,
      typeDescription: typeDescription ?? this.typeDescription,
      read: read ?? this.read, 
      createdAt: this.createdAt,
      
    );
  }
}
