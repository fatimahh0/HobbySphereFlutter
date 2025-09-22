class UserNotification {
  final int id;
  final String message;
  final String
  typeCode; // e.g., BOOKING_CREATED / BOOKING_CANCELLED / NEW_MESSAGE
  final String typeDescription; // human readable
  final DateTime createdAt;
  final bool read;

  const UserNotification({
    required this.id,
    required this.message,
    required this.typeCode,
    required this.typeDescription,
    required this.createdAt,
    required this.read,
  });

  UserNotification copyWith({
    int? id,
    String? message,
    String? typeCode,
    String? typeDescription,
    DateTime? createdAt,
    bool? read,
  }) {
    return UserNotification(
      id: id ?? this.id,
      message: message ?? this.message,
      typeCode: typeCode ?? this.typeCode,
      typeDescription: typeDescription ?? this.typeDescription,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}
